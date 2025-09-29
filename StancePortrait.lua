-- StancePortrait.lua
-- Displays rounded stance icons on player portrait for warriors
local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

-- Only initialize for warriors
if not QA.isWarrior then return end

QA.StancePortrait = {}
local SP = QA.StancePortrait

-- Store original portrait texture
SP.originalPortraitModel = nil
SP.isPortraitHooked = false
SP.currentStance = 0

-- Stance texture cache
SP.stanceTextures = {}

function SP:GetStanceTexture(stanceIndex)
    -- Cache stance textures for performance
    if not self.stanceTextures[stanceIndex] then
        local texture, name, isActive, isCastable = GetShapeshiftFormInfo(stanceIndex)
        if texture then
            self.stanceTextures[stanceIndex] = texture
            debug(2, "StancePortrait", "Cached stance texture", stanceIndex, name, texture)
        end
    end
    return self.stanceTextures[stanceIndex]
end

function SP:ApplyStancePortrait(stanceIndex)
    -- Check if feature is enabled
    if not QA.db or not QA.db.profile.warriorStancePortrait then
        return
    end

    if not PlayerFrame or not PlayerFrame.portrait then
        debug(2, "StancePortrait", "PlayerFrame or portrait not available")
        return
    end

    -- Store original if first time
    if not self.originalPortraitModel and not self.isPortraitHooked then
        -- Save the original SetUnit function to restore later
        self.isPortraitHooked = true
        debug(2, "StancePortrait", "Hooked player portrait")
    end

    if stanceIndex and stanceIndex > 0 then
        -- Get stance texture
        local texture = self:GetStanceTexture(stanceIndex)
        if texture then
            -- Apply rounded stance icon
            SetPortraitToTexture(PlayerFrame.portrait, texture)
            self.currentStance = stanceIndex
            debug(2, "StancePortrait", "Applied stance portrait", stanceIndex, texture)
        else
            debug(1, "StancePortrait", "Failed to get texture for stance", stanceIndex)
        end
    else
        -- No stance active, restore default portrait
        self:RestorePortrait()
    end
end

function SP:RestorePortrait()
    if PlayerFrame and PlayerFrame.portrait then
        -- Restore default 3D portrait
        SetPortraitTexture(PlayerFrame.portrait, "player")
        self.currentStance = 0
        debug(2, "StancePortrait", "Restored default portrait")
    end
end

function SP:UpdatePortrait()
    -- Check if feature is disabled, restore default portrait
    if not QA.db or not QA.db.profile.warriorStancePortrait then
        if self.currentStance ~= 0 then
            self:RestorePortrait()
        end
        return
    end

    local stanceIndex = GetShapeshiftForm()

    -- Only update if stance changed
    if stanceIndex ~= self.currentStance then
        self:ApplyStancePortrait(stanceIndex)
    end
end

function SP:Initialize()
    debug(2, "StancePortrait", "Initializing warrior stance portraits")

    -- Apply initial stance portrait
    C_Timer.After(0.5, function()
        self:UpdatePortrait()
    end)
end

function SP:OnShapeshiftFormChanged()
    self:UpdatePortrait()
end

-- Initialize on load
C_Timer.After(1, function()
    SP:Initialize()
end)