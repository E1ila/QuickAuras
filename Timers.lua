local MeleeUtils = MUGLOBAL

function MeleeUtils:AddTimer(progressSpell, duration, expTime, onUpdate, onEnd)
    --MUGLOBAL.Debug("Adding timer", "name", name, "expTime", expTime)
    if MeleeUtils.timerByName[progressSpell.name] then
        MeleeUtils:RemoveTimer(MeleeUtils.timerByName[progressSpell.name])
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
    MeleeUtils.timers[key] = timer
    MeleeUtils.timerByName[progressSpell.name] = timer
end

function MeleeUtils:RemoveTimer(timer)
    local key = timer.name..tostring(timer.expTime)
    if timer.onEnd then
        timer:onEnd(timer)
    end
    if MeleeUtils.timers[key] then
        MeleeUtils.timers[key] = nil
        MeleeUtils.timerByName[timer.name] = nil
    end
end

function MeleeUtils:CheckTimers()
    for key, timer in pairs(MeleeUtils.timers) do
        if timer.onUpdate then
            if not timer:onUpdate(timer) then
                MeleeUtils:RemoveTimer(timer)
            end
        end
    end
end
