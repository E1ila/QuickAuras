local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug
local pbId = 0

function MeleeUtils:SetProgressTimer(conf, duration, expTime, onUpdate, onEnd)
    local existingTimer = self.timerByName[conf.name]
    local index = #conf.list
    if existingTimer then
        if existingTimer.expTime == expTime and existingTimer.name == conf.name then
            return -- already exists
        end
        -- different timer, remove old
        self:RemoveProgressTimer(existingTimer)
        debug("Replacing timer", "name", conf.name, "expTime", expTime)
        index = existingTimer.index
    else
        debug("Adding timer", "name", conf.name, "expTime", expTime)
    end

    local frame = self:CreateProgressBar(conf.parent, conf.list, index, 25, 2, conf.color, conf.icon, 0)
    local timer = {
        frame = frame,
        index = index,
        list = conf.list,
        name = conf.name,
        icon = conf.icon,
        color = conf.color,
        expTime = expTime,
        duration = duration,
        onUpdate = onUpdate,
        onEnd = onEnd,
    }
    timer.key = self:GetTimerKey(timer)
    table.insert(conf.list, timer)
    self.timers[timer.key] = timer
    self.timerByName[conf.name] = timer
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
