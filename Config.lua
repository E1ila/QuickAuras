local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local abilities = MeleeUtils.abilities

MeleeUtils.optionalEvents = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_AURA",
    "UI_ERROR_MESSAGE",
    "SPELL_UPDATE_COOLDOWN",
}

MeleeUtils.adjustableFrames = {
    "MeleeUtils_Parry",
    "MeleeUtils_Combo",
    "MeleeUtils_Flurry",
}

MeleeUtils.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}

-- these will be detected through UNIT_AURA event
MeleeUtils.watchBarAuras = {
    [13877] = abilities.bladeFlurry,
    [13750] = abilities.adrenalineRush,
    [6774] = abilities.sliceAndDice,
    [5277] = abilities.evasion,
    [11305] = abilities.sprint,
}

-- these will be detected through COMBAT_LOG_EVENT_UNFILTERED
MeleeUtils.watchBarCombatLog = {
    [8647] = abilities.exposeArmor, -- 1
    [8649] = abilities.exposeArmor, -- 2
    [8650] = abilities.exposeArmor, -- 3
    [11197] = abilities.exposeArmor, -- 4
    [11198] = abilities.exposeArmor, -- 5
    [1776] = abilities.gouge, -- r1
    [1777] = abilities.gouge, -- r2
    [8629] = abilities.gouge, -- r3
    [11285] = abilities.gouge, -- r4
    [11286] = abilities.gouge, -- r5
    [1833] = abilities.cheapShot,
    [408] = abilities.kidneyShot,  -- r1
    [8643] = abilities.kidneyShot, -- r2
    [2094] = abilities.blind,
    [6770] = abilities.sap,
    [2070] = abilities.sap,
    [11297] = abilities.sap,
}

MeleeUtils.trackedCooldowns = {
    [13750] = abilities.adrenalineRush,
    [13877] = abilities.bladeFlurry,
    [11286] = abilities.gouge,
    [1857] = abilities.vanish,
    [11305] = abilities.sprint,
    [1785] = abilities.stealth,
    [1766] = abilities.kick,
    [20572] = abilities.bloodFury,
    [2094] = abilities.blind,
    [5277] = abilities.evasion,
}
