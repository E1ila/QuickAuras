local VERSION = "1.0.0"
local VERSION_INT = 1.0000
local ADDON_NAME = "MeleeUtils"
local CREDITS = "by |cffb266ffKof|r @ |cffff2222Firemaw|r (era)"

local L = MeleeUtils_BuildLocalization()
local REALM = GetRealmName()

local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local DEFAULT_FONT_NAME = SharedMedia.MediaTable.font[SharedMedia.DefaultMedia.font]

MeleeUtils = CreateFrame("Frame", "MeleeUtils")
MeleeUtils:RegisterEvent("ADDON_LOADED")
MeleeUtils.L = L
MeleeUtils.Version = VERSION
MeleeUtils.AddonName = ADDON_NAME

MeleeUtilsGlobalVars = {
    debug = false,
    fontName = DEFAULT_FONT_NAME,
    ver = VERSION_INT,
}

MeleeUtilsVars = {
    enabled = true,
}

local function out(text, ...)
    print(" |cffff8800{|cffffbb00MeleeUtils|cffff8800}|r", text, ...)
end
MeleeUtils.out = out

local function debug(...)
    if MeleeUtilsGlobalVars.debug then
        out(...)
    end
end
MeleeUtils.debug = debug

function MeleeUtils:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    out("|cffffbb00v" .. tostring(VERSION) .. "|r " .. CREDITS .. ", " .. L["loaded-welcome"]);

    -- Options UI
    MeleeUtils.InterfacePanel:AddonLoaded()

    MeleeUtils:SetScript("OnUpdate", function(self, ...)
        MeleeUtils:OnUpdate(...)
    end)
end

MeleeUtils:SetScript("OnEvent", function(self, event, a, b, ...)
    MeleeUtils[event](self, a, b, ...)
end)

function MeleeUtils:OnUpdate()
end

