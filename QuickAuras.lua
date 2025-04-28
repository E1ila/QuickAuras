-- QuickAuras.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("QuickAuras", "AceConsole-3.0")
local QuickAuras = addon.root
QuickAuras.version = "1.0"
QuickAuras.events = CreateFrame("Frame")
QuickAuras.timers = {}
QuickAuras.timerByName = {}
QuickAuras.watchBars = {}
QuickAuras.offensiveBars = {}
QuickAuras.cooldowns = {}
QuickAuras.iconWarnings = {}
QAG = QuickAuras

QuickAuras.playerClass = select(2, UnitClass("player"))
QuickAuras.playerRace = select(1, UnitRace("player"))
QuickAuras.playerGuid = UnitGUID("player")
QuickAuras.isRogue = QuickAuras.playerClass == "ROGUE"
QuickAuras.isWarrior = QuickAuras.playerClass == "WARRIOR"
QuickAuras.isPaladin = QuickAuras.playerClass == "PALADIN"
QuickAuras.isShaman = QuickAuras.playerClass == "SHAMAN"
QuickAuras.isMage = QuickAuras.playerClass == "MAGE"
QuickAuras.isWarlock = QuickAuras.playerClass == "WARLOCK"
QuickAuras.isHunter = QuickAuras.playerClass == "HUNTER"
QuickAuras.isDruid = QuickAuras.playerClass == "DRUID"
QuickAuras.isPriest = QuickAuras.playerClass == "PRIEST"
QuickAuras.isOrc = QuickAuras.playerRace == "Orc"
local _c

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
QuickAuras.Print = out

local function debug(text, ...)
    if QuickAurasDB and QuickAurasDB.debug then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cff009999DEBUG|cff999999", text, ...)
    end
end
QuickAuras.Debug = debug

function QuickAuras:OnInitialize()
    debug("Initializing...")
    _c = self.colors

    QuickAuras:BuildTrackedSpells()
    QuickAuras:BuildOptions()

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
        local cmd = input:trim():lower()
        if cmd == "debug" then
            QuickAurasDB.debug = not QuickAurasDB.debug
            if QuickAurasDB.debug then
                out("Debug mode ".._c.enabled.."enabled|r") -- Green text
            else
                out("Debug mode ".._c.disabled.."disabled|r") -- Orange text
            end
        elseif cmd == "test" then
            self:TestWatchBars()
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

function QuickAuras_Timer_OnUpdate(timer)
    return QuickAuras:UpdateProgressBar(timer)
end
