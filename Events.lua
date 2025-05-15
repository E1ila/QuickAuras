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
    self:ZoneChanged()
end

function QA:ZONE_CHANGED_INDOORS()
    self:ZoneChanged()
end

function QA:ZONE_CHANGED_NEW_AREA()
    self:ZoneChanged()
end

function QA:PLAYER_ENTERING_WORLD()
    self:ZoneChanged()
end

function QA:UNIT_AURA(unit)
    if unit ~= "player" then return end
    self:CheckAuras()
end

function QA:UI_ERROR_MESSAGE(errorType, errorMessage)
    if self.db.profile.outOfRange and UnitAffectingCombat("player") then
        --debug("UI_ERROR_MESSAGE", errorType, errorMessage)
        if  errorMessage == ERR_OUT_OF_RANGE
            or errorMessage == ERR_SPELL_OUT_OF_RANGE
            or errorMessage == "You must be behind your target" then
            self:ShowNoticableError(errorMessage)
        end
    end
end

function QA:SPELL_UPDATE_COOLDOWN(...)
    self:CheckCooldowns()
end

function QA:PLAYER_EQUIPMENT_CHANGED(...)
    self:CheckGear("equip", ...)
end

function QA:PLAYER_TARGET_CHANGED(...)
    self:CheckGear("target", ...)
    self:CheckWarriorExecute()
    self:CheckWarriorOverpower()
    self:ResetErrorCount()
end

function QA:BAG_UPDATE(bagId)
    if bagId >= 0 and bagId <= 4 then
        self:BagsChanged()
    end
end

function QA:ENCOUNTER_START(encounterId, encounterName)
    self.encounter.id = encounterId
    self.encounter.name = encounterName

    self:CheckMissingBuffs()

    local OnStart = self.encounter.OnStart[encounterId]
    if OnStart and type(OnStart) == "function" then
        OnStart(self)
    end
end

function QA:ENCOUNTER_END()
    if not self.encounter.id then return end -- not in encounter
    local encounterId = self.encounter.id
    self.encounter.id = nil

    self:CheckMissingBuffs()

    local OnEnd = self.encounter.OnEnd[encounterId]
    if OnEnd and type(OnEnd) == "function" then
        OnEnd(self)
    end
end

function QA:MINIMAP_UPDATE_TRACKING()
    self:CheckTrackingStatus()
end

function QA:PLAYER_ALIVE()
    self:CheckTrackingStatus()
end

function QA:PLAYER_UNGHOST()
    self:CheckTrackingStatus()
end

function QA:PLAYER_LEVEL_UP()
    self.playerLevel = UnitLevel("player")
end

function QA:BANKFRAME_OPENED()
    self.bankOpen = true
    self:ScanBank()
end

function QA:BANKFRAME_CLOSED()
    self.bankOpen = false
end

function QA:UNIT_POWER_UPDATE(unit, powerType)
    self:CheckPower(unit, powerType)
end

function QA:PLAYER_REGEN_DISABLED()
    -- in combat
    self.inCombat = true
    self:CheckAuras()
end

function QA:PLAYER_REGEN_ENABLED()
    -- out of combat
    self.inCombat = false
    self:CheckAuras()
end

function QA:GROUP_ROSTER_UPDATE()
    self:CheckIfWarriorInParty()
end

function QA:GROUP_ROSTER_UPDATE()
    self:CheckIfWarriorInParty()
end

function QA:PARTY_MEMBER_ENABLE()
    self:CheckIfWarriorInParty()
end

function QA:SPELL_UPDATE_USABLE(a, b, c)
    -- happens too much
end

function QA:UPDATE_SHAPESHIFT_FORM(...)
    self.shapeshiftForm = GetShapeshiftForm()
    --debug("UPDATE_SHAPESHIFT_FORM", self.shapeshiftForm, ...)
end

-- OnUpdate

function QA:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckTimers()
        self:CheckTargetRange()
    end
end

-- Combat log

local DAMAGE_SUBEVENTS = {
    SWING_DAMAGE = true,
    SPELL_DAMAGE = true,
}

function QA:COMBAT_LOG_EVENT_UNFILTERED()
    self:HandleCombatLogEvent(CombatLogGetCurrentEventInfo())
end

function QA:HandleCombatLogEvent(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    local extra = {...}
    --debug("CombatLog", subevent, sourceName, destName, ...)

    if  -- parry haste
            self.db.profile.harryPaste and
            subevent == "SWING_MISSED" and
            extra[1] == "PARRY" and -- missType
            destGuid == UnitGUID("target") and
            sourceGuid ~= UnitGUID("targettarget") and
            not UnitIsPlayer("target") and
            IsInInstance()
    then
        if sourceGuid == self.playerGuid then
            self:ShowParry()
        elseif UnitLevel("target") >= BOSS_LEVEL then
            out("|cffff0000Warning:|r "..destName.." has parried ".._c.bold..sourceName.."|r hit!")
        end
    end

    -- tracked spells
    if type(extra[1]) == "number" and extra[1] > 0 then
        for spellId, conf in pairs(self.trackedCombatLog) do
            --debug("CombatLog", "spellId", spellId, "conf.name", conf.name, "extra1", extra[1], "conf.raidBars", conf.raidBars)
            if extra[1] == spellId then
                -- offensive debuffs
                if conf.duration and conf.list then
                    if  (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                            and sourceGuid == self.playerGuid
                            --and destGUID == UnitGUID("target")
                            and self.db.profile.watchBars
                            and (not conf.option or self.db.profile[conf.option])
                    then
                        -- start offensive timer
                        local timer = self:AddTimer("combatlog", conf, spellId, conf.duration, GetTime()+conf.duration)
                        if not enemyDebuffs[extra[1]] then enemyDebuffs[extra[1]] = {} end
                        enemyDebuffs[extra[1]][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid == self.playerGuid
                            and enemyDebuffs[extra[1]] and enemyDebuffs[extra[1]][destGuid]
                    then
                        -- end offensive timer
                        self:RemoveTimer(enemyDebuffs[extra[1]][destGuid], "combatlog")
                        enemyDebuffs[extra[1]][destGuid] = nil
                    end
                end
                -- raid tracking
                if conf.raidBars and IsInInstance() then
                    debug(2, "Raid tracking", conf.name, "spellId", spellId, "subevent", subevent, "sourceGUID", sourceGuid, "destGUID", destGuid)
                    if      (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                            and sourceGuid ~= self.playerGuid
                            and self.db.profile.raidBars
                            --and (not conf.option or self.db.profile[conf.option.."_rbars"])
                    then
                        -- start offensive timer
                        local name = strsplit("-", sourceName)
                        local timer = self:AddTimer("raidbar", conf, spellId, conf.duration, GetTime()+conf.duration, nil, name, name)
                        if not raidBuffs[extra[1]] then raidBuffs[extra[1]] = {} end
                        raidBuffs[extra[1]][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid ~= self.playerGuid
                            and raidBuffs[extra[1]] and raidBuffs[extra[1]][destGuid]
                    then
                        -- end offensive timer
                        self:RemoveTimer(raidBuffs[extra[1]][destGuid], "raidbar")
                        raidBuffs[extra[1]][destGuid] = nil
                    end
                end
            end
        end
    end

    -- reset buffs/debuffs of dead unit
    if subevent == "UNIT_DIED" then
        for spellId, conf in pairs(QA.trackedCombatLog) do
            if enemyDebuffs[spellId] and enemyDebuffs[spellId][destGuid] then
                self:RemoveTimer(enemyDebuffs[spellId][destGuid], "combatlog")
                enemyDebuffs[spellId][destGuid] = nil
            end
            if raidBuffs[spellId] and raidBuffs[spellId][destGuid] then
                self:RemoveTimer(raidBuffs[spellId][destGuid], "raidbar")
                raidBuffs[spellId][destGuid] = nil
            end
        end
    end

    -- announce interrupts
    if      subevent == "SPELL_INTERRUPT" and
            sourceGuid == self.playerGuid and
            self.InstanceName and self.db.profile.announceInterrupts and
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
            sourceGuid == self.playerGuid and
            self.InstanceName and self.db.profile.announceMisses and
            destGuid == UnitGUID("target") and
            sourceGuid == UnitGUID("targettarget") and extra[1]
    then
        SendChatMessage(">> "..tostring(extra[1]).." <<", "SAY")
    end

    if self.encounter.OnSwingDamage and subevent == "SWING_DAMAGE" then
        self.encounter.OnSwingDamage(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
    end

    if QA.isWarrior then
        if QA.db.profile.warriorOverpower and QA.shapeshiftForm == QA.warrior.stance.battle and sourceGuid == self.playerGuid then
            local overpower = QA.spells.warrior.overpower
            -- overpower
            if subevent == "SWING_MISSED" and overpower.triggers[extra[1]] or subevent == "SPELL_MISSED" and overpower.triggers[extra[4]] then
                -- someone dodged
                C_Timer.After(0.05, function() QA:CheckWarriorOverpower() end) -- doesn't become enabled right away
            end
            if subevent == "SPELL_CAST_SUCCESS"  then
                local spellId = overpower.bySpellId[extra[1]]
                --debug("SPELL_CAST_SUCCESS", extra[1], spellId)
                if spellId == overpower.spellId[1] then
                    -- used ovepower
                    C_Timer.After(0.05, function() QA:CheckWarriorOverpower() end)
                end
            end
        end
        if QA.db.profile.warriorRevenge and QA.shapeshiftForm == QA.warrior.stance.defensive and destGuid == self.playerGuid then
            local revenge = QA.spells.warrior.revenge
            local partiallyBlocked = false
            local blockIndex = 5
            if DAMAGE_SUBEVENTS[subevent] then
                if subevent == "SPELL_DAMAGE" then blockIndex = blockIndex+3 end
                if extra[blockIndex] and tonumber(extra[blockIndex]) > 0 then -- block amount
                    partiallyBlocked = true
                end
            end
            -- overpower
            if      partiallyBlocked
                    or subevent == "SWING_MISSED" and revenge.triggers[extra[1]]
                    or (subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED") and revenge.triggers[extra[4]]
            then
                -- someone dodged
                C_Timer.After(0.05, function() QA:CheckWarriorRevenge() end) -- doesn't become enabled right away
            end
            if subevent == "SPELL_CAST_SUCCESS"  then
                local spellId = revenge.bySpellId[extra[1]]
                --debug("SPELL_CAST_SUCCESS", extra[1], spellId)
                if spellId == revenge.spellId[1] then
                    -- used ovepower
                    C_Timer.After(0.05, function() QA:CheckWarriorRevenge() end)
                end
            end
        end
    end
end
