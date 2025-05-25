local UIWidget = require("scripts/managers/ui/ui_widget")
local HudElementBossNameSettings = require("scripts/ui/hud/elements/boss_health/hud_element_boss_name_settings")
local HudElementBossHealthSettings = require("scripts/ui/hud/elements/boss_health/hud_element_boss_health_settings")

local name_text_style = table.clone(HudElementBossNameSettings.style)
name_text_style.font_size = 28

local small_bar_spacing = 30

local health_bar_size = HudElementBossHealthSettings.size
local health_bar_size_small = HudElementBossHealthSettings.size_small
local health_bar_size_v = health_bar_size[2] + 4

local scenegraph_definition = {
	ritual_timer = {
		horizontal_alignment = "center",
		parent = "health_bar",
		vertical_alignment = "center",
		size = health_bar_size,
		position = {
			0,
			-13,
			5,
		},
	},
}

local single_target_widget_definitions = {
	ritual_timer = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "text",
			value = "∞",
			value_id = "text",
			style = table.merge_recursive(table.clone(name_text_style), {
				offset = {
					0,
					0,
					5,
				},
			}),
		},
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_l",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 0, 0 },
                    { 1, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    -50,
                    0,
                    0,
                }
            }
        },
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_r",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 1, 0 },
                    { 0, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    50,
                    0,
                    0,
                }
            }
        },
	}, "ritual_timer", 
    {
        visible = false
    }),
}

local gradient_width = 50

local left_double_target_widget_definitions = {
	ritual_timer = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "text",
			value = "∞",
			value_id = "text",
			style = table.merge_recursive(table.clone(name_text_style), {
				offset = {
					-(health_bar_size_small[1] + small_bar_spacing) * 0.5,
					0,
					5,
				},
			}),
		},
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_l",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 0, 0 },
                    { 1, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    -50 - (health_bar_size_small[1] + small_bar_spacing) * 0.5,
                    0,
                    0,
                }
            }
        },
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_r",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 1, 0 },
                    { 0, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    50 - (health_bar_size_small[1] + small_bar_spacing) * 0.5,
                    0,
                    0,
                }
            }
        },
	}, "ritual_timer", 
    {
        visible = false
    }),
}

local right_double_target_widget_definitions = {
	ritual_timer = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "text",
			value = "∞",
			value_id = "text",
			style = table.merge_recursive(table.clone(name_text_style), {
				offset = {
					(health_bar_size_small[1] + small_bar_spacing) * 0.5,
					0,
					5,
				},
			}),
		},
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_l",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 0, 0 },
                    { 1, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    -50 + (health_bar_size_small[1] + small_bar_spacing) * 0.5,
                    0,
                    0,
                }
            }
        },
        {
            value = "content/ui/materials/gradients/gradient_horizontal",
            style_id = "gradient_r",
            pass_type = "texture_uv",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                uvs = {
                    { 1, 0 },
                    { 0, 1 },
                },
                size = { 
                    100, 
                    health_bar_size_v
                },
                color = Color.black(255, true),
                color_default = Color.black(255, true),
                offset = {
                    50 + (health_bar_size_small[1] + small_bar_spacing) * 0.5,
                    0,
                    0,
                }
            }
        },
	}, "ritual_timer", 
    {
        visible = false
    }),
}

return {
    single_target_widget_definitions = single_target_widget_definitions,
    right_double_target_widget_definitions = right_double_target_widget_definitions,
    left_double_target_widget_definitions = left_double_target_widget_definitions,
	scenegraph_definition = scenegraph_definition,
}