
function MeleeUtils:OnSpellCastEvent(unit, target, guid, spellId)
    debug("|cff999999OnSpellCastEvent|r spellId |cffff9900" .. tostring(spellId))
end

function MeleeUtils:OnSpellCastSuccessEvent(unit, target, spellId)
    debug("|cff999999OnSpellCastSuccessEvent|r spellId |cffff9900" .. tostring(spellId) .. "|r unit |cffff9900" .. tostring(unit))
end

function MeleeUtils:OnPlayerDead()
end

function MeleeUtils:OnCombatLogEvent()
    local eventInfo = { CombatLogGetCurrentEventInfo() }
    local eventName = eventInfo[2]

    if eventName == "PARTY_KILL" then
        if not MeleeUtilsGlobalVars.track.kills then
            return
        end

        local mobName = eventInfo[9]
        local mobGuid = eventInfo[8]
        local mobFlags = eventInfo[10]

        if bit.band(mobFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 then
            debug("Player " .. eventInfo[5] .. " killed NPC " .. mobName)
        end
        MeleeUtils_MainWindow:Refresh()
    end
end
