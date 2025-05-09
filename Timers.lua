local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

function QuickAuras:AddTimer(timerType, conf, id, duration, expTime, onUpdate, onEnd)
    local arrangeFunc = self.ArrangeTimerBars
    local uiType, list, parent
    local widthMul = 1
    if timerType == "test-cooldowns" or timerType == "cooldowns" then
        list = self.cooldowns
        parent = QuickAuras_Cooldowns
        uiType = "button"
    elseif conf.list == "watch" then
        list = self.watchBars
        parent = QuickAuras_WatchBars
        uiType = "bar"
    elseif conf.list == "offensive" then
        list = self.offensiveBars
        parent = QuickAuras_OffensiveBars
        uiType = "bar"
        widthMul = 1.5
    elseif conf.list == "alert" then
        list = self.iconAlerts
        parent = QuickAuras_IconAlerts
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons("alert") end
    elseif timerType == "reminder" or conf.list == "reminder" then
        list = self.reminders
        parent = QuickAuras_Reminders
        uiType = "button"
        arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons("reminder") end
    end
    if not parent then parent = UIParent end
    if not onUpdate then onUpdate = conf.onUpdate or QuickAuras_Timer_OnUpdate end
    if not onEnd then onEnd = conf.onEnd or QuickAuras_Timer_OnUpdate end

    local index = 0
    for _ in pairs(list) do
        index = index + 1
    end

    local existingTimer = self.timerByName[conf.name.."-"..uiType]
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
    else
        local text = self.db.profile.showTimeOnBars and tostring(duration) or nil
        frame = self:CreateTimerBar(parent, index, 2, conf.color, conf.icon, text)
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
    timer.key = self:GetTimerKey(conf.name, expTime, uiType)
    list[id] = timer
    self.timers[timer.key] = timer
    self.timerByName[conf.name.."-"..uiType] = timer
    onUpdate(timer)
    arrangeFunc(self, list, parent)
    return timer
end

function QuickAuras:GetTimerKey(name, expTime, uiType)
    return name.."-"..tostring(expTime).."-"..tostring(uiType)
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
    timer.list[timer.id] = nil
    self.timerByName[timer.name.."-"..timer.uiType] = nil
    self.timers[timer.key] = nil
    --debug(" -- ", timer.key)
    if timer.arrangeFunc then
        timer.arrangeFunc(self, timer.list, timer.parent)
    else
        self:ArrangeTimerBars(timer.list, timer.parent)
    end
end

function QuickAuras:CheckTimers()
    for _, timer in pairs(self.timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                self:RemoveTimer(timer, "expired")
            end
        end
    end
end
