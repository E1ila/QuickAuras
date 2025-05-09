local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local out = QuickAuras.Print
local debug = QuickAuras.Debug
local _c = QuickAuras.colors

QuickAuras.defaultOptions = {
    profile = {
        debug = 0,
        enabled = true,
        cooldowns = true,
        watchBars = true,
        trackedGear = true,
        missingConsumes = true,
        remindersEnabled = true,
        lowConsumesInCapital = true,
        reminderLowConsumes = true,
        reminderTransmute = true,
        forceShowMissing = false,
        outOfConsumeWarning = true,
        missingBuffsMode = "raid",
        rogueUseTea = "always",
        someSetting = 50,
        barHeight = 25,
        barWidth = 128,
        barGap = 2,
        buttonHeight = 50,
        gearWarningSize = 80,
        iconAlertSize = 80,
        missingBuffsSize = 35,
        reminderIconSize = 40,
        weaponEnchantSize = 40,
        crucialBuffsSize = 50,
        transmutePreReadyTime = 3600,
        rogue5combo = true,
        harryPaste = true,
        outOfRange = true,
        outOfRangeSound = true,
        offensiveBars = true,
        showTimeOnBars = true,
        lowConsumesMinLevel = 58,
        lowConsumesMinCount = 1,
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
            name = "Missing Buffs",
            desc = "Enables showing of list missing buffs/consumables in instances",
            get = function(info) return QuickAuras.db.profile.missingConsumes end,
            set = function(info, value)
                QuickAuras.db.profile.missingConsumes = value
                QuickAuras:RefreshMissing()
            end,
            order = 9,
        },
        remindersEnabled = {
            type = "toggle",
            name = "Reminders",
            desc = "Enables reminders for low consumes, candles, ankh, tracking buffs, etc.",
            get = function(info) return QuickAuras.db.profile.remindersEnabled end,
            set = function(info, value)
                QuickAuras.db.profile.remindersEnabled = value
                QuickAuras:RefreshReminders()
            end,
            order = 10,
        },
        spacer99 = {
            type = "description",
            name = "",
            order = 99,
        },
        lookAndFeel = {
            type = "group",
            name = "Look and Feel",
            order = 100,
            args = {
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
                barWidth = {
                    type = "range",
                    name = "Bar Width",
                    desc = "Set the height of the bars",
                    min = 50,
                    max = 200,
                    step = 1,
                    get = function(info) return QuickAuras.db.profile.barWidth end,
                    set = function(info, value)
                        QuickAuras.db.profile.barWidth = value
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
                reminderIconSize = {
                    type = "range",
                    name = "Reminders Size",
                    desc = "Set the size of the missing consumes icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QuickAuras.db.profile.reminderIconSize end,
                    set = function(info, value)
                        QuickAuras.db.profile.reminderIconSize = value
                        QuickAuras:TestReminders()
                    end,
                    order = 107,
                },
                spacer198 = {
                    type = "description",
                    name = "",
                    order = 198,
                },
                showTimeOnBars = {
                    type = "toggle",
                    name = "Show Time Left",
                    desc = "Enables showing of time left on timers",
                    get = function(info) return QuickAuras.db.profile.showTimeOnBars end,
                    set = function(info, value) QuickAuras.db.profile.showTimeOnBars = value end,
                    order = 200,
                },
            },
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
                rogueUseTea = {
                    type = "select",
                    name = "Use Tea Now",
                    desc = "Shows a visible Thistle Tea indication when you have less than 6 energy.",
                    values = {
                        never = "Never",
                        flurry = "On Blade Flurry",
                        always = "Always",
                    },
                    get = function(info)
                        return QuickAuras.db.profile.rogueUseTea or "always"
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile.rogueUseTea = value
                    end,
                    order = 306,
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
                header1 = {
                    type = "header",
                    name = "",
                    order = 998,
                },
                title = {
                    type = "description",
                    name = "FYI: You can right click warning icons to dismiss them for this session.",
                    order = 999,
                },
            }
        },
        iconAlerts = {
            type = "group",
            name = "Icon Alerts",
            order = 10001,
            args = {
            },
        },
        consumes = {
            type = "group",
            name = "Consumes",
            order = 10002,
            args = {
                header1 = {
                    type = "header",
                    name = "Consumables Options",
                    order = 999,
                },
                missingBuffsMode = {
                    type = "select",
                    name = "Show Missing Buffs",
                    desc = "Choose when to show missing buffs.",
                    values = {
                        never = "Never",
                        instance = "Any Instance",
                        raid = "Raid Instances",
                    },
                    get = function(info)
                        return QuickAuras.db.profile.missingBuffsMode or "raid"
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile.missingBuffsMode = value
                        QuickAuras:RefreshMissing()
                    end,
                    order = 1000,
                },
            },
        },
        reminders = {
            type = "group",
            name = "Reminders",
            order = 10003,
            args = {
                reminderLowConsumes = {
                    type = "toggle",
                    name = "Low Consumes",
                    desc = "Shows a reminder to get consumes you're low on, at a capital city",
                    get = function(info)
                        return QuickAuras.db.profile.reminderLowConsumes
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile.reminderLowConsumes = value
                        QuickAuras:RefreshReminders()
                    end,
                    order = 50,
                },
                outOfConsumeWarning = {
                    type = "toggle",
                    name = "Out of Consume",
                    desc = "Shows a warning if a consumable has been depleted during an instance. Right click icon to dismiss.",
                    get = function(info)
                        return QuickAuras.db.profile.outOfConsumeWarning
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile.outOfConsumeWarning = value
                    end,
                    order = 51,
                },
                header1 = {
                    type = "header",
                    name = "Profession Cooldowns",
                    order = 100,
                },
                transmutePreReadyTime = {
                    type = "range",
                    name = "Minutes Before",
                    desc = "Show warning when cooldown is less than this many minutes",
                    min = 0,
                    max = 60*24,
                    step = 1,
                    get = function(info) return QuickAuras.db.profile.transmutePreReadyTime end,
                    set = function(info, value)
                        QuickAuras.db.profile.transmutePreReadyTime = value
                        QuickAuras:CheckTransmuteCooldownDebounce()
                    end,
                    order = 109,
                },
                header2 = {
                    type = "header",
                    name = "Gathering",
                    order = 199,
                },
                header3 = {
                    type = "header",
                    name = "",
                    order = 299,
                },
                title = {
                    type = "description",
                    name = "FYI: You can right click reminder icons to dismiss them for this session.",
                    order = 999,
                },
            },
        }
    },
}

local function AddSpells(cspells, subCategory)
    local order = 1
    for spellKey, spell in pairs(cspells) do
        order = order + 1
        debug(3, "AddAbilitiesOptions", "Adding spell", spellKey, spell.name, spell.spellId, spell.visible)
        if spell.visible == nil or spell.visible == true then
            -- obj.option in format of class_abilityName
            if QuickAuras.defaultOptions.profile[spell.option] == nil then
                QuickAuras.defaultOptions.profile[spell.option] = true
            end
            local categoryOptions = QuickAuras.options.args[spell.category or "bars"]
            if categoryOptions and spell.list and not spell.transmute then
                -- Buff/Debuff option
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
                -- Cooldowns option
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
            if spell.transmute then
                -- Profession cooldowns option
                if QuickAuras.defaultOptions.profile[spell.option.."_pcd"] == nil then
                    QuickAuras.defaultOptions.profile[spell.option.."_pcd"] = true
                end
                QuickAuras.options.args.reminders.args[spellKey] = {
                    type = "toggle",
                    name = spell.name,
                    desc = "Reminder icon when "..spell.name.." cooldown is ready.",
                    get = function(info)
                        return QuickAuras.db.profile[spell.option.."_pcd"]
                    end,
                    set = function(info, value)
                        QuickAuras.db.profile[spell.option.."_pcd"] = value
                        QuickAuras:RefreshReminders()
                    end,
                    order = order + 100,
                }
            end
        end
    end
end

function QuickAuras:AddAbilitiesOptions()
    AddSpells(QuickAuras.spells.racials)
    AddSpells(QuickAuras.spells.iconAlerts)
    AddSpells(QuickAuras.spells.other)
    AddSpells(QuickAuras.spells.transmutes)
    --AddSpells(QuickAuras.spells.reminders)
    AddSpells(QuickAuras.spells.trinkets, "trinkets")
    local lowerClass = string.lower(QuickAuras.playerClass)
    local classAbilities = QuickAuras.spells[lowerClass]
    if classAbilities then
        AddSpells(classAbilities, "abilities")
    end
end

function QuickAuras:AddGearWarningOptions()
    local order = 200
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
                QuickAuras:RefreshWarnings()
            end,
            order = order,
        }
    end
end

function QuickAuras:AddRemindersOptions()
    local order = 200

    local function AddOption(obj, optionsList)
        obj.option = "reminders_"..obj.name:gsub("%s+", "")
        debug(3, "Adding reminder option", obj.name, obj.option)
        QuickAuras.defaultOptions.profile[obj.option] = true
        optionsList.args[obj.option] = {
            type = "toggle",
            name = obj.name,
            desc = obj.desc or "Shows a warning when you're low on "..obj.name,
            get = function(info)
                return QuickAuras.db.profile[obj.option]
            end,
            set = function(info, value)
                debug(3, "Set reminder", obj.name, obj.option, value)
                QuickAuras.db.profile[obj.option] = value
                QuickAuras:RefreshReminders()
            end,
            order = order,
        }
    end

    --for _, obj in ipairs(QuickAuras.trackedLowConsumes, QuickAuras.options.args.consumes) do
    --    order = order + 1
    --    AddOption(obj)
    --end
    order = 200
    for _, obj in pairs(QuickAuras.trackedTracking) do
        order = order + 1
        AddOption(obj, QuickAuras.options.args.reminders)
    end
end

function QuickAuras:AddConsumeOptions()
    local order = 200
    for _, item in ipairs(self.consumes) do
        if item.visible == nil or item.visible then
            order = order + 1
            debug(3, "AddConsumeOptions", item.name, item.option, item.default)
            if item.cooldown then
                QuickAuras.defaultOptions.profile[item.option.."_cd"] = true
            end
            QuickAuras.options.args.consumes.args[item.option] = {
                type = "toggle",
                name = item.name,
                desc = item.desc or "Shows a warning when ".. item.name.." is missing.",
                get = function(info)
                    return QuickAuras.db.profile[item.option]
                end,
                set = function(info, value)
                    QuickAuras.db.profile[item.option] = value
                    QuickAuras:RefreshMissing()
                    if (item.visible == nil or item.visible) and (item.visibleFunc == nil or item.visibleFunc()) then
                        QuickAuras:RefreshReminders()
                    end
                end,
                order = order,
            }
        end
    end
end

function QuickAuras:BuildOptions()
    self:AddAbilitiesOptions()
    self:AddGearWarningOptions()
    self:AddConsumeOptions()
    self:AddRemindersOptions()
end

--------

function QuickAuras:SetOptionsDefaults()
    for _, item in ipairs(self.consumes) do
        if (item.visible == nil or item.visible) and self.bags[item.itemId] then
            -- enable currently helf consumes for low consumes reminder
            self.db.profile[item.option] = true
        end
    end
end
