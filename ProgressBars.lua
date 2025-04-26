local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug
local pbId = 0
local pbCount = 0

function MeleeUtils:CreateStatusBar(index, height, padding, color, icon)
    local frame
    if type(index) == "table" then
        frame = index
    else
        pbId = pbId + 1
        frame = CreateFrame("Frame", "MeleeUtils_PB"..tostring(pbId), UIParent, "MeleeUtils_StatusBar")
        debug("Created progress bar", "name", frame:GetName(), "index", index)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, -180 - (index * (height + padding)))
    end
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

function MeleeUtils:UpdateProgress(timer)
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

-- Timers ------------------------

function MeleeUtils:AddProgressTimer(progressSpell, duration, expTime, onUpdate, onEnd)
    local existingTimer = self.timerByName[progressSpell.name]
    local index = pbCount
    if existingTimer then
        if existingTimer.expTime == expTime and existingTimer.name == progressSpell.name then
            return -- already exists
        end
        -- different timer, remove old
        self:RemoveProgressTimer(existingTimer)
        debug("Replacing timer", "name", progressSpell.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug("Adding timer", "name", progressSpell.name, "expTime", expTime)
        pbCount = pbCount + 1
        index = pbCount - 1
    end

    local frame = self:CreateStatusBar(index, 25, 2, progressSpell.color, progressSpell.icon)
    local timer = {
        frame = frame,
        index = index,
        name = progressSpell.name,
        icon = progressSpell.icon,
        color = progressSpell.color,
        expTime = expTime,
        duration = duration,
        onUpdate = onUpdate,
        onEnd = onEnd,
    }
    local key = progressSpell.name..tostring(expTime)
    self.timers[key] = timer
    self.timerByName[progressSpell.name] = timer
end

function MeleeUtils:RemoveProgressTimer(timer)
    debug("Removing timer", "name", timer.name, "expTime", timer.expTime)
    local key = timer.name..tostring(timer.expTime)
    if timer.onEnd then
        timer:onEnd(timer)
    end
    if self.timers[key] then
        timer.frame:Hide()
        timer.frame:SetParent(nil)
        timer.frame:ClearAllPoints()
        timer.frame = nil
        self.timers[key] = nil
        self.timerByName[timer.name] = nil
    end
    pbCount = pbCount - 1
end

function MeleeUtils:CheckProgressTimers()
    for key, timer in pairs(self.timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                self:RemoveProgressTimer(timer)
            end
        end
    end
end
