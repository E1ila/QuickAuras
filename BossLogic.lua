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
QA.boss = {
    FHM = FHM,
    KT = KT,
}

function QA:InitBossLogic()
    self.encounter.OnStart[FHM.encounterId] = self.FHM_EncounterStart
    self.encounter.OnEnd[FHM.encounterId] = self.FHM_EncounterEnd
    self.encounter.OnStart[KT.encounterId] = self.KT_EncounterStart
    self.encounter.OnEnd[KT.encounterId] = self.KT_EncounterEnd
end

function QA:KT_EncounterStart()
    out(_c.bold.."KT".."|r Encounter started")
    KT.phase = 1

    self.encounter.OnSwingDamage = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, p1, p2, p3, p4, p5, p6)
        if QA:GetNpcIdFromGuid(sourceGuid) == KT.npcId then
            KT.phase = 2
            QA.encounter.OnSwingDamage = nil
            out(_c.bold.."KT".."|r Phase 2")
            self:CheckAuras()
        end
    end
end

function QA:KT_EncounterEnd()
    out(_c.bold.."KT".."|r Encounter ended")
    self.encounter.OnSwingDamage = nil
    KT.phase = 0
end

function QA:FHM_EncounterStart()
    out(_c.bold.."4HM".."|r Encounter started")
    FHM.mark = 0
    FHM.timer = C_Timer.NewTimer(21, function()
        QA:FTM_Mark()
    end)
end

function QA:FHM_EncounterEnd()
    out(_c.bold.."4HM".."|r Encounter ended")
    if FHM.timer then
        FHM.timer:Cancel()
        FHM.timer = nil
    end
end

function QA:FTM_Mark()
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
        QA:FTM_Mark()
    end)
end
