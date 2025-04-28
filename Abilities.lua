local ADDON_NAME, addon = ...
local QuickAuras = addon.root
QuickAuras.abilities = { rogue = {}, warrior = {}, orc = {} }
local abilities = QuickAuras.abilities

abilities.orc.bloodFury = {
    name = "Blood Fury",
    icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    color = {0.5, 0.5, 0.5},
    list = QuickAuras.watchBars,
    duration = 15,
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_WatchBars,
}

abilities.rogue.bladeFlurry = {
    name = "Blade Flurry",
    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    color = {246/256, 122/256, 0},
    list = QuickAuras.watchBars,
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
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    debuff = true,
    list = QuickAuras.offensiveBars,
    duration = 6,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_OffensiveBars,
    cooldown = 10,
    visible = QuickAuras.isRogue,
}

abilities.rogue.cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    debuff = true,
    list = QuickAuras.offensiveBars,
    duration = 4,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    debuff = true,
    list = QuickAuras.offensiveBars,
    duration = 6,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_OffensiveBars,
    cooldown = 20,
    visible = QuickAuras.isRogue,
}

abilities.rogue.vanish = {
    name = "Vanish",
    icon = "Interface\\Icons\\Ability_Vanish",
    color = {0.5, 0.5, 0.5},
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sprint = {
    name = "Sprint",
    icon = "Interface\\Icons\\Ability_Rogue_Sprint",
    color = {1.0, 0.4195, 0.0000},
    list = QuickAuras.watchBars,
    duration = 15,
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.stealth = {
    name = "Stealth",
    icon = "Interface\\Icons\\Ability_Stealth",
    color = {0.4451, 0.7882, 0.8000},
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    visible = QuickAuras.isRogue,
}

abilities.rogue.kick = {
    name = "Kick",
    icon = "Interface\\Icons\\Ability_Kick",
    color = {0.7, 0.7, 0.7},
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    visible = QuickAuras.isRogue,
}

abilities.rogue.blind = {
    name = "Blind",
    icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
    color = {0.9059, 0.7451, 0.5804},
    debuff = true,
    list = QuickAuras.offensiveBars,
    duration = 10,
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.evasion = {
    name = "Evasion",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
    color = {1.0, 0.0606, 1.0},
    list = QuickAuras.watchBars,
    duration = 15,
    cooldown = true,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_WatchBars,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sap = {
    name = "Sap",
    icon = "Interface\\Icons\\Ability_Sap",
    color = {0.8941, 0.2157, 0.0627},
    debuff = true,
    list = QuickAuras.offensiveBars,
    duration = 45,
    onUpdate = QuickAuras_Timer_OnUpdate,
    parent = QuickAuras_OffensiveBars,
    visible = QuickAuras.isRogue,
}

for class, cabilities in pairs(abilities) do
    for ability, obj in pairs(cabilities) do
        obj.option = class.."_"..ability
    end
end
