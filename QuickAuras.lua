-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QuickAuras = addon.root
QuickAuras.version = "0.7"
QuickAuras.events = CreateFrame("Frame")
QuickAuras.bags = {} -- items in bags
QuickAuras.playerBuffs = {}
QuickAuras.playerIsStealthed = {}
QuickAuras.existingConsumes = {}
QuickAuras.encounter = { OnStart = {}, OnEnd = {} }
QAG = QuickAuras
QuickAurasDBG = QuickAurasDBG or {
    debug = 0,
}
QuickAurasDB = QuickAurasDB or {}
QuickAurasDB.bank = QuickAurasDB.bank or {}
QuickAuras.bank = QuickAurasDB.bank

-- managed timers
QuickAuras.list_timers = {} -- all active timers
QuickAuras.list_timerByName = {}
-- managed timers by frame type
QuickAuras.list_watchBars = {} -- timer obj
QuickAuras.list_offensiveBars = {} -- timer obj
QuickAuras.list_cooldowns = {} -- timer obj
QuickAuras.list_iconWarnings = {} -- item obj
QuickAuras.list_iconAlerts = {} -- timer obj
QuickAuras.list_missingBuffs = {} -- item obj
QuickAuras.list_reminders = {} -- spell obj
QuickAuras.list_crucial = {} -- timer / icon
QuickAuras.list_range = {}
QuickAuras.list_raidBars = {} -- timer

local pclass = select(2, UnitClass("player"))
QuickAuras.playerClass = pclass
QuickAuras.playerRace = select(1, UnitRace("player"))
QuickAuras.playerGuid = UnitGUID("player")
QuickAuras.playerLevel = UnitLevel("player")
QuickAuras.isRogue = pclass == "ROGUE"
QuickAuras.isWarrior = pclass == "WARRIOR"
QuickAuras.isPaladin = pclass == "PALADIN"
QuickAuras.isShaman = pclass == "SHAMAN"
QuickAuras.isMage = pclass == "MAGE"
QuickAuras.isWarlock = pclass == "WARLOCK"
QuickAuras.isHunter = pclass == "HUNTER"
QuickAuras.isDruid = pclass == "DRUID"
QuickAuras.isPriest = pclass == "PRIEST"
QuickAuras.isOrc = QuickAuras.playerRace == "Orc"
QuickAuras.isTroll = QuickAuras.playerRace == "Troll"
QuickAuras.isUndead = QuickAuras.playerRace == "Undead"
QuickAuras.isManaClass = QuickAuras.isPriest or QuickAuras.isMage or QuickAuras.isWarlock or QuickAuras.isDruid or QuickAuras.isPaladin or QuickAuras.isShaman or QuickAuras.isHunter
local _c

QuickAuras.ICON = {
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
QuickAuras.Print = out

local function debug(text, ...)
    local minLevel = type(text) == "number" and text or 1
    if QuickAurasDBG.debug and QuickAurasDBG.debug >= minLevel then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r","|cff009999DEBUG|cff999999", "|cffbb9977"..tostring(GetTime()).."|r", text, ...)
    end
end
QuickAuras.Debug = debug

function QuickAuras:Debounce(func, delay)
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

function QuickAuras:OnInitialize()
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
        QuickAuras[event](QuickAuras, ...)
    end)
    self.events:SetScript("OnUpdate", function()
        QuickAuras:OnUpdate()
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
        QuickAuras:InitUI()
        QuickAuras:RegisterOptionalEvents()
        QuickAuras:CheckIfWarriorInParty()
        QuickAuras:CheckAuras()
        QuickAuras:CheckCooldowns()
        QuickAuras:CheckGear()
        QuickAuras:InitBossLogic()
        --QuickAuras:CheckTrackingStatus() -- updated on load due to zone event
        --QuickAuras:CheckMissingBuffs() -- updated on load due to zone event
        --QuickAuras:CheckLowConsumes() -- updated on load due to zone event
        --QuickAuras:CheckTransmuteCooldown() -- updated on load due to zone event
        out("QuickAuras loaded. Type " .. _c.bold .. "/qa|r for options.")
    end)
end

function QuickAuras:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    self.events:RegisterEvent("ZONE_CHANGED")
    self.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    self.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function QuickAuras:RegisterOptionalEvents()
    if self.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(self.optionalEvents) do
            self.events:RegisterEvent(event)
        end
    end
end

function QuickAuras:UnregisterOptionalEvents()
    debug("Unregistering events")
    for _, event in ipairs(self.optionalEvents) do
        self.events:UnregisterEvent(event)
    end
end

function QuickAuras:Options_ToggleEnabled(value)
    self.db.profile.enabled = value
    if self.db.profile.enabled then
        self:RegisterOptionalEvents()
    else
        self:UnregisterOptionalEvents()
    end
end

function QuickAuras:HandleSlashCommand(input)
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

function QuickAuras:ScanBag(bag)
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

function QuickAuras:ScanBags()
    self.bags = {}
    for bag = 0, NUM_BAG_SLOTS do -- Iterate through all bags (0 is the backpack)
        self:ScanBag(bag)
    end
end

function QuickAuras:ScanBank()
    if not self.bankOpen then return end
    debug("Scanning bank")
    QuickAurasDB.bank = {}
    QuickAuras.bank = QuickAurasDB.bank
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
    return QuickAuras:UpdateProgressBar(timer)
end
