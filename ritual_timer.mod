return {
	run = function()
		fassert(rawget(_G, "ritual_timer"), "`ritual_timer` encountered an error loading the Darktide Mod Framework.")

		new_mod("ritual_timer", {
			mod_script       = "ritual_timer/scripts/ritual_timer_main",
			mod_data         = "ritual_timer/scripts/ritual_timer_data",
			mod_localization = "ritual_timer/scripts/ritual_timer_localization",
		})
	end,
	packages = {},
}
