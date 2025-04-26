local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug

function MeleeUtils:InitStatusBar(frame, height, padding, color, icon)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8, -- Border thickness
        insets = { left = padding, right = padding, top = padding, bottom = padding } -- Padding
    })
    frame:SetBackdropBorderColor(unpack(color)) -- Red border
    frame:SetBackdropColor(0, 0, 0, 0.5) -- Black background with 50% opacity

    local iconFrame = _G[frame:GetName().."_Icon"]
    local barFrame = _G[frame:GetName().."_Progress_Bar"]
    local progFrame = _G[frame:GetName().."_Progress"]

    progFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 0, 0)
    progFrame:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMRIGHT", 0, 0)
    progFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", padding, 0)
    progFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", padding, 0)

    barFrame:SetStatusBarColor(unpack(color))

    iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    iconFrame.icon:SetTexture(icon)
    iconFrame:SetSize(height-padding*2, height-padding*2)
    iconFrame.icon:SetSize(height-padding*2, height-padding*2)
end

function MeleeUtils:UpdateProgress(timer)
    debug("Updating progress for", timer.name, "expTime", timer.expTime, "duration", timer.duration)
    if timer.duration > 0 and timer.expTime > GetTime() then
        MeleeUtils_Flurry:Show()
        local progress = (timer.expTime - GetTime()) / timer.duration
        MeleeUtils_Flurry_Progress_Bar:SetValue(progress)
        return true
    else
        MeleeUtils_Flurry:Hide()
        return false
    end
end
