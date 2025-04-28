local ADDON_NAME, addon = ...
local QuickAuras = addon.root
QuickAuras.abilities = { rogue = {}, warrior = {}, orc = {} }
local abilities = QuickAuras.abilities

abilities.orc.bloodFury = {
    name = "Blood Fury",
    icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    color = {0.5, 0.5, 0.5},
    list = "watch",
    duration = 15,
    cooldown = true,
}

abilities.rogue.bladeFlurry = {
    spellId = { 13877 },
    aura = true,
    name = "Blade Flurry",
    icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
    color = {246/256, 122/256, 0},
    list = "watch",
    cooldown = 120,
    visible = QuickAuras.isRogue,
}

abilities.rogue.adrenalineRush = {
    name = "Adrenaline Rush",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    color = {246/256, 220/256, 0},
    list = "watch",
    cooldown = 300,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sliceAndDice = {
    name = "Slice and Dice",
    icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
    color = {0, 0.9, 0.2},
    list = "watch",
    visible = QuickAuras.isRogue,
}

abilities.rogue.exposeArmor = {
    name = "Expose Armor",
    icon = "Interface\\Icons\\Ability_Warrior_Riposte",
    color = {0.6784, 0.6706, 0.8706},
    list = "watch",
    duration = 30,
    visible = QuickAuras.isRogue,
}

abilities.rogue.gouge = {
    name = "Gouge",
    icon = "Interface\\Icons\\Ability_Gouge",
    color = {0.9333, 0.1255, 0.2941},
    list = "offensive",
    duration = 6,
    cooldown = 10,
    visible = QuickAuras.isRogue,
}

abilities.rogue.cheapShot = {
    name = "Cheap Shot",
    icon = "Interface\\Icons\\Ability_CheapShot",
    color = {0.7961, 0.5922, 0.3529},
    list = "offensive",
    duration = 4,
    visible = QuickAuras.isRogue,
}

abilities.rogue.kidneyShot = {
    name = "Kidney Shot",
    icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
    color = {0.7961, 0.2784, 0.0980},
    list = "offensive",
    duration = 6,
    cooldown = 20,
    visible = QuickAuras.isRogue,
}

abilities.rogue.vanish = {
    name = "Vanish",
    icon = "Interface\\Icons\\Ability_Vanish",
    color = {0.5, 0.5, 0.5},
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sprint = {
    name = "Sprint",
    icon = "Interface\\Icons\\Ability_Rogue_Sprint",
    color = {1.0, 0.4195, 0.0000},
    list = "watch",
    duration = 15,
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.stealth = {
    name = "Stealth",
    icon = "Interface\\Icons\\Ability_Stealth",
    color = {0.4451, 0.7882, 0.8000},
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.kick = {
    name = "Kick",
    icon = "Interface\\Icons\\Ability_Kick",
    color = {0.7, 0.7, 0.7},
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.blind = {
    name = "Blind",
    icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
    color = {0.9059, 0.7451, 0.5804},
    list = "offensive",
    duration = 10,
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.evasion = {
    name = "Evasion",
    icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
    color = {1.0, 0.0606, 1.0},
    list = "watch",
    duration = 15,
    cooldown = true,
    visible = QuickAuras.isRogue,
}

abilities.rogue.sap = {
    name = "Sap",
    icon = "Interface\\Icons\\Ability_Sap",
    color = {0.8941, 0.2157, 0.0627},
    list = "offensive",
    duration = 45,
    visible = QuickAuras.isRogue,
}

for class, cabilities in pairs(abilities) do
    for ability, obj in pairs(cabilities) do
        obj.option = class.."_"..ability
    end
end
