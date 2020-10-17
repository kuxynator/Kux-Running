data:extend({
	{
        type = "bool-setting",
        name = "Kux-Running_Enable",
        setting_type = "runtime-global",
		default_value = true,
        order = "a01"
	},

	{
        type = "bool-setting",
        name = "Kux-Running_CheatMode",
        setting_type = "runtime-global",
		default_value = false,
        order = "a01"
	},
	{
        type = "bool-setting",
        name = "Kux-Running_EnableLog",
        setting_type = "runtime-global",
		default_value = false,
        order = "a01"
	},
	{
        type = "string-setting",
        name = "Kux-Running_Mode",
        setting_type = "runtime-per-user",
		default_value = "accelerate",
		allowed_values = {"none","accelerate","zoom","hover"},
        order = "a01"
	},

	{
        type = "double-setting",
        name = "Kux-Running_DefaultCharacterRunningSpeedModifier",
        setting_type = "runtime-per-user",
        default_value = 0,
        maximum_value = 1000,
        minimum_value = -1,
        order = "b01"
	},

-- settings for mode "accelerating"
    {
        type = "double-setting",
        name = "Kux-Running_InitialSpeedFactor",
        setting_type = "runtime-per-user",
        default_value = 1,
        maximum_value = 10,
        minimum_value = 0.01,
        order = "b01"
	},

	{
        type = "double-setting",
        name = "Kux-Running_WalkingSpeedTable_1",
        setting_type = "runtime-per-user",
        default_value = 1,
        maximum_value = 5,
        minimum_value = 0.1,
        order = "b02"
	},
	{
        type = "double-setting",
        name = "Kux-Running_WalkingSpeedTable_2",
        setting_type = "runtime-per-user",
        default_value = 2,
        maximum_value = 10,
        minimum_value = 0.5,
        order = "b03"
	},
	{
        type = "double-setting",
        name = "Kux-Running_WalkingSpeedTable_3",
        setting_type = "runtime-per-user",
        default_value = 5,
        maximum_value = 100,
        minimum_value = 1,
        order = "b04"
	},
	{
        type = "double-setting",
        name = "Kux-Running_UpsAdjustment",
        setting_type = "runtime-per-user",
        default_value = 1,
        maximum_value = 100,
        minimum_value = 0.1,
        order = "b05"
	},
	{
        type = "bool-setting",
        name = "Kux-Running_SlowerGameSpeedAdaptation",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "b06"
	},
	{
        type = "bool-setting",
        name = "Kux-Running_FasterGameSpeedAdaptation",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "b07"
	},

-- settings for mode "zoom"

	{
        type = "double-setting",
        name = "Kux-Running_ZoomSpeedModificator",
        setting_type = "runtime-per-user",
        default_value = 1,
        maximum_value = 10,
        minimum_value = 0.1,
        order = "c01"
	},
--[[	{
        type = "double-setting",
        name = "Kux-Running_ZoomSpeedOffset",
        setting_type = "runtime-per-user",
        default_value = 0,
        maximum_value = 100,
        minimum_value = -100,
        order = "c02"
	},
	]]
})
