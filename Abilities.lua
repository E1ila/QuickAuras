local ADDON_NAME, addon = ...
local QuickAuras = addon.root
QuickAuras.abilities = { rogue = {}, warrior = {} }
local abilities = QuickAuras.abilities

abilities.rogue.bladeFlurry = {
    name = "Blade Flurry",
    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    color = {246/256, 122/256, 0},
    list = QuickAuras.watchBars,
    option = "rogueFlurryBar",
    parent = QuickAuras_WatchBars,
    onUpdate = QuickAuras_Timer_OnUpdate,
    cooldown = 120,
    visible = QuickAuras.isRogue,
}

abilities.rogue.adrenalineRush = {
    name = "Adrenaline Rush",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    color = {246/256, 220/256, 0},
    list = QuickAuras.watchBars,
    option = "rogueAdrenalineRush",
    parent = QuickAuras_WatchBars,
    onUpdate = QuickAuras_Timer_OnUpdate,
    cooldown = 300,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sliceAndDice = {
    name = "Slice and Dice",
    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
    color = {0, 0.9, 0.2},
    list = QuickAuras.watchBars,
    option = "rogueSndBar",
    parent = QuickAuras_WatchBars,
    onUpdate = QuickAuras_Timer_OnUpdate,
    visible = QuickAuras.isRogue,
}

abilities.rogue.exposeArmor = {
    name = "Expose Armor",
    icon = "Interface\\Icons\\Ability_Warrior_Riposte",
    color = {0.6784, 0.6706, 0.8706},
    list = QuickAuras.watchBars,
    duration = 30,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueEaBar",
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    list = QuickAuras.offensiveBars,
    duration = 6,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueGouge",
    parent = QuickAuras_OffensiveBars,
    cooldown = 10,
    visible = QuickAuras.isRogue,
}

abilities.rogue.cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    list = QuickAuras.offensiveBars,
    duration = 4,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueCheapShot",
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    list = QuickAuras.offensiveBars,
    duration = 6,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueKidneyShot",
    parent = QuickAuras_OffensiveBars,
    cooldown = 20,
    visible = QuickAuras.isRogue,
}

abilities.rogue.vanish = {
    name = "Vanish",
    icon = "Interface\\Icons\\Ability_Vanish",
    color = {0.5, 0.5, 0.5},
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueVanish",
    visible = QuickAuras.isRogue,
}

abilities.rogue.sprint = {
    name = "Sprint",
    icon = "Interface\\Icons\\Ability_Rogue_Sprint",
    color = {1.0, 0.4195, 0.0000},
    list = QuickAuras.watchBars,
    duration = 15,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueSprint",
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.stealth = {
    name = "Stealth",
    icon = "Interface\\Icons\\Ability_Stealth",
    color = {0.4451, 0.7882, 0.8000},
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueStealth",
    visible = QuickAuras.isRogue,
}

abilities.rogue.kick = {
    name = "Kick",
    icon = "Interface\\Icons\\Ability_Kick",
    color = {0.7, 0.7, 0.7},
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueKick",
    visible = QuickAuras.isRogue,
}

abilities.rogue.bloodFury = {
    name = "Blood Fury",
    icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    color = {0.5, 0.5, 0.5},
    list = QuickAuras.watchBars,
    duration = 15,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "bloodFury",
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.blind = {
    name = "Blind",
    icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
    color = {0.9059, 0.7451, 0.5804},
    list = QuickAuras.offensiveBars,
    duration = 10,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueBlind",
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.evasion = {
    name = "Evasion",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
    color = {1.0, 0.0606, 1.0},
    list = QuickAuras.watchBars,
    duration = 15,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueEvasion",
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sap = {
    name = "Sap",
    icon = "Interface\\Icons\\Ability_Sap",
    color = {0.8941, 0.2157, 0.0627},
    list = QuickAuras.offensiveBars,
    duration = 45,
    onUpdate = QuickAuras_Timer_OnUpdate,
    option = "rogueSap",
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}
