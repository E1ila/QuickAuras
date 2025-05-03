local ADDON_NAME, addon = ...
local QuickAuras = addon.root
QuickAuras.spells = { }
local spells = QuickAuras.spells

spells.warrior = {
}

spells.rogue = {
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
        flashOnEnd = 2,
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

spells.shaman = {
    naturesSwiftness = {
        spellId = { 16188 },
        name = "Nature's Swiftness",
        icon = "Interface\\Icons\\Spell_nature_ravenform",
        readyTexture = "DruidEclipse-SolarSun",
        color = {0.5, 0.5, 0.5},
        cooldown = 180,
        visible = QuickAuras.isShaman,
    },
    manaTide = {
        spellId = { 16190 },
        name = "Mana Tide",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        cooldown = 300,
        duration = 12,
        visible = QuickAuras.isShaman,
    },
    --graceOfAirAura = { -- test
    --    spellId = { 25360 },
    --    aura = true,
    --    list = "alert",
    --    option = "graceOfAirAura",
    --    name = "Grace of Air Aura",
    --    icon = "Interface\\Icons\\Spell_nature_invisibilitytotem",
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

spells.trinkets = {
    jomGabbar = {
        spellId = { 29604 },
        aura = true,
        name = "Jom Gabbar",
        icon = "Interface\\Icons\\inv_misc_enggizmos_19",
        color = {0.8039, 0.6667, 0.4000},
        list = "watch",
        duration = 20,
        manualExpTime = true,
    },
    kissOfTheSpider = {
        spellId = { 28866 },
        aura = true,
        name = "Kill of the Spider",
        icon = "Interface\\Icons\\inv_trinket_naxxramas04",
        color = {0.8745, 0.7373, 0.4745},
        list = "watch",
        duration = 15,
    },
    earthStrike = {
        spellId = { 25891 },
        aura = true,
        name = "Earth Strike",
        icon = "Interface\\Icons\\spell_nature_abolishmagic",
        color = {0.3686, 0.8824, 0.7608},
        list = "watch",
        duration = 20,
    },
    slayersCrest = {
        spellId = { 28777 },
        aura = true,
        name = "Slayer's Crest",
        icon = "Interface\\Icons\\inv_trinket_naxxramas03",
        color = {0.4314, 0.8745, 0.5373},
        list = "watch",
        duration = 20,
    },
}

spells.iconAlerts = {
    limitedInvulnerabilityPotion = {
        spellId = { 3169 },
        aura = true,
        list = "alert",
        option = "limitedInvulnerabilityPotion",
        category = "iconAlerts",
        name = "LIP Active",
        desc = "Shows when Limited Invulnerability Potion is active.",
        duration = 6,
        icon = "Interface\\Icons\\spell_holy_divineintervention",
    },
    manaTideAura = {
        spellId = { 17360 },
        aura = true,
        list = "alert",
        option = "manaTideAura",
        category = "iconAlerts",
        name = "Mana Tide Aura",
        desc = "Notify when you or someone in your group uses a Mana Tide. Useful to know since they don't stack.",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        visible = QuickAuras.isManaClass,
    },
    innervateAura = {
        spellId = { 29166 },
        aura = true,
        list = "alert",
        option = "innervateAura",
        category = "iconAlerts",
        name = "Innervate Buff",
        icon = "Interface\\Icons\\spell_nature_lightning",
        visible = QuickAuras.isManaClass,
    },
    powerInfusion = {
        spellId = { 10060 },
        aura = true,
        list = "alert",
        option = "powerInfusionAura",
        category = "iconAlerts",
        name = "Power Infusion Buff",
        duration = 15,
        icon = "Interface\\Icons\\Spell_Holy_PowerInfusion",
    },
    itchDebuff = {
        spellId = { 26077 },
        aura = true,
        list = "alert",
        option = "itchDebuff",
        category = "iconAlerts",
        name = "AQ40 Itch",
        desc = "Shows when you have the itch debuff from AQ40, before the lethal poison. Poison needs to be instantly cleansed.",
        duration = 6,
        icon = "Interface\\Icons\\spell_nature_naturetouchdecay",
    },
}

spells.racials = {
    wotf = { -- ability
        spellId = { 7744 },
        name = "Will of the Forsaken",
        icon = "Interface\\Icons\\spell_shadow_raisedead",
        cooldown = true,
        visible = QuickAuras.isUndead,
    },
    bloodFury = { -- ability
        spellId = { 20572 },
        name = "Blood Fury",
        icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
        cooldown = true,
        visible = QuickAuras.isOrc,
    },
    bloodFuryBuff = { -- buff
        spellId = { 23234 },
        aura = true,
        name = "Blood Fury",
        icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
        color = {0.9451, 0.6863, 0.5333},
        list = "watch",
        duration = 15,
        visible = QuickAuras.isOrc,
        subCategory = "abilities"
    },
}

spells.other = {
    potion = {
        spellId = { 13444 },
        aura = true,
        name = "Potion",
        icon = "Interface\\Icons\\inv_potion_76",
        color = {0.5, 0.5, 0.5},
        cooldown = true,
    },
}

-- will be added to options by AddRemindersOptions and not AddAbilitiesOptions
spells.reminders = {
    findHerbs = {
        spellId = { 2383 },
        textureId = 133939,
        category = "reminders",
        name = "Find Herbs",
        icon = "Interface\\Icons\\spell_nature_earthquake",
        list = "reminder",
        visible = IsSpellKnown(2383),
    },
    findMinerals = {
        spellId = { 2580 },
        textureId = 136025,
        category = "reminders",
        name = "Find Minerals",
        icon = "Interface\\Icons\\inv_misc_flower_02",
        list = "reminder",
        visible = IsSpellKnown(2580),
    },
}

function QuickAuras:InitSpells()
    for class, cspells in pairs(spells) do
        for ability, obj in pairs(cspells) do
            if not obj.option then
                obj.option = class.."_"..ability
            end
        end
    end
end
