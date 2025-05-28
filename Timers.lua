local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local WINDOW = QA.WINDOW

function QA:AddTimer(window, conf, id, duration, expTime, showAtTime, text, keyExtra)
    keyExtra = keyExtra or ""
    showAtTime = showAtTime or conf.showAtTime
    window = window or conf.window
    local attr = QA:GetWindowAttr(window)
    local onUpdate = conf.onUpdate or QuickAuras_Timer_OnUpdate
    local onEnd = conf.onEnd or QuickAuras_Timer_OnUpdate
    local uiType = attr.bar and "bar" or "button"

    local index = 0
    for _ in pairs(attr.list) do
        index = index + 1
    end

    local key = keyExtra..conf.name.."-"..uiType
    local existingTimer = QA.list_timerByName[key]
    if existingTimer then
        if existingTimer.expTime == expTime and existingTimer.name == conf.name then
            --debug(3, "Timer already exists", "name", conf.name, "ui", uiType, "expTime", expTime)
            return existingTimer, false -- already exists
        end
        debug(2, "Replacing timer", "name", existingTimer.name, conf.name, "expTime", existingTimer.expTime, expTime, "key", key)
        -- different timer, remove old
        QA:RemoveTimer(existingTimer, "replaced")
        --debug("Replacing", uiType, "timer", "name", conf.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug(2, QA.colors.bold.."Adding", uiType , "timer|r", "name", conf.name, "expTime", expTime, "showAtTime", showAtTime, "key", key)
    end

    local frame
    if attr.bar then
        --debug(3, "Creating bar timer", "name", conf.name, "expTime", expTime)
        frame = QA:CreateTimerBar(attr.parent, index, 2, conf.color or {0.5, 0.5, 0.5}, conf.icon, text or QA.db.profile.showTimeOnBars and tostring(duration) or nil)
    else
        --      QA:CreateTimerButton(parent,     index,  icon, showCount)
        frame = QA:CreateTimerButton(attr.parent, index, conf.icon, conf.count)
        if showAtTime then
            showAtTime = expTime - showAtTime
            frame:SetAlpha(0.5)
            frame:Hide()
        end
    end
    local timer = {
        frame = frame,
        index = index,
        list = attr.list,
        id = id,
        name = conf.name,
        icon = conf.icon,
        color = conf.color or {0.5, 0.5, 0.5},
        expTime = expTime,
        duration = duration,
        showAtTime = showAtTime,
        keyExtra = keyExtra,
        text = text,
        onUpdate = onUpdate,
        onEnd = onEnd,
        uiType = uiType,
        parent = attr.parent,
        window = window,
        flashOnEnd = conf.flashOnEnd,
        glowOnEnd = true,
        widthMul = attr.widthMul,
        isTimer = true
    }
    timer.key = keyExtra..QA:GetTimerKey(conf.name, expTime, uiType)
    attr.list[keyExtra..tostring(id)] = timer
    QA.list_timers[timer.key] = timer
    QA.list_timerByName[keyExtra..conf.name.."-"..uiType] = timer
    onUpdate(timer)
    QA.arrangeQueue[window] = true
    return timer, true
end

function QA:GetTimerKey(name, expTime, uiType)
    return name.."-"..tostring(expTime).."-"..tostring(uiType)
end

function QA:UpdateProgressBar(timer)
    if not timer or not timer.frame then return end -- timer destroyed
    if timer.expTime and timer.expTime == 0 or (timer.duration and timer.duration > 0 and timer.expTime > GetTime()) then
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
                    if timer.glowOnEnd and not timer.glow and timer.expTime - GetTime() < 0.30 then
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
    QA.arrangeQueue[timer.window] = true
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
