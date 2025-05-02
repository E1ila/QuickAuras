local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

local enemyDebuffs = {
    exporeArmor = {},
}

local lastUpdate = 0
local updateInterval = 0.01 -- Execute every 0.1 seconds

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
        for spellId, conf in pairs(self.trackedCombatLog) do
            if p1 == spellId then
                if  (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
                    and sourceGUID == self.playerGuid
                    --and destGUID == UnitGUID("target")
                    and self.db.profile.watchBars
                    and (not conf.option or self.db.profile[conf.option])
                then
                    local timer = self:AddTimer("combatlog", "bar", nil, nil, conf, conf.duration, GetTime()+conf.duration)
                    if not enemyDebuffs[p1] then enemyDebuffs[p1] = {} end
                    enemyDebuffs[p1][destGUID] = timer
                end

                if  subevent == "SPELL_AURA_REMOVED"
                    and sourceGUID == self.playerGuid
                    and enemyDebuffs[p1] and enemyDebuffs[p1][destGUID]
                then
                    self:RemoveTimer(enemyDebuffs[p1][destGUID], "combatlog")
                    enemyDebuffs[p1][destGUID] = nil
                end
            end
        end
    end

    if subevent == "UNIT_DIED" then
        for spellId, conf in pairs(QuickAuras.trackedCombatLog) do
            if enemyDebuffs[spellId] and enemyDebuffs[spellId][destGUID] then
                self:RemoveTimer(enemyDebuffs[spellId][destGUID], "combatlog")
                enemyDebuffs[spellId][destGUID] = nil
            end
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
end

function QuickAuras:BAG_UPDATE(bagID)
    self:ScanBag(bagID)
end

-- OnUpdate

function QuickAuras:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckTimers()
    end
end
