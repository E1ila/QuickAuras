local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug


function MeleeUtils:CheckAuras()
    if not self.db.profile.spellProgress then return end
    local i = 1
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        --debug(UnitAura("player", i, "HELPFUL"))
        if not name then break end -- Exit the loop when no more auras are found
        local progressSpell = self.progressSpells[spellID]
        if progressSpell then
            --debug("Aura", name, icon, duration, expTime)
            local onUpdate = function(timer)
                return MeleeUtils:UpdateProgress(timer)
            end
            self:AddTimer(progressSpell, duration, expTime, onUpdate, onUpdate)
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
    if _isRogue and self.db.profile.rogue5combo then
        if unit == "player" and powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            self:Rogue_SetCombo(comboPoints)
        end
    end
end

function MeleeUtils:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, p1, p2, p3 = CombatLogGetCurrentEventInfo()

    if  -- parry haste
    self.db.profile.harryPaste and
            subevent == "SWING_MISSED" and
            sourceGUID == _playerGuid and
            p1 == "PARRY" and -- missType
            destGUID == UnitGUID("target") and
            _playerGuid ~= UnitGUID("targettarget") and
            not UnitIsPlayer("target") and
            IsInInstance()
    then
        self:ShowParry()
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

-- OnUpdate

local lastUpdate = 0
local updateInterval = 0.1 -- Execute every 0.1 seconds

function MeleeUtils:OnUpdate()
    local currentTime = GetTime()
    if self.db.profile.spellProgress and currentTime - lastUpdate >= updateInterval then
        lastUpdate = currentTime
        self:CheckTimers()
    end
end
