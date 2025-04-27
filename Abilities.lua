local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
MeleeUtils.abilities = { rogue = {}, warrior = {} }
local abilities = MeleeUtils.abilities

abilities.rogue.bladeFlurry = {
    name = "Blade Flurry",
    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    color = {246/256, 122/256, 0},
    list = MeleeUtils.watchBars,
    option = "rogueFlurryBar",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    cooldown = 120,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.adrenalineRush = {
    name = "Adrenaline Rush",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    color = {246/256, 220/256, 0},
    list = MeleeUtils.watchBars,
    option = "rogueAdrenalineRush",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    cooldown = 300,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.sliceAndDice = {
    name = "Slice and Dice",
    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
    color = {0, 0.9, 0.2},
    list = MeleeUtils.watchBars,
    option = "rogueSndBar",
    parent = MeleeUtils_WatchBars,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.exposeArmor = {
    name = "Expose Armor",
    icon = "Interface\\Icons\\Ability_Warrior_Riposte",
    color = {0.6784, 0.6706, 0.8706},
    list = MeleeUtils.watchBars,
    duration = 30,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueEaBar",
    parent = MeleeUtils_WatchBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueGouge",
    parent = MeleeUtils_OffensiveBars,
    cooldown = 10,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    list = MeleeUtils.offensiveBars,
    duration = 4,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueCheapShot",
    parent = MeleeUtils_OffensiveBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    list = MeleeUtils.offensiveBars,
    duration = 6,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueKidneyShot",
    parent = MeleeUtils_OffensiveBars,
    cooldown = 20,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.vanish = {
    name = "Vanish",
    icon = "Interface\\Icons\\Ability_Vanish",
    color = {0.5, 0.5, 0.5},
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueVanish",
    visible = MeleeUtils.isRogue,
}

abilities.rogue.sprint = {
    name = "Sprint",
    icon = "Interface\\Icons\\Ability_Rogue_Sprint",
    color = {1.0, 0.4195, 0.0000},
    list = MeleeUtils.watchBars,
    duration = 15,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueSprint",
    parent = MeleeUtils_WatchBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.stealth = {
    name = "Stealth",
    icon = "Interface\\Icons\\Ability_Stealth",
    color = {0.4451, 0.7882, 0.8000},
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueStealth",
    visible = MeleeUtils.isRogue,
}

abilities.rogue.kick = {
    name = "Kick",
    icon = "Interface\\Icons\\Ability_Kick",
    color = {0.7, 0.7, 0.7},
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueKick",
    visible = MeleeUtils.isRogue,
}

abilities.rogue.bloodFury = {
    name = "Blood Fury",
    icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    color = {0.5, 0.5, 0.5},
    list = MeleeUtils.watchBars,
    duration = 15,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "bloodFury",
    parent = MeleeUtils_WatchBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.blind = {
    name = "Blind",
    icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
    color = {0.9059, 0.7451, 0.5804},
    list = MeleeUtils.offensiveBars,
    duration = 10,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueBlind",
    parent = MeleeUtils_OffensiveBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.evasion = {
    name = "Evasion",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
    color = {1.0, 0.0606, 1.0},
    list = MeleeUtils.watchBars,
    duration = 15,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueEvasion",
    parent = MeleeUtils_WatchBars,
    visible = MeleeUtils.isRogue,
}

abilities.rogue.sap = {
    name = "Sap",
    icon = "Interface\\Icons\\Ability_Sap",
    color = {0.8941, 0.2157, 0.0627},
    list = MeleeUtils.offensiveBars,
    duration = 45,
    onUpdate = MeleeUtils_Timer_OnUpdate,
    option = "rogueSap",
    parent = MeleeUtils_OffensiveBars,
    visible = MeleeUtils.isRogue,
}
