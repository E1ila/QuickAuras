local ADDON_NAME, addon = ...
local MeleeUtils = addon.root

MeleeUtils.options = {
    name = "Melee Utils",
    handler = MeleeUtils,
    type = "group",
    childGroups = "tab",
    args = {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return MeleeUtils.db.profile.enabled end,
            set = function(info, value) MeleeUtils:Options_ToggleEnabled(value) end,
        },
        harryPaste = {
            type = "toggle",
            name = "Harry Paste",
            desc = "Warn when a mob parries your attack while being tanked",
            get = function(info) return MeleeUtils.db.profile.harryPaste end,
            set = function(info, value) MeleeUtils.db.profile.harryPaste = value end,
        },
        spellProgress = {
            type = "toggle",
            name = "Spell Progress",
            desc = "Show a progress bar with time left on important spells",
            get = function(info) return MeleeUtils.db.profile.spellProgress end,
            set = function(info, value) MeleeUtils.db.profile.spellProgress = value end,
        },
        rogueUtils = {
            type = "group",
            name = "Rogue Utils",
            args = {
                rogue5Combo = {
                    type = "toggle",
                    name = "5 Combo Points",
                    desc = "Shows a visible indication when you have 5 combo points.",
                    get = function(info) return MeleeUtils.db.profile.rogue5combo end,
                    set = function(info, value) MeleeUtils.db.profile.rogue5combo = value end,
                },
            }
        },
    },
}
