local ADDON_NAME, addon = ...
local MeleeUtils = addon.root

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

MeleeUtils.watchBarAuras = {
    [13877] = {
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
        list = MeleeUtils.watchBars,
        option = "rogueFlurryBar",
        parent = MeleeUtils_WatchBars,
    },
    [13750] = {
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        color = {246/256, 220/256, 0},
        list = MeleeUtils.watchBars,
        option = "rogueArBar",
        parent = MeleeUtils_WatchBars,
    },
    [6774] = {
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
        list = MeleeUtils.watchBars,
        option = "rogueSndBar",
        parent = MeleeUtils_WatchBars,
    },
}

function MeleeUtils_Timer_OnUpdate(timer)
    return MeleeUtils:UpdateProgressBar(timer)
end

local _exposeArmor = {
    name = "Expose Armor",
    icon = "Interface\\Icons\\Ability_Warrior_Riposte",
    color = {0.0, 0.0, 1.0},
    list = MeleeUtils.watchBars,
    duration = 30,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueEaBar",
    parent = MeleeUtils_WatchBars,
}
local _gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueGouge",
    parent = MeleeUtils_OffensiveBars,
}
local _cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    list = MeleeUtils.offensiveBars,
    duration = 4,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueCheapShot",
    parent = MeleeUtils_OffensiveBars,
}
local _kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueKidneyShot",
    parent = MeleeUtils_OffensiveBars,
}

MeleeUtils.watchBarOffensive = {
    [8647] = _exposeArmor, -- 1
    [8649] = _exposeArmor, -- 2
    [8650] = _exposeArmor, -- 3
    [11197] = _exposeArmor, -- 4
    [11198] = _exposeArmor, -- 5
    [1776] = _gouge, -- r1
    [1777] = _gouge, -- r2
    [8629] = _gouge, -- r3
    [11285] = _gouge, -- r4
    [11286] = _gouge, -- r5
    [1833] = _cheapShot,
    [408] = _kidneyShot,  -- r1
    [8643] = _kidneyShot, -- r2
}

MeleeUtils.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}
