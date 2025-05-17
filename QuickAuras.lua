-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QA = addon.root
QA.version = "0.9"
QA.events = CreateFrame("Frame")
QA.bags = {} -- items in bags
QA.playerBuffs = {}
QA.playerIsStealthed = {}
QA.existingConsumes = {}
QA.partyShamans = {}
QA.encounter = { OnStart = {}, OnEnd = {} }
QA.procCheck = { cooldown = {}, FadeCheck = {} }
QAG = QA
QuickAurasDBG = QuickAurasDBG or {
    debug = 0,
}
QuickAurasDB = QuickAurasDB or {}
QuickAurasDB.bank = QuickAurasDB.bank or {}
QA.bank = QuickAurasDB.bank

-- managed timers
QA.list_timers = {} -- all active timers
QA.list_timerByName = {}
-- managed timers by frame type
QA.list_watchBars = {} -- timer obj
QA.list_offensiveBars = {} -- timer obj
QA.list_cooldowns = {} -- timer obj
QA.list_iconWarnings = {} -- item obj
QA.list_iconAlerts = {} -- timer obj
QA.list_missingBuffs = {} -- item obj
QA.list_reminders = {} -- spell obj
QA.list_crucial = {} -- timer / icon
QA.list_range = {}
QA.list_raidBars = {} -- timer

local pclass = select(2, UnitClass("player"))
QA.playerClass = pclass
QA.playerRace = select(1, UnitRace("player"))
QA.playerGuid = UnitGUID("player")
QA.playerLevel = UnitLevel("player")
QA.isRogue = pclass == "ROGUE"
QA.isWarrior = pclass == "WARRIOR"
QA.isPaladin = pclass == "PALADIN"
QA.isShaman = pclass == "SHAMAN"
QA.isMage = pclass == "MAGE"
QA.isWarlock = pclass == "WARLOCK"
QA.isHunter = pclass == "HUNTER"
QA.isDruid = pclass == "DRUID"
QA.isPriest = pclass == "PRIEST"
QA.isOrc = QA.playerRace == "Orc"
QA.isTroll = QA.playerRace == "Troll"
QA.isUndead = QA.playerRace == "Undead"
QA.isTauren = QA.playerRace == "Tauren"
QA.isManaClass = QA.isPriest or QA.isMage or QA.isWarlock or QA.isDruid or QA.isPaladin or QA.isShaman or QA.isHunter
QA.isHorde = QA.isOrc or QA.isTroll or QA.isUndead or QA.isTauren
QA.isAlliance = not QA.isHorde
local _c

QA.ICON = {
    ALERT = "alert",
    REMINDER = "reminder",
    WARNING = "warning",
    MISSING = "missing",
    CRUCIAL = "crucial",
    RANGE = "range",
}

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
QA.Print = out

local function debug(text, ...)
    local minLevel = type(text) == "number" and text or 1
    if QuickAurasDBG.debug and QuickAurasDBG.debug >= minLevel then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r","|cff009999DEBUG|cff999999", "|cffbb9977"..tostring(GetTime()).."|r", text, ...)
    end
end
QA.Debug = debug

function QA:Debounce(func, delay)
    local timer = nil
    return function(...)
        local args = { ... }
        if timer then
            timer:Cancel() -- Cancel the previous timer if it exists
        end
        timer = C_Timer.NewTimer(delay, function()
            func(unpack(args)) -- Call the original function with the arguments
        end)
    end
end

function QA:OnInitialize()
    debug("Initializing...")
    _c = QA.colors

    QA:InitSpells()
    QA:BuildTrackedGear()
    QA:BuildTrackedSpells()
    QA:BuildTrackedTracking()
    QA:BuildTrackedItems()
    QA:BuildOptions()

    QA.db = LibStub("AceDB-3.0"):New("QuickAurasDB", QA.defaultOptions, true)
    AceConfig:RegisterOptionsTable("QuickAuras", QA.options)
    QA.optionsFrame = AceConfigDialog:AddToBlizOptions("QuickAuras", "QuickAuras")
    QA:RegisterChatCommand("qa", "HandleSlashCommand")

    QA.events:SetScript("OnEvent", function(self, event, ...)
        QA[event](QA, ...)
    end)
    QA.events:SetScript("OnUpdate", function()
        QA:OnUpdate()
    end)

    QA:RegisterMandatoryEvents()

    C_Timer.After(0.2, function()
        debug("Init delay ended")
        QA:ScanBags()
        if not QA.db.profile.initialized then
            debug("First time initialization")
            QA.db.profile.initialized = true
            QA:SetOptionsDefaults()
        end
        QA:InitUI()
        QA:RegisterOptionalEvents()
        QA:CheckIfWarriorInParty()
        QA:CheckAuras()
        QA:CheckCooldowns()
        QA:CheckGear()
        QA:InitBossLogic()
        QA:UPDATE_SHAPESHIFT_FORM()
        --QuickAuras:CheckTrackingStatus() -- updated on load due to zone event
        --QuickAuras:CheckMissingBuffs() -- updated on load due to zone event
        --QuickAuras:CheckLowConsumes() -- updated on load due to zone event
        --QuickAuras:CheckTransmuteCooldown() -- updated on load due to zone event
        out("QuickAuras loaded. Type " .. _c.bold .. "/qa|r for options.")
    end)
end

function QA:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    QA.events:RegisterEvent("ZONE_CHANGED")
    QA.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    QA.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    QA.events:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function QA:RegisterOptionalEvents()
    if QA.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(QA.optionalEvents) do
            QA.events:RegisterEvent(event)
        end
    end
end

function QA:UnregisterOptionalEvents()
    debug("Unregistering events")
    for _, event in ipairs(QA.optionalEvents) do
        QA.events:UnregisterEvent(event)
    end
end

function QA:Options_ToggleEnabled(value)
    QA.db.profile.enabled = value
    if QA.db.profile.enabled then
        QA:RegisterOptionalEvents()
    else
        QA:UnregisterOptionalEvents()
    end
end

function QA:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open("QuickAuras")
    else
        local cmd, arg1 = strsplit(" ", input:trim():lower())
        if cmd == "debug" or cmd == "d" then
            local level
            if QuickAurasDBG.debug and QuickAurasDBG.debug > 0 and not arg1 then
                level = 0
            else
                level = arg1 and tonumber(arg1) or 1
            end
            QuickAurasDBG.debug = level
            if level > 0 then
                out("Debug mode ".._c.enabled.."enabled|r", "("..tostring(level)..")") -- Green text
            else
                out("Debug mode ".._c.disabled.."disabled|r") -- Orange text
            end
        elseif cmd == "c" or cmd == "clear" then
            out("Cleared ignored icons!")
            QA.ignoredIcons = {}
            QA:RefreshAll()
        elseif cmd == "test" then
            QA:DemoUI()
        elseif cmd == "test2" then
            QA:DemoUI2()
        elseif cmd == "lock" or cmd == "l" then
            QA:ToggleLockedState()
        elseif cmd == "reset" then
            QA:ResetWidgets()
        elseif cmd == "4hm" then
            local startAt = arg1 and tonumber(arg1) or 0
            QA.db.profile.encounter4hmStartAt = startAt
            if startAt and startAt > 0 then
                out("4HM healer mode, start moving set to ".._c.bold..tostring(startAt))
            else
                out("4HM healer mode disabled.")
            end
        elseif cmd == "spore" then
            local startAt = arg1 and tonumber(arg1) or 0
            QA.db.profile.encounterLoathebStartAt = startAt
            if startAt and startAt > 0 then
                out("Loatheb set Spore group ".._c.bold..tostring(startAt))
            else
                out("Loatheb Spore alert disabled.")
            end
        else
            out("QuickAuras available commands:")
            out("  |cFF00FFaa/qa|r - Open options")
            out("  |cFF00FFaa/qa lock|r - Toggle lock/unlock window position")
            out("  |cFF00FFaa/qa clear|r - Clear ignored (right clicked) icons")
            --out("  |cFF00FFaa/qa reset|r - Reset UI position")
        end
    end
end

function QA:ScanBag(bag)
    for slot = 1, C_Container.GetContainerNumSlots(bag) do -- Iterate through all slots in the bag
        local id = C_Container.GetContainerItemID(bag, slot)
        if id ~= nil then
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if QA.bags[id] then
                QA.bags[id].count = QA.bags[id].count + itemInfo.stackCount
            else
                QA.bags[id] = { bag = bag, slot = slot, count = itemInfo.stackCount }
            end
        end
    end
end

function QA:ScanBags()
    QA.bags = {}
    for bag = 0, NUM_BAG_SLOTS do -- Iterate through all bags (0 is the backpack)
        QA:ScanBag(bag)
    end
end

function QA:ScanBank()
    if not QA.bankOpen then return end
    debug("Scanning bank")
    QuickAurasDB.bank = {}
    QA.bank = QuickAurasDB.bank
    -- Scan the main bank slots (bag ID -1)
    for slot = 1, C_Container.GetContainerNumSlots(-1) do
        local id = C_Container.GetContainerItemID(-1, slot)
        if id then
            local itemInfo = C_Container.GetContainerItemInfo(-1, slot)
            QA.bank[id] = { bag = -1, slot = slot, count = itemInfo.stackCount }
        end
    end

    -- Scan the bank bags
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id then
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if QA.bank[id] then
                    QA.bank[id].count = QA.bank[id].count + itemInfo.stackCount
                else
                    QA.bank[id] = { bag = bag, slot = slot, count = itemInfo.stackCount }
                end
            end
        end
    end
end

function QuickAuras_Timer_OnUpdate(timer)
    return QA:UpdateProgressBar(timer)
end

function QA:GetNpcIdFromGuid(guid)
    local npcId = guid:match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    return tonumber(npcId)
end
