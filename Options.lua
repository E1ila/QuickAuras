local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

MeleeUtils.defaultOptions = {
    profile = {
        enabled = true,
        someSetting = 50,
        rogue5combo = true,
        rogueEaBar = true,
        rogueSndBar = true,
        rogueFlurryBar = true,
        rogueArBar = true,
        harryPaste = true,
        watchBars = true,
    },
}

MeleeUtils.options = {
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
        watchBars = {
            type = "toggle",
            name = "Watch Bars",
            desc = "Show a progress bar with time left on important abilities",
            get = function(info) return MeleeUtils.db.profile.watchBars end,
            set = function(info, value) MeleeUtils.db.profile.watchBars = value end,
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
                rogueEaBar = {
                    type = "toggle",
                    name = "Watch Expose Armor",
                    desc = "Shows a watch bar for Expose Armor.",
                    get = function(info) return MeleeUtils.db.profile.rogueEaBar end,
                    set = function(info, value) MeleeUtils.db.profile.rogueEaBar = value end,
                },
                rogueSndBar = {
                    type = "toggle",
                    name = "Watch Slice and Dice",
                    desc = "Shows a watch bar for Slice and Dice.",
                    get = function(info) return MeleeUtils.db.profile.rogueSndBar end,
                    set = function(info, value) MeleeUtils.db.profile.rogueSndBar = value end,
                },
                rogueFlurryBar = {
                    type = "toggle",
                    name = "Watch Flurry Bar",
                    desc = "Shows a watch bar for Flurry.",
                    get = function(info) return MeleeUtils.db.profile.rogueFlurryBar end,
                    set = function(info, value) MeleeUtils.db.profile.rogueFlurryBar = value end,
                },
                rogueArBar = {
                    type = "toggle",
                    name = "Watch Adrenaline Rush",
                    desc = "Shows a watch bar for Adrenaline Rush.",
                    get = function(info) return MeleeUtils.db.profile.rogueArBar end,
                    set = function(info, value) MeleeUtils.db.profile.rogueArBar = value end,
                },
                --eaAnnounce = {
                --    type = "toggle",
                --    name = "IEA Announce",
                --    desc = "Informs the raid in /s once you've applied IEA.",
                --    get = function(info) return MeleeUtils.db.profile.eaAnnounce end,
                --    set = function(info, value) MeleeUtils.db.profile.eaAnnounce = value end,
                --},
            }
        },
    },
}

function MeleeUtils:Options_ToggleEnabled(value)
    self.db.profile.enabled = value
    if self.db.profile.enabled then
        self:RegisterOptionalEvents()
    else
        self:UnregisterOptionalEvents()
    end
end

function MeleeUtils:ToggleLockedState()
    _uiLocked = not _uiLocked
    for _, frame in ipairs(self.adjustableFrames) do
        local f = _G[frame]
        if f then
            f:EnableMouse(not _uiLocked)
            if _uiLocked then f:Hide() else f:Show() end
        end
    end
    out("Frames are now "..(_uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))
end

function MeleeUtils:ResetWidgets()
    debug("Resetting widgets")
    self:ResetGeneralWidgets()
    self:ResetRogueWidgets()
end

function MeleeUtils:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open("MeleeUtils")
    else
        local cmd = input:trim():lower()
        if cmd == "debug" then
            MeleeUtilsDB.debug = not MeleeUtilsDB.debug
            if MeleeUtilsDB.debug then
                out("Debug mode ".._c.enabled.."enabled|r") -- Green text
            else
                out("Debug mode ".._c.disabled.."disabled|r") -- Orange text
            end
        elseif cmd == "lock" then
            self:ToggleLockedState()
        elseif cmd == "reset" then
            self:ResetWidgets()
        else
            out("Unknown command. Use '/mu' to open the options or '/mu debug' to toggle debug mode.")
        end
    end
end
