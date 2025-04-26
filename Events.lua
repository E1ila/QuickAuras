local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug

function MeleeUtils:CheckAuras()
    if not self.db.profile.watchBars then return end
    local i = 1
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        --debug(UnitAura("player", i, "HELPFUL"))
        if not name then break end -- Exit the loop when no more auras are found
        local progressSpell = self.watchBarAuras[spellID]
        if progressSpell and (not progressSpell.option or self.db.profile[progressSpell.option]) then
            --debug("Aura", name, icon, duration, expTime)
            self:SetProgressTimer(progressSpell, duration, expTime, MeleeUtils_Timer_OnUpdate, MeleeUtils_Timer_OnUpdate)
        end
        i = i + 1
    end
end

function MeleeUtils:UpdateZone()
    local inInstance, instanceType = IsInInstance()
    self.InstanceName = nil
    if inInstance and (instanceType == "raid" or instanceType == "party") then
        self.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
    end
    self.ZoneName = GetRealZoneText()
    debug("Updating Zone:", MUGLOBAL.ZoneName)
end



-- WoW Events

function MeleeUtils:UNIT_POWER_UPDATE(unit, powerType)
    if self.isRogue and self.db.profile.rogue5combo then
        if unit == "player" and powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            self:Rogue_SetCombo(comboPoints)
        end
    end
end

local exporeArmor = {

}

function MeleeUtils:COMBAT_LOG_EVENT_UNFILTERED()
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

    if self.db.profile.watchBars and self.db.profile.rogueEaBar then
        if  -- IEA apply
            (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")
            and sourceGUID == self.playerGuid
            and p1 == 11198 -- IEA
            and destGUID == UnitGUID("target")
        then
            local progressSpell = self.watchBarOffensive[p1]
            local timer = self:SetProgressTimer(progressSpell, 30, GetTime()+30, MeleeUtils_Timer_OnUpdate, MeleeUtils_Timer_OnUpdate)
            exporeArmor[destGUID] = timer
        end

        if  -- IEA remove
            subevent == "SPELL_AURA_REMOVED"
            and sourceGUID == self.playerGuid
            and p1 == 11198 -- IEA
            and exporeArmor[destGUID]
        then
            self:RemoveProgressTimer(exporeArmor[destGUID])
            exporeArmor[destGUID] = nil
        end

        if -- IEA remove
            subevent == "UNIT_DIED"
            and exporeArmor[destGUID]
        then
            self:RemoveProgressTimer(exporeArmor[destGUID])
            exporeArmor[destGUID] = nil
        end
    end
end

function MeleeUtils:ZONE_CHANGED()
    self:UpdateZone()
end

function MeleeUtils:ZONE_CHANGED_INDOORS()
    self:UpdateZone()
end

function MeleeUtils:ZONE_CHANGED_NEW_AREA()
    self:UpdateZone()
end

function MeleeUtils:PLAYER_ENTERING_WORLD()
    self:UpdateZone()
end

function MeleeUtils:UNIT_AURA(unit)
    if unit ~= "player" then return end
    self:CheckAuras()
end

function MeleeUtils:UI_ERROR_MESSAGE(errorType, errorMessage)
    if self.db.profile.outOfRange then
        --debug("UI_ERROR_MESSAGE", errorType, errorMessage)
        if errorMessage == ERR_OUT_OF_RANGE or errorMessage == ERR_SPELL_OUT_OF_RANGE or errorMessage == "You must be behind your target" then
            self:ShowNoticableError(errorMessage)
        end
    end
end

-- OnUpdate

local lastUpdate = 0
local updateInterval = 0.1 -- Execute every 0.1 seconds

function MeleeUtils:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.watchBars and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckProgressTimers()
    end
end
