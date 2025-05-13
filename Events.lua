local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local out = QuickAuras.Print
local _c = QuickAuras.colors

local enemyDebuffs = {}
local raidBuffs = {}

local lastUpdate = 0
local updateInterval = 0.01 -- Execute every 0.1 seconds

local BOSS_LEVEL = 63

-- WoW Events

function QuickAuras:ZONE_CHANGED()
    self:ZoneChanged()
end

function QuickAuras:ZONE_CHANGED_INDOORS()
    self:ZoneChanged()
end

function QuickAuras:ZONE_CHANGED_NEW_AREA()
    self:ZoneChanged()
end

function QuickAuras:PLAYER_ENTERING_WORLD()
    self:ZoneChanged()
end

function QuickAuras:UNIT_AURA(unit)
    if unit ~= "player" then return end
    self:CheckAuras()
end

function QuickAuras:UI_ERROR_MESSAGE(errorType, errorMessage)
    if self.db.profile.outOfRange and UnitAffectingCombat("player") then
        --debug("UI_ERROR_MESSAGE", errorType, errorMessage)
        if  errorMessage == ERR_OUT_OF_RANGE
            or errorMessage == ERR_SPELL_OUT_OF_RANGE
            or errorMessage == "You must be behind your target" then
            self:ShowNoticableError(errorMessage)
        end
    end
end

function QuickAuras:SPELL_UPDATE_COOLDOWN(...)
    self:CheckCooldowns()
end

function QuickAuras:PLAYER_EQUIPMENT_CHANGED(...)
    self:CheckGear("equip", ...)
end

function QuickAuras:PLAYER_TARGET_CHANGED(...)
    self:CheckGear("target", ...)
    self:ResetErrorCount()
end

function QuickAuras:BAG_UPDATE(bagId)
    if bagId >= 0 and bagId <= 4 then
        self:BagsChanged()
    end
end

function QuickAuras:ENCOUNTER_START(encounterId, encounterName)
    self.encounter.id = encounterId
    self.encounter.name = encounterName

    self:CheckMissingBuffs()

    local OnStart = self.encounter.OnStart[encounterId]
    if OnStart and type(OnStart) == "function" then
        OnStart(self)
    end
end

function QuickAuras:ENCOUNTER_END()
    if not self.encounter.id then return end -- not in encounter
    local encounterId = self.encounter.id
    self.encounter.id = nil

    self:CheckMissingBuffs()

    local OnEnd = self.encounter.OnEnd[encounterId]
    if OnEnd and type(OnEnd) == "function" then
        OnEnd(self)
    end
end

function QuickAuras:MINIMAP_UPDATE_TRACKING()
    self:CheckTrackingStatus()
end

function QuickAuras:PLAYER_ALIVE()
    self:CheckTrackingStatus()
end

function QuickAuras:PLAYER_UNGHOST()
    self:CheckTrackingStatus()
end

function QuickAuras:PLAYER_LEVEL_UP()
    self.playerLevel = UnitLevel("player")
end

function QuickAuras:BANKFRAME_OPENED()
    self.bankOpen = true
    self:ScanBank()
end

function QuickAuras:BANKFRAME_CLOSED()
    self.bankOpen = false
end

function QuickAuras:UNIT_POWER_UPDATE(unit, powerType)
    self:CheckPower(unit, powerType)
end

function QuickAuras:PLAYER_REGEN_DISABLED()
    -- in combat
    self.inCombat = true
    self:CheckAuras()
end

function QuickAuras:PLAYER_REGEN_ENABLED()
    -- out of combat
    self.inCombat = false
    self:CheckAuras()
end

function QuickAuras:GROUP_ROSTER_UPDATE()
    self:CheckIfWarriorInParty()
end

function QuickAuras:GROUP_ROSTER_UPDATE()
    self:CheckIfWarriorInParty()
end

function QuickAuras:PARTY_MEMBER_ENABLE()
    self:CheckIfWarriorInParty()
end

-- OnUpdate

function QuickAuras:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckTimers()
        self:CheckTargetRange()
    end
end

-- Combat log

function QuickAuras:COMBAT_LOG_EVENT_UNFILTERED()
    self:HandleCombatLogEvent(CombatLogGetCurrentEventInfo())
end

function QuickAuras:HandleCombatLogEvent(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, p1, p2, p3, p4, p5, p6)
    --debug("CombatLog", subevent, sourceName, destName, p1, p2, p3)

    if  -- parry haste
            self.db.profile.harryPaste and
            subevent == "SWING_MISSED" and
            p1 == "PARRY" and -- missType
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
    if type(p1) == "number" and p1 > 0 then
        for spellId, conf in pairs(self.trackedCombatLog) do
            --debug("CombatLog", "spellId", spellId, "conf.name", conf.name, "p1", p1, "conf.raidBars", conf.raidBars)
            if p1 == spellId then
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
                        if not enemyDebuffs[p1] then enemyDebuffs[p1] = {} end
                        enemyDebuffs[p1][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid == self.playerGuid
                            and enemyDebuffs[p1] and enemyDebuffs[p1][destGuid]
                    then
                        -- end offensive timer
                        self:RemoveTimer(enemyDebuffs[p1][destGuid], "combatlog")
                        enemyDebuffs[p1][destGuid] = nil
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
                        if not raidBuffs[p1] then raidBuffs[p1] = {} end
                        raidBuffs[p1][destGuid] = timer
                    end

                    if  subevent == "SPELL_AURA_REMOVED"
                            and sourceGuid ~= self.playerGuid
                            and raidBuffs[p1] and raidBuffs[p1][destGuid]
                    then
                        -- end offensive timer
                        self:RemoveTimer(raidBuffs[p1][destGuid], "raidbar")
                        raidBuffs[p1][destGuid] = nil
                    end
                end
            end
        end
    end

    -- reset buffs/debuffs of dead unit
    if subevent == "UNIT_DIED" then
        for spellId, conf in pairs(QuickAuras.trackedCombatLog) do
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
        if p5 then
            SendChatMessage(">> Interrupted "..tostring(p5).." <<", "SAY")
        else
            SendChatMessage(">> Interrupted "..destName.." <<", "SAY")
        end
    end

    -- announce misses
    if      subevent == "SWING_MISSED" and
            sourceGuid == self.playerGuid and
            self.InstanceName and self.db.profile.announceMisses and
            destGuid == UnitGUID("target") and
            sourceGuid == UnitGUID("targettarget") and p1
    then
        SendChatMessage(">> "..tostring(p1).." <<", "SAY")
    end

end
