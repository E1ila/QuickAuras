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

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        someSetting = 50,
    },
}

-- Options table for the settings page
local options = {
    name = "Melee Utils",
    handler = MeleeUtils,
    type = "group",
    args = {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return MeleeUtils.db.profile.enabled end,
            set = function(info, value) MeleeUtils.db.profile.enabled = value end,
        },
        someSetting = {
            type = "range",
            name = "Some Setting",
            desc = "Adjust some setting",
            min = 1,
            max = 100,
            step = 1,
            get = function(info) return MeleeUtils.db.profile.someSetting end,
            set = function(info, value) MeleeUtils.db.profile.someSetting = value end,
        },
        rogue = {
            type = "group",
            name = "Rogue Options",
            desc = "Settings specific to rogues",
            args = {
                someSetting = {
                    type = "range",
                    name = "Some Setting",
                    desc = "Adjust some setting",
                    min = 1,
                    max = 100,
                    step = 1,
                    get = function(info) return true end,
                    set = function(info, value)  end,
                },
            },
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
    C_Timer.After(0.2, function()
        MeleeUtils:InitUI()
        MeleeUtils:LoadConfig()
        MeleeUtils:RegisterEvents()
        out("MeleeUtils loaded. Type " .. c.bold .. "/mu|r for options.")
    end)
end

function MeleeUtils:RegisterEvents()
    debug("Registering events")
    MeleeUtils.events:SetScript("OnEvent", function(self, event, unit, powerType)
        MeleeUtils[event](self, unit, powerType)
    end)

    MeleeUtils.events:RegisterEvent("UNIT_POWER_UPDATE")
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
    MeleeUtils_Rogue:InitRogueUI()
end

function MeleeUtils:LoadConfig()
    debug("Loading config")
end

-- Event

function MeleeUtils:UNIT_POWER_UPDATE(unit, powerType)
    if unit == "player" and powerType == "COMBO_POINTS" then
        local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
        MeleeUtils_Rogue:Rogue_SetCombo(comboPoints)
    end
end
