local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local WINDOW = QA.WINDOW
local _c = QA.colors

local FHM = {
    encounterId = 1121,
    timer = nil,
    mark = 0,
}
local KT = {
    encounterId = 1114,
    npcId = 15990,
    phase = 0,
}
local Loatheb = {
    encounterId = 1115,
    npcId = 16011,
    spore = 0,
    alertDuration = 5,
}
local Sapphiron = {
    encounterId = 1119,
    npcId = 15989,
    phase = 0, -- 1 ground, 2 air
    sampleInterval = 0.3,
    minNoTargetTime = 0.5,
}
QA.boss = {
    FHM = FHM,
    KT = KT,
    Loatheb = Loatheb,
    Sapphiron = Sapphiron,
}
QA.trackedEncounters = {}

function QA:InitBossLogic()
    for name, boss in pairs(QA.boss) do
        debug(2, "Adding encounter", name, boss.encounterId)
        QA.trackedEncounters[boss.encounterId] = boss
        boss.name = name
    end
end

function QA:EncounterStarted(encounterId)
    local boss = QA.trackedEncounters[encounterId]
    if boss then
        out(_c.bold..boss.name.."|r Encounter started")
        boss.active = true
        if boss.EncounterStart then
            boss:EncounterStart()
        end
    end
end

function QA:EncounterEnded(encounterId)
    local boss = QA.trackedEncounters[encounterId]
    if boss then
        out(_c.bold..boss.name.."|r Encounter ended")
        boss.active = false
        if boss.timer then
            boss.timer:Cancel()
            boss.timer = nil
        end
        if boss.EncounterEnd then
            boss:EncounterEnd()
        end
    end
    QA.encounter.CombatLog = {}
end

function Sapphiron:EncounterStart()
    self.phase = 1
    self.noTargetTime = 0
    QA.encounter.CombatLog.SPELL_CAST_SUCCESS = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, spellId, spellName, ...)
        if spellId == 28524 then
            self:GroundPhase()
        end
    end
end

function Sapphiron:GroundPhase()
    self.phase = 1
    out(_c.bold..QA.name.."|r Ground Phase")
end

function Sapphiron:AirPhase()
    self.phase = 2
    out(_c.bold..QA.name.."|r Air Phase")
end

function Sapphiron:ScheduleCheckBossTarget()
    self.timer = C_Timer.NewTimer(self.sampleInterval, function()
        if not QA.inCombat then return end
        self:CheckBossTarget()
        self:ScheduleCheckBossTarget()
    end)
end

function Sapphiron:CheckBossTarget()
    local foundBoss, target
    for i = 1, GetNumGroupMembers() do
        local unitId = "raid"..i.."target"
        if UnitExists(unitId) and QA:GetNpcIdFromGuid(UnitGUID(unitId)) == self.npcId and UnitAffectingCombat(unitId) then
            target = UnitName(unitId.."target") -- sapphiron's target
            foundBoss = true
            break
        end
    end
    if foundBoss and not target then
        self.noTargetTime = self.noTargetTime + self.sampleInterval
    elseif foundBoss then
        self.noTargetTime = 0
    end
    --Timers don't appear right for classic, close but might need some slight tweaking
    if self.phase ~= 2 and self.noTargetTime > self.minNoTargetTime then
        self.noTargetTime = 0
        self:AirPhase()
    end
end

function Loatheb:EncounterStart()
    self.spore = 0
    QA.encounter.CombatLog.SPELL_SUMMON = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == self.npcId then
            out(_c.bold..QA.name.."|r "..destName.." spawned")
            self.spore = self.spore + 1
            if QA.db.profile.encounterLoathebStartAt > 0 and self.spore % QA.db.profile.encounterLoathebCycle == QA.db.profile.encounterLoathebStartAt then
                out(_c.bold..QA.name.."|r TAKE SPORE!")
                self:TakeSpore()
            end
        end
    end
end

function Loatheb:TakeSpore()
    local conf = {
        name = "Spore",
        icon = "Interface\\Icons\\spell_nature_unyeildingstamina",
    }
    QA:AddTimer(WINDOW.ALERT, conf, "loatheb-spore", Loatheb.alertDuration, GetTime() + Loatheb.alertDuration)
    QA:PlayAirHorn()
end

function KT:EncounterStart()
    self.phase = 1
    QA.encounter.CombatLog.SWING_DAMAGE = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == self.npcId then
            self.phase = 2
            QA.encounter.CombatLog.SWING_DAMAGE = nil
            out(_c.bold.."KT".."|r Phase 2")
            QA:CheckAuras()
        end
    end
end

function KT:EncounterEnd()
    self.phase = 0
end

function FHM:EncounterStart()
    self.mark = 0
    self.timer = C_Timer.NewTimer(21, function()
        FHM:Mark()
    end)
end

function FHM:Mark()
    self.mark = self.mark + 1
    local extraText = ""

    local startAt = QA.db.profile.encounter4hmStartAt
    if startAt and startAt > 0 then
        local shouldMove = ((self.mark - startAt) % QA.db.profile.encounter4hmMoveEvery) == 0
        if shouldMove then
            extraText = " ".._c.yellow.."MOVE!".."|r"
        end
    end

    out(_c.bold..QA.name.."|r Mark "..self.mark..extraText)
    self.timer = C_Timer.NewTimer(13, function()
        FHM:Mark()
    end)
end
