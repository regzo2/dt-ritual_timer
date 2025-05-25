local HavocSettings = require("scripts/settings/havoc_settings")

local function _setup_boss_localization()
    local Breeds = require("scripts/settings/breed/breeds")

    local localization = {}
    local language =  Managers.localization and Managers.localization:language()

    gbl_breeds = Breeds

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
    },
    mod_description = {
        en = "Adds a timer to bosses and Hexbound rituals.",
    },

    group_timer_settings = {
        en = "Timer Settings"
    },
    sett_timer_lerp_id = {
        en = "Timer Smoothness",
    },
    sett_timer_format_id = {
        en = "Timer Format",
    },
    sett_timer_millisecond_decimals_id = {
        en = "Timer Millisecond Decimals",
    },
    sett_timer_visible_time_id = {
        en = "Timer Visiblity Speed",
    },

    group_boss_settings = {
        en = "Boss Settings",
    },
    loc_timer_regenerate = {
        en = "Show Regeneration Time",
    },
    loc_timer_ttk = {
        en = "Show Time-To-Kill Time",
    },

    loc_opt_seconds_only = {
        en = "Seconds (0.000)"
    },
    loc_opt_stopwatch = {
        en = "Minutes and Seconds (0:00.000)"
    }
}

local function _localization_table()

    local localizations = {}

    local categories = {
        base_localization,
        _setup_boss_localization(),
    }

    gbl_1 = categories

    for _, locs in pairs(categories) do
        for k, v in pairs(locs) do 
            localizations[k] = v
        end
    end

    gbl_loc = localizations

    return localizations
end

return _localization_table()