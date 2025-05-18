local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local _c = QA.colors

local enemyDebuffs = {}
local raidBuffs = {}

local lastUpdate = 0
local updateInterval = 0.01 -- Execute every 0.1 seconds

local BOSS_LEVEL = 63

-- WoW Events

function QA:ZONE_CHANGED()
    QA:ZoneChanged()
end

function QA:ZONE_CHANGED_INDOORS()
    QA:ZoneChanged()
end

function QA:ZONE_CHANGED_NEW_AREA()
    QA:ZoneChanged()
end

function QA:PLAYER_ENTERING_WORLD()
    QA:ZoneChanged()
end

function QA:UNIT_AURA(unit)
    if unit ~= "player" then return end
    QA:CheckAuras()
end

function QA:UI_ERROR_MESSAGE(errorType, errorMessage)
    if QA.db.profile.outOfRange and UnitAffectingCombat("player") then
        --debug("UI_ERROR_MESSAGE", errorType, errorMessage)
        if  errorMessage == ERR_OUT_OF_RANGE
            or errorMessage == ERR_SPELL_OUT_OF_RANGE
            or errorMessage == "You must be behind your target" then
            QA:ShowNoticableError(errorMessage)
        end
    end
end

function QA:SPELL_UPDATE_COOLDOWN(...)
    QA:CheckCooldowns()
end

function QA:PLAYER_EQUIPMENT_CHANGED(...)
    QA:CheckGear("equip", ...)
end

function QA:PLAYER_TARGET_CHANGED(...)
    QA:CheckGear("target", ...)
    QA:ResetErrorCount()
    QA:CheckAllProcs()
end

function QA:BAG_UPDATE(bagId)
    if bagId >= 0 and bagId <= 4 then
        QA:BagsChanged()
    end
end

function QA:ENCOUNTER_START(encounterId, encounterName)
    QA.encounter.id = encounterId
    QA.encounter.name = encounterName

    QA:CheckMissingBuffs()

    QA:EncounterStarted(encounterId)
end

function QA:ENCOUNTER_END()
    if not QA.encounter.id then return end -- not in encounter
    local encounterId = QA.encounter.id
    QA.encounter.id = nil

    QA:EncounterEnded(encounterId)

    QA:CheckMissingBuffs()
end

function QA:MINIMAP_UPDATE_TRACKING()
    QA:CheckTrackingStatus()
end

function QA:PLAYER_ALIVE()
    QA:CheckTrackingStatus()
end

function QA:PLAYER_UNGHOST()
    QA:CheckTrackingStatus()
end

function QA:PLAYER_LEVEL_UP()
    QA.playerLevel = UnitLevel("player")
    if QA.playerLevel == 60 then
        QuickAuras_XP:Hide()
    end
end

function QA:BANKFRAME_OPENED()
    QA.bankOpen = true
    QA:ScanBank()
end

function QA:BANKFRAME_CLOSED()
    QA.bankOpen = false
end

function QA:UNIT_POWER_UPDATE(unit, powerType)
    QA:CheckPower(unit, powerType)
end

function QA:PLAYER_REGEN_DISABLED()
    -- in combat
    QA.inCombat = true
    QA:CheckAuras()
end

function QA:PLAYER_REGEN_ENABLED()
    -- out of combat
    QA.inCombat = false
    QA:CheckAuras()
    QA:CheckPlayerAggro()
end

function QA:GROUP_ROSTER_UPDATE()
    QA.isMainTank = QA.isWarrior and IsInRaid() and (GetPartyAssignment("MAINTANK", "player") or GetPartyAssignment("MAINASSIST", "player"))
    QA:CheckIfWarriorInParty()
end

function QA:PARTY_MEMBER_ENABLE()
    QA:CheckIfWarriorInParty()
end

function QA:UPDATE_SHAPESHIFT_FORM(...)
    QA.shapeshiftForm = GetShapeshiftForm()
    --debug("UPDATE_SHAPESHIFT_FORM", QA.shapeshiftForm, ...)
end

function QA:UNIT_HEALTH()
    for _, spell in ipairs(QA.trackedProcAbilities.unitHealth) do
        QA:CheckProc(spell)
    end
end

function QA:PLAYER_XP_UPDATE()
    QA:UpdateXpFrame()
end

function QA:QUEST_TURNED_IN()
    QA:UpdateXpFrame()
end

function QA:UNIT_THREAT_LIST_UPDATE(unit)
    if unit == "target" then
        QA:CheckPlayerAggro()
    end
end

-- OnUpdate

function QA:OnUpdate()
    local currentTime = GetTime()
    if QA.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        QA:CheckTimers()
        QA:CheckTargetRange()
    end
end

-- Combat log

QA.cluMax = 0
function QA:COMBAT_LOG_EVENT_UNFILTERED()
    local t1 = debugprofilestop()
    QA:HandleCombatLogEvent(CombatLogGetCurrentEventInfo())
    local t = debugprofilestop() - t1
    if t > QA.cluMax then
        QA.cluMax = t
        if t > 0.01 then
            debug(2, "CLEU", "max", _c.bold..tostring(t))
        end
    end
    if t >= 1 then
        debug("Slow CLEU", _c.alert..tostring(t))
    end
end

local TRACKED_SPELL_EVENTS = {
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
    ["SPELL_AURA_REMOVED"] = true,
    --["SPELL_CAST_SUCCESS"] = true,
    --["SPELL_SUMMON"] = true,
}

function QA:HandleCombatLogEvent(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    local extra = {...}
    --debug("CombatLog", subevent, sourceName, destName, ...)

    if  -- parry haste
            QA.db.profile.harryPaste and
            subevent == "SWING_MISSED" and
            extra[1] == "PARRY" and -- missType
            destGuid == UnitGUID("target") and
            sourceGuid ~= UnitGUID("targettarget") and
            not UnitIsPlayer("target") and
            IsInInstance()
    then
        if sourceGuid == QA.playerGuid then
            QA:ShowParry()
        elseif UnitLevel("target") >= BOSS_LEVEL then
            out("|cffff0000Warning:|r "..destName.." has parried ".._c.bold..sourceName.."|r hit!")
        end
    end

    -- tracked spells
    if type(extra[1]) == "number" and extra[1] > 0 and TRACKED_SPELL_EVENTS[subevent] then
        for spellId, conf in pairs(QA.trackedCombatLog) do
            --debug("CombatLog", "spellId", spellId, "conf.name", conf.name, "extra1", extra[1], "conf.raidBars", conf.raidBars)
            if extra[1] == spellId then
                -- taunt
                if conf.taunt and subevent == "SPELL_AURA_APPLIED" and sourceGuid == QA.playerGuid then
                    debug("CLEU ".._c.bold.."Taunt|r spell:", conf.name, "sourceGUID", sourceGuid, "destGUID", destGuid)
                    QA.hasTaunted = GetTime() + (conf.duration or 1)
                end
                -- offensive debuffs
                if conf.duration and conf.list then
                    if  (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                            and sourceGuid == QA.playerGuid
                            --and destGUID == UnitGUID("target")
                            and QA.db.profile.watchBars
                            and (not conf.option or QA.db.profile[conf.option])
                    then
                        -- start offensive timer
                        if conf.OnDetect then
                            conf.OnDetect(conf, sourceGuid, sourceName, destGuid, destName)
                        end
                        local timer = QA:AddTimer("combatlog", conf, spellId, conf.duration, GetTime()+conf.duration)
                        if not enemyDebuffs[extra[1]] then enemyDebuffs[extra[1]] = {} end
                        enemyDebuffs[extra[1]][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid == QA.playerGuid
                            and enemyDebuffs[extra[1]] and enemyDebuffs[extra[1]][destGuid]
                    then
                        -- end offensive timer
                        QA:RemoveTimer(enemyDebuffs[extra[1]][destGuid], "combatlog")
                        enemyDebuffs[extra[1]][destGuid] = nil
                    end
                end
                -- raid tracking
                if conf.raidBars and IsInInstance() then
                    debug(2, "Raid tracking", conf.name, "spellId", spellId, "subevent", subevent, "sourceGUID", sourceGuid, "destGUID", destGuid)
                    if      (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                            and sourceGuid ~= QA.playerGuid
                            and QA.db.profile.raidBars
                            --and (not conf.option or QA.db.profile[conf.option.."_rbars"])
                    then
                        -- start offensive timer
                        local name = strsplit("-", sourceName)
                        local timer = QA:AddTimer("raidbar", conf, spellId, conf.duration, GetTime()+conf.duration, nil, name, name)
                        if not raidBuffs[extra[1]] then raidBuffs[extra[1]] = {} end
                        raidBuffs[extra[1]][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid ~= QA.playerGuid
                            and raidBuffs[extra[1]] and raidBuffs[extra[1]][destGuid]
                    then
                        -- end offensive timer
                        QA:RemoveTimer(raidBuffs[extra[1]][destGuid], "raidbar")
                        raidBuffs[extra[1]][destGuid] = nil
                    end
                end
            end
        end
    end

    if subevent == "UNIT_DIED" then
        if sourceGuid == QA.playerGuid then
            enemyDebuffs = {}
            QA:PlayerDied()
        end
        -- reset buffs/debuffs of dead unit
        for spellId, conf in pairs(QA.trackedCombatLog) do
            if enemyDebuffs[spellId] and enemyDebuffs[spellId][destGuid] then
                QA:RemoveTimer(enemyDebuffs[spellId][destGuid], "combatlog")
                enemyDebuffs[spellId][destGuid] = nil
            end
            if raidBuffs[spellId] and raidBuffs[spellId][destGuid] then
                QA:RemoveTimer(raidBuffs[spellId][destGuid], "raidbar")
                raidBuffs[spellId][destGuid] = nil
            end
        end
    end

    -- announce interrupts
    if      subevent == "SPELL_INTERRUPT" and
            sourceGuid == QA.playerGuid and
            QA.InstanceName and QA.db.profile.announceInterrupts and
            destGuid == UnitGUID("target")
    then
        if extra[5] then
            SendChatMessage(">> Interrupted "..tostring(extra[5]).." <<", "SAY")
        else
            SendChatMessage(">> Interrupted "..destName.." <<", "SAY")
        end
    end

    -- announce misses
    if      subevent == "SWING_MISSED" and
            sourceGuid == QA.playerGuid and
            QA.InstanceName and QA.db.profile.announceMisses and
            destGuid == UnitGUID("target") and
            sourceGuid == UnitGUID("targettarget") and extra[1]
    then
        SendChatMessage(">> "..tostring(extra[1]).." <<", "SAY")
    end

    if QA.encounter.OnSwingDamage and subevent == "SWING_DAMAGE" then
        QA.encounter.OnSwingDamage(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    end
    if QA.encounter.OnSpellSummon and subevent == "SPELL_SUMMON" then
        QA.encounter.OnSpellSummon(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    end

    -- check procs
    for _, spell in ipairs(QA.trackedProcAbilities.combatLog) do
        if QA.db.profile[spell.procFrameOption] then
            local spellCasted = false

            if subevent == "SPELL_CAST_SUCCESS" then
                if spell.bySpellId[extra[1]] == spell.spellId[1] then
                    spellCasted = true
                end
            end

            if spellCasted or spell.CheckProc(spell, subevent, sourceGuid, sourceName, destGuid, destName, extra) then
                -- doesn't become enabled right away
                C_Timer.After(0.05, function() QA:CheckProc(spell) end)
            end
        end
    end
end
