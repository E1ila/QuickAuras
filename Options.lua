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
        missingConsumes = true,
        someSetting = 50,
        barHeight = 25,
        barGap = 2,
        buttonHeight = 50,
        gearWarningSize = 80,
        iconAlertSize = 80,
        missingBuffsSize = 35,
        rogue5combo = true,
        harryPaste = true,
        outOfRange = true,
        outOfRangeSound = true,
        offensiveBars = true,
        showTimeOnBars = true,
        manaTideAura = QuickAuras.isManaClass,
        innervateAura = QuickAuras.isManaClass,
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
                    QuickAuras:ClearIcons("warning")
                end
            end,
            order = 8,
        },
        missingBuffsEnabled = {
            type = "toggle",
            name = "Missing Consumes",
            desc = "Enables showing of list missing consumables in instances",
            get = function(info) return QuickAuras.db.profile.missingConsumes end,
            set = function(info, value)
                QuickAuras.db.profile.missingConsumes = value
                QuickAuras:ClearIcons("missing")
                QuickAuras:CheckMissingBuffs()
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
                QuickAuras:TestBars()
            end,
            order = 102,
        },
        barGap = {
            type = "range",
            name = "Bar Gap",
            desc = "Set the spacing between bars",
            min = 0,
            max = 10,
            step = 1,
            get = function(info) return QuickAuras.db.profile.barGap end,
            set = function(info, value)
                QuickAuras.db.profile.barGap = value
                QuickAuras:TestBars()
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
        missingBuffsSize = {
            type = "range",
            name = "Missing Consumes Size",
            desc = "Set the size of the missing consumes icons",
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return QuickAuras.db.profile.missingBuffsSize end,
            set = function(info, value)
                QuickAuras.db.profile.missingBuffsSize = value
                QuickAuras:TestIconMissingBuffs()
            end,
            order = 106,
        },
        showTimeOnBars = {
            type = "toggle",
            name = "Show Time Left",
            desc = "Enables showing of time left on timers",
            get = function(info) return QuickAuras.db.profile.showTimeOnBars end,
            set = function(info, value) QuickAuras.db.profile.showTimeOnBars = value end,
            order = 150,
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
        --commonUtilsHeader = {
        --    type = "header",
        --    name = "Common Utils",
        --    order = 200,
        --},
        --spacer201 = {
        --    type = "description",
        --    name = "",
        --    order = 201,
        --},
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
                    order = 102,
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
                    order = 104,
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
                    order = 104,
                },
                rogueUtilsHeader = {
                    type = "header",
                    name = "Rogue Utils",
                    order = 298,
                },
                spacer201 = {
                    type = "description",
                    name = "",
                    order = 299,
                },
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
                    hidden = not QuickAuras.isRogue,
                    order = 304,
                },
            },
        },
        bars = {
            type = "group",
            name = "Buffs / Debuffs",
            order = 1002,
            args = {
                abilities = {
                    type = "group",
                    name = "Abilities",
                    order = 1000,
                    args = {
                    },
                },
                trinkets = {
                    type = "group",
                    name = "Trinkets",
                    order = 1001,
                    args = {
                    },
                },
            },
        },
        cooldowns = {
            type = "group",
            name = "Cooldowns",
            order = 1003,
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
            },
        },
        missingBuffs = {
            type = "group",
            name = "Consumes",
            order = 10002,
            args = {
            },
        }
    },
}

local function AddSpells(cspells, subCategory)
    local order = 1
    for spellKey, spell in pairs(cspells) do
        order = order + 1
        --debug("Adding spell option", spellKey, spell.name, spell.spellId, spell.visible)
        if spell.visible == nil or spell.visible == true then
            -- obj.option in format of class_abilityName
            if QuickAuras.defaultOptions.profile[spell.option] == nil then
                QuickAuras.defaultOptions.profile[spell.option] = true
            end
            local categoryOptions = QuickAuras.options.args[spell.category or "bars"]
            if categoryOptions and spell.list then
                local args = categoryOptions.args
                local sub = subCategory or spell.subCategory
                if sub and args[sub] then
                    args = args[sub].args
                end
                args[spellKey] = {
                    type = "toggle",
                    name = spell.name,
                    desc = spell.desc or "Shows "..(spell.offensive and "debuff" or "buff").." time for ".. spell.name..".",
                    get = function(info) return QuickAuras.db.profile[spell.option] end,
                    set = function(info, value)
                        QuickAuras.db.profile[spell.option] = value
                        if spell.aura then QuickAuras:CheckAuras() end
                    end,
                    order = order,
                }
            end
            categoryOptions = QuickAuras.options.args[spell.category or "cooldowns"]
            if categoryOptions and spell.cooldown then
                if QuickAuras.defaultOptions.profile[spell.option.."_cd"] == nil then
                    QuickAuras.defaultOptions.profile[spell.option.."_cd"] = true
                end
                categoryOptions.args[spellKey] = {
                    type = "toggle",
                    name = spell.name,
                    desc = spell.desc or "Shows cooldown for ".. spell.name..".",
                    get = function(info) return QuickAuras.db.profile[spell.option.."_cd"] end,
                    set = function(info, value)
                        QuickAuras.db.profile[spell.option.."_cd"] = value
                        QuickAuras:CheckCooldowns()
                        if spell.aura then QuickAuras:CheckAuras() end
                    end,
                    order = order + 1000,
                }
            end
        end
    end
end

function QuickAuras:AddAbilitiesOptions()
    AddSpells(QuickAuras.spells.racials)
    AddSpells(QuickAuras.spells.iconAlerts)
    AddSpells(QuickAuras.spells.other)
    AddSpells(QuickAuras.spells.trinkets, "trinkets")
    local lowerClass = string.lower(QuickAuras.playerClass)
    local classAbilities = QuickAuras.spells[lowerClass]
    if classAbilities then
        AddSpells(classAbilities, "abilities")
    end
end

function QuickAuras:AddGearWarningOptions()
    local order = 0
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
                QuickAuras:ClearIcons("warning")
                QuickAuras:CheckGear()
            end,
            order = order,
        }
    end
end

function QuickAuras:AddMissingBuffsOptions()
    local order = 0
    for _, buff in ipairs(self.consumes) do
        order = order + 1
        --debug("Adding missing buff option", buff.name, buff.option, buff.default)
        QuickAuras.defaultOptions.profile[buff.option] = buff.default == nil and true or buff.default
        QuickAuras.options.args.missingBuffs.args[buff.option] = {
            type = "toggle",
            name = buff.name,
            desc = buff.desc or "Shows a warning when ".. buff.name.." buff is missing.",
            get = function(info)
                return QuickAuras.db.profile[buff.option]
            end,
            set = function(info, value)
                QuickAuras.db.profile[buff.option] = value
                QuickAuras:ClearIcons("missing") -- need to clear, since CheckAuras don't remove disabled buffs
                QuickAuras:CheckMissingBuffs()
                --QuickAuras:CheckAuras()
            end,
            order = order,
        }
    end
end

function QuickAuras:BuildOptions()
    self:AddAbilitiesOptions()
    self:AddGearWarningOptions()
    self:AddMissingBuffsOptions()
end
