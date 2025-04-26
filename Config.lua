local ADDON_NAME, addon = ...
local MeleeUtils = addon.root

MeleeUtils.optionalEvents = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_AURA",
}

MeleeUtils.adjustableFrames = {
    "MeleeUtils_Parry",
    "MeleeUtils_Combo",
    "MeleeUtils_Flurry",
}

MeleeUtils.progressSpells = {
    [13877] = {
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
    },
    [13750] = {
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Ability_Rogue_AdrenalineRush",
        color = {246/256, 220/256, 0},
    },
    [6774] = {
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
    },
}

MeleeUtils.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}
