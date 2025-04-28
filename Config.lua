local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local abilities = QuickAuras.abilities

QuickAuras.optionalEvents = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_AURA",
    "UI_ERROR_MESSAGE",
    "SPELL_UPDATE_COOLDOWN",
}

QuickAuras.adjustableFrames = {
    "QuickAuras_Parry",
    "QuickAuras_Combo",
    "QuickAuras_Flurry",
}

QuickAuras.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}

local function removeNonVisible(list)
    local newTable = {}
    for k, v in pairs(list) do
        if v.visible then
            newTable[k] = v
        end
    end
    return newTable
end

-- these will be detected through UNIT_AURA event
QuickAuras.trackedAuras = removeNonVisible({
    [13877] = abilities.rogue.bladeFlurry,
    [13750] = abilities.rogue.adrenalineRush,
    [6774] = abilities.rogue.sliceAndDice,
    [5277] = abilities.rogue.evasion,
    [11305] = abilities.rogue.sprint,
    [20572] = abilities.orc.bloodFury,
})

-- these will be detected through COMBAT_LOG_EVENT_UNFILTERED
QuickAuras.trackedCombatLog = removeNonVisible({
    [8647] = abilities.rogue.exposeArmor, -- 1
    [8649] = abilities.rogue.exposeArmor, -- 2
    [8650] = abilities.rogue.exposeArmor, -- 3
    [11197] = abilities.rogue.exposeArmor, -- 4
    [11198] = abilities.rogue.exposeArmor, -- 5
    [1776] = abilities.rogue.gouge, -- r1
    [1777] = abilities.rogue.gouge, -- r2
    [8629] = abilities.rogue.gouge, -- r3
    [11285] = abilities.rogue.gouge, -- r4
    [11286] = abilities.rogue.gouge, -- r5
    [1833] = abilities.rogue.cheapShot,
    [408] = abilities.rogue.kidneyShot,  -- r1
    [8643] = abilities.rogue.kidneyShot, -- r2
    [2094] = abilities.rogue.blind,
    [6770] = abilities.rogue.sap,
    [2070] = abilities.rogue.sap,
    [11297] = abilities.rogue.sap,
})

QuickAuras.trackedCooldowns = removeNonVisible({
    [20572] = abilities.orc.bloodFury,
    [13750] = abilities.rogue.adrenalineRush,
    [13877] = abilities.rogue.bladeFlurry,
    [1776] = abilities.rogue.gouge,
    [1777] = abilities.rogue.gouge,
    [8629] = abilities.rogue.gouge,
    [11285] = abilities.rogue.gouge,
    [11286] = abilities.rogue.gouge,
    [1856] = abilities.rogue.vanish,
    [1857] = abilities.rogue.vanish,
    [2983] = abilities.rogue.sprint,
    [8696] = abilities.rogue.sprint,
    [11305] = abilities.rogue.sprint,
    [1784] = abilities.rogue.stealth,
    [1785] = abilities.rogue.stealth,
    [1786] = abilities.rogue.stealth,
    [1787] = abilities.rogue.stealth,
    [1766] = abilities.rogue.kick,
    [1767] = abilities.rogue.kick,
    [1768] = abilities.rogue.kick,
    [1769] = abilities.rogue.kick,
    [2094] = abilities.rogue.blind,
    [5277] = abilities.rogue.evasion,
    [408] = abilities.rogue.kidneyShot,  -- r1
    [8643] = abilities.rogue.kidneyShot, -- r2
})
