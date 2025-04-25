-- Define your options table
local options = {
	name = "Melee Utils",
	type = "group",
	args = {
		enable = {
			type = "toggle",
			name = "Enable",
			desc = "Enable or disable the addon",
			get = function(info) return MeleeUtilsVars.enabled end,
			set = function(info, value) MeleeUtilsVars.enabled = value end,
		},
	},
}

-- Register the options table
LibStub("AceConfig-3.0"):RegisterOptionsTable("MeleeUtils", options)

-- Add the options to the Blizzard Interface Options
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MeleeUtils", "Melee Utils")
