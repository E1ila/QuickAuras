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
            debug(3, "AddTimer", "Updating", uiType, conf.name, "parent", attr.parent:GetName(), "expTime", expTime, "count", conf.count)
            QA:UpdateIcon(existingTimer, attr, conf.count)
            return existingTimer, false -- already exists
        end
        debug(3, "AddTimer", "Replacing", uiType, conf.name, "parent", attr.parent:GetName(), "expTime", expTime, "key", key)
        -- different timer, remove old
        QA:RemoveTimer(existingTimer, "replaced")
        --debug("Replacing", uiType, "timer", "name", conf.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug(3, "AddTimer", "Creating", uiType, conf.name, "parent", attr.parent:GetName(), "expTime", expTime, "showAtTime", showAtTime, "key", key)
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
        color = conf.color or {0.5, 0.5, 0.5},
        count = conf.count,
        duration = duration,
        expTime = expTime,
        flashOnEnd = conf.flashOnEnd,
        frame = frame,
        glowOnEnd = true,
        icon = conf.icon,
        id = id,
        index = index,
        isTimer = true,
        keyExtra = keyExtra,
        list = attr.list,
        name = conf.name,
        onEnd = onEnd,
        onUpdate = onUpdate,
        parent = attr.parent,
        showAtTime = showAtTime,
        text = text,
        uiType = uiType,
        window = window,
        widthMul = attr.widthMul,
    }
    timer.key = keyExtra..QA:GetTimerKey(conf.name, expTime, uiType)
    if #keyExtra > 0 then
        attr.list[keyExtra..tostring(id)] = timer
    else
        attr.list[id] = timer -- we want int key
    end
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

function QA:RemoveTimer(timer, source)
    if not timer or not timer.frame then return false end -- target died, already removed
    debug(3, "RemoveTimer", "key", timer.key, "source", source, "map key", timer.keyExtra..timer.id)
    if timer.onEnd then
        timer:onEnd(timer)
    end
    -- remove from timers the one with matching name and expTime
    timer.frame:Hide()
    timer.frame:SetParent(nil)
    timer.frame:ClearAllPoints()
    timer.frame = nil
    if #timer.keyExtra > 0 or type(timer.id) == "string" then
        timer.list[timer.keyExtra..tostring(timer.id)] = nil
    else
        timer.list[tonumber(timer.id)] = nil
    end
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
