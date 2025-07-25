local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local _c = QA.colors
local WINDOW = QA.WINDOW

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
    if unit == "target" then
        QA:CheckTargetAuras()
    elseif unit == "player" then
        QA:CheckAuras()
    end
end

function QA:UI_ERROR_MESSAGE(errorType, errorMessage)
    if QA.db.profile.outOfRange and UnitAffectingCombat("player") then
        --debug("UI_ERROR_MESSAGE", errorType, errorMessage)
        if  errorMessage == ERR_OUT_OF_RANGE
            or errorMessage == ERR_SPELL_OUT_OF_RANGE then
            QA:ShowNoticableError("RANGE")
        elseif errorMessage == "You must be behind your target" then
            QA:ShowNoticableError("NOT BEHIND")
        end
    end
end

function QA:SPELL_UPDATE_COOLDOWN(...)
    QA:CheckCooldowns()
end

function QA:BAG_UPDATE_COOLDOWN(...)
    QA:CheckCooldowns()
end

function QA:PLAYER_EQUIPMENT_CHANGED(...)
    QA:CheckGear("equip", ...)
end

function QA:PLAYER_TARGET_CHANGED(...)
    QA:CheckGear("target", ...)
    QA:ResetErrorCount()
    QA:CheckAllProcs()
    QA:CheckTargetAuras(true)
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
    QA:CheckCooldowns()
    QA:CheckWeaponEnchants()
end

function QA:PLAYER_REGEN_ENABLED()
    -- out of combat
    QA.inCombat = false
    QA:CheckAuras()
    QA:CheckPlayerAggro()
    QA:CheckCooldowns()
    QA:CheckWeaponEnchants()
end

function QA:GROUP_ROSTER_UPDATE()
    QA:GroupCompoChanged()
end

function QA:PARTY_MEMBER_ENABLE()
    QA:GroupCompoChanged()
end

function QA:UPDATE_SHAPESHIFT_FORM(...)
    QA.shapeshiftForm = GetShapeshiftForm()
    --debug("UPDATE_SHAPESHIFT_FORM", QA.shapeshiftForm, ...)
end

function QA:UNIT_HEALTH()
    for _, spell in ipairs(QA.trackedProcAbilities.unitHealth) do
        --debug(1, "UNIT_HEALTH", spell.name, spell.procFrameOption)
        QA:CheckProcSpellUsable(spell)
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

function QA:UNIT_SPELLCAST_SENT(unit, _, spellGuid)
    QA:CheckSpellQueue(unit, spellGuid)
end

function QA:ADDON_ACTION_BLOCKED(...)
    debug("ADDON_ACTION_BLOCKED", _c.alert, ...)
end

function QA:UNIT_INVENTORY_CHANGED()
    QA:CheckWeaponEnchants()
end

-- OnUpdate

function QA:OnUpdate()
    if QA.queuedSwingUpdateCount > 0 then
        if QA.queuedSwingUpdateCount == 1 then
            for hand, reason in pairs(QA.queuedSwingUpdate) do
                QA:UpdateSwingTimers(hand, reason)
            end
        else
            QA:UpdateSwingTimers()
        end
        QA.queuedSwingUpdate = {}
        QA.queuedSwingUpdateCount = 0
    end

    local currentTime = GetTime()
    if QA.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        QA:CheckTimers()
        QA:CheckTargetRange()
    end

    QA:ArrangeWindows()
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

local IGNORED_EVENTS = {
    ["UNIT_SPELLCAST_SENT"] = true,
}

function QA:HandleCombatLogEvent(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    if IGNORED_EVENTS[subevent] then return end
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
        --debug("CombatLog", subevent, extra[2], extra[1])
        local conf = QA.trackedCombatLog[extra[1]]
        if conf then
            local spellId = extra[1]
            --debug("CLEU", subevent, "spellId", spellId, conf and conf.name, conf and conf.OnSpellDetectCombatLog)
            if conf.OnSpellDetectCombatLog then
                conf.OnSpellDetectCombatLog(conf, subevent, sourceGuid, sourceName, destGuid, destName, ...)
            end
            -- npc auras
            if conf.npcId and QA:GetNpcIdFromGuid(sourceGuid) == conf.npcId and QA.db.profile[conf.option] then
                if subevent == "SPELL_AURA_APPLIED" then
                    local keyExtra, duration = destGuid, QA:GetDuration(conf, spellId)
                    local timer = QA:AddTimer(conf.list or WINDOW.ALERT, conf, spellId, duration, GetTime()+duration, nil, nil, keyExtra)
                    if not enemyDebuffs[spellId] then enemyDebuffs[spellId] = {} end
                    enemyDebuffs[spellId][sourceGuid] = timer

                elseif subevent == "SPELL_AURA_REMOVED" and enemyDebuffs[spellId] and enemyDebuffs[spellId][sourceGuid] then
                    -- end offensive timer
                    QA:RemoveTimer(enemyDebuffs[spellId][sourceGuid], "combatlog")
                    enemyDebuffs[spellId][sourceGuid] = nil
                end
            end

            -- taunt
            if conf.taunt and subevent == "SPELL_AURA_APPLIED" and sourceGuid == QA.playerGuid then
                --debug(2, "CLEU ".._c.bold.."Taunt|r spell:", conf.name, "sourceGUID", sourceGuid, "destGUID", destGuid)
                QA.hasTaunted = GetTime() + (QA:GetDuration(conf, spellId) or 1)
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
                    if not conf.aura then -- players aura are not offensive
                        local text, keyExtra, duration = nil, destGuid, QA:GetDuration(conf, spellId)
                        if conf.multi then
                            text = destName
                        end
                        --            QA:AddTimer(window,  conf,  id,     duration,       expTime,                 showAtTime, text, keyExtra)
                        local timer = QA:AddTimer(conf.list or WINDOW.OFFENSIVE, conf, spellId, duration, GetTime()+duration, nil, text, keyExtra)
                        if not conf.aoe then
                            if not enemyDebuffs[extra[1]] then enemyDebuffs[extra[1]] = {} end
                            enemyDebuffs[extra[1]][destGuid] = timer
                        end
                    end
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
                debug(2, "CLEU", "raid bar", conf.name, "spellId", spellId, "subevent", subevent, "sourceGUID", sourceGuid, "destGUID", destGuid)
                if      (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                        and sourceGuid ~= QA.playerGuid
                        and QA.db.profile.raidBars
                --and (not conf.option or QA.db.profile[conf.option.."_rbars"])
                then
                    -- start offensive timer
                    local name = strsplit("-", sourceName)
                    local duration = QA:GetDuration(conf, spellId)
                    local timer = QA:AddTimer(WINDOW.RAIDBARS, conf, spellId, duration, GetTime()+duration, nil, name, name)
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

    if subevent == "UNIT_DIED" then
        if sourceGuid == QA.playerGuid then
            enemyDebuffs = {}
            QA:PlayerDied()
        else
            QA:CheckTargetAuras(true)
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

    -- announce taunt resists
    if      subevent == "SPELL_MISSED" and
            sourceGuid == QA.playerGuid and
            QA.InstanceName and QA.db.profile.announceTauntResists and
            destGuid == UnitGUID("target") and
            type(extra[1]) == "number" and extra[1] > 0
    then
        local spellId = extra[1]
        local missType = extra[4]
        local conf = QA.trackedCombatLog[spellId]
        if conf and conf.taunt and missType == "RESIST" then
            local spellName = conf.name or GetSpellInfo(spellId)
            SendChatMessage(">> "..string.upper(tostring(spellName)).." RESISTED <<", "SAY")
        end
    end

    -- warrior spell cast success events
    if QA.isWarrior and subevent == "SPELL_CAST_SUCCESS" and sourceGuid == QA.playerGuid then
        -- announce Shield Wall activation
        if QA.db.profile.announceShieldWall and QA.spells.warrior.shieldWall.bySpellId[extra[1]] then
            SendChatMessage(">> SHIELD WALL ACTIVATED <<", "PARTY")
            SendChatMessage(">> SHIELD WALL ACTIVATED <<", "YELL")
            
            -- countdown in PARTY chat from 5 to 1 seconds remaining
            C_Timer.After(5, function() SendChatMessage(">> Shield Wall: 5 <<", "YELL") end)
            C_Timer.After(6, function() SendChatMessage(">> Shield Wall: 4 <<", "YELL") end)
            C_Timer.After(7, function() SendChatMessage(">> Shield Wall: 3 <<", "YELL") end)
            C_Timer.After(8, function() SendChatMessage(">> Shield Wall: 2 <<", "YELL") end)
            C_Timer.After(9, function() SendChatMessage(">> Shield Wall: 1 <<", "YELL") end)
        end
        
        -- warrior unqueue spell
        local spell = QA.spells.warrior.heroicStrike.bySpellId[extra[1]] and QA.spells.warrior.heroicStrike
                or QA.spells.warrior.cleave.bySpellId[extra[1]] and QA.spells.warrior.cleave
        if spell then
            QA:UnQueuedSpell(spell)
        end
    end

    if QA.encounter.CombatLog[subevent] then
        QA.encounter.CombatLog[subevent](timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    end

    -- check procs
    for _, spell in ipairs(QA.trackedProcAbilities.combatLog) do
        if QA.db.profile[spell.procFrameOption] then
            local spellCasted = false

            if subevent == "SPELL_CAST_SUCCESS" then
                if spell.bySpellId[extra[1]] == spell.spellId[1] then
                    spellCasted = true -- spell was used, remove it
                end
            end

            if spellCasted or spell.CheckProc(spell, subevent, sourceGuid, sourceName, destGuid, destName, extra) then
                -- doesn't become enabled right away
                C_Timer.After(0.05, function() QA:CheckProcSpellUsable(spell) end)
            end
        end
    end
end
