local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local out = QuickAuras.Print
local ICON = QuickAuras.ICON
local _c = QuickAuras.colors

local FHM_ENCOUNTER = 1121
local FHM_timer
local FHM_mark = 0

function QuickAuras:InitBossLogic()
    self.encounter.OnStart[FHM_ENCOUNTER] = self.FHM_EncounterStart
    self.encounter.OnEnd[FHM_ENCOUNTER] = self.FHM_EncounterEnd
end

function QuickAuras:FHM_EncounterStart()
    out(_c.bold.."4HM".."|r Encounter started")
    FHM_mark = 0
    FHM_timer = C_Timer.NewTimer(21, function()
        QuickAuras:FTM_Mark()
    end)
end

function QuickAuras:FHM_EncounterEnd()
    out(_c.bold.."4HM".."|r Encounter ended")
    if FHM_timer then
        FHM_timer:Cancel()
        FHM_timer = nil
    end
end

function QuickAuras:FTM_Mark()
    FHM_mark = FHM_mark + 1
    local extraText = ""

    local startAt = self.db.profile.encounter4hmStartAt
    if startAt and startAt > 0 then
        local shouldMove = ((FHM_mark - startAt) % self.db.profile.encounter4hmMoveEvery) == 0
        if shouldMove then
            extraText = " ".._c.yellow.."MOVE!".."|r"
        end
    end

    out(_c.bold.."4HM".."|r Mark "..FHM_mark..extraText)
    FHM_timer = C_Timer.NewTimer(13, function()
        QuickAuras:FTM_Mark()
    end)
end
