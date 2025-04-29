local ADDON_NAME, addon = ...
local QuickAuras = addon.root
QuickAuras.abilities = { orc = {} }
local abilities = QuickAuras.abilities

abilities.orc.bloodFury = {
    spellId = { 20572 },
    aura = true,
    name = "Blood Fury",
    icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    color = {0.5, 0.5, 0.5},
    list = "watch",
    duration = 15,
    cooldown = true,
}

abilities.warrior = {
}

abilities.rogue = {
    bladeFlurry = {
        spellId = { 13877 },
        aura = true,
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
        list = "watch",
        cooldown = 120,
        visible = QuickAuras.isRogue,
    },
    adrenalineRush = {
        spellId = { 13750 },
        aura = true,
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        color = {246/256, 220/256, 0},
        list = "watch",
        cooldown = 300,
        visible = QuickAuras.isRogue,
    },
    sliceAndDice = {
        spellId = { 6774 },
        aura = true,
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
        list = "watch",
        visible = QuickAuras.isRogue,
    },
    exposeArmor = {
        spellId = { 8647, 8649, 8650, 11197, 11198 },
        name = "Expose Armor",
        icon = "Interface\\Icons\\Ability_Warrior_Riposte",
        color = {0.6784, 0.6706, 0.8706},
        list = "watch",
        duration = 30,
        visible = QuickAuras.isRogue,
    },
    gouge = {
        spellId = { 1776, 1777, 8629, 11285, 11286 },
        name = "Gouge",
        icon = "Interface\\Icons\\Ability_Gouge",
        color = {0.9333, 0.1255, 0.2941},
        list = "offensive",
        duration = 6,
        cooldown = 10,
        visible = QuickAuras.isRogue,
    },
    cheapShot = {
        spellId = { 1833 },
        name = "Cheap Shot",
        icon = "Interface\\Icons\\Ability_CheapShot",
        color = {0.7961, 0.5922, 0.3529},
        list = "offensive",
        duration = 4,
        visible = QuickAuras.isRogue,
    },
    kidneyShot = {
        spellId = { 408, 8643 },
        name = "Kidney Shot",
        icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
        color = {0.7961, 0.2784, 0.0980},
        list = "offensive",
        duration = 6,
        cooldown = 20,
        visible = QuickAuras.isRogue,
    },
    vanish = {
        spellId = { 1856, 1857 },
        name = "Vanish",
        icon = "Interface\\Icons\\Ability_Vanish",
        color = {0.5, 0.5, 0.5},
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    sprint = {
        spellId = { 2983, 8696, 11305 },
        aura = true,
        name = "Sprint",
        icon = "Interface\\Icons\\Ability_Rogue_Sprint",
        color = {1.0, 0.4195, 0.0000},
        list = "watch",
        duration = 15,
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    stealth = {
        spellId = { 1784, 1785, 1786, 1787 },
        name = "Stealth",
        icon = "Interface\\Icons\\Ability_Stealth",
        color = {0.4451, 0.7882, 0.8000},
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    kick = {
        spellId = { 1766, 1767, 1768, 1769 },
        name = "Kick",
        icon = "Interface\\Icons\\Ability_Kick",
        color = {0.7, 0.7, 0.7},
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    blind = {
        spellId = { 2094 },
        name = "Blind",
        icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
        color = {0.9059, 0.7451, 0.5804},
        list = "offensive",
        duration = 10,
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    evasion = {
        spellId = { 5277 },
        aura = true,
        name = "Evasion",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
        color = {1.0, 0.0606, 1.0},
        list = "watch",
        duration = 15,
        cooldown = true,
        visible = QuickAuras.isRogue,
    },
    sap = {
        spellId = { 6770, 2070, 11297 },
        name = "Sap",
        icon = "Interface\\Icons\\Ability_Sap",
        color = {0.8941, 0.2157, 0.0627},
        list = "offensive",
        duration = 45,
        visible = QuickAuras.isRogue,
    },
}

abilities.shaman = {
    naturesSwiftness = {
        spellId = { 16188 },
        name = "Nature's Swiftness",
        icon = "Interface\\Icons\\Spell_nature_ravenform",
        color = {0.5, 0.5, 0.5},
        cooldown = 180,
        visible = QuickAuras.isShaman,
    },
    manaTide = {
        spellId = { 16190 },
        name = "Mana Tide",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        cooldown = 300,
        visible = QuickAuras.isShaman,
    },
    manaTideAura = {
        spellId = { 17360 },
        aura = true,
        list = "alert",
        option = "manaTideAura",
        name = "Mana Tide Aura",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        visible = QuickAuras.isShaman,
    },
    --graceOfAir = {
    --    spellId = { 25360 },
    --    aura = true,
    --    list = "alert",
    --    name = "Grace of Air",
    --    icon = "Interface\\Icons\\Spell_nature_invisibilitytotem",
    --    color = {0.5, 0.5, 0.5},
    --    cooldown = 300,
    --    visible = QuickAuras.isShaman,
    --},
    frostShock = {
        spellId = { 8056, 8058, 10472, 10473 },
        name = "Frost Shock",
        icon = "Interface\\Icons\\Spell_Frost_FrostShock",
        color = {0.5, 0.5, 0.5},
        visible = QuickAuras.isShaman,
        cooldown = 6
    },
    reincarnation = {
        spellId = { 20608 },
        name = "Reincarnation",
        icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        color = {0.5, 0.5, 0.5},
        cooldown = 1800,
        visible = QuickAuras.isShaman,
    },
    elementalMastery = {
        spellId = { 16166 },
        name = "Elemental Mastery",
        icon = "Interface\\Icons\\Spell_Nature_WispHeal",
        color = {0.3, 0.6, 0.9},
        cooldown = 180,
        visible = QuickAuras.isShaman,
    },
}

function QuickAuras:InitAbilities()
    for class, cabilities in pairs(abilities) do
        for ability, obj in pairs(cabilities) do
            obj.option = class.."_"..ability
        end
    end
end
