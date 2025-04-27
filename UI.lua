local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug
local pbId = 0

-- General -----------------------------------------------------------

function MeleeUtils:InitUI()
    debug("Initializing UI")
    MeleeUtils_Parry_Texture:SetVertexColor(1, 0, 0)
    MeleeUtils_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)

    --self:SetDarkBackdrop(MeleeUtils_WatchBars)
    --self:DisableDarkBackdrop(MeleeUtils_WatchBars)
    MeleeUtils_WatchBars_Text:Hide()

    --self:SetDarkBackdrop(MeleeUtils_OffensiveBars)
    --self:DisableDarkBackdrop(MeleeUtils_OffensiveBars)
    MeleeUtils_OffensiveBars_Text:Hide()

    --self:SetDarkBackdrop(MeleeUtils_Cooldowns)
    --self:DisableDarkBackdrop(MeleeUtils_Cooldowns)
    MeleeUtils_Cooldowns_Text:Hide()

    --self:CreateProgressBar(MeleeUtils_Flurry, 25, 2, {0.9, 0.6, 0}, "Interface\\Icons\\Ability_Warrior_PunishingBlow")
    --MeleeUtils_Flurry:Show()
    --MeleeUtils_Flurry_Progress_Bar:SetValue(1)
end

function MeleeUtils:ResetRogueWidgets()
    --MeleeUtils_Combo_Texture:ClearAllPoints()
    --MeleeUtils_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --MeleeUtils_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)

    --MeleeUtils_Parry_Texture:ClearAllPoints()
    --MeleeUtils_Parry_Texture:SetSize(128, 128)
    --MeleeUtils_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

end

function MeleeUtils:SetDarkBackdrop(frame)
    frame:SetBackdrop ({bgFile = [[Interface\AddOns\MeleeUtils\assets\background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function MeleeUtils:DisableDarkBackdrop(frame)
    frame:SetBackdrop (nil)
end


-- Progress Bar -----------------------------------------------------------

function MeleeUtils:CreateProgressBar(parent, list, index, height, padding, color, icon)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "MeleeUtils_PB"..tostring(pbId), parent, "MeleeUtils_StatusBar")
    debug("Created progress bar", "name", frame:GetName(), "index", index, "parent", parent)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8, -- Border thickness
        insets   = { left = padding, right = padding, top = padding, bottom = padding } -- Padding
    })
    frame:SetBackdropBorderColor(unpack(color)) -- Red border
    frame:SetBackdropColor(0, 0, 0, 0.5) -- Black background with 50% opacity

    local iconFrame = _G[frame:GetName().."_Icon"]
    local barFrame  = _G[frame:GetName().."_Progress_Bar"]
    local progFrame = _G[frame:GetName().."_Progress"]

    progFrame:ClearAllPoints()
    progFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 0, 0)
    progFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, 2)

    barFrame:SetStatusBarColor(unpack(color))

    iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    iconFrame.icon:SetTexture(icon)
    iconFrame:SetSize(height-padding*2, height-padding*2)
    iconFrame.icon:SetSize(height-padding*2, height-padding*2)

    return frame
end

function MeleeUtils:ArrangeProgressBars(list, parent, height, gap)
    local lastFrame = nil
    for i, timer in ipairs(list) do
        timer.frame:ClearAllPoints()
        if lastFrame then
            timer.frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -(gap or -2))
        else
            timer.frame:SetPoint("TOP", parent, "TOP", 0, 0)
        end
        timer.frame:SetPoint("LEFT", parent, "LEFT", 0, 0)
        timer.frame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        timer.frame:SetHeight(height)
        lastFrame = timer.frame
    end
end

function MeleeUtils:UpdateProgressBar(timer)
    --debug("Updating progress for", timer.name, "expTime", timer.expTime, "duration", timer.duration)
    if timer.duration > 0 and timer.expTime > GetTime() then
        timer.frame:Show()
        local progress = (timer.expTime - GetTime()) / timer.duration
        _G[timer.frame:GetName().."_Progress_Bar"]:SetValue(progress)
        return true
    else
        timer.frame:Hide()
        return false
    end
end


-------------------------------------------------------------

function MeleeUtils:Rogue_SetCombo(n)
    if n < 5 then
        MeleeUtils_Combo:Hide()
    else
        MeleeUtils_Combo:Show()
    end
end

function MeleeUtils:ShowParry()
    MeleeUtils_Parry:Show()
    C_Timer.After(1, function()
        MeleeUtils_Parry:Hide()
    end)
end

local lastErrorTime = 0
local errorCount = 0
function MeleeUtils:ShowNoticableError(text)
    MeleeUtils_OutOfRange_Text:SetText(string.upper(text))
    MeleeUtils_OutOfRange:Show()
    if self.db.profile.outOfRangeSound then
        if GetTime() - lastErrorTime > 6 then
            errorCount = 0
        end
        lastErrorTime = GetTime()
        if errorCount == 1 then
            PlaySoundFile("Interface\\AddOns\\MeleeUtils\\assets\\sonar.ogg", "Master")
        elseif errorCount == 4 then
            errorCount = 0
        end
        errorCount = errorCount + 1
    end
    C_Timer.After(1, function()
        MeleeUtils_OutOfRange:Hide()
    end)
end

-- Test UI -----------------------------------------------------------

function MeleeUtils:TestProgressBar(abilities)
    for i, conf in pairs(abilities) do
        if conf.list then
            local duration = math.min(conf.duration or 10, 15)
            local expTime = GetTime() + duration
            self:SetProgressTimer("progress", conf.list, conf.parent, conf, duration, expTime, conf.onUpdate, conf.onUpdate)
        end
    end
end

function MeleeUtils:TestWatchBars()
    self:TestProgressBar(self.watchBarAuras)
    self:TestProgressBar(self.watchBarCombatLog)
end

function MeleeUtils:TestButtons()
    local t = 0
    for i, conf in pairs(self.trackedCooldowns) do
        self:SetProgressTimer("button", self.cooldowns, MeleeUtils_Cooldowns, conf, 15-t, GetTime()+15-t, conf.onUpdate, conf.onUpdate)
        t = t + 1
    end
end
