-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QuickAuras = addon.root
QuickAuras.version = "0.3"
QuickAuras.events = CreateFrame("Frame")
QuickAuras.bags = {} -- items in bags
QAG = QuickAuras

-- managed timers
QuickAuras.timers = {} -- all active timers
QuickAuras.timerByName = {}
-- managed timers by frame type
QuickAuras.watchBars = {} -- timer obj
QuickAuras.offensiveBars = {} -- timer obj
QuickAuras.cooldowns = {} -- timer obj
QuickAuras.iconWarnings = {} -- item obj
QuickAuras.iconAlerts = {} -- timer obj
QuickAuras.missingBuffs = {} -- item obj

local pclass = select(2, UnitClass("player"))
QuickAuras.playerClass = pclass
QuickAuras.playerRace = select(1, UnitRace("player"))
QuickAuras.playerGuid = UnitGUID("player")
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
QuickAuras.isUndead = QuickAuras.playerRace == "Undead"
QuickAuras.isManaClass = QuickAuras.isPriest or QuickAuras.isMage or QuickAuras.isWarlock or QuickAuras.isDruid or QuickAuras.isPaladin or QuickAuras.isShaman or QuickAuras.isHunter
local _c

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
QuickAuras.Print = out

local function debug(text, ...)
    local minLevel = type(text) == "number" and text or 1
    if QuickAurasDB and QuickAurasDB.debug >= minLevel then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cff009999DEBUG|cff999999", text, ...)
    end
end
QuickAuras.Debug = debug

function QuickAuras:OnInitialize()
    debug("Initializing...")
    _c = self.colors

    self:InitAbilities()
    self:BuildTrackedGear()
    self:BuildTrackedSpells()
    self:BuildTrackedMissingBuffs()
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
        QuickAuras:ScanBags()
        QuickAuras:InitUI()
        QuickAuras:LoadConfig()
        QuickAuras:RegisterOptionalEvents()
        QuickAuras:CheckAuras()
        QuickAuras:CheckCooldowns()
        QuickAuras:CheckGear()
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

function QuickAuras:LoadConfig()
    debug("Loading config")
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
            if QuickAurasDB.debug > 0 and not arg1 then
                level = 0
            else
                level = arg1 and tonumber(arg1) or 1
            end
            QuickAurasDB.debug = level
            if level > 0 then
                out("Debug mode ".._c.enabled.."enabled|r", "("..tostring(level)..")") -- Green text
            else
                out("Debug mode ".._c.disabled.."disabled|r") -- Orange text
            end
        elseif cmd == "test" then
            self:TestBars()
            self:TestCooldowns()
        elseif cmd == "lock" then
            self:ToggleLockedState()
        elseif cmd == "reset" then
            self:ResetWidgets()
        else
            out("Unknown command. Use '/qa' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end

function QuickAuras:ScanBag(bag)
    for slot = 1, C_Container.GetContainerNumSlots(bag) do -- Iterate through all slots in the bag
        local id = C_Container.GetContainerItemID(bag, slot)
        if id ~= nil then
            self.bags[id] = { bag = bag, slot = slot }
        end
    end
end

function QuickAuras:ScanBags()
    self.bags = {}
    for bag = 0, NUM_BAG_SLOTS do -- Iterate through all bags (0 is the backpack)
        self:ScanBag(bag)
    end
end

function QuickAuras_Timer_OnUpdate(timer)
    return QuickAuras:UpdateProgressBar(timer)
end
