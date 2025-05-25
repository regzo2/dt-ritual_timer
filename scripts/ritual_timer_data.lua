local mod = get_mod("ritual_timer")



local function _setup_boss_widgets()
    local Breeds = require("scripts/settings/breed/breeds")

    local widgets = {}

    for _, breed in pairs(Breeds) do
        if breed.is_boss then
            table.insert(widgets, {
                setting_id = "group_" .. breed.name .. "_settings",
                type       = "group",
                sub_widgets = {
                    {
                        setting_id    = "sett_timer_" .. breed.name .. "_regenerate_id",
                        title         = "loc_timer_regenerate",
                        type          = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id    = "sett_timer_" .. breed.name .. "_ttk_id",
                        title         = "loc_timer_ttk",
                        type          = "checkbox",
                        default_value = true,
                    },
                },
            })
        end
    end

    return widgets
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "group_timer_settings",
                type       = "group",
                sub_widgets = {
                    {
                        setting_id    = "sett_timer_format_id",
                        type          = "dropdown",
                        default_value = "opt_stopwatch",
                        options = {
                            {text = "loc_opt_seconds_only",   value = "opt_seconds_only"},
                            {text = "loc_opt_stopwatch",   value = "opt_stopwatch"},
                        },
                    },
                    --[[
                    {
                        setting_id      = "sett_timer_lerp_id",
                        type            = "numeric",
                        default_value   = 0.05,
                        range           = {0, 1},
                        decimals_number = 2,
                    },
                    ]]
                    {
                        setting_id      = "sett_timer_millisecond_decimals_id",
                        type            = "numeric",
                        default_value   = 3,
                        range           = {0, 4},
                        decimals_number = 0,
                    },
                    {
                        setting_id      = "sett_timer_visible_time_id",
                        type            = "numeric",
                        default_value   = 5,
                        range           = {1, 10},
                        decimals_number = 1,
                    },
                },
            },
            {
                setting_id  = "group_boss_settings",
                type        = "group",
                sub_widgets = _setup_boss_widgets()
            },
        },
    },
}