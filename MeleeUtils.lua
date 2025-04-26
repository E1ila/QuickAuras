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

local optionalEvents = {
    "UNIT_POWER_UPDATE",
    --"COMBAT_LOG_EVENT_UNFILTERED",
    --"UNIT_AURA",
}

local adjustableFrames = {
    "MeleeUtils_Parry",
    "MeleeUtils_Combo",
    "MeleeUtils_Flurry",
}

local progressSpells = {
    [13877] = {
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
    },
    [13750] = {
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Ability_Rogue_AdrenalineRush",
        color = {246/256, 220/256, 0},
    },
    [6774] = {
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
    },
}

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        someSetting = 50,
        rogue5combo = true,
        harryPaste = true,
        spellProgress = true,
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
    AceConfig:RegisterOptionsTable("MeleeUtils", MeleeUtils.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MeleeUtils", "Melee Utils")
    self:RegisterChatCommand("mu", "HandleSlashCommand")
    MeleeUtils.events:SetScript("OnEvent", function(self, event, unit, powerType)
        MeleeUtils[event](self, unit, powerType)
    end)
    MeleeUtils.events:SetScript("OnUpdate", function()
        MeleeUtils:OnUpdate()
    end)
    MeleeUtils:RegisterMandatoryEvents()
    C_Timer.After(0.2, function()
        debug("Init delay ended")
        MeleeUtils:InitUI()
        MeleeUtils:LoadConfig()
        MeleeUtils:RegisterOptionalEvents()
        MeleeUtils:CheckAuras()
        out("MeleeUtils loaded. Type " .. c.bold .. "/mu|r for options.")
    end)
end

function MeleeUtils:RegisterMandatoryEvents()
    debug("Registering mandatory events")
    MeleeUtils.events:RegisterEvent("ZONE_CHANGED")
    MeleeUtils.events:RegisterEvent("ZONE_CHANGED_INDOORS")
    MeleeUtils.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    MeleeUtils.events:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function MeleeUtils:RegisterOptionalEvents()
    if MeleeUtils.db.profile.enabled  then
        debug("Registering events")
        for _, event in ipairs(optionalEvents) do
            MeleeUtils.events:RegisterEvent(event)
        end
    end
end

function MeleeUtils:UnregisterOptionalEvents()
    debug("Unregistering events")
    for _, event in ipairs(optionalEvents) do
        MeleeUtils.events:UnregisterEvent(event)
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
        elseif cmd == "lock" then
            MeleeUtils:ToggleLockedState()
        elseif cmd == "reset" then
            MeleeUtils:ResetWidgets()
        else
            out("Unknown command. Use '/mu' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end

function MeleeUtils:InitUI()
    debug("Initializing UI")
    MeleeUtils:InitGeneralUI()
    MeleeUtils:InitRogueUI()
end

function MeleeUtils:LoadConfig()
    debug("Loading config")
end

function MeleeUtils:Options_ToggleEnabled(value)
    MeleeUtils.db.profile.enabled = value
    if MeleeUtils.db.profile.enabled then
        MeleeUtils:RegisterOptionalEvents()
    else
        MeleeUtils:UnregisterOptionalEvents()
    end
end

function MeleeUtils:ToggleLockedState()
    _uiLocked = not _uiLocked
    for _, frame in ipairs(adjustableFrames) do
        local f = _G[frame]
        if f then
            f:EnableMouse(not _uiLocked)
            if _uiLocked then f:Hide() else f:Show() end
        end
    end
    out("Frames are now "..(_uiLocked and c.disabled.."locked|r" or c.enabled.."unlocked|r"))
end

function MeleeUtils:ResetWidgets()
    debug("Resetting widgets")
    MeleeUtils:ResetGeneralWidgets()
    MeleeUtils:ResetRogueWidgets()
end

-- Events

function MeleeUtils:CheckAuras()
    if not MeleeUtils.db.profile.spellProgress then return end
    local i = 1
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        --debug(UnitAura("player", i, "HELPFUL"))
        if not name then break end -- Exit the loop when no more auras are found
        local progressSpell = progressSpells[spellID]
        if progressSpell then
            --debug("Aura", name, icon, duration, expTime)
            local onUpdate = function(timer)
                return MeleeUtils:UpdateProgress(timer)
            end
            MeleeUtils:AddTimer(progressSpell, duration, expTime, onUpdate, onUpdate)
        end
        i = i + 1
    end
end

-- Events

function MeleeUtils:UNIT_POWER_UPDATE(unit, powerType)
    if _isRogue and MeleeUtils.db.profile.rogue5combo then
        if unit == "player" and powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            MeleeUtils:Rogue_SetCombo(comboPoints)
        end
    end
end

function MeleeUtils:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, p1, p2, p3 = CombatLogGetCurrentEventInfo()

    if  -- parry haste
        MeleeUtils.db.profile.harryPaste and
        subevent == "SWING_MISSED" and
        sourceGUID == _playerGuid and
        p1 == "PARRY" and -- missType
        destGUID == UnitGUID("target") and
        _playerGuid ~= UnitGUID("targettarget") and
        not UnitIsPlayer("target") and
        IsInInstance()
    then
        MeleeUtils:ShowParry()
    end
end

function MeleeUtils:ZONE_CHANGED()
    MeleeUtils:UpdateZone()
end

function MeleeUtils:ZONE_CHANGED_INDOORS()
    MeleeUtils:UpdateZone()
end

function MeleeUtils:ZONE_CHANGED_NEW_AREA()
    MeleeUtils:UpdateZone()
end

function MeleeUtils:PLAYER_ENTERING_WORLD()
    MeleeUtils:UpdateZone()
end

function MeleeUtils:UNIT_AURA(unit)
    if unit ~= "player" then return end
    MeleeUtils:CheckAuras()
end

-- OnUpdate

local lastUpdate = 0
local updateInterval = 0.1 -- Execute every 0.1 seconds

function MeleeUtils:OnUpdate()
    local currentTime = GetTime()
    if MeleeUtils.db.profile.spellProgress and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        MeleeUtils:CheckTimers()
    end
end
