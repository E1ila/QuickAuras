local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local ICON = QA.ICON
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
}
QA.boss = {
    FHM = FHM,
    KT = KT,
    Loatheb = Loatheb,
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
        boss:EncounterStart()
    end
end

function QA:EncounterEnded(encounterId)
    local boss = QA.trackedEncounters[encounterId]
    if boss then
        out(_c.bold..boss.name.."|r Encounter ended")
        boss:EncounterEnd()
    end
end

function Loatheb:EncounterStart()
    self.spore = 0
    QA.encounter.OnSpellSummon = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == self.npcId then
            out(_c.bold..QA.name.."|r "..destName.." spawned")
            self.spore = self.spore + 1
            if QA.db.profile.encounterLoathebStartAt > 0 and self.spore % QA.db.profile.encounterLoathebCycle == QA.db.profile.encounterLoathebStartAt then
                out(_c.bold..QA.name.."|r TAKE SPORE!")
            end
        end
    end
end

function Loatheb:EncounterEnd()
    QA.OnSpellSummon = nil
end

function KT:EncounterStart()
    self.phase = 1
    QA.encounter.OnSwingDamage = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == self.npcId then
            self.phase = 2
            QA.encounter.OnSwingDamage = nil
            out(_c.bold.."KT".."|r Phase 2")
            QA:CheckAuras()
        end
    end
end

function KT:EncounterEnd()
    QA.encounter.OnSwingDamage = nil
    self.phase = 0
end

function FHM:EncounterStart()
    self.mark = 0
    self.timer = C_Timer.NewTimer(21, function()
        FHM:Mark()
    end)
end

function FHM:EncounterEnd()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
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
