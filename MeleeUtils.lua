-- MeleeUtils.lua
local ADDON_NAME, MeleeUtils = ...

-- Load Ace3 libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local _ = LibStub("AceConsole-3.0")

MeleeUtils = AceAddon:NewAddon("MeleeUtils", "AceConsole-3.0")
MeleeUtils.events = CreateFrame("Frame")
MUGLOBAL = MeleeUtils

local _class = select(2, UnitClass("player"))
local _playerGuid = UnitGUID("player")
local _isRogue = _class == "ROGUE"

local EVENTS = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
}

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        someSetting = 50,
        rogue5combo = true,
        harryPaste = true,
    },
}

-- Options table for the settings page
local options = {
    name = "Melee Utils",
    handler = MeleeUtils,
    type = "group",
    childGroups = "tab",
    args = {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return MeleeUtils.db.profile.enabled end,
            set = function(info, value) MeleeUtils:Options_ToggleEnabled(value) end,
        },
        harryPaste = {
            type = "toggle",
            name = "Harry Paste",
            desc = "Warn when a mob parries your attack while being tanked",
            get = function(info) return MeleeUtils.db.profile.harryPaste end,
            set = function(info, value) MeleeUtils.db.profile.harryPaste = value end,
        },
        rogueUtils = {
            type = "group",
            name = "Rogue Utils",
            args = {
                rogue5Combo = {
                    type = "toggle",
                    name = "5 Combo Points",
                    desc = "Shows a visible indication when you have 5 combo points.",
                    get = function(info) return MeleeUtils.db.profile.rogue5combo end,
                    set = function(info, value) MeleeUtils.db.profile.rogue5combo = value end,
                },
            }
        },
    },
}

local function out(text, ...)
    print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cffaaeeff"..text, ...)
end
MeleeUtils.Print = out

local function debug(text, ...)
    if MeleeUtilsDB.debug then
        print("|cff0088ff{|cff00bbff"..ADDON_NAME.."|cff0088ff}|r |cff009999DEBUG|cff999999", text, ...)
    end
end
MeleeUtils.Debug = debug

local c = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}
MeleeUtils.Colors = c

function MeleeUtils:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MeleeUtilsDB", defaults, true)
    AceConfig:RegisterOptionsTable("MeleeUtils", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MeleeUtils", "Melee Utils")
    self:RegisterChatCommand("mu", "HandleSlashCommand")
    MeleeUtils.events:SetScript("OnEvent", function(self, event, unit, powerType)
        MeleeUtils[event](self, unit, powerType)
    end)
    C_Timer.After(0.2, function()
        MeleeUtils:InitUI()
        MeleeUtils:LoadConfig()
        MeleeUtils:RegisterEvents()
        out("MeleeUtils loaded. Type " .. c.bold .. "/mu|r for options.")
    end)
end

function MeleeUtils:RegisterEvents()
    if MeleeUtils.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(EVENTS) do
            MeleeUtils.events:RegisterEvent(event)
        end
    end
end

function MeleeUtils:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open("MeleeUtils")
    else
        local cmd = input:trim():lower()
        if cmd == "debug" then
            MeleeUtilsDB.debug = not MeleeUtilsDB.debug
            if MeleeUtilsDB.debug then
                out("Debug mode "..c.enabled.."enabled|r") -- Green text
            else
                out("Debug mode "..c.disabled.."disabled|r") -- Orange text
            end
        else
            out("Unknown command. Use '/mu' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end

function MeleeUtils:InitUI()
    debug("Initializing UI")
    MeleeUtils_UI:InitGeneralUI()
    MeleeUtils_UI:InitRogueUI()
end

function MeleeUtils:LoadConfig()
    debug("Loading config")
end

function MeleeUtils:Options_ToggleEnabled(value)
    MeleeUtils.db.profile.enabled = value
    if MeleeUtils.db.profile.enabled then
        MeleeUtils:RegisterEvents()
    else
        debug("Unregistering events")
        MeleeUtils.events:UnregisterAllEvents()
    end
end

-- Events

function MeleeUtils:UNIT_POWER_UPDATE(unit, powerType)
    if _isRogue and MeleeUtils.db.profile.rogue5combo then
        if unit == "player" and powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            MeleeUtils_UI:Rogue_SetCombo(comboPoints)
        end
    end
end

function MeleeUtils:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ = CombatLogGetCurrentEventInfo()

    --debug("Combat Log Event:", sourceGUID, sourceName, destGUID, subevent, missType, UnitGUID("target"), UnitGUID("targettarget"), _playerGuid)

    if MeleeUtils.db.profile.harryPaste and subevent == "SWING_MISSED" and sourceGUID == _playerGuid then
        local missType = select(12, CombatLogGetCurrentEventInfo())
        if missType == "PARRY" and destGUID == UnitGUID("target") and _playerGuid ~= UnitGUID("targettarget") then
            MeleeUtils_UI:ShowParry()
        end
    end

    -- Example: Filter for SPELL_DAMAGE events
    --if subevent == "SPELL_DAMAGE" then
    --    print("Spell Damage Event:")
    --    print("Source:", sourceName, "Target:", destName, "Spell:", spellName, "Amount:", amount)
    --end
end
