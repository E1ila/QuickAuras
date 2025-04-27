local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local abilities = MeleeUtils.abilities

MeleeUtils.optionalEvents = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_AURA",
    "UI_ERROR_MESSAGE",
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
}
