-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QA = addon.root
QA.version = "0.8"
QA.events = CreateFrame("Frame")
QA.bags = {} -- items in bags
QA.playerBuffs = {}
QA.playerIsStealthed = {}
QA.existingConsumes = {}
QA.encounter = { OnStart = {}, OnEnd = {} }
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
QA.isManaClass = QA.isPriest or QA.isMage or QA.isWarlock or QA.isDruid or QA.isPaladin or QA.isShaman or QA.isHunter
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
    _c = self.colors

    self:InitSpells()
    self:BuildTrackedGear()
    self:BuildTrackedSpells()
    self:BuildTrackedTracking()
    self:BuildTrackedItems()
    self:BuildOptions()

    self.db = LibStub("AceDB-3.0"):New("QuickAurasDB", self.defaultOptions, true)
    AceConfig:RegisterOptionsTable("QuickAuras", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("QuickAuras", "QuickAuras")
    self:RegisterChatCommand("qa", "HandleSlashCommand")

    self.events:SetScript("OnEvent", function(self, event, ...)
        QA[event](QA, ...)
    end)
    self.events:SetScript("OnUpdate", function()
        QA:OnUpdate()
    end)

    self:RegisterMandatoryEvents()

    C_Timer.After(0.2, function()
        debug("Init delay ended")
        self:ScanBags()
        if not self.db.profile.initialized then
            debug("First time initialization")
            self.db.profile.initialized = true
            self:SetOptionsDefaults()
        end
        QA:InitUI()
        QA:RegisterOptionalEvents()
        QA:CheckIfWarriorInParty()
        QA:CheckAuras()
        QA:CheckCooldowns()
        QA:CheckGear()
        QA:InitBossLogic()
        --QuickAuras:CheckTrackingStatus() -- updated on load due to zone event
        --QuickAuras:CheckMissingBuffs() -- updated on load due to zone event
        --QuickAuras:CheckLowConsumes() -- updated on load due to zone event
        --QuickAuras:CheckTransmuteCooldown() -- updated on load due to zone event
        out("QuickAuras loaded. Type " .. _c.bold .. "/qa|r for options.")
    end)
end

function QA:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    self.events:RegisterEvent("ZONE_CHANGED")
    self.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    self.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function QA:RegisterOptionalEvents()
    if self.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(self.optionalEvents) do
            self.events:RegisterEvent(event)
        end
    end
end

function QA:UnregisterOptionalEvents()
    debug("Unregistering events")
    for _, event in ipairs(self.optionalEvents) do
        self.events:UnregisterEvent(event)
    end
end

function QA:Options_ToggleEnabled(value)
    self.db.profile.enabled = value
    if self.db.profile.enabled then
        self:RegisterOptionalEvents()
    else
        self:UnregisterOptionalEvents()
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
            self.ignoredIcons = {}
            self:RefreshAll()
        elseif cmd == "test" then
            self:DemoUI()
        elseif cmd == "test2" then
            self:DemoUI2()
        elseif cmd == "lock" or cmd == "l" then
            self:ToggleLockedState()
        elseif cmd == "reset" then
            self:ResetWidgets()
        elseif cmd == "4hm" then
            local startAt = arg1 and tonumber(arg1) or 0
            self.db.profile.encounter4hmStartAt = startAt
            if startAt and startAt > 0 then
                out("4HM healer mode, start moving set to ".._c.bold..tostring(startAt))
            else
                out("4HM healer mode disabled.")
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
            if self.bags[id] then
                self.bags[id].count = self.bags[id].count + itemInfo.stackCount
            else
                self.bags[id] = { bag = bag, slot = slot, count = itemInfo.stackCount }
            end
        end
    end
end

function QA:ScanBags()
    self.bags = {}
    for bag = 0, NUM_BAG_SLOTS do -- Iterate through all bags (0 is the backpack)
        self:ScanBag(bag)
    end
end

function QA:ScanBank()
    if not self.bankOpen then return end
    debug("Scanning bank")
    QuickAurasDB.bank = {}
    QA.bank = QuickAurasDB.bank
    -- Scan the main bank slots (bag ID -1)
    for slot = 1, C_Container.GetContainerNumSlots(-1) do
        local id = C_Container.GetContainerItemID(-1, slot)
        if id then
            local itemInfo = C_Container.GetContainerItemInfo(-1, slot)
            self.bank[id] = { bag = -1, slot = slot, count = itemInfo.stackCount }
        end
    end

    -- Scan the bank bags
    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id then
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if self.bank[id] then
                    self.bank[id].count = self.bank[id].count + itemInfo.stackCount
                else
                    self.bank[id] = { bag = bag, slot = slot, count = itemInfo.stackCount }
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
