local mod = get_mod("ritual_timer")

local RitualTimerDefinitions = mod:io_dofile("ritual_timer/scripts/views/ritual_timer_defs")
local Breeds = require("scripts/settings/breed/breeds")

local _timer_lerp
local _timer_format
local _timer_millisecond_decimals
local _timer_visible_time
local _timer_boss_active
local _timer_boss_data

local function _apply_settings()
    _timer_lerp                  = mod:get("sett_timer_lerp_id") or 0
    _timer_format                = mod:get("sett_timer_format_id") or "opt_stopwatch"
    _timer_millisecond_decimals  = mod:get("sett_timer_millisecond_decimals_id") or 3
    _timer_visible_time          = mod:get("sett_timer_visible_time_id") or 5
end

local function _apply_boss_cache()
    _timer_boss_active = {}
    _timer_boss_data = {}

    for _, breed in pairs(Breeds) do
        if breed.is_boss then
            _timer_boss_active[breed.name] = true
            _timer_boss_data[breed.name] = {}
            _timer_boss_data[breed.name].regen = mod:get("sett_timer_" .. breed.name .. "_regenerate_id") or false
            _timer_boss_data[breed.name].ttk = mod:get("sett_timer_" .. breed.name .. "_ttk_id") or false
        end
    end
end

mod.on_setting_changed = function()
    _apply_settings()
    _apply_boss_cache()
end

mod.on_setting_changed()

mod:hook_require("scripts/ui/hud/elements/boss_health/hud_element_boss_health_definitions", function(instance)

    instance.scenegraph_definition.ritual_timer = RitualTimerDefinitions.scenegraph_definition.ritual_timer

    instance.single_target_widget_definitions.ritual_timer = RitualTimerDefinitions.single_target_widget_definitions.ritual_timer
    instance.left_double_target_widget_definitions.ritual_timer = RitualTimerDefinitions.left_double_target_widget_definitions.ritual_timer
    instance.right_double_target_widget_definitions.ritual_timer = RitualTimerDefinitions.right_double_target_widget_definitions.ritual_timer
end)

mod:hook_safe(CLASS.HudElementBossHealth, "event_boss_encounter_start", function(self, unit, boss_extension)

    local target = self._active_targets_by_unit[unit]

    local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
	local breed_name = unit_data_extension:breed().name

    --if target and boss_extension:display_name() == "loc_mutator_daemonhost_name" then
    if target and _timer_boss_active[breed_name] then
        target.ritual_timer = true
        target.breed_name = breed_name
        --target.time = 1
    end

end)

local PI = math.pi

local function _alpha(hz, cutoff)
    local tau = 1.0 / (2 * PI * cutoff)
    local te = 1.0 / hz
    return 1.0 / (1.0 + tau / te)
end

local function _low_pass(target, prev_key, x, alpha_val)
    local hat_x = alpha_val * x + (1 - alpha_val) * (target[prev_key] or x)
    target[prev_key] = hat_x
    return hat_x
end

local function _filter_health_rate(target, current_rate)
    
    if current_rate == nil or current_rate ~= current_rate then
        return target.rate
    end
    
    local prev_rate = target.rate or current_rate
    local direction_changed = (prev_rate * current_rate < 0)
    
    if direction_changed then
        target._filter_derivative_prev = 0
        target._filter_rate_prev = current_rate
        return current_rate
    end
    
    local rate_derivative = (current_rate - prev_rate) * target._filter_hz
    
    local filtered_derivative = _low_pass(
        target, 
        "_filter_derivative_prev", 
        rate_derivative, 
        _alpha(target._filter_hz, target._filter_d_cutoff)
    )
    
    local adaptive_cutoff = target._filter_min_cutoff + 
                           target._filter_beta * math.abs(filtered_derivative)
    
    return _low_pass(
        target, 
        "_filter_rate_prev", 
        current_rate, 
        _alpha(target._filter_hz, adaptive_cutoff)
    )
end

local function _calculate_rate(current_value, previous_value, dt)
    if dt <= 0 then
        return nil
    end
    
    local value_dt = current_value - previous_value
    local rate = value_dt / dt
    
    if rate == 0 or math.abs(rate) > 1 then
        return nil
    end
    
    return rate
end

local function _convert_to_time_string(seconds)
    if _timer_format == "opt_stopwatch" then
        local minutes = math.floor(seconds / 60)
        local remaining_seconds = math.floor(seconds % 60)

        if _timer_millisecond_decimals > 0 then
            local milli_power = math.pow(10, _timer_millisecond_decimals)
            local remaining_milliseconds = math.floor((seconds * milli_power) % milli_power)
            if minutes > 0 then
                return string.format("%d:%02d.%0" .. _timer_millisecond_decimals .. "d", minutes, remaining_seconds, remaining_milliseconds)
            end

            return string.format("%d.%0" .. _timer_millisecond_decimals .. "d", remaining_seconds, remaining_milliseconds)
        end

        if minutes > 0 then
            return string.format("%d:%02d", minutes, remaining_seconds)
        end
    end

    if _timer_millisecond_decimals > 0 then
        local milli_power = math.pow(10, _timer_millisecond_decimals)
        local remaining_milliseconds = math.floor((seconds * milli_power) % milli_power)
        return string.format("%d.%0" .. _timer_millisecond_decimals .. "d", seconds, remaining_milliseconds)
    end

    return string.format("%d", seconds)
end

local function _set_widget_visibility(widget, visible, dt) 
    local visible_rate = (visible and 1 or -1) * _timer_visible_time * dt
    
    if widget.alpha_multiplier == 0 and widget.content.visible then
        widget.content.visible = false
    elseif widget.alpha_multiplier == 0 and visible_rate < 0 then 
        return
    end

    if not widget.content.visible then
        widget.content.visible = true
    end

    widget.alpha_multiplier = math.max(0, math.min(1, (widget.alpha_multiplier or 0) + visible_rate)) 
end

mod:hook_safe(CLASS.HudElementBossHealth, "update", function(self, dt, t)
    local active_targets_array = self._active_targets_array
    local num_active_targets = #active_targets_array
    local num_health_bars_to_update = math.min(num_active_targets, self._max_health_bars)

    for i = 1, num_health_bars_to_update do
        local target = active_targets_array[i]
        local unit = target.unit

        if ALIVE[unit] and target.ritual_timer then
            local widget_groups = self._widget_groups
            local widget_group_index = num_active_targets > 1 and i + 1 or i
            local widget_group = widget_groups[widget_group_index]
            local health_extension = target.health_extension
            --mod:echo("r: " .. (target.rate or "nil"))
            local current_health_percent = health_extension:current_health_percent()
            local ritual_timer_widget = widget_group.ritual_timer
            local color = widget_group.health.style.bar.color

            if color ~= ritual_timer_widget.style.text.text_color then
                ritual_timer_widget.style.text.text_color = color
            end

            if target.last_health_percent ~= current_health_percent then
                local _dt = t - (target.last_time_checked or t)
                --mod:echo("stats: " .. current_health_percent.. " " .. (target.last_health_percent or "nil") .. " " .. _dt)
                local raw_rate = _calculate_rate(
                    current_health_percent, 
                    target.last_health_percent,
                    _dt
                )
                mod:echo("rr" .. (raw_rate or "nil"))
                target._filter_hz = 1/_dt
                target._filter_min_cutoff = 0.001
                target._filter_beta = 1
                target._filter_d_cutoff = 0.1
                target.rate = _filter_health_rate(target, raw_rate) or target.rate
                mod:echo("r" .. (target.rate or "nil"))
                
                if target.rate and (target.rate ~= 0 or math.abs(target.rate) > 1) then
                    local dir = (target.last_health_percent - current_health_percent) < 0 and 1 or 0
                    --mod:echo("d: " .. (dir))
                    target.time = (dir - current_health_percent) / target.rate
                end
                target.last_health_percent = current_health_percent
                target.last_time_checked = t
                target.dt_decay = 1
            elseif target.time then
                if target.rate < 0 then
                    target.dt_decay = math.max(0, (target.dt_decay or 1) - 1/8 * dt)
                else
                    target.dt_decay = 1
                end
                
                target.time = math.max(0, target.time - dt * target.dt_decay)
            end

            if target.rate and (_timer_boss_data[target.breed_name].regen == false) and target.rate > 0 then
                _set_widget_visibility(ritual_timer_widget, false, dt)
            elseif target.rate and (_timer_boss_data[target.breed_name].ttk == false) and target.rate <= 0 then
                _set_widget_visibility(ritual_timer_widget, false, dt)
            elseif target.time and target.time < 1800 and target.time ~= 0 and math.abs(target.rate) > 0.00001 and target.dt_decay ~= 0 then
                --ritual_timer_widget.content.visible = true
                _set_widget_visibility(ritual_timer_widget, true, dt)
                local lerp = 2 * dt
                target.lerped_time = target.time * lerp + (target.lerped_time or target.time) * (1-lerp)
                ritual_timer_widget.content.text = _convert_to_time_string(target.lerped_time)
            else
                _set_widget_visibility(ritual_timer_widget, false, dt)
            end
        elseif target.ritual_timer then
            target.ritual_timer = false
            _set_widget_visibility(ritual_timer_widget, false, dt)
        end
    end
end)