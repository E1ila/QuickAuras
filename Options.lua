local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local out = QuickAuras.Print
local debug = QuickAuras.Debug
local _c = QuickAuras.colors

QuickAuras.defaultOptions = {
    profile = {
        enabled = true,
        cooldowns = true,
        watchBars = true,
        trackedGear = true,
        someSetting = 50,
        barHeight = 25,
        buttonHeight = 50,
        gearWarningSize = 80,
        iconAlertSize = 80,
        rogue5combo = true,
        harryPaste = true,
        outOfRange = true,
        outOfRangeSound = true,
        offensiveBars = true,
        bloodFury = true,
        manaTideAura = QuickAuras.isManaClass,
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
        spacer2 = {
            type = "description",
            name = "",
            order = 2,
        },
        spacer3 = {
            type = "description",
            name = "",
            order = 3,
        },
        addonEnabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return QuickAuras.db.profile.enabled end,
            set = function(info, value) QuickAuras:Options_ToggleEnabled(value) end,
            order = 4,
        },
        watchBarsEnabled = {
            type = "toggle",
            name = "Watch Bars",
            desc = "Enables progress bars for player's auras",
            get = function(info) return QuickAuras.db.profile.watchBars end,
            set = function(info, value)
                QuickAuras.db.profile.watchBars = value
                if value then
                    QuickAuras:TestProgressBar(QuickAuras.trackedAuras)
                end
            end,
            order = 5,
        },
        offensiveBarsEnabled = {
            type = "toggle",
            name = "Offensive Bars",
            desc = "Show a progress bar with time left on important abilities",
            get = function(info) return QuickAuras.db.profile.offensiveBars end,
            set = function(info, value)
                QuickAuras.db.profile.offensiveBars = value
                if value then
                    QuickAuras:TestProgressBar(QuickAuras.trackedCombatLog)
                end
            end,
            order = 6,
        },
        cooldownsEnabled = {
            type = "toggle",
            name = "Cooldown Timers",
            desc = "Enables cooldown timers",
            get = function(info) return QuickAuras.db.profile.cooldowns end,
            set = function(info, value)
                QuickAuras.db.profile.cooldowns = value
                if value then
                    QuickAuras:TestCooldowns()
                end
            end,
            order = 7,
        },
        iconWarningEnabled = {
            type = "toggle",
            name = "Gear Warnings",
            desc = "Enables gear warnings",
            get = function(info) return QuickAuras.db.profile.trackedGear end,
            set = function(info, value)
                QuickAuras.db.profile.trackedGear = value
                if value then
                    QuickAuras:CheckGear()
                else
                    QuickAuras:ClearIconWarnings()
                end
            end,
            order = 8,
        },
        spacer99 = {
            type = "description",
            name = "",
            order = 99,
        },
        lookAndFeelHeader = {
            type = "header",
            name = "Look and Feel",
            order = 100,
        },
        spacer101 = {
            type = "description",
            name = "",
            order = 101,
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
            order = 102,
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
                QuickAuras:TestCooldowns()
            end,
            order = 103,
        },
        gearWarningSize = {
            type = "range",
            name = "Warning Icon Size",
            desc = "Set the size of the warning icons",
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return QuickAuras.db.profile.gearWarningSize end,
            set = function(info, value)
                QuickAuras.db.profile.gearWarningSize = value
                QuickAuras:TestIconWarnings()
            end,
            order = 104,
        },
        iconAlertSize = {
            type = "range",
            name = "Alert Icon Size",
            desc = "Set the size of the alert icons",
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return QuickAuras.db.profile.iconAlertSize end,
            set = function(info, value)
                QuickAuras.db.profile.iconAlertSize = value
                QuickAuras:TestIconAlerts()
            end,
            order = 105,
        },
        spacer198 = {
            type = "description",
            name = "",
            order = 198,
        },
        spacer199 = {
            type = "description",
            name = "",
            order = 199,
        },
        commonUtilsHeader = {
            type = "header",
            name = "Common Utils",
            order = 200,
        },
        spacer201 = {
            type = "description",
            name = "",
            order = 201,
        },
        bloodFury = {
            type = "toggle",
            name = "Blood Fury",
            desc = "Show a cooldown for Blood Fury.",
            get = function(info) return QuickAuras.db.profile.bloodFury end,
            set = function(info, value) QuickAuras.db.profile.bloodFury = value end,
            order = 205,
            hidden = not QuickAuras.isOrc,
        },
        meleeUtils = {
            type = "group",
            name = "Melee Utils",
            order = 1000,
            hidden = not QuickAuras.isRogue,
            args = {
                harryPaste = {
                    type = "toggle",
                    name = "Harry Paste",
                    desc = "Warn when a mob parries your attack while being tanked",
                    get = function(info) return QuickAuras.db.profile.harryPaste end,
                    set = function(info, value) QuickAuras.db.profile.harryPaste = value end,
                    order = 202,
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
            },
        },
        rogueUtils = {
            type = "group",
            name = "Rogue Utils",
            order = 1001,
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
            order = 1002,
            hidden = not QuickAuras.isRogue,
            args = {
            },
        },
        rogueCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isRogue,
            args = {
            }
        },
        shamanBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isRogue,
            args = {
            },
        },
        shamanCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isShaman,
            args = {
            }
        },
        mageBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isMage,
            args = {
            },
        },
        mageCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isMage,
            args = {
            }
        },
        priestBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isPriest,
            args = {
            },
        },
        priestCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isPriest,
            args = {
            }
        },
        warriorBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isWarrior,
            args = {
            },
        },
        warriorCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isWarrior,
            args = {
            }
        },
        hunterBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isHunter,
            args = {
            },
        },
        hunterCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isHunter,
            args = {
            }
        },
        warlockBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isWarlock,
            args = {
            },
        },
        warlockCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isWarlock,
            args = {
            }
        },
        druidBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isDruid,
            args = {
            },
        },
        druidCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isDruid,
            args = {
            }
        },
        paladinBars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            hidden = not QuickAuras.isPaladin,
            args = {
            },
        },
        paladinCooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1002,
            hidden = not QuickAuras.isPaladin,
            args = {
            }
        },
        gearWarnings = {
            type = "group",
            name = "Gear Warnings",
            order = 10000,
            args = {
            }
        },
        iconAlerts = {
            type = "group",
            name = "Icon Alerts",
            order = 10001,
            args = {
                manaTideAura = {
                    type = "toggle",
                    name = "Mana Tide",
                    desc = "Notify when Mana Tide is up.",
                    get = function(info) return QuickAuras.db.profile.manaTideAura end,
                    set = function(info, value) QuickAuras.db.profile.manaTideAura = value end,
                    order = 1,
                    hidden = not QuickAuras.isManaClass,
                },
            },
        },
    },
}

function QuickAuras:AddAbilitiesOptions()
    local order = 1
    local lowerClass = string.lower(QuickAuras.playerClass)
    if not QuickAuras.abilities[lowerClass] then return end
    for ability, obj in pairs(QuickAuras.abilities[lowerClass]) do
        order = order + 1
        -- obj.option in format of class_abilityName
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
end

function QuickAuras:AddGearWarningOptions()
    local order = 1
    for itemId, obj in pairs(QuickAuras.trackedGear) do
        order = order + 1
        obj.option = "gw_"..obj.name:gsub("%s+", "")
        QuickAuras.defaultOptions.profile[obj.option] = true
        QuickAuras.options.args.gearWarnings.args[obj.option] = {
            type = "toggle",
            name = obj.name,
            desc = obj.desc or "Shows a warning when "..obj.name.." is worn.",
            get = function(info)
                return QuickAuras.db.profile[obj.option]
            end,
            set = function(info, value)
                QuickAuras.db.profile[obj.option] = value
                QuickAuras:ClearIconWarnings()
                QuickAuras:CheckGear()
            end,
            order = order,
        }
    end
end

function QuickAuras:BuildOptions()
    self:AddAbilitiesOptions()
    self:AddGearWarningOptions()
end
