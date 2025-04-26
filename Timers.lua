local ADDON_NAME, addon = ...
local MeleeUtils = addon.root

function MeleeUtils:AddTimer(progressSpell, duration, expTime, onUpdate, onEnd)
    --MUGLOBAL.Debug("Adding timer", "name", name, "expTime", expTime)
    if self.timerByName[progressSpell.name] then
        self:RemoveTimer(self.timerByName[progressSpell.name])
    end
    local timer = {
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

function MeleeUtils:RemoveTimer(timer)
    local key = timer.name..tostring(timer.expTime)
    if timer.onEnd then
        timer:onEnd(timer)
    end
    if self.timers[key] then
        self.timers[key] = nil
        self.timerByName[timer.name] = nil
    end
end

function MeleeUtils:CheckTimers()
    for key, timer in pairs(self.timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                self:RemoveTimer(timer)
            end
        end
    end
end
