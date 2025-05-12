local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local out = QuickAuras.Print
local ICON = QuickAuras.ICON
local _c = QuickAuras.colors

local FHM_ENCOUNTER = 1121

function QuickAuras:InitBossLogic()
    self.encounter.OnStart[FHM_ENCOUNTER] = self.FHM_EncounterStart
    self.encounter.OnEnd[FHM_ENCOUNTER] = self.FHM_EncounterEnd
end

function QuickAuras:FHM_EncounterStart()
    out(_c.bold.."4HM".."|r Encounter Started")
end

function QuickAuras:FHM_EncounterEnd()
    out(_c.bold.."4HM".."|r Encounter Ended")
end
