local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local ICON = QA.ICON

function QA:AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
    local arrangeFunc = QA.ArrangeTimerBars
    local uiType, list, parent, height
    local widthMul = 1
    keyExtra = keyExtra or ""
    showAtTime = showAtTime or conf.showAtTime
    if timerType == "swing" then
        list = QA.list_swingTimers
        uiType = "swing"
        arrangeFunc = function(_list, _parent, _gap)  end
    elseif timerType == "raidbar" then
        list = QA.list_raidBars
        parent = QuickAuras_RaidBars
        uiType = "bar"
        height = QA.db.profile.raidBarHeight
    elseif timerType == "test-cooldowns" or timerType == "cooldowns" then
        list = QA.list_cooldowns
        parent = QuickAuras_Cooldowns
        uiType = "button"
    elseif conf.list == "watch" then
        list = QA.list_watchBars
        parent = QuickAuras_WatchBars
        uiType = "bar"
    elseif conf.list == "offensive" then
        list = QA.list_offensiveBars
        parent = QuickAuras_OffensiveBars
        uiType = "bar"
        widthMul = 1.5
    elseif conf.list == "alert" then
        list = QA.list_iconAlerts
        parent = QuickAuras_IconAlerts
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QA:ArrangeIcons(ICON.ALERT) end
    elseif timerType == "reminder" or conf.list == "reminder" then
        list = QA.list_reminders
        parent = QuickAuras_Reminders
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QA:ArrangeIcons(ICON.REMINDER) end
    elseif timerType == "crucial" or conf.list == "crucial" then
        list = QA.list_crucial
        parent = QuickAuras_Crucial
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QA:ArrangeIcons(ICON.CRUCIAL) end
    end
    if not parent then parent = UIParent end
    local onUpdate = conf.onUpdate or QuickAuras_Timer_OnUpdate
    local onEnd = conf.onEnd or QuickAuras_Timer_OnUpdate

    local index = 0
    for _ in pairs(list) do
        index = index + 1
    end

    local existingTimer = QA.list_timerByName[keyExtra..conf.name.."-"..uiType]
    if existingTimer then
        if existingTimer.expTime == expTime and existingTimer.name == conf.name then
            --debug("Timer already exists", "name", conf.name, "ui", uiType, "expTime", expTime)
            return existingTimer, false -- already exists
        end
        debug(2, "Replacing timer", "name", existingTimer.name, conf.name, "expTime", existingTimer.expTime, expTime)
        -- different timer, remove old
        QA:RemoveTimer(existingTimer, "replaced")
        --debug("Replacing", uiType, "timer", "name", conf.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug(2, "Adding", uiType , "timer", "name", conf.name, "expTime", expTime, "conf.flashOnEnd", conf.flashOnEnd, "showAtTime", showAtTime)
    end

    local frame
    if uiType == "button" then
        frame = QA:CreateTimerButton(parent, index, 2, conf.color, conf.icon)
        if showAtTime then
            showAtTime = expTime - showAtTime
            frame:SetAlpha(0.5)
            frame:Hide()
        end
    else
        frame = QA:CreateTimerBar(parent, index, 2, conf.color or {0.5, 0.5, 0.5}, conf.icon, text or QA.db.profile.showTimeOnBars and tostring(duration) or nil)
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
        glowOnEnd = true,
        widthMul = widthMul,
        arrangeFunc = arrangeFunc,
        isTimer = true
    }
    timer.key = keyExtra..QA:GetTimerKey(conf.name, expTime, uiType)
    list[keyExtra..tostring(id)] = timer
    QA.list_timers[timer.key] = timer
    QA.list_timerByName[keyExtra..conf.name.."-"..uiType] = timer
    onUpdate(timer)
    arrangeFunc(QA, list, parent)
    return timer, true
end

function QA:GetTimerKey(name, expTime, uiType)
    return name.."-"..tostring(expTime).."-"..tostring(uiType)
end

function QA:UpdateProgressBar(timer)
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
                    if timer.glowOnEnd and not timer.glow and timer.expTime - GetTime() < 0.35 then
                        ActionButton_ShowOverlayGlow(timer.frame)
                        timer.glow = true
                    end
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

function QA:RemoveTimer(timer, reason)
    if not timer or not timer.frame then return false end -- target died, already removed
    debug(2, "Removing timer", "["..tostring(reason)..","..tostring(timer.key).."]")
    if timer.onEnd then
        timer:onEnd(timer)
    end
    -- remove from timers the one with matching name and expTime
    timer.frame:Hide()
    timer.frame:SetParent(nil)
    timer.frame:ClearAllPoints()
    timer.frame = nil
    timer.list[timer.keyExtra..timer.id] = nil
    QA.list_timerByName[timer.keyExtra..timer.name.."-"..timer.uiType] = nil
    QA.list_timers[timer.key] = nil
    --debug(" -- ", timer.key)
    if timer.arrangeFunc then
        timer.arrangeFunc(QA, timer.list, timer.parent)
    else
        QA:ArrangeTimerBars(timer.list, timer.parent)
    end
end

function QA:CheckTimers()
    for _, timer in pairs(QA.list_timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                QA:RemoveTimer(timer, "expired")
            end
        end
    end
end

function QA:ClearTimers()
    for _, timer in pairs(QA.list_timers) do
        QA:RemoveTimer(timer, "cleared")
    end
end
