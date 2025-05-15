local ADDON_NAME, addon = ...
local QA = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local out = QA.Print
local debug = QA.Debug
local _c = QA.colors
local ICON = QA.ICON

QA.defaultOptions = {
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
        hsNotCapitalWarning = true,
        targetInRangeIndication = true,
        announceInterrupts = true,
        announceMisses = false,
        stealthInInstance = true,
        raidBars = true,
        missingBuffsMode = "raid",
        rogueTeaTime = "always",
        rogueTeaTimeFrame = ICON.WARNING,
        warriorExecute = QA.isWarrior,
        warriorExecuteFrame = ICON.WARNING,
        warriorOverpower = QA.isWarrior,
        warriorOverpowerFrame = ICON.WARNING,
        warriorRevenge = QA.isWarrior,
        warriorRevengeFrame = ICON.WARNING,
        someSetting = 50,
        raidBarHeight = 20,
        barHeight = 25,
        barWidth = 128,
        barGap = 2,
        buttonHeight = 50,
        gearWarningSize = 80,
        iconAlertSize = 80,
        crucialIconSize = 50,
        rangeIconSize = 30,
        missingBuffsSize = 40,
        reminderIconSize = 40,
        weaponEnchantSize = 40,
        crucialExpireTime = 8,
        transmutePreReadyTime = 60,
        rogue5combo = true,
        harryPaste = true,
        outOfRange = true,
        outOfRangeSound = true,
        offensiveBars = true,
        showTimeOnBars = true,
        battleShoutMissing = QA.isWarrior or QA.isRogue,
        frostResistanceTotemMissing = true,
        lowConsumesMinLevel = 58,
        lowConsumesMinCount = 1,
        manaTideAura = QA.isManaClass,
        innervateAura = QA.isManaClass,
        encounter4hmStartAt = 0, -- 0 = disabled
        encounter4hmMoveEvery = 3,
    },
}

QA.options = {
    name = "QuickAuras",
    handler = QA,
    type = "group",
    childGroups = "tab",
    args = {
        addonEnabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return QA.db.profile.enabled end,
            set = function(info, value) QA:Options_ToggleEnabled(value) end,
            order = 4,
        },
        watchBarsEnabled = {
            type = "toggle",
            name = "Watch Bars",
            desc = "Enables progress bars for player's auras",
            get = function(info) return QA.db.profile.watchBars end,
            set = function(info, value)
                QA.db.profile.watchBars = value
                if value then
                    QA:TestProgressBar(QA.trackedAuras)
                end
            end,
            order = 5,
        },
        offensiveBarsEnabled = {
            type = "toggle",
            name = "Offensive Bars",
            desc = "Show a progress bar with time left on important abilities",
            get = function(info) return QA.db.profile.offensiveBars end,
            set = function(info, value)
                QA.db.profile.offensiveBars = value
                if value then
                    QA:TestProgressBar(QA.trackedCombatLog)
                end
            end,
            order = 6,
        },
        cooldownsEnabled = {
            type = "toggle",
            name = "Cooldown Timers",
            desc = "Enables cooldown timers",
            get = function(info) return QA.db.profile.cooldowns end,
            set = function(info, value)
                QA.db.profile.cooldowns = value
                if value then
                    QA:TestCooldowns()
                end
            end,
            order = 7,
        },
        iconWarningEnabled = {
            type = "toggle",
            name = "Warnings",
            desc = "Enables warnings for gear and other",
            get = function(info) return QA.db.profile.trackedGear end,
            set = function(info, value)
                QA.db.profile.trackedGear = value
                if value then
                    QA:CheckGear()
                else
                    QA:ClearIcons(ICON.WARNING)
                end
            end,
            order = 8,
        },
        missingBuffsEnabled = {
            type = "toggle",
            name = "Missing Buffs",
            desc = "Enables showing of list missing buffs/consumables in instances",
            get = function(info) return QA.db.profile.missingConsumes end,
            set = function(info, value)
                QA.db.profile.missingConsumes = value
                QA:RefreshMissing()
            end,
            order = 9,
        },
        remindersEnabled = {
            type = "toggle",
            name = "Reminders",
            desc = "Enables reminders for low consumes, candles, ankh, tracking buffs, etc.",
            get = function(info) return QA.db.profile.remindersEnabled end,
            set = function(info, value)
                QA.db.profile.remindersEnabled = value
                QA:RefreshReminders()
            end,
            order = 10,
        },
        raidBars = {
            type = "toggle",
            name = "Raid Bars",
            desc = "Enables tracking of raid players' buffs, cooldowns, etc.",
            get = function(info) return QA.db.profile.raidBars end,
            set = function(info, value)
                QA.db.profile.raidBars = value
            end,
            order = 11,
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
                    get = function(info) return QA.db.profile.barHeight end,
                    set = function(info, value)
                        QA.db.profile.barHeight = value
                        QA:TestBars()
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
                    get = function(info) return QA.db.profile.barWidth end,
                    set = function(info, value)
                        QA.db.profile.barWidth = value
                        QA:TestBars()
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
                    get = function(info) return QA.db.profile.barGap end,
                    set = function(info, value)
                        QA.db.profile.barGap = value
                        QA:TestBars()
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
                    get = function(info) return QA.db.profile.buttonHeight end,
                    set = function(info, value)
                        QA.db.profile.buttonHeight = value
                        QA:TestCooldowns()
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
                    get = function(info) return QA.db.profile.gearWarningSize end,
                    set = function(info, value)
                        QA.db.profile.gearWarningSize = value
                        QA:TestIconWarnings()
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
                    get = function(info) return QA.db.profile.iconAlertSize end,
                    set = function(info, value)
                        QA.db.profile.iconAlertSize = value
                        QA:TestIconAlerts()
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
                    get = function(info) return QA.db.profile.missingBuffsSize end,
                    set = function(info, value)
                        QA.db.profile.missingBuffsSize = value
                        QA:TestIconMissingBuffs()
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
                    get = function(info) return QA.db.profile.reminderIconSize end,
                    set = function(info, value)
                        QA.db.profile.reminderIconSize = value
                        QA:TestReminders()
                    end,
                    order = 107,
                },
                crucialIconSize = {
                    type = "range",
                    name = "Crucial Alert Size",
                    desc = "Set the size of the alert icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.crucialIconSize end,
                    set = function(info, value)
                        QA.db.profile.crucialIconSize = value
                        QA:RefreshCrucial()
                    end,
                    order = 108,
                },
                rangeIconSize = {
                    type = "range",
                    name = "Range Size",
                    desc = "Set the size of the range indicator icon",
                    min = 5,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.rangeIconSize end,
                    set = function(info, value)
                        QA.db.profile.rangeIconSize = value
                        --QuickAuras:TestIconAlerts()
                    end,
                    order = 110,
                },
                raidBarsHeight = {
                    type = "range",
                    name = "Raid Bar Height",
                    desc = "Set the height of the raid bars",
                    min = 5,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.raidBarHeight end,
                    set = function(info, value)
                        QA.db.profile.raidBarHeight = value
                        --QuickAuras:TestIconAlerts()
                    end,
                    order = 111,
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
                    get = function(info) return QA.db.profile.showTimeOnBars end,
                    set = function(info, value) QA.db.profile.showTimeOnBars = value end,
                    order = 200,
                },
            },
        },
        generalUtils = {
            type = "group",
            name = "Utils",
            order = 1000,
            --hidden = not QuickAuras.isRogue and not QuickAuras.isWarrior,
            args = {
                announceInterrupts = {
                    type = "toggle",
                    name = "Announce Interrupts",
                    desc = "Say when you interrupt a spell",
                    get = function(info) return QA.db.profile.announceInterrupts end,
                    set = function(info, value) QA.db.profile.announceInterrupts = value end,
                    order = 10,
                },
                outOfRange = {
                    type = "toggle",
                    name = "Out of Range",
                    desc = "Show a noticable warning when you are out of range of your target in combat",
                    get = function(info) return QA.db.profile.outOfRange end,
                    set = function(info, value)
                        QA.db.profile.outOfRange = value
                        if not value then QA.db.profile.outOfRangeSound = false end
                    end,
                    order = 11,
                },
                outOfRangeSound = {
                    type = "toggle",
                    name = "Out of Range Sound",
                    desc = "Play a warning when you are out of range of your target in combat",
                    get = function(info) return QA.db.profile.outOfRangeSound end,
                    set = function(info, value)
                        QA.db.profile.outOfRangeSound = value
                        if value then QA.db.profile.outOfRange = true end
                    end,
                    order = 12,
                },
                meleeUtilsHeader = {
                    type = "header",
                    name = "Melee Utils",
                    order = 98,
                    hidden = not QA.isRogue,
                },
                spacer201 = {
                    type = "description",
                    name = "",
                    order = 99,
                    hidden = not QA.isRogue,
                },
                harryPaste = {
                    type = "toggle",
                    name = "Harry Paste",
                    desc = "Warn when a mob parries your attack while being tanked",
                    get = function(info) return QA.db.profile.harryPaste end,
                    set = function(info, value) QA.db.profile.harryPaste = value end,
                    order = 102,
                },
                battleShoutMissing = {
                    type = "toggle",
                    name = "Battle Shout Missing",
                    desc = "Show a warning when Battle Shout is missing",
                    get = function(info) return QA.db.profile.battleShoutMissing end,
                    set = function(info, value)
                        QA.db.profile.battleShoutMissing = value
                        QA:ClearIcons(ICON.CRUCIAL)
                        QA:CheckAuras()
                    end,
                    order = 105,
                },
                announceMisses = {
                    type = "toggle",
                    name = "Announce Misses",
                    desc = "When tanking a mob in an instance, will say when your swing missed.",
                    get = function(info) return QA.db.profile.announceMisses end,
                    set = function(info, value)
                        QA.db.profile.announceMisses = value
                    end,
                    order = 106,
                },
                warriorUtilsHeader = {
                    type = "header",
                    name = "Warrior Utils",
                    order = 398,
                    hidden = not QA.isWarrior,
                },
                spacer202 = {
                    type = "description",
                    name = "",
                    order = 399,
                    hidden = not QA.isWarrior,
                },
                warriorExecute = {
                    type = "toggle",
                    name = "Execute!",
                    desc = "Shows a visible Execute indication when enemy has 20% or less HP.",
                    get = function(info)
                        return QA.db.profile.warriorExecute
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorExecute = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 400,
                },
                warriorOverpower = {
                    type = "toggle",
                    name = "Overpower!",
                    desc = "Shows a visible Overpower indication when enemy has 20% or less HP.",
                    get = function(info)
                        return QA.db.profile.warriorOverpower
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorOverpower = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 401,
                },
                warriorRevenge = {
                    type = "toggle",
                    name = "Revenge!",
                    desc = "Shows a visible Revenge indication.",
                    get = function(info)
                        return QA.db.profile.warriorRevenge
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorRevenge = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 402,
                },
                warriorExecuteFrame = {
                    type = "select",
                    name = "Execute! Frame",
                    desc = "Choose where to show the Execute indication.",
                    values = {
                        warning = "Warning Frame",
                        alert = "Alert Frame",
                    },
                    get = function(info)
                        return QA.db.profile.warriorExecuteFrame or "always"
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorExecuteFrame = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 403,
                },
                warriorOverpowerFrame = {
                    type = "select",
                    name = "Overpower! Frame",
                    desc = "Choose where to show the Overpower indication.",
                    values = {
                        warning = "Warning Frame",
                        alert = "Alert Frame",
                    },
                    get = function(info)
                        return QA.db.profile.warriorOverpowerFrame or "warning"
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorOverpowerFrame = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 404,
                },
                warriorRevengeFrame = {
                    type = "select",
                    name = "Revenge! Frame",
                    desc = "Choose where to show the Revenge indication.",
                    values = {
                        warning = "Warning Frame",
                        alert = "Alert Frame",
                    },
                    get = function(info)
                        return QA.db.profile.warriorRevengeFrame or "warning"
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorRevengeFrame = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 405,
                },
                rogueUtilsHeader = {
                    type = "header",
                    name = "Rogue Utils",
                    order = 298,
                    hidden = not QA.isRogue,
                },
                spacer201 = {
                    type = "description",
                    name = "",
                    order = 299,
                    hidden = not QA.isRogue,
                },
                rogue5Combo = {
                    type = "toggle",
                    name = "5 Combo Points",
                    desc = "Shows a visible indication when you have 5 combo points.",
                    get = function(info)
                        return QA.db.profile.rogue5combo
                    end,
                    set = function(info, value)
                        QA.db.profile.rogue5combo = value
                    end,
                    hidden = not QA.isRogue,
                    order = 304,
                },
                rogueTeaTime = {
                    type = "select",
                    name = "Tea Time!",
                    desc = "Shows a visible Thistle Tea indication when you have less than 6 energy, the perfect time for a tea.",
                    values = {
                        never = "Never",
                        flurry = "On Blade Flurry",
                        always = "Always",
                    },
                    get = function(info)
                        return QA.db.profile.rogueTeaTime or "always"
                    end,
                    set = function(info, value)
                        QA.db.profile.rogueTeaTime = value
                    end,
                    hidden = not QA.isRogue,
                    order = 306,
                },
                rogueTeaTimeFrame = {
                    type = "select",
                    name = "Tea Time Frame",
                    desc = "Choose where to show the Thistle Tea indication.",
                    values = {
                        warning = "Warning Frame",
                        alert = "Alert Frame",
                    },
                    get = function(info)
                        return QA.db.profile.rogueTeaTimeFrame or "always"
                    end,
                    set = function(info, value)
                        QA.db.profile.rogueTeaTimeFrame = value
                    end,
                    hidden = not QA.isRogue,
                    order = 307,
                },
                stealthInInstance = {
                    type = "toggle",
                    name = "Stealthed Warn",
                    desc = "Show a warning when stealthed in an instance. Can be useful when vanishing mid combat, it's hard to see whether you're stealthed or not.",
                    get = function(info)
                        return QA.db.profile.stealthInInstance
                    end,
                    set = function(info, value)
                        QA.db.profile.stealthInInstance = value
                    end,
                    hidden = not QA.isRogue,
                    order = 308,
                },
            },
        },
        bars = {
            type = "group",
            name = "Time Bars",
            order = 1002,
            args = {
                header1 = {
                    type = "header",
                    name = "Tracked Abilities",
                    order = 1000,
                },
                header2 = {
                    type = "header",
                    name = "Tracked Trinkets",
                    order = 2000,
                },
                header3 = {
                    type = "header",
                    name = "Tracked Raid Buffs",
                    order = 3000,
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
        warnings = {
            type = "group",
            name = "Warnings",
            order = 10000,
            args = {
                hsNotCapitalWarning = {
                    type = "toggle",
                    name = "Hearthstone",
                    desc = "Shows a warning if your hearthstone is not set to a capital city.",
                    get = function(info)
                        return QA.db.profile.hsNotCapitalWarning
                    end,
                    set = function(info, value)
                        QA.db.profile.hsNotCapitalWarning = value
                        QA:RefreshWarnings()
                    end,
                    order = 50,
                },
                header1 = {
                    type = "header",
                    name = "Gear Warnings",
                    order = 199,
                },
                header2 = {
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
                targetInRangeIndication = {
                    type = "toggle",
                    name = "Target In Range",
                    desc = "Lets you know when target is in range for casting a spell",
                    get = function(info)
                        return QA.db.profile.targetInRangeIndication
                    end,
                    set = function(info, value)
                        QA.db.profile.targetInRangeIndication = value
                        QuickAuras_RangeIndicator:Hide()
                        QA.targetInRange = false
                        QA:CheckTargetRange()
                    end,
                    order = 50,
                },
                header1 = {
                    type = "header",
                    name = "Buff/Debuff Alert",
                    order = 99,
                },
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
                        return QA.db.profile.missingBuffsMode or "raid"
                    end,
                    set = function(info, value)
                        QA.db.profile.missingBuffsMode = value
                        QA:RefreshMissing()
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
                        return QA.db.profile.reminderLowConsumes
                    end,
                    set = function(info, value)
                        QA.db.profile.reminderLowConsumes = value
                        QA:RefreshReminders()
                    end,
                    order = 50,
                },
                outOfConsumeWarning = {
                    type = "toggle",
                    name = "Out of Consume",
                    desc = "Shows a warning if a consumable has been depleted during an instance. Right click icon to dismiss.",
                    get = function(info)
                        return QA.db.profile.outOfConsumeWarning
                    end,
                    set = function(info, value)
                        QA.db.profile.outOfConsumeWarning = value
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
                    get = function(info) return QA.db.profile.transmutePreReadyTime end,
                    set = function(info, value)
                        QA.db.profile.transmutePreReadyTime = value
                        QA:CheckTransmuteCooldownDebounce()
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

local function AddSpells(cspells, orderStart, categoryHidden)
    orderStart = orderStart or 0
    local order = 1
    for spellKey, spell in pairs(cspells) do
        order = order + 1
        debug(3, "AddAbilitiesOptions", "Adding spell", spellKey, spell.name, spell.spellId, spell.visible)
        if spell.raidBars then
            if QA.defaultOptions.profile[spell.option.."_rbars"] == nil then
                QA.defaultOptions.profile[spell.option.."_rbars"] = true
            end
            QA.options.args.bars.args[spellKey.."_rbars"] = {
                type = "toggle",
                name = spell.name,
                desc = "Shows time bar when "..spell.name.." is active for a raid member.",
                get = function(info) return QA.db.profile[spell.option.."_rbars"] end,
                set = function(info, value)
                    QA.db.profile[spell.option.."_rbars"] = value
                end,
                order = order + 3000,
            }
        end
        if not categoryHidden then
            if spell.visible == nil or spell.visible == true then
                -- obj.option in format of class_abilityName
                if QA.defaultOptions.profile[spell.option] == nil then
                    QA.defaultOptions.profile[spell.option] = true
                end
                local categoryOptions = QA.options.args[spell.category or "bars"]
                if categoryOptions and spell.list and not spell.transmute then
                    -- Buff/Debuff option
                    local args = categoryOptions.args
                    args[spellKey] = {
                        type = "toggle",
                        name = spell.name,
                        desc = spell.desc or "Shows "..(spell.offensive and "debuff" or "buff").." time for ".. spell.name..".",
                        get = function(info) return QA.db.profile[spell.option] end,
                        set = function(info, value)
                            QA.db.profile[spell.option] = value
                            if spell.aura then QA:CheckAuras() end
                        end,
                        order = order + orderStart,
                    }
                end
                categoryOptions = QA.options.args[spell.category or "cooldowns"]
                if categoryOptions and spell.cooldown then
                    -- Cooldowns option
                    if QA.defaultOptions.profile[spell.option.."_cd"] == nil then
                        QA.defaultOptions.profile[spell.option.."_cd"] = true
                    end
                    categoryOptions.args[spellKey] = {
                        type = "toggle",
                        name = spell.name,
                        desc = spell.desc or "Shows cooldown for ".. spell.name..".",
                        get = function(info) return QA.db.profile[spell.option.."_cd"] end,
                        set = function(info, value)
                            QA.db.profile[spell.option.."_cd"] = value
                            QA:RefreshCooldowns()
                            if spell.aura then QA:CheckAuras() end
                        end,
                        order = order + 1000,
                    }
                end
                if spell.transmute then
                    -- Profession cooldowns option
                    if QA.defaultOptions.profile[spell.option.."_pcd"] == nil then
                        QA.defaultOptions.profile[spell.option.."_pcd"] = true
                    end
                    QA.options.args.reminders.args[spellKey] = {
                        type = "toggle",
                        name = spell.name,
                        desc = "Reminder icon when "..spell.name.." cooldown is ready.",
                        get = function(info)
                            return QA.db.profile[spell.option.."_pcd"]
                        end,
                        set = function(info, value)
                            QA.db.profile[spell.option.."_pcd"] = value
                            QA:RefreshReminders()
                        end,
                        order = order + 100,
                    }
                end
            end
        end
    end
end

function QA:AddAbilitiesOptions()
    AddSpells(self.spells.racials)
    AddSpells(self.spells.iconAlerts, 100)
    AddSpells(self.spells.other)
    AddSpells(self.spells.transmutes)
    --AddSpells(self.spells.reminders)
    AddSpells(self.spells.trinkets, 2000)
    AddSpells(self.spells.rogue, 1000, not self.isRogue)
    AddSpells(self.spells.hunter, 1000, not self.isHunter)
    AddSpells(self.spells.warrior, 1000, not self.isWarrior)
    AddSpells(self.spells.shaman, 1000, not self.isShaman)
end

function QA:AddGearWarningOptions()
    local order = 200
    for itemId, obj in pairs(QA.trackedGear) do
        order = order + 1
        obj.option = "gw_"..obj.name:gsub("%s+", "")
        QA.defaultOptions.profile[obj.option] = true
        QA.options.args.warnings.args[obj.option] = {
            type = "toggle",
            name = obj.name,
            desc = obj.desc or "Shows a warning when "..obj.name.." is worn.",
            get = function(info)
                return QA.db.profile[obj.option]
            end,
            set = function(info, value)
                QA.db.profile[obj.option] = value
                QA:RefreshWarnings()
            end,
            order = order,
        }
    end
end

function QA:AddRemindersOptions()
    local order = 200

    local function AddOption(obj, optionsList)
        obj.option = "reminders_"..obj.name:gsub("%s+", "")
        debug(3, "Adding reminder option", obj.name, obj.option)
        QA.defaultOptions.profile[obj.option] = true
        optionsList.args[obj.option] = {
            type = "toggle",
            name = obj.name,
            desc = obj.desc or "Shows a warning when you're low on "..obj.name,
            get = function(info)
                return QA.db.profile[obj.option]
            end,
            set = function(info, value)
                debug(3, "Set reminder", obj.name, obj.option, value)
                QA.db.profile[obj.option] = value
                QA:RefreshReminders()
            end,
            order = order,
        }
    end

    --for _, obj in ipairs(QuickAuras.trackedLowConsumes, QuickAuras.options.args.consumes) do
    --    order = order + 1
    --    AddOption(obj)
    --end
    order = 200
    for _, obj in pairs(QA.trackedTracking) do
        order = order + 1
        AddOption(obj, QA.options.args.reminders)
    end
end

function QA:AddConsumeOptions()
    local order = 200
    for _, item in ipairs(self.consumes) do
        if item.visible == nil or item.visible then
            order = order + 1
            debug(3, "AddConsumeOptions", item.name, item.option, item.default)
            if item.cooldown then
                QA.defaultOptions.profile[item.option.."_cd"] = true
            end
            QA.options.args.consumes.args[item.option] = {
                type = "toggle",
                name = item.name,
                desc = item.desc or "Shows a warning when ".. item.name.." is missing.",
                get = function(info)
                    return QA.db.profile[item.option]
                end,
                set = function(info, value)
                    QA.db.profile[item.option] = value
                    QA:RefreshMissing()
                    if (item.visible == nil or item.visible) and (item.visibleFunc == nil or item.visibleFunc()) then
                        QA:RefreshReminders()
                    end
                end,
                order = order,
            }
        end
    end
end

function QA:SetRangeDefaultSpellId()
    if QA.isWarrior then
        QA.defaultOptions.profile.rangeSpellId = 6178 -- charge
    elseif QA.isShaman then
        QA.defaultOptions.profile.rangeSpellId = 8056 -- frost shock
    elseif QA.isMage then
        QA.defaultOptions.profile.rangeSpellId = 116 -- frostbolt
    elseif QA.isWarlock then
        QA.defaultOptions.profile.rangeSpellId = 686 -- shadow bolt
    elseif QA.isHunter then
        QA.defaultOptions.profile.rangeSpellId = 3044 -- arcane shot
    else
        QA.defaultOptions.profile.rangeSpellId = nil
    end
end

function QA:BuildOptions()
    self:AddAbilitiesOptions()
    self:AddGearWarningOptions()
    self:AddConsumeOptions()
    self:AddRemindersOptions()
    self:SetRangeDefaultSpellId()
end

--------

function QA:SetOptionsDefaults()
    for _, item in ipairs(self.consumes) do
        if (item.visible == nil or item.visible) and self.bags[item.itemId] then
            -- enable currently helf consumes for low consumes reminder
            self.db.profile[item.option] = true
        end
    end
end
