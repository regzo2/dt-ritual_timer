local HavocSettings = require("scripts/settings/havoc_settings")

local function _setup_boss_localization()
    local Breeds = require("scripts/settings/breed/breeds")

    local localization = {}
    local language =  Managers.localization and Managers.localization:language()

    for _, breed in pairs(Breeds) do
        if breed.is_boss then
            localization["group_" .. breed.name .. "_settings"] = {}
            localization["group_" .. breed.name .. "_settings"][language] = Localize(type(breed.boss_display_name) == "string" and breed.boss_display_name or breed.display_name)
        end
    end

    return localization
end

local base_localization = {
    mod_name = {
        en = "Boss Timer",
        ["zh-cn"] = "Boss计时器",
 
    },
    mod_description = {
        en = "Adds a timer to bosses and Hexbound rituals.",
        ["zh-cn"] = "为Boss、仪式宿主添加计时器——B站独一无二的小真寻汉化",
       
    },
 
    group_timer_settings = {
        en = "Timer Settings",
        ["zh-cn"] = "时间设置",
    },
    sett_timer_lerp_id = {
        en = "Timer Smoothness",
        ["zh-cn"] = "计时器平滑度",
    },
    sett_timer_format_id = {
        en = "Timer Format",
        ["zh-cn"] = "计时器格式",
    },
    sett_timer_millisecond_decimals_id = {
        en = "Timer Millisecond Decimals",
        ["zh-cn"] = "计时器平滑度",
    },
    sett_timer_visible_time_id = {
        en = "Timer Visiblity Speed",
        ["zh-cn"] = "计时器可视速率",
    },
    sett_timer_time_delta_id = {
        en = "Timer Update Interval",
        ["zh-cn"] = "计时器更新间隔",
    },
 
    group_boss_settings = {
        en = "Boss Settings",
        ["zh-cn"] = "Boss设置",
    },
    loc_timer_regenerate = {
        en = "Show Regeneration Time",
        ["zh-cn"] = "显示再生时间",
    },
    loc_timer_ttk = {
        en = "Show Time-To-Kill Time",
        ["zh-cn"] = "显示击杀时间",
    },
 
    loc_opt_seconds_only = {
        en = "Seconds (0.000)",
        ["zh-cn"] = "秒(0.000)",
    },
    loc_opt_stopwatch = {
        en = "Minutes and Seconds (0:00.000)",
        ["zh-cn"] = "秒(0:00.000)",
    }

    
}

local function _localization_table()

    local localizations = {}

    local categories = {
        base_localization,
        _setup_boss_localization(),
    }

    for _, locs in pairs(categories) do
        for k, v in pairs(locs) do 
            localizations[k] = v
        end
    end

    return localizations
end

return _localization_table()