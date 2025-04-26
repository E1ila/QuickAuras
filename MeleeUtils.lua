-- MeleeUtils.lua
local ADDON_NAME, addon = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

addon.root = AceAddon:NewAddon("MeleeUtils", "AceConsole-3.0")
local MeleeUtils = addon.root
MeleeUtils.events = CreateFrame("Frame")
MeleeUtils.timers = {}
MeleeUtils.timerByName = {}
MUGLOBAL = MeleeUtils

local _class = select(2, UnitClass("player"))
local _playerGuid = UnitGUID("player")
local _isRogue = _class == "ROGUE"
local _uiLocked = true
local _c

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
MeleeUtils.Print = out

local function debug(text, ...)
    if MeleeUtilsDB and MeleeUtilsDB.debug then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cff009999DEBUG|cff999999", text, ...)
    end
end
MeleeUtils.Debug = debug

function MeleeUtils:OnInitialize()
    debug("Initializing...")
    _c = self.colors
    self.db = LibStub("AceDB-3.0"):New("MeleeUtilsDB", self.defaultOptions, true)
    AceConfig:RegisterOptionsTable("MeleeUtils", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MeleeUtils", "Melee Utils")
    self:RegisterChatCommand("mu", "HandleSlashCommand")
    self.events:SetScript("OnEvent", function(self, event, unit, powerType)
        MeleeUtils[event](self, unit, powerType)
    end)
    self.events:SetScript("OnUpdate", function()
        MeleeUtils:OnUpdate()
    end)
    self:RegisterMandatoryEvents()
    C_Timer.After(0.2, function()
        debug("Init delay ended")
        MeleeUtils:InitUI()
        MeleeUtils:LoadConfig()
        MeleeUtils:RegisterOptionalEvents()
        MeleeUtils:CheckAuras()
        out("MeleeUtils loaded. Type " .. _c.bold .. "/mu|r for options.")
    end)
end

function MeleeUtils:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    self.events:RegisterEvent("ZONE_CHANGED")
    self.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    self.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function MeleeUtils:RegisterOptionalEvents()
    if self.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(self.optionalEvents) do
            self.events:RegisterEvent(event)
        end
    end
end

function MeleeUtils:UnregisterOptionalEvents()
    debug("Unregistering events")
    for _, event in ipairs(self.optionalEvents) do
        self.events:UnregisterEvent(event)
    end
end

function MeleeUtils:InitUI()
    debug("Initializing UI")
    self:InitGeneralUI()
    self:InitRogueUI()
end

function MeleeUtils:LoadConfig()
    debug("Loading config")
end
