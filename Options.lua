local ADDON_NAME, addon = ...
local QA = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local out = QA.Print
local debug = QA.Debug
local _c = QA.colors
local WINDOW = QA.WINDOW

local frameSelection = {
    warning = "Warning Frame",
    alert = "Alert Frame",
    queue = "Queue Frame",
}

QA.defaultOptions = {
    profile = {
        debug = 0,
        enabled = true,
        cooldowns = true,
        watchBars = true,
        trackedGear = true,
        soundsEnabled = true,
        missingConsumes = true,
        remindersEnabled = true,
        lowConsumesInCapital = true,
        reminderLowConsumes = true,
        reminderTransmute = true,
        forceShowMissing = false,
        outOfConsumeWarning = true,
        hsNotCapitalWarning = true,
        targetInRangeIndication = true,
        overaggroWarning = true,
        announceInterrupts = true,
        bossFhmLastMark = true,
        announceMisses = QA.isWarrior,
        announceSquawk = true,
        announceCcBreak = true,
        stealthInInstance = true,
        xpFrameEnabled = true,
        spellQueueEnabled = true,
        swingTimersEnabled = QA.isWarrior or QA.isRogue,
        swingTimerOH = true,
        swingTimerRanged = true,
        raidBars = true,
        missingBuffsMode = "raid",
        rogueTeaTime = "always",
        rogueTeaTimeFrame = WINDOW.WARNING,
        warriorExecute = QA.isWarrior,
        warriorExecuteFrame = WINDOW.WARNING,
        warriorOverpower = QA.isWarrior,
        warriorOverpowerFrame = WINDOW.WARNING,
        warriorRevenge = QA.isWarrior,
        warriorRevengeFrame = WINDOW.WARNING,
        targetMissingDebuffFrame = WINDOW.WARNING,
        swingDebug = 3,
        someSetting = 50,
        raidBarHeight = 20,
        barHeight = 25,
        barWidth = 128,
        barGap = 2,
        cooldownIconSize = 50,
        gearWarningSize = 80,
        iconAlertSize = 80,
        crucialIconSize = 50,
        spellQueueIconSize = 40,
        rangeIconSize = 30,
        missingBuffsSize = 40,
        reminderIconSize = 40,
        readyIconSize = 50,
        weaponEnchantSize = 40,
        crucialExpireTime = 5,
        targetAuraExpireTime = 8,
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
        encounterLoathebStartAt = 0, -- 0 = disabled
        encounterLoathebCycle = 6,
        aggroBlinkCount = 2,
        warrior_retaliation_cd = false,
        warrior_shieldWall_cd = false,
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
        spacer99 = {
            type = "description",
            name = "",
            order = 90,
        },
        features = {
            type = "group",
            name = "Features",
            order = 91,
            args = {
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
                            QA:ClearIcons(WINDOW.WARNING)
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
                xpFrameEnabled = {
                    type = "toggle",
                    name = "XP Bar",
                    desc = "Shows XP bar with rested % and quest XP",
                    get = function(info) return QA.db.profile.xpFrameEnabled end,
                    set = function(info, value)
                        QA.db.profile.xpFrameEnabled = value
                        if value and QA.playerLevel < 60 then
                            QuickAuras_XP:Show()
                        else
                            QuickAuras_XP:Hide()
                        end
                    end,
                    order = 12,
                },
                spellQueueEnabled = {
                    type = "toggle",
                    name = "Attack Queue",
                    desc = "Shows attack spell queue",
                    get = function(info) return QA.db.profile.spellQueueEnabled end,
                    set = function(info, value)
                        QA.db.profile.spellQueueEnabled = value
                        if value then
                            QuickAuras_SpellQueue:Show()
                        else
                            QuickAuras_SpellQueue:Hide()
                        end
                    end,
                    order = 13,
                },
                swingTimersEnabled = {
                    type = "toggle",
                    name = "Swing Timers",
                    desc = "Shows MH and OH swing timers",
                    get = function(info) return QA.db.profile.swingTimersEnabled end,
                    set = function(info, value)
                        QA.db.profile.swingTimersEnabled = value
                        if value then
                            QuickAuras_SwingTimer:Show()
                        else
                            QuickAuras_SwingTimer:Hide()
                        end
                    end,
                    order = 14,
                },
                overaggroWarning = {
                    type = "toggle",
                    name = "Overaggro Warn",
                    desc = "Shows a visible warning when overaggroing a tanked mob",
                    get = function(info) return QA.db.profile.overaggroWarning end,
                    set = function(info, value)
                        QA.db.profile.overaggroWarning = value
                    end,
                    order = 15,
                },
                soundsEnabled = {
                    type = "toggle",
                    name = "Sounds",
                    desc = "Enable or disable all sounds",
                    get = function(info) return QA.db.profile.soundsEnabled end,
                    set = function(info, value)
                        QA.db.profile.soundsEnabled = value
                    end,
                    order = 99,
                },
            }
        },
        lookAndFeel = {
            type = "group",
            name = "Look and Feel",
            order = 100,
            args = {
                lockState = {
                    type = "execute",
                    name = "Locked",
                    desc = "Allows customizing frame positions",
                    func = function()
                        QA:ToggleLockedState()
                        QA.options.args.lookAndFeel.args.lockState.name = QA.uiLocked and "Unlock" or "Lock"
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("QuickAuras")
                    end,
                    order = 1,
                },
                spacer98 = {
                    type = "header",
                    name = "Dimensions",
                    order = 98,
                },
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
                cooldownIconSize = {
                    type = "range",
                    name = "Cooldown Size",
                    desc = "Set the size of the cooldown icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.cooldownIconSize end,
                    set = function(info, value)
                        QA.db.profile.cooldownIconSize = value
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
                    name = "Crucial Icon Size",
                    desc = "Set the size of the alert icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.crucialIconSize end,
                    set = function(info, value)
                        QA.db.profile.crucialIconSize = value
                        QA:TestCrucial()
                    end,
                    order = 108,
                },
                readyIconSize = {
                    type = "range",
                    name = "Ready Icon Size",
                    desc = "Set the size of ready icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.readyIconSize end,
                    set = function(info, value)
                        QA.db.profile.readyIconSize = value
                        QA:TestReady()
                    end,
                    order = 108,
                },
                spellQueueIconSize = {
                    type = "range",
                    name = "Attack Queue Size",
                    desc = "Set the size of the attack queue icons",
                    min = 10,
                    max = 100,
                    step = 1,
                    get = function(info) return QA.db.profile.spellQueueIconSize end,
                    set = function(info, value)
                        QA.db.profile.spellQueueIconSize = value
                        QA:TestSpellQueue()
                    end,
                    order = 109,
                    hidden = not QA.isWarrior and not QA.isRogue,
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
                        QA:TestBars()
                    end,
                    order = 111,
                },
                spacer198 = {
                    type = "header",
                    name = "Other",
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
                    hidden = not QA.isRogue and not QA.isWarrior,
                },
                spacer201 = {
                    type = "description",
                    name = "",
                    order = 99,
                    hidden = not QA.isRogue and not QA.isWarrior,
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
                        QA:ClearIcons(WINDOW.CRUCIAL)
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
                announceSquawk = {
                    type = "toggle",
                    name = "Announce Squawk",
                    desc = "Say in /p when a Battle Chicken buff is applied.",
                    get = function(info) return QA.db.profile.announceSquawk end,
                    set = function(info, value)
                        QA.db.profile.announceSquawk = value
                    end,
                    order = 106,
                },
                swingTimerOH = {
                    type = "toggle",
                    name = "Swing Timer OH",
                    desc = "Show off-hand swing timer",
                    get = function(info) return QA.db.profile.swingTimerOH end,
                    set = function(info, value)
                        QA.db.profile.swingTimerOH = value
                        QuickAuras_SwingTimer_OH:Hide()
                    end,
                    order = 107,
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
                    values = frameSelection,
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
                    values = frameSelection,
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
                    values = frameSelection,
                    get = function(info)
                        return QA.db.profile.warriorRevengeFrame or "warning"
                    end,
                    set = function(info, value)
                        QA.db.profile.warriorRevengeFrame = value
                    end,
                    hidden = not QA.isWarrior,
                    order = 405,
                },
                warlockUtilsHeader = {
                    type = "header",
                    name = "Warlock Utils",
                    order = 450,
                    hidden = not QA.isWarlock,
                },
                spacer451 = {
                    type = "description",
                    name = "",
                    order = 451,
                    hidden = not QA.isWarlock,
                },
                warlockShadowTrance = {
                    type = "toggle",
                    name = "Shadow Trance",
                    desc = "Shows a visible Shadow Trance it procs.",
                    get = function(info)
                        return QA.db.profile.warlockShadowTrance
                    end,
                    set = function(info, value)
                        QA.db.profile.warlockShadowTrance = value
                    end,
                    hidden = not QA.isWarlock,
                    order = 452,
                },
                warlockShadowTranceFrame = {
                    type = "select",
                    name = "Shadow Trance Frame",
                    desc = "Choose where to show the Shadow Trance indication.",
                    values = frameSelection,
                    get = function(info)
                        return QA.db.profile.warlockShadowTranceFrame or "warning"
                    end,
                    set = function(info, value)
                        QA.db.profile.warlockShadowTranceFrame = value
                    end,
                    hidden = not QA.isWarlock,
                    order = 453,
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
                rogueSndMissing = {
                    type = "toggle",
                    name = "SnD Missing",
                    desc = "Show a warning when Slice & Dice is missing during combat",
                    get = function(info) return QA.db.profile.rogueSndMissing end,
                    set = function(info, value)
                        QA.db.profile.rogueSndMissing = value
                    end,
                    order = 305,
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
                    order = 306,
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
                    order = 307,
                },
                rogueTeaTimeFrame = {
                    type = "select",
                    name = "Tea Time Frame",
                    desc = "Choose where to show the Thistle Tea indication.",
                    values = frameSelection,
                    get = function(info)
                        return QA.db.profile.rogueTeaTimeFrame or "always"
                    end,
                    set = function(info, value)
                        QA.db.profile.rogueTeaTimeFrame = value
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
        },
        naxxramas = {
            type = "group",
            name = "Naxxramas",
            order = 20000,
            args = {
            },
        }
    },
}

local function AddSpells(cspells, orderStart, categoryHidden)
    orderStart = orderStart or 0
    local order = 1
    for spellKey, spell in pairs(cspells) do
        order = order + 1
        --debug(3, "AddAbilitiesOptions", "Adding spell", spellKey, spell.name, spell.spellId, spell.visible)
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
        if spell.enemyAura then
            local key = (spell.option or spellKey).."_enemy"
            if QA.defaultOptions.profile[key] == nil then
                QA.defaultOptions.profile[key] = true
            end
            QA.options.args.generalUtils.args[key] = {
                type = "toggle",
                name = "Enemy "..spell.name,
                desc = "Shows indication when "..spell.name.." is missing from target.",
                get = function(info) return QA.db.profile[key] end,
                set = function(info, value)
                    QA.db.profile[key] = value
                    debug("Set enemy aura", key, value)
                end,
                order = order + 30,
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
                if spell.buff then
                    table.insert(QA.trackedMissingBuffs, spell)
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
    AddSpells(QA.spells.racials)
    AddSpells(QA.spells.iconAlerts, 100)
    AddSpells(QA.spells.other)
    AddSpells(QA.spells.transmutes)
    --AddSpells(QA.spells.reminders)
    AddSpells(QA.spells.trinkets, 2000)
    AddSpells(QA.spells.rogue, 1000, not QA.isRogue)
    AddSpells(QA.spells.hunter, 1000, not QA.isHunter)
    AddSpells(QA.spells.warrior, 1000, not QA.isWarrior)
    AddSpells(QA.spells.shaman, 1000, not QA.isShaman)
    AddSpells(QA.spells.warlock, 1000, not QA.isWarlock)
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
        --debug(3, "Adding reminder option", obj.name, obj.option)
        QA.defaultOptions.profile[obj.option] = true
        optionsList.args[obj.option] = {
            type = "toggle",
            name = obj.name,
            desc = obj.desc or "Shows a warning when you're low on "..obj.name,
            get = function(info)
                return QA.db.profile[obj.option]
            end,
            set = function(info, value)
                --debug(3, "Set reminder", obj.name, obj.option, value)
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
    for _, item in ipairs(QA.consumes) do
        if item.visible == nil or item.visible then
            order = order + 1
            --debug(3, "AddConsumeOptions", item.name, item.option, item.default)
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
    QA:AddAbilitiesOptions()
    QA:AddGearWarningOptions()
    QA:AddConsumeOptions()
    QA:AddRemindersOptions()
    QA:SetRangeDefaultSpellId()
end

--------

function QA:SetOptionsDefaults()
    for _, item in ipairs(QA.consumes) do
        if (item.visible == nil or item.visible) and QA.bags[item.itemId] then
            -- enable currently helf consumes for low consumes reminder
            QA.db.profile[item.option] = true
        end
    end
end
