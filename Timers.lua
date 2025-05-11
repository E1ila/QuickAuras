local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local ICON = QuickAuras.ICON

function QuickAuras:AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
    local arrangeFunc = self.ArrangeTimerBars
    local uiType, list, parent, height
    local widthMul = 1
    keyExtra = keyExtra or ""
    if timerType == "raidbar" then
        list = self.list_raidBars
        parent = QuickAuras_RaidBars
        uiType = "bar"
        height = self.db.profile.raidBarHeight
    elseif timerType == "test-cooldowns" or timerType == "cooldowns" then
        list = self.list_cooldowns
        parent = QuickAuras_Cooldowns
        uiType = "button"
    elseif conf.list == "watch" then
        list = self.list_watchBars
        parent = QuickAuras_WatchBars
        uiType = "bar"
    elseif conf.list == "offensive" then
        list = self.list_offensiveBars
        parent = QuickAuras_OffensiveBars
        uiType = "bar"
        widthMul = 1.5
    elseif conf.list == "alert" then
        list = self.list_iconAlerts
        parent = QuickAuras_IconAlerts
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons(ICON.ALERT) end
    elseif timerType == "reminder" or conf.list == "reminder" then
        list = self.list_reminders
        parent = QuickAuras_Reminders
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons(ICON.REMINDER) end
    elseif timerType == "crucial" or conf.list == "crucial" then
        list = self.list_crucial
        parent = QuickAuras_Crucial
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons(ICON.CRUCIAL) end
    end
    if not parent then parent = UIParent end
    local onUpdate = conf.onUpdate or QuickAuras_Timer_OnUpdate
    local onEnd = conf.onEnd or QuickAuras_Timer_OnUpdate

    local index = 0
    for _ in pairs(list) do
        index = index + 1
    end

    local existingTimer = self.list_timerByName[conf.name.."-"..uiType]
    if existingTimer then
        if existingTimer.expTime == expTime and existingTimer.name == conf.name then
            --debug("Timer already exists", "name", conf.name, "ui", uiType, "expTime", expTime)
            return existingTimer -- already exists
        end
        -- different timer, remove old
        self:RemoveTimer(existingTimer, "replaced")
        --debug("Replacing", uiType, "timer", "name", conf.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug("Adding", uiType , "timer", "name", conf.name, "expTime", expTime, "conf.flashOnEnd", conf.flashOnEnd)
    end

    local frame
    if uiType == "button" then
        frame = self:CreateTimerButton(parent, index, 2, conf.color, conf.icon)
        if showAtTime then
            showAtTime = expTime - showAtTime
            frame:Hide()
        end
    else
        frame = self:CreateTimerBar(parent, index, 2, conf.color or {0.5, 0.5, 0.5}, conf.icon, text or self.db.profile.showTimeOnBars and tostring(duration) or nil)
    end
    local timer = {
        frame = frame,
        index = index,
        list = list,
        id = id,
        name = conf.name,
        icon = conf.icon,
        color = conf.color or {0.5, 0.5, 0.5},
        expTime = expTime,
        duration = duration,
        showAtTime = showAtTime,
        keyExtra = keyExtra,
        text = text,
        height = height,
        onUpdate = onUpdate,
        onEnd = onEnd,
        uiType = uiType,
        parent = parent,
        timerType = timerType,
        flashOnEnd = conf.flashOnEnd,
        widthMul = widthMul,
        arrangeFunc = arrangeFunc,
        isTimer = true
    }
    timer.key = keyExtra..self:GetTimerKey(conf.name, expTime, uiType)
    list[keyExtra..tostring(id)] = timer
    self.list_timers[timer.key] = timer
    self.list_timerByName[keyExtra..conf.name.."-"..uiType] = timer
    onUpdate(timer)
    arrangeFunc(self, list, parent)
    return timer
end

function QuickAuras:GetTimerKey(name, expTime, uiType)
    return name.."-"..tostring(expTime).."-"..tostring(uiType)
end

function QuickAuras:UpdateProgressBar(timer)
    if not timer or not timer.frame then return end -- timer destroyed
    if timer.expTime == 0 or (timer.duration > 0 and timer.expTime > GetTime()) then
        if not timer.showAtTime or GetTime() >= timer.showAtTime then
            timer.frame:Show()
            if timer.duration > 0 then
                local timeLeft = timer.expTime - GetTime()
                local progress = timeLeft / timer.duration
                if timer.flashOnEnd and timeLeft < timer.flashOnEnd then
                    --debug(3, "UpdateProgressBar", timer.key, "flashing", timeLeft)
                    if math.floor(timeLeft / 0.4) % 2 == 0 then
                        timer.frame:SetBackdropBorderColor(1, 0, 0) -- Red border
                        timer.frame.barFrame:SetStatusBarColor(1, 0, 0)
                    else
                        timer.frame:SetBackdropBorderColor(unpack(timer.color)) -- Red border
                        timer.frame.barFrame:SetStatusBarColor(unpack(timer.color))
                    end
                end
                if timer.uiType == "bar" then
                    _G[timer.frame:GetName().."_Progress_Bar"]:SetValue(progress)
                    if timer.frame.text and not timer.text then
                        timer.frame.text:SetText(string.format("%.1f", timer.expTime - GetTime()))
                    end
                elseif timer.uiType == "button" then
                    timer.frame.cooldown:SetCooldown(timer.expTime - timer.duration, timer.duration)
                end
            end
        end
        return true
    else
        timer.frame:Hide()
        return false
    end
end

function QuickAuras:RemoveTimer(timer, reason)
    --debug("Removing timer", "["..tostring(reason)..","..tostring(timer.key).."]")
    if timer.onEnd then
        timer:onEnd(timer)
    end
    -- remove from timers the one with matching name and expTime
    timer.frame:Hide()
    timer.frame:SetParent(nil)
    timer.frame:ClearAllPoints()
    timer.frame = nil
    timer.list[timer.keyExtra..timer.id] = nil
    self.list_timerByName[timer.keyExtra..timer.name.."-"..timer.uiType] = nil
    self.list_timers[timer.key] = nil
    --debug(" -- ", timer.key)
    if timer.arrangeFunc then
        timer.arrangeFunc(self, timer.list, timer.parent)
    else
        self:ArrangeTimerBars(timer.list, timer.parent)
    end
end

function QuickAuras:CheckTimers()
    for _, timer in pairs(self.list_timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                self:RemoveTimer(timer, "expired")
            end
        end
    end
end
