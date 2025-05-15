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
    Loatheb.spore = 0
    self.encounter.OnSpellSummon = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == Loatheb.npcId then
            out(_c.bold.."KT".."|r "..destName.." spawned")
            Loatheb.spore = Loatheb.spore + 1
        end
    end
end

function Loatheb:EncounterEnd()
    out(_c.bold.."Loatheb".."|r Encounter ended")
    self.OnSpellSummon = nil
end

function KT:EncounterStart()
    out(_c.bold.."KT".."|r Encounter started")
    KT.phase = 1

    self.encounter.OnSwingDamage = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, ...)
        if QA:GetNpcIdFromGuid(sourceGuid) == KT.npcId then
            KT.phase = 2
            QA.encounter.OnSwingDamage = nil
            out(_c.bold.."KT".."|r Phase 2")
            self:CheckAuras()
        end
    end
end

function KT:EncounterEnd()
    out(_c.bold.."KT".."|r Encounter ended")
    self.encounter.OnSwingDamage = nil
    KT.phase = 0
end

function FHM:EncounterStart()
    out(_c.bold.."4HM".."|r Encounter started")
    FHM.mark = 0
    FHM.timer = C_Timer.NewTimer(21, function()
        FTM:Mark()
    end)
end

function FHM:EncounterEnd()
    out(_c.bold.."4HM".."|r Encounter ended")
    if FHM.timer then
        FHM.timer:Cancel()
        FHM.timer = nil
    end
end

function FTM:Mark()
    FHM.mark = FHM.mark + 1
    local extraText = ""

    local startAt = self.db.profile.encounter4hmStartAt
    if startAt and startAt > 0 then
        local shouldMove = ((FHM.mark - startAt) % self.db.profile.encounter4hmMoveEvery) == 0
        if shouldMove then
            extraText = " ".._c.yellow.."MOVE!".."|r"
        end
    end

    out(_c.bold.."4HM".."|r Mark "..FHM.mark..extraText)
    FHM.timer = C_Timer.NewTimer(13, function()
        FTM:Mark()
    end)
end
