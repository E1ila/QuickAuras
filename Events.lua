local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

local enemyDebuffs = {
    exporeArmor = {},
}

local lastUpdate = 0
local updateInterval = 0.01 -- Execute every 0.1 seconds

function QuickAuras:CheckCooldowns()
    if not self.db.profile.cooldowns then return end
    for spellID, conf in pairs(self.trackedCooldowns) do
        local start, duration, enabled = GetSpellCooldown(spellID)
        if start > 0 and duration > 2 and (not conf.option or self.db.profile[conf.option.."CD"]) then
            --debug("Cooldown", spellID, conf.name, start, duration, enabled)
            local updatedDuration = duration - (GetTime() - start)
            self:SetProgressTimer("button", self.cooldowns, QuickAuras_Cooldowns, conf, updatedDuration, start + duration, conf.onUpdate, conf.onUpdate)
        end
    end
end

function QuickAuras:CheckAuras()
    if not self.db.profile.watchBars then return end
    local i = 1
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        --debug(UnitAura("player", i, "HELPFUL"))
        if not name then break end -- Exit the loop when no more auras are found
        local conf = self.watchBarAuras[spellID]
        if conf and (not conf.option or self.db.profile[conf.option]) then
            --debug("Aura", name, icon, duration, expTime)
            self:SetProgressTimer("bar", nil, nil, conf, duration, expTime, conf.onUpdate, conf.onUpdate)
        end
        i = i + 1
    end
end

function QuickAuras:UpdateZone()
    local inInstance, instanceType = IsInInstance()
    self.InstanceName = nil
    if inInstance and (instanceType == "raid" or instanceType == "party") then
        self.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
    end
    self.ZoneName = GetRealZoneText()
    debug("Updating Zone:", QAG.ZoneName)
end



-- WoW Events

function QuickAuras:UNIT_POWER_UPDATE(unit, powerType)
    if self.isRogue and self.db.profile.rogue5combo then
        if unit == "player" and powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            self:Rogue_SetCombo(comboPoints)
        end
    end
end

function QuickAuras:ZONE_CHANGED()
    self:UpdateZone()
end

function QuickAuras:ZONE_CHANGED_INDOORS()
    self:UpdateZone()
end

function QuickAuras:ZONE_CHANGED_NEW_AREA()
    self:UpdateZone()
end

function QuickAuras:PLAYER_ENTERING_WORLD()
    self:UpdateZone()
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

function QuickAuras:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, p1, p2, p3 = CombatLogGetCurrentEventInfo()

    --debug("CombatLog", subevent, sourceName, destName, p1, p2, p3)

    if  -- parry haste
        self.db.profile.harryPaste and
        subevent == "SWING_MISSED" and
        sourceGUID == self.playerGuid and
        p1 == "PARRY" and -- missType
        destGUID == UnitGUID("target") and
        self.playerGuid ~= UnitGUID("targettarget") and
        not UnitIsPlayer("target") and
        IsInInstance()
    then
        self:ShowParry()
    end

    if type(p1) == "number" and p1 > 0 then
        for spellID, conf in pairs(self.watchBarCombatLog) do
            if p1 == spellID then
                if  (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                    and sourceGUID == self.playerGuid
                    --and destGUID == UnitGUID("target")
                    and self.db.profile.watchBars
                    and (not conf.option or self.db.profile[conf.option])
                then
                    local timer = self:SetProgressTimer("bar", nil, nil, conf, conf.duration, GetTime()+conf.duration, conf.onUpdate, conf.onUpdate)
                    if not enemyDebuffs[p1] then enemyDebuffs[p1] = {} end
                    enemyDebuffs[p1][destGUID] = timer
                end

                if  subevent == "SPELL_AURA_REMOVED"
                    and sourceGUID == self.playerGuid
                    and enemyDebuffs[p1] and enemyDebuffs[p1][destGUID]
                then
                    self:RemoveProgressTimer(enemyDebuffs[p1][destGUID])
                    enemyDebuffs[p1][destGUID] = nil
                end
            end
        end
    end

    if subevent == "UNIT_DIED" then
        for spellID, conf in pairs(QuickAuras.watchBarCombatLog) do
            if enemyDebuffs[spellID] and enemyDebuffs[spellID][destGUID] then
                self:RemoveProgressTimer(enemyDebuffs[spellID][destGUID])
                enemyDebuffs[spellID][destGUID] = nil
            end
        end
    end
end

function QuickAuras:SPELL_UPDATE_COOLDOWN(...)
    self:CheckCooldowns()
end


-- OnUpdate

function QuickAuras:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckProgressTimers()
    end
end
