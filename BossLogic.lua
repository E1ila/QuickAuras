local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local out = QuickAuras.Print
local ICON = QuickAuras.ICON
local _c = QuickAuras.colors

local FHM = {
    ENCOUNTER = 1121,
    timer = nil,
    mark = 0,
}
local KT = {
    ENCOUNTER = 1114,
    NPC_ID = 15990,
    phase = 0,
}

function QuickAuras:InitBossLogic()
    self.encounter.OnStart[FHM.ENCOUNTER] = self.FHM_EncounterStart
    self.encounter.OnEnd[FHM.ENCOUNTER] = self.FHM_EncounterEnd
    self.encounter.OnStart[KT.ENCOUNTER] = self.KT_EncounterStart
    self.encounter.OnEnd[KT.ENCOUNTER] = self.KT_EncounterEnd
end

function QuickAuras:KT_EncounterStart()
    out(_c.bold.."KT".."|r Encounter started")
    KT.phase = 1

    self.encounter.OnSwingDamage = function(timestamp, subevent, _, sourceGuid, sourceName, _, _, destGuid, destName, _, _, p1, p2, p3, p4, p5, p6)
        if QuickAuras:GetNpcIdFromGuid(sourceGuid) == KT.NPC_ID then
            KT.phase = 2
            QuickAuras.encounter.OnSwingDamage = nil
            out(_c.bold.."KT".."|r Phase 2")
            self:CheckAuras()
        end
    end
end

function QuickAuras:KT_EncounterEnd()
    out(_c.bold.."KT".."|r Encounter ended")
    self.encounter.OnSwingDamage = nil
end

function QuickAuras:FHM_EncounterStart()
    out(_c.bold.."4HM".."|r Encounter started")
    FHM.mark = 0
    FHM.timer = C_Timer.NewTimer(21, function()
        QuickAuras:FTM_Mark()
    end)
end

function QuickAuras:FHM_EncounterEnd()
    out(_c.bold.."4HM".."|r Encounter ended")
    if FHM.timer then
        FHM.timer:Cancel()
        FHM.timer = nil
    end
end

function QuickAuras:FTM_Mark()
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
        QuickAuras:FTM_Mark()
    end)
end
