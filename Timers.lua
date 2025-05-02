local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

function QuickAuras:AddTimer(source, uiType, list, parent, conf, duration, expTime, onUpdate, onEnd)
    local arrangeFunc = self.ArrangeProgressFrames
    if not list then
        if conf.list == "watch" then
            list = self.watchBars
            parent = QuickAuras_WatchBars
        elseif conf.list == "offensive" then
            list = self.offensiveBars
            parent = QuickAuras_OffensiveBars
        elseif conf.list == "alert" then
            list = self.iconAlerts
            parent = QuickAuras_IconAlerts
            uiType = "button" -- override
            arrangeFunc = function(_list, _parent, _gap) QuickAuras:ArrangeIcons("alert") end
        end
    end
    if not parent then parent = UIParent end
    if not onUpdate then onUpdate = conf.onUpdate or QuickAuras_Timer_OnUpdate end
    if not onEnd then onEnd = conf.onEnd or QuickAuras_Timer_OnUpdate end
    local index = #list
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
        --debug("Adding", uiType , "timer", "name", conf.name, "expTime", expTime)
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
        name = conf.name,
        icon = conf.icon,
        color = conf.color or {0.5, 0.5, 0.5},
        expTime = expTime,
        duration = duration,
        onUpdate = onUpdate,
        onEnd = onEnd,
        uiType = uiType,
        parent = parent,
        source = source,
        arrangeFunc = arrangeFunc,
    }
    timer.key = self:GetTimerKey(conf.name, expTime, uiType)
    table.insert(list, timer)
    --debug(" ++ ", timer.key, source)
    self.timers[timer.key] = timer
    self.timerByName[conf.name.."-"..uiType] = timer
    onUpdate(timer)
    arrangeFunc(self, list, parent)
    return timer
end

function QuickAuras:GetTimerKey(name, expTime, uiType)
    return name.."-"..tostring(expTime).."-"..tostring(uiType)
end

function QuickAuras:DebugPrintTimers()
    debug("timers")
    for _, timer in pairs(self.timers) do
        debug("  - ", timer.key, "source", timer.source, "expTime", timer.expTime, "duration", timer.duration)
    end
    debug("timerByName")
    for _, timer in pairs(self.timerByName) do
        debug("  - ", timer.key, "source", timer.source, "expTime", timer.expTime, "duration", timer.duration)
    end
    debug("lists")
    debug("  - watchBars", #self.watchBars)
    debug("  - offensiveBars", #self.offensiveBars)
    debug("  - iconWarnings", #self.iconWarnings)
    debug("  - iconAlerts", #self.iconAlerts)
end

function QuickAuras:RemoveTimer(timer, reason)
    --debug("Removing timer", "["..tostring(reason)..","..tostring(timer.key).."]")
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
    self.timerByName[timer.name.."-"..timer.uiType] = nil
    self.timers[timer.key] = nil
    --debug(" -- ", timer.key)
    if timer.arrangeFunc then
        timer.arrangeFunc(self, timer.list, timer.parent)
    else
        self:ArrangeProgressFrames(timer.list, timer.parent)
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
