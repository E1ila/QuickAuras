-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QA = addon.root
QA.version = "0.17"
QA.events = CreateFrame("Frame")
QA.bags = {} -- items in bags
QA.playerBuffs = {}
QA.playerIsStealthed = {}
QA.existingConsumes = {}
QA.partyShamans = {}
QA.encounter = { OnStart = {}, OnEnd = {}, CombatLog = {} }
QA.procCheck = { cooldown = {}, FadeCheck = {} }
QA.hasTaunted = 0
QAG = QA
QuickAurasDBG = QuickAurasDBG or {
    debug = 0,
}
QuickAurasDB = QuickAurasDB or {}
QuickAurasDB.bank = QuickAurasDB.bank or {}
QA.bank = QuickAurasDB.bank
QA.OnUpdateQueue = {};

-- managed timers
QA.list = {}
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
QA.list_queue = {}
QA.list_swingTimers = {}
QA.list_ready = {}
QA.list_readyThings = {} -- item/spell icon
QA.arrangeQueue = {}

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
QA.colors = {
    alert = "|cffff0000",
    yellow = "|cffffde00",
    brown = "|cffbb9977",
    bold = "|cffff99cc",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
    purple = "|cffcc99ff",
    white = "|cffeeeeee",
    gray = "|cffaaaaaa",
    cyan = "|cff009999",
}
local _c = QA.colors

QA.WINDOW = {
    ALERT = "alert",
    REMINDER = "reminder",
    WARNING = "warning",
    MISSING = "missing",
    CRUCIAL = "crucial",
    RANGE = "range",
    QUEUE = "queue",
    SWING = "swing",
    RAIDBARS = "raidbar",
    COOLDOWNS = "cooldowns",
    WATCH = "watch",
    OFFENSIVE = "offensive",
    READY = "ready",
    READYTHINGS = "readythings",
}

QA.FEATUERS = {

}

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
QA.Print = out

local function debug(text, func, ...)
    local textIsNumber = type(text) == "number"
    local minLevel = textIsNumber and text or 1
    if QuickAurasDBG.debug and QuickAurasDBG.debug >= minLevel then
        local argc = select("#", ...)
        if textIsNumber and argc > 1 then
            local s = ""
            for i = 1, argc do
                local c = (i % 2 == 0) and _c.gray or _c.brown
                s = s .. c .. tostring(select(i, ...)) .. "|r "
            end
            print("|cff0088ff{|r|cff00bbff"..ADDON_NAME.."|r|cff0088ff}|r", _c.cyan.."DEBUG|r", _c.gray..tostring(GetTime()), "["..text.."]|r", _c.purple..func.."|r", s)
        else
            print("|cff0088ff{|r|cff00bbff"..ADDON_NAME.."|r|cff0088ff}|r", _c.cyan.."DEBUG|r", _c.gray..tostring(GetTime()).."|r".._c.gray, text, func, ...)
        end
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

    QA:InitSpells()
    QA:BuildTrackedGear()
    QA:BuildTrackedSpells()
    QA:BuildTrackedTracking()
    QA:BuildTrackedItems()
    QA:BuildOptions()

    QA.db = LibStub("AceDB-3.0"):New("QuickAurasDB", QA.defaultOptions, true)
    QA.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")

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
        QA.inCombat = UnitAffectingCombat("player")
        QA:InitUI()
        QA:InitBossLogic()
        QA.InitSwingTimer()
        QA:InitStancePortrait()
        QA:InitReadyThings()
        QA:RegisterOptionalEvents()
        QA:GroupCompoChanged()
        QA:CheckAuras()
        QA:CheckCooldowns()
        QA:CheckGear()
        QA:UPDATE_SHAPESHIFT_FORM()
        --QuickAuras:CheckTrackingStatus() -- updated on load due to zone event
        --QuickAuras:CheckMissingBuffs() -- updated on load due to zone event
        --QuickAuras:CheckLowConsumes() -- updated on load due to zone event
        --QuickAuras:CheckTransmuteCooldown() -- updated on load due to zone event
        out("QuickAuras loaded. Type " .. _c.bold .. "/qa|r for options.")
    end)
end

function QA:OnProfileChanged(a, b)
    debug("Profile changed", a, b)
    --QA:UnregisterOptionalEvents()
    --QA:RegisterOptionalEvents()
    --QA:RefreshAll()
end

function QA:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    QA.events:RegisterEvent("ZONE_CHANGED")
    QA.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    QA.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    QA.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    QA.events:RegisterEvent("ADDON_ACTION_BLOCKED")
end

local registeredEvents = {}

function QA:RegisterOptionalEvents()
    if QA.db.profile.enabled  then
        debug("Registering events")
        for event, optionKeys in pairs(QA.optionalEvents) do
            local enabled = true
            for _, optionKey in ipairs(optionKeys) do
                if not QA.db.profile[optionKey] then
                    enabled = false
                    break
                end
            end
            if enabled and not registeredEvents[event] then
                QA.events:RegisterEvent(event)
                registeredEvents[event] = true
                debug(2, "++ "..event)
            elseif not enabled and registeredEvents[event] then
                QA.events:UnregisterEvent(event)
                debug(2, "-- "..event)
                registeredEvents[event] = false
            end
        end
    else
        QA:UnregisterOptionalEvents()
    end
end

function QA:UnregisterOptionalEvents()
    debug("Unregistering all events")
    for event, enabled in pairs(registeredEvents) do
        if enabled then
            QA.events:UnregisterEvent(event)
            registeredEvents[event] = false
        end
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
        elseif cmd == "inj" then
            QA:TestInject()
        elseif cmd == "4hm" then
            local startAt = arg1 and tonumber(arg1) or 0
            QA.db.profile.encounter4hmStartAt = startAt
            if startAt and startAt > 0 then
                out("4HM healer mode, start moving set to ".._c.bold..tostring(startAt))
            else
                out("4HM healer mode disabled.")
            end
        elseif cmd == "thaddius" then
            local startAt = arg1 and tonumber(arg1) or 0
            QA.db.profile.announceThaddiusAdds = not QA.db.profile.announceThaddiusAdds
            if QA.db.profile.announceThaddiusAdds then
                out("Thaddius adds announce is ".._c.enabled.."enabled")
            else
                out("Thaddius adds announce is ".._c.disabled.."disabled")
            end
        elseif cmd == "spore" then
            local startAt = arg1 and tonumber(arg1) or 0
            QA.db.profile.encounterLoathebStartAt = startAt
            if startAt and startAt > 0 then
                out("Loatheb set Spore group ".._c.bold..tostring(startAt))
            else
                out("Loatheb Spore alert disabled.")
            end
        elseif cmd == "xp" then
            QA:ResetXpTracker()
        else
            out("QuickAuras available commands:")
            out("  |cFF00FFaa/qa|r - Open options")
            out("  |cFF00FFaa/qa lock|r - Toggle lock/unlock window position")
            out("  |cFF00FFaa/qa clear|r - Clear ignored (right clicked) icons")
            out("  |cFF00FFaa/qa xp|r - Reset XP session tracker")
            out("|cff000000-------------------------------|r")
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
    --debug(2, "Scanning bank")
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

function QA:GetSpellIdFromGuid(guid)
    local npcId = guid:match("Cast%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    return tonumber(npcId)
end

function QA:IsClassicEra()
    return true
end

function QA:IsRetail()
    return false
end

function QA:GetDuration(conf, spellId)
    if not conf.duration then return nil end
    if type(conf.duration) == "number" then
        return conf.duration
    end
    local index = 1
    if spellId and type(conf.spellId) == "table" then
        for i = 1, #conf.spellId do
            if conf.spellId[i] == spellId then
                index = i
                break
            end
        end
    end
    return conf.duration[index]
end

function QA:PlayAirHorn()
    if QA.db.profile.soundsEnabled then
        PlaySoundFile("Interface\\AddOns\\QuickAuras\\assets\\AirHorn.ogg", "Master")
    end
end

function QA:GetDebuffStacks(spellId)
    for i = 1, 40 do
        local name, _, count, _, _, _, _, _, _, id = UnitDebuff("player", i)
        if not name then break end
        if id == spellId then
            return count or 0
        end
    end
    return 0
end
