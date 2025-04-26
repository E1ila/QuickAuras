local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug
local pbId = 0

function MeleeUtils_Timer_OnUpdate(timer)
    return MeleeUtils:UpdateProgressBar(timer)
end

function MeleeUtils:CreateProgressBar(parent, list, index, height, padding, color, icon, gap)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "MeleeUtils_PB"..tostring(pbId), parent, "MeleeUtils_StatusBar")
    debug("Created progress bar", "name", frame:GetName(), "index", index)
    if index > 0 then
        local lastFrame = list[index].frame
        frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -gap)
    else
        frame:SetPoint("TOP", parent, "TOP", 0, 0)
    end
    frame:SetPoint("LEFT", parent, "LEFT", 0, 0)
    frame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    frame:SetHeight(height)
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

-- Timers ------------------------

function MeleeUtils:SetProgressTimer(progressSpell, duration, expTime, onUpdate, onEnd)
    local list = progressSpell.list
    local existingTimer = self.timerByName[progressSpell.name]
    local index = #list
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
    end

    local frame = self:CreateProgressBar(MeleeUtils_BuffProgress, list, index, 25, 2, progressSpell.color, progressSpell.icon, 0)
    local timer = {
        frame = frame,
        index = index,
        list = list,
        name = progressSpell.name,
        icon = progressSpell.icon,
        color = progressSpell.color,
        expTime = expTime,
        duration = duration,
        onUpdate = onUpdate,
        onEnd = onEnd,
    }
    timer.key = self:GetTimerKey(timer)
    table.insert(list, timer)
    self.timers[timer.key] = timer
    self.timerByName[progressSpell.name] = timer
    onUpdate(timer)
    return timer
end

function MeleeUtils:GetTimerKey(timer)
    return timer.name..tostring(timer.expTime)
end

function MeleeUtils:RemoveProgressTimer(timer)
    debug("Removing timer", "name", timer.name, "expTime", timer.expTime)
    if timer.onEnd then
        timer:onEnd(timer)
    end
    -- remove from timers the one with matching name and expTime
    for i, t in ipairs(timer.list) do
        if t.name == timer.name and t.expTime == timer.expTime then
            table.remove(timer.list, i)
            break
        end
    end
    timer.frame:Hide()
    timer.frame:SetParent(nil)
    timer.frame:ClearAllPoints()
    timer.frame = nil
    self.timerByName[timer.name] = nil
    self.timers[timer.key] = nil
end

function MeleeUtils:CheckProgressTimers()
    for _, timer in pairs(self.timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                self:RemoveProgressTimer(timer)
            end
        end
    end
end
