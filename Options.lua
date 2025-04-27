local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _uiLocked = true
local out = MeleeUtils.Print
local debug = MeleeUtils.Debug
local _c = MeleeUtils.colors

MeleeUtils.defaultOptions = {
    profile = {
        enabled = true,
        cooldowns = true,
        watchBars = true,
        someSetting = 50,
        barHeight = 25,
        buttonHeight = 50,
        rogue5combo = true,
        harryPaste = true,
        outOfRange = true,
        outOfRangeSound = true,
        offensiveBars = true,
        bloodFury = true,
        rogueEaBar = true,
        rogueSndBar = true,
        rogueFlurryBar = true,
        rogueAdrenalineRush = true,
        rogueGouge = true,
        rogueCheapShot = true,
        rogueKidneyShot = true,
        rogueVanish = true,
        rogueSprint = true,
        rogueStealth = true,
        rogueKick = true,
        rogueBlind = true,
        rogueEvasion = true,
        rogueSap = true,
        rogueFlurryBarCD = true,
        rogueAdrenalineRushCD = true,
        rogueGougeCD = true,
        rogueKidneyShotCD = true,
        rogueVanishCD = true,
        rogueSprintCD = true,
        rogueStealthCD = true,
        rogueKickCD = true,
        rogueBlindCD = true,
        rogueEvasionCD = true,
    },
}

MeleeUtils.options = {
    name = "Melee Utils",
    handler = MeleeUtils,
    type = "group",
    childGroups = "tab",
    args = {
        titleText = {
            type = "description",
            name = "  " .. ADDON_NAME .. " (v" .. MeleeUtils.version .. ")",
            fontSize = "large",
            order = 1,
        },
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return MeleeUtils.db.profile.enabled end,
            set = function(info, value) MeleeUtils:Options_ToggleEnabled(value) end,
            order = 4,
        },
        lookAndFeelHeader = {
            type = "header",
            name = "Look and Feel",
            order = 100,
        },
        barHeight = {
            type = "range",
            name = "Bar Height",
            desc = "Set the height of the bars",
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return MeleeUtils.db.profile.barHeight end,
            set = function(info, value)
                MeleeUtils.db.profile.barHeight = value
                MeleeUtils:TestWatchBars()
            end,
            order = 101,
        },
        buttonHeight = {
            type = "range",
            name = "Cooldown Size",
            desc = "Set the size of the cooldown icons",
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return MeleeUtils.db.profile.buttonHeight end,
            set = function(info, value)
                MeleeUtils.db.profile.buttonHeight = value
                MeleeUtils:TestButtons()
            end,
            order = 101,
        },
        commonUtilsHeader = {
            type = "header",
            name = "Common Utils",
            order = 200,
        },
        harryPaste = {
            type = "toggle",
            name = "Harry Paste",
            desc = "Warn when a mob parries your attack while being tanked",
            get = function(info) return MeleeUtils.db.profile.harryPaste end,
            set = function(info, value) MeleeUtils.db.profile.harryPaste = value end,
            order = 202,
        },
        offensiveBars = {
            type = "toggle",
            name = "Offensive Bars",
            desc = "Show a progress bar with time left on important abilities",
            get = function(info) return MeleeUtils.db.profile.offensiveBars end,
            set = function(info, value) MeleeUtils.db.profile.offensiveBars = value end,
            order = 203,
        },
        outOfRange = {
            type = "toggle",
            name = "Out of Range",
            desc = "Show a noticable warning when you are out of range of your target in combat",
            get = function(info) return MeleeUtils.db.profile.outOfRange end,
            set = function(info, value)
                MeleeUtils.db.profile.outOfRange = value
                if not value then MeleeUtils.db.profile.outOfRangeSound = false end
            end,
            order = 204,
        },
        outOfRangeSound = {
            type = "toggle",
            name = "Out of Range Sound",
            desc = "Play a warning when you are out of range of your target in combat",
            get = function(info) return MeleeUtils.db.profile.outOfRangeSound end,
            set = function(info, value)
                MeleeUtils.db.profile.outOfRangeSound = value
                if value then MeleeUtils.db.profile.outOfRange = true end
            end,
            order = 204,
        },
        bloodFury = {
            type = "toggle",
            name = "Blood Fury",
            desc = "Show a cooldown for Blood Fury.",
            get = function(info) return MeleeUtils.db.profile.bloodFury end,
            set = function(info, value) MeleeUtils.db.profile.bloodFury = value end,
            order = 205,
        },
        rogueUtils = {
            type = "group",
            name = "Utils",
            order = 1000,
            hidden = not MeleeUtils.isRogue,
            args = {
                rogue5Combo = {
                    type = "toggle",
                    name = "5 Combo Points",
                    desc = "Shows a visible indication when you have 5 combo points.",
                    get = function(info)
                        return MeleeUtils.db.profile.rogue5combo
                    end,
                    set = function(info, value)
                        MeleeUtils.db.profile.rogue5combo = value
                    end,
                },
            },
        },
        rogueBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1001,
            hidden = not MeleeUtils.isRogue,
            args = {
                watchBars = {
                    type = "toggle",
                    name = "Enabled",
                    desc = "Enables progress bars for buffs/debuffs",
                    get = function(info) return MeleeUtils.db.profile.watchBars end,
                    set = function(info, value) MeleeUtils.db.profile.watchBars = value end,
                    order = 1,
                },
                separatorHeader = {
                    type = "header",
                    name = "Tracked Abilities",
                    order = 10,
                },
                rogueEaBar = {
                    type = "toggle",
                    name = "Expose Armor",
                    desc = "Shows debuff time for Expose Armor.",
                    get = function(info)
                        return MeleeUtils.db.profile.rogueEaBar
                    end,
                    set = function(info, value)
                        MeleeUtils.db.profile.rogueEaBar = value
                    end,
                    order = 100,
                },
                rogueSndBar = {
                    type = "toggle",
                    name = "Slice and Dice",
                    desc = "Shows buff time for Slice and Dice.",
                    get = function(info)
                        return MeleeUtils.db.profile.rogueSndBar
                    end,
                    set = function(info, value)
                        MeleeUtils.db.profile.rogueSndBar = value
                    end,
                    order = 101,
                },
                rogueFlurryBar = {
                    type = "toggle",
                    name = "Blade Flurry",
                    desc = "Shows buff time for Blade Flurry.",
                    get = function(info)
                        return MeleeUtils.db.profile.rogueFlurryBar
                    end,
                    set = function(info, value)
                        MeleeUtils.db.profile.rogueFlurryBar = value
                    end,
                    order = 102,
                },
                rogueAdrenalineRush = {
                    type = "toggle",
                    name = "Adrenaline Rush",
                    desc = "Shows buff time for Adrenaline Rush.",
                    get = function(info)
                        return MeleeUtils.db.profile.rogueAdrenalineRush
                    end,
                    set = function(info, value)
                        MeleeUtils.db.profile.rogueAdrenalineRush = value
                    end,
                    order = 103,
                },
                rogueSap = {
                    type = "toggle",
                    name = "Sap",
                    desc = "Shows debuff time for Sap.",
                    get = function(info) return MeleeUtils.db.profile.rogueSap end,
                    set = function(info, value) MeleeUtils.db.profile.rogueSap = value end,
                    order = 104,
                },
                rogueGouge = {
                    type = "toggle",
                    name = "Gauge",
                    desc = "Shows debuff time for Gauge.",
                    get = function(info) return MeleeUtils.db.profile.rogueGouge end,
                    set = function(info, value) MeleeUtils.db.profile.rogueGouge = value end,
                    order = 105,
                },
                rogueCheapShot = {
                    type = "toggle",
                    name = "Cheap Shot",
                    desc = "Shows debuff time for Cheap Shot.",
                    get = function(info) return MeleeUtils.db.profile.rogueCheapShot end,
                    set = function(info, value) MeleeUtils.db.profile.rogueCheapShot = value end,
                    order = 106,
                },
                rogueKidneyShot = {
                    type = "toggle",
                    name = "Kidney Shot",
                    desc = "Shows debuff time for Kidney Shot.",
                    get = function(info) return MeleeUtils.db.profile.rogueKidneyShot end,
                    set = function(info, value) MeleeUtils.db.profile.rogueKidneyShot = value end,
                    order = 107,
                },
                rogueSprint = {
                    type = "toggle",
                    name = "Sprint",
                    desc = "Shows buff time for Sprint.",
                    get = function(info) return MeleeUtils.db.profile.rogueSprint end,
                    set = function(info, value) MeleeUtils.db.profile.rogueSprint = value end,
                },
                rogueBlind = {
                    type = "toggle",
                    name = "Blind",
                    desc = "Shows debuff time for Blind.",
                    get = function(info) return MeleeUtils.db.profile.rogueBlind end,
                    set = function(info, value) MeleeUtils.db.profile.rogueBlind = value end,
                },
                rogueEvasion = {
                    type = "toggle",
                    name = "Evasion",
                    desc = "Shows buff time for Evasion.",
                    get = function(info) return MeleeUtils.db.profile.rogueEvasion end,
                    set = function(info, value) MeleeUtils.db.profile.rogueEvasion = value end,
                },
            },
        },
        rogueCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not MeleeUtils.isRogue,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enabled",
                    desc = "Enables cooldown timers",
                    get = function(info) return MeleeUtils.db.profile.cooldowns end,
                    set = function(info, value) MeleeUtils.db.profile.cooldowns = value end,
                    order = 1,
                },
                separatorHeader = {
                    type = "header",
                    name = "Tracked Abilities",
                    order = 10,
                },
                rogueGougeCD = {
                    type = "toggle",
                    name = "Gauge",
                    desc = "Shows time bar for Gauge.",
                    get = function(info) return MeleeUtils.db.profile.rogueGougeCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueGougeCD = value end,
                    order = 100,
                },
                rogueKidneyShotCD = {
                    type = "toggle",
                    name = "Kidney Shot",
                    desc = "Shows time bar for Kidney Shot.",
                    get = function(info) return MeleeUtils.db.profile.rogueKidneyShotCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueKidneyShotCD = value end,
                    order = 101,
                },
                rogueVanishCD = {
                    type = "toggle",
                    name = "Vanish",
                    desc = "Shows cooldown for Vanish.",
                    get = function(info) return MeleeUtils.db.profile.rogueVanishCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueVanishCD = value end,
                },
                rogueSprintCD = {
                    type = "toggle",
                    name = "Sprint",
                    desc = "Shows cooldown for Sprint.",
                    get = function(info) return MeleeUtils.db.profile.rogueSprintCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueSprintCD = value end,
                },
                rogueStealthCD = {
                    type = "toggle",
                    name = "Stealth",
                    desc = "Shows cooldown for Stealth.",
                    get = function(info) return MeleeUtils.db.profile.rogueStealthCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueStealthCD = value end,
                },
                rogueKickCD = {
                    type = "toggle",
                    name = "Kick",
                    desc = "Shows cooldown for Kick.",
                    get = function(info) return MeleeUtils.db.profile.rogueKickCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueKickCD = value end,
                },
                rogueBlindCD = {
                    type = "toggle",
                    name = "Blind",
                    desc = "Shows cooldown for Blind.",
                    get = function(info) return MeleeUtils.db.profile.rogueBlindCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueBlindCD = value end,
                },
                rogueEvasionCD = {
                    type = "toggle",
                    name = "Evasion",
                    desc = "Shows cooldown for Evasion.",
                    get = function(info) return MeleeUtils.db.profile.rogueEvasionCD end,
                    set = function(info, value) MeleeUtils.db.profile.rogueEvasionCD = value end,
                },
                --eaAnnounce = {
                --    type = "toggle",
                --    name = "IEA Announce",
                --    desc = "Informs the raid in /s once you've applied IEA.",
                --    get = function(info) return MeleeUtils.db.profile.eaAnnounce end,
                --    set = function(info, value) MeleeUtils.db.profile.eaAnnounce = value end,
                --},
            }
        },
    },
}

function MeleeUtils:Options_ToggleEnabled(value)
    self.db.profile.enabled = value
    if self.db.profile.enabled then
        self:RegisterOptionalEvents()
    else
        self:UnregisterOptionalEvents()
    end
end

function MeleeUtils:ToggleLockedState()
    _uiLocked = not _uiLocked
    for _, frame in ipairs(self.adjustableFrames) do
        local f = _G[frame]
        if f then
            f:EnableMouse(not _uiLocked)
            if _uiLocked then f:Hide() else f:Show() end
        end
    end
    out("Frames are now "..(_uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))
end

function MeleeUtils:ResetWidgets()
    debug("Resetting widgets")
    self:ResetGeneralWidgets()
    self:ResetRogueWidgets()
end

function MeleeUtils:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open("MeleeUtils")
    else
        local cmd = input:trim():lower()
        if cmd == "debug" then
            MeleeUtilsDB.debug = not MeleeUtilsDB.debug
            if MeleeUtilsDB.debug then
                out("Debug mode ".._c.enabled.."enabled|r") -- Green text
            else
                out("Debug mode ".._c.disabled.."disabled|r") -- Orange text
            end
        elseif cmd == "test" then
            self:TestWatchBars()
            self:TestButtons()
        elseif cmd == "lock" then
            self:ToggleLockedState()
        elseif cmd == "reset" then
            self:ResetWidgets()
        else
            out("Unknown command. Use '/mu' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end
