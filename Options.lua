local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _uiLocked = true
local out = QuickAuras.Print
local debug = QuickAuras.Debug
local _c = QuickAuras.colors

QuickAuras.defaultOptions = {
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
    },
}

QuickAuras.options = {
    name = "QuickAuras",
    handler = QuickAuras,
    type = "group",
    childGroups = "tab",
    args = {
        titleText = {
            type = "description",
            name = "  " .. ADDON_NAME .. " (v" .. QuickAuras.version .. ")",
            fontSize = "large",
            order = 1,
        },
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return QuickAuras.db.profile.enabled end,
            set = function(info, value) QuickAuras:Options_ToggleEnabled(value) end,
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
            get = function(info) return QuickAuras.db.profile.barHeight end,
            set = function(info, value)
                QuickAuras.db.profile.barHeight = value
                QuickAuras:TestWatchBars()
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
            get = function(info) return QuickAuras.db.profile.buttonHeight end,
            set = function(info, value)
                QuickAuras.db.profile.buttonHeight = value
                QuickAuras:TestButtons()
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
            get = function(info) return QuickAuras.db.profile.harryPaste end,
            set = function(info, value) QuickAuras.db.profile.harryPaste = value end,
            order = 202,
        },
        offensiveBars = {
            type = "toggle",
            name = "Offensive Bars",
            desc = "Show a progress bar with time left on important abilities",
            get = function(info) return QuickAuras.db.profile.offensiveBars end,
            set = function(info, value) QuickAuras.db.profile.offensiveBars = value end,
            order = 203,
        },
        outOfRange = {
            type = "toggle",
            name = "Out of Range",
            desc = "Show a noticable warning when you are out of range of your target in combat",
            get = function(info) return QuickAuras.db.profile.outOfRange end,
            set = function(info, value)
                QuickAuras.db.profile.outOfRange = value
                if not value then QuickAuras.db.profile.outOfRangeSound = false end
            end,
            order = 204,
        },
        outOfRangeSound = {
            type = "toggle",
            name = "Out of Range Sound",
            desc = "Play a warning when you are out of range of your target in combat",
            get = function(info) return QuickAuras.db.profile.outOfRangeSound end,
            set = function(info, value)
                QuickAuras.db.profile.outOfRangeSound = value
                if value then QuickAuras.db.profile.outOfRange = true end
            end,
            order = 204,
        },
        bloodFury = {
            type = "toggle",
            name = "Blood Fury",
            desc = "Show a cooldown for Blood Fury.",
            get = function(info) return QuickAuras.db.profile.bloodFury end,
            set = function(info, value) QuickAuras.db.profile.bloodFury = value end,
            order = 205,
        },
        rogueUtils = {
            type = "group",
            name = "Utils",
            order = 1000,
            hidden = not QuickAuras.isRogue,
            args = {
                rogue5Combo = {
                    type = "toggle",
                    name = "5 Combo Points",
                    desc = "Shows a visible indication when you have 5 combo points.",
                    get = function(info)
                        return QuickAuras.db.profile.rogue5combo
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile.rogue5combo = value
                    end,
                },
            },
        },
        rogueBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1001,
            hidden = not QuickAuras.isRogue,
            args = {
                watchBars = {
                    type = "toggle",
                    name = "Enabled",
                    desc = "Enables progress bars for buffs/debuffs",
                    get = function(info) return QuickAuras.db.profile.watchBars end,
                    set = function(info, value) QuickAuras.db.profile.watchBars = value end,
                    order = 1,
                },
                separatorHeader = {
                    type = "header",
                    name = "Tracked Abilities",
                    order = 10,
                },
            },
        },
        rogueCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isRogue,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enabled",
                    desc = "Enables cooldown timers",
                    get = function(info) return QuickAuras.db.profile.cooldowns end,
                    set = function(info, value) QuickAuras.db.profile.cooldowns = value end,
                    order = 1,
                },
                separatorHeader = {
                    type = "header",
                    name = "Tracked Abilities",
                    order = 10,
                },
            }
        },
    },
}

function QuickAuras:Options_ToggleEnabled(value)
    self.db.profile.enabled = value
    if self.db.profile.enabled then
        self:RegisterOptionalEvents()
    else
        self:UnregisterOptionalEvents()
    end
end

function QuickAuras:ToggleLockedState()
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

function QuickAuras:ResetWidgets()
    debug("Resetting widgets")
    self:ResetGeneralWidgets()
    self:ResetRogueWidgets()
end

function QuickAuras:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open("QuickAuras")
    else
        local cmd = input:trim():lower()
        if cmd == "debug" then
            QuickAurasDB.debug = not QuickAurasDB.debug
            if QuickAurasDB.debug then
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
            out("Unknown command. Use '/qa' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end

local order = 1000
local lowerClass = string.lower(QuickAuras.playerClass)
for ability, obj in pairs(QuickAuras.abilities[lowerClass]) do
    order = order + 1
    QuickAuras.defaultOptions.profile[obj.option] = true
    QuickAuras.defaultOptions.profile[obj.option.."_cd"] = true
    if obj.list then
        QuickAuras.options.args[lowerClass.."Bars"].args[ability] = {
            type = "toggle",
            name = obj.name,
            desc = "Shows "..(obj.offensive and "debuff" or "buff").." time for "..obj.name..".",
            get = function(info)
                return QuickAuras.db.profile[obj.option]
            end,
            set = function(info, value)
                QuickAuras.db.profile[obj.option] = value
            end,
            order = order,
        }
    end
    if obj.cooldown then
        QuickAuras.options.args[lowerClass.."Cooldowns"].args[ability] = {
            type = "toggle",
            name = obj.name,
            desc = "Shows cooldown for "..obj.name..".",
            get = function(info) return QuickAuras.db.profile[obj.option.."_cd"] end,
            set = function(info, value) QuickAuras.db.profile[obj.option.."_cd"] = value end,
            order = order + 1000,
        }
    end
end
