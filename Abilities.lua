local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
MeleeUtils.abilities = {}
local abilities = MeleeUtils.abilities

abilities.bladeFlurry = {
    name = "Blade Flurry",
    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    color = {246/256, 122/256, 0},
    list = MeleeUtils.watchBars,
    option = "rogueFlurryBar",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    cooldown = 120,
}

abilities.adrenalineRush = {
    name = "Adrenaline Rush",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    color = {246/256, 220/256, 0},
    list = MeleeUtils.watchBars,
    option = "rogueArBar",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    cooldown = 300
}

abilities.sliceAndDice = {
    name = "Slice and Dice",
    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
    color = {0, 0.9, 0.2},
    list = MeleeUtils.watchBars,
    option = "rogueSndBar",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
}

abilities.exposeArmor = {
    name = "Expose Armor",
    icon = "Interface\\Icons\\Ability_Warrior_Riposte",
    color = {0.0, 0.0, 1.0},
    list = MeleeUtils.watchBars,
    duration = 30,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueEaBar",
    parent = MeleeUtils_WatchBars,
}

abilities.gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueGouge",
    parent = MeleeUtils_OffensiveBars,
    cooldown = 10,
}

abilities.cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    list = MeleeUtils.offensiveBars,
    duration = 4,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueCheapShot",
    parent = MeleeUtils_OffensiveBars,
}

abilities.kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueKidneyShot",
    parent = MeleeUtils_OffensiveBars,
    cooldown = 20,
}
