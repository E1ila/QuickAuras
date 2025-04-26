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

MeleeUtils.watchBarAuras = {
    [13877] = {
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
        list = MeleeUtils.watchBars,
        option = "rogueFlurryBar",
    },
    [13750] = {
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        color = {246/256, 220/256, 0},
        list = MeleeUtils.watchBars,
        option = "rogueArBar",
    },
    [6774] = {
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
        list = MeleeUtils.watchBars,
        option = "rogueSndBar",
    },
}

MeleeUtils.watchBarOffensive = {
    [11198] = {
        name = "Expose Armor",
        icon = "Interface\\Icons\\Ability_Warrior_Riposte",
        color = {0.0, 0.0, 1.0},
        list = MeleeUtils.watchBars,
    },
}

MeleeUtils.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}
