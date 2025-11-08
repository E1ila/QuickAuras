local ADDON_NAME, addon = ...
local QA = addon.root
QA.spells = { }
local spells = QA.spells
local WINDOW = QA.WINDOW
local out = QA.Print
local debug = QA.Debug

spells.warlock = {
    corruption = {
        spellId = { 172, 6222, 6223, 7648, 11671, 11672, 25311 },
        name = "Corruption",
        icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
        list = WINDOW.OFFENSIVE,
        category = "bars",
        color = {0.8314, 0.3255, 0.2196},
        duration = 18,
        multi = true,
        visible = QA.isWarlock,
    },
    immolate = {
        spellId = { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 },
        name = "Immolate",
        icon = "Interface\\Icons\\Spell_Fire_Immolation",
        list = WINDOW.OFFENSIVE,
        category = "bars",
        color = {1.0, 0.79805, 0.06897},
        duration = 15,
        multi = true,
        visible = QA.isWarlock,
    },
    petSpellLock = {
        spellId = { 19647 },
        name = "Spell Lock",
        icon = "Interface\\Icons\\spell_shadow_mindrot",
        cooldown = true,
        visible = QA.isWarlock,
    },
    shadowTrance = {
        spellId = { 17941 },
        name = "Shadow Trance",
        icon = "Interface\\Icons\\spell_shadow_twilight",
        proc = "aura",
        procFrameOption = "warlockShadowTrance",
        option = "warlockShadowTrance",
        visible = QA.isWarlock,
    },
    shadowWard = {
        spellId = { 6229, 11739, 11740, 28610 },
        name = "Shadow Ward",
        icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
        cooldown = true,
        visible = QA.isWarlock,
    },
    deathCoil = {
        spellId = { 6789, 17925, 17926 },
        name = "Death Coil",
        icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        cooldown = true,
        visible = QA.isWarlock,
    },
    soulstone = {
        name = "Soulstone",
        icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
        cooldown = true,
        visible = QA.isWarlock,
        itemId = 16896,
        evenIfNotInBag = true,
    },
    shadowburn = {
        spellId = { 17877, 18867, 18868, 18869, 18870, 18871 },
        name = "Shadowburn",
        icon = "Interface\\Icons\\spell_shadow_scourgebuild",
        cooldown = true,
        visible = QA.isWarlock,
    },
    conflagrate = {
        spellId = { 17962, 18930, 18931, 18932 },
        name = "Conflagrate",
        icon = "Interface\\Icons\\spell_fire_fireball",
        cooldown = true,
        visible = QA.isWarlock,
    },
    amplifyCurse = {
        spellId = { 18288 },
        name = "Amplify Curse",
        icon = "Interface\\Icons\\Spell_Shadow_Contagion",
        cooldown = true,
        visible = QA.isWarlock,
    },
    demonArmor = {
        spellId = { 706, 1086, 11733, 11734, 11735 },
        name = "Demon Armor",
        icon = "Interface\\Icons\\spell_shadow_ragingscream",
        visible = QA.isWarlock,
        buff = true,
        selfBuff = true,
        showMissing = "always",
    },
    houleOfTerror = {
        spellId = { 5484, 17928 },
        name = "Howl of Terror",
        icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
        color = {0.671, 0.251, 0.024},
        raidBars = true,
        duration = 15,
        cooldown = true,
        visible = QA.isWarlock,
    },
    warlockFear = {
        spellId = { 5782, 6213, 6215 },
        name = "Fear",
        icon = "Interface\\Icons\\Spell_Shadow_Possession",
        color = {0.3529, 0.2941, 0.7922},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = { 10, 15, 20 },
        visible = QA.isWarlock,
    },
    siphonLife = {
        spellId = { 18265, 18879, 18880, 18881 },
        name = "Siphon Life",
        icon = "Interface\\Icons\\Spell_Shadow_Requiem",
        color = {0.5176, 0.9059, 0.3882},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 30,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfAgony = {
        spellId = { 980, 1014, 6217, 11711, 11712, 11713 },
        name = "Curse of Agony",
        icon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
        color = {0.9804, 0.9137, 0.7020},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 24,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfWeakness = {
        spellId = { 702, 1108, 6205, 7646, 11707, 11708 },
        name = "Curse of Weakness",
        icon = "Interface\\Icons\\spell_shadow_curseofmannoroth",
        color = {0.9412, 0.9490, 0.5059},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 120,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfRecklessness = {
        spellId = { 704, 7658, 7659, 11717 },
        name = "Curse of Recklessness",
        icon = "Interface\\Icons\\spell_shadow_unholystrength",
        color = {0.8039, 0.6431, 0.5569},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 120,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfElements = {
        spellId = { 1490, 11721, 11722 },
        name = "Curse of Elements",
        icon = "Interface\\Icons\\spell_shadow_chilltouch",
        color = {0.3725, 0.3333, 0.6314},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 120,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfShadow = {
        spellId = { 17862, 17937 },
        name = "Curse of Shadow",
        icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
        color = {0.2706, 0.3020, 0.9490},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 120,
        multi = true,
        visible = QA.isWarlock,
    },
    curseOfTongues = {
        spellId = { 1714, 11719 },
        name = "Curse of Tongues",
        icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
        color = {0.7961, 0.3961, 0.1765},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 30,
        multi = true,
        visible = QA.isWarlock,
    },
}

spells.hunter = {
    scatterShot = {
        spellId = { 19503 },
        name = "Scatter Shot",
        icon = "Interface\\Icons\\ability_golemstormbolt",
        color = {0.6784, 0.6706, 0.8706},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 4,
        cooldown = true,
        visible = QA.isHunter,
    },
    concussiveShot = {
        spellId = { 5116 },
        name = "Concussive Shot",
        icon = "Interface\\Icons\\spell_frost_stun",
        color = {0.6784, 0.6706, 0.8706},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 4,
        cooldown = true,
        visible = QA.isHunter,
    },
    multiShot = {
        spellId = { 2643, 14288, 14289, 14290, 25294 },
        name = "Multi-Shot",
        icon = "Interface\\Icons\\ability_upgrademoonglaive",
        cooldown = true,
        shootCastTime = 0.5,
        visible = QA.isHunter,
    },
    aimedShot = {
        spellId = { 19434, 20900, 20901, 20902, 20903, 20904 },
        name = "Aimed Shot",
        icon = "Interface\\Icons\\inv_spear_07",
        cooldown = true,
        shootCastTime = 3,
        visible = QA.isHunter,
    },
    flare = {
        spellId = { 1543 },
        name = "Flare",
        icon = "Interface\\Icons\\spell_fire_flare",
        cooldown = true,
        visible = QA.isHunter,
    },
    frostTrap = {
        spellId = { 13809 },
        name = "Frost Trap",
        icon = "Interface\\Icons\\spell_frost_freezingbreath",
        --cooldown = true,
        visible = QA.isHunter,
    },
    freezingTrap = {
        spellId = { 1499, 14310, 14311 },
        name = "Freezing Trap",
        icon = "Interface\\Icons\\spell_frost_chainsofice",
        color = {0.6784, 0.6706, 0.8706},
        duration = 10,
        list = WINDOW.OFFENSIVE,
        category = "bars",
        cooldown = true,
        visible = QA.isHunter,
    },
    wingClip = {
        spellId = { 2974, 14267, 14268 },
        name = "Wing Clip",
        icon = "Interface\\Icons\\ability_rogue_trip",
        color = {246/256, 220/256, 0},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 10,
        cooldown = true,
        visible = QA.isHunter,
    },
    feignDeath = {
        spellId = { 5384 },
        name = "Feign Death",
        icon = "Interface\\Icons\\Ability_Rogue_FeignDeath",
        cooldown = true,
        visible = QA.isHunter,
    },
    explosiveTrap = {
        spellId = { 13813, 14316, 14317 },
        name = "Explosive Trap",
        icon = "Interface\\Icons\\spell_fire_selfdestruct",
        --cooldown = true,
        visible = QA.isHunter,
    },
    distractingShot = {
        spellId = { 20736, 14274, 15629, 15630, 15631, 15632 },
        name = "Distracting Shot",
        icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
        cooldown = true,
        visible = QA.isHunter,
    },
    rapidFire = {
        spellId = { 3045 },
        name = "Rapid Fire",
        icon = "Interface\\Icons\\Ability_Hunter_RunningShot",
        color = {0.914, 0.086, 0.086},
        cooldown = true,
        duration = 15,
        list = WINDOW.WATCH,
        category = "bars",
        visible = QA.isHunter,
    }
}

spells.warrior = {
    flurry = {
        spellId = { 12970 },
        name = "Flurry",
        icon = "Interface\\Icons\\ability_ghoulfrenzy",
        color = {0.933, 0.471, 0.373},
    },
    bloodthirst = {
        spellId = { 23881, 23892, 23893, 23894 },
        name = "Bloodthirst",
        icon = "Interface\\Icons\\spell_nature_bloodlust",
        cooldown = true,
        proc = "powerUpdate",
        procFrameOption = "warriorBloodthirst",
        visible = QA.isWarrior,
    },
    sunderArmor = {
        spellId = { 7386, 7405, 8380, 11596, 11597 },
        name = "Sunder Armor",
        icon = "Interface\\Icons\\Ability_Warrior_Sunder",
        duration = 30,
        enemyAura = {
            requiredStacks = 5,
            ShowCond = function()
                return QA.isWarrior or QA.hasWarriorInParty
            end,
            glowInCombat = function()
                return QA.isWarrior and IsInRaid()
            end,
        },
        visible = QA.isWarrior,
    },
    whirlwind = {
        spellId = { 1680 },
        name = "Whirlwind",
        icon = "Interface\\Icons\\ability_whirlwind",
        cooldown = true,
        visible = QA.isWarrior,
    },
    heroicStrike = {
        name = "Heroic Strike",
        spellId = { 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286 },
        bySpellId = {
            [78] = 78,
            [284] = 284,
            [285] = 285,
            [1608] = 1608,
            [11564] = 11564,
            [11565] = 11565,
            [11566] = 11566,
            [11567] = 11567,
            [25286] = 25286,
         },
    },
    cleave = {
        name = "Cleave",
        spellId = { 845, 7369, 11608, 11609, 20569 },
        bySpellId = {
            [845] = 845,
            [7369] = 7369,
            [11608] = 11608,
            [11609] = 11609,
            [20569] = 20569,
        },
    },
    recklessness = {
        spellId = { 1719 },
        name = "Recklessness",
        icon = "Interface\\Icons\\ability_criticalstrike",
        color = {0.914, 0.086, 0.086},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
        cooldown = true, -- shared with shield wall
        raidBars = true,
        visible = QA.isWarrior,
    },
    disarm = {
        spellId = { 676 },
        bySpellId = {
            [676] = 676,
        },
        name = "Disarm",
        icon = "Interface\\Icons\\Ability_Warrior_Disarm",
        color = {0.533, 0.290, 0.173},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 10,
        cooldown = true,
        visible = QA.isWarrior,
    },
    retaliation = {
        spellId = { 20230 },
        name = "Retaliation",
        icon = "Interface\\Icons\\Ability_Warrior_Challange",
        color = {0.5, 0.5, 0.5},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
        cooldown = true, -- shares cooldown with shieldwall
        visible = QA.isWarrior,
    },
    shieldWall = {
        spellId = { 871 },
        bySpellId = {
            [871] = 871,
        },
        name = "Shield Wall",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        color = {0.6784, 0.6706, 0.8706},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 10,
        cooldown = true,
        visible = QA.isWarrior,
    },
    piercingHowl = {
        spellId = { 12323 },
        name = "Piercing Howl",
        icon = "Interface\\Icons\\spell_shadow_deathscream",
        color = {0.671, 0.251, 0.024},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 6,
        visible = QA.isWarrior,
    },
    berserkerRage = {
        spellId = { 18499 },
        name = "Berserker Rage",
        icon = "Interface\\Icons\\spell_nature_ancestralguardian",
        color = {0.914, 0.086, 0.086},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 10,
        cooldown = true,
        visible = QA.isWarrior,
    },
    intercept = {
        spellId = { 20252, 20616, 20617 },
        name = "Intercept",
        icon = "Interface\\Icons\\ability_rogue_sprint",
        cooldown = true,
        visible = QA.isWarrior,
    },
    intimidatingShout = {
        spellId = { 20511 },
        name = "Intimidating Shout",
        icon = "Interface\\Icons\\ability_golemthunderclap",
        color = {0.671, 0.251, 1},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 8,
        cooldown = true,
        visible = QA.isWarrior,
    },
    execute = {
        spellId = { 5308, 20658, 20660, 20661, 20662 },
        name = "Execute",
        icon = "Interface\\Icons\\inv_sword_48",
        cooldown = true,
        proc = "unitHealth",
        procFrameOption = "warriorExecute",
        unitHealth = "target",
        visible = QA.isWarrior,
    },
    overpower = {
        spellId = { 7384, 7887, 11584, 11585 },
        triggers = {
            DODGE = true,
        },
        proc = "combatLog",
        procFadeCheck = true,
        procFrameOption = "warriorOverpower",
        bySpellId = { -- mandatory for CLUE proc
            [7384] = 7384,
            [7887] = 7384,
            [11584] = 7384,
            [11585] = 7384,
        },
        name = "Overpower",
        icon = "Interface\\Icons\\ability_meleedamage",
        visible = QA.isWarrior,
        CheckProc = function(spell, subevent, sourceGuid, sourceName, destGuid, destName, extra)
            if not QA.shapeshiftForm == QA.warrior.stance.battle and sourceGuid == QA.playerGuid then return false end

            return  subevent == "SWING_MISSED" and spell.triggers[extra[1]]
                    or subevent == "SPELL_MISSED" and spell.triggers[extra[4]]
        end ,
    },
    revenge = {
        spellId = { 6572, 6574, 7379, 11600, 11601, 25288 },
        triggers = {
            DODGE = true,
            PARRY = true,
            BLOCK = true,
        },
        proc = 'combatLog',
        procFadeCheck = true,
        procFrameOption = "warriorRevenge",
        bySpellId = { -- mandatory for CLUE proc
            [6572] = 6572,
            [6574] = 6572,
            [7379] = 6572,
            [11600] = 6572,
            [11601] = 6572,
            [25288] = 6572,
        },
        name = "Revenge",
        icon = "Interface\\Icons\\ability_warrior_revenge",
        visible = QA.isWarrior,
        DAMAGE_SUBEVENTS = {
            SWING_DAMAGE = true,
            SPELL_DAMAGE = true,
        },
        CheckProc = function(spell, subevent, sourceGuid, sourceName, destGuid, destName, extra)
            if not QA.shapeshiftForm == QA.warrior.stance.defensive and destGuid == QA.playerGuid then return false end

            local partiallyBlocked = false
            local blockIndex = 5
            if spell.DAMAGE_SUBEVENTS[subevent] then
                if subevent == "SPELL_DAMAGE" then blockIndex = blockIndex+3 end
                if extra[blockIndex] and tonumber(extra[blockIndex]) > 0 then -- block amount
                    partiallyBlocked = true
                end
            end
            if      partiallyBlocked
                    or subevent == "SWING_MISSED" and spell.triggers[extra[1]]
                    or (subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED") and spell.triggers[extra[4]]
            then
                return true
            end
        end,
    },
    charge = {
        spellId = { 100, 6178, 11578 },
        name = "Charge",
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        color = {0.914, 0.086, 0.086},
        cooldown = true,
        --duration = 1,
        visible = QA.isWarrior,
    },
    shieldBash = {
        spellId = { 72, 1671, 1672 },
        name = "Shield Bash",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
        cooldown = true,
        visible = QA.isWarrior,
    },
    taunt = {
        spellId = { 355 },
        name = "Taunt",
        icon = "Interface\\Icons\\spell_nature_reincarnation",
        cooldown = true,
        raidBars = true,
        taunt = true,
        duration = 3,
        color = {0.914, 0.086, 0.086},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        visible = QA.isWarrior,
    },
    mockingBlow = {
        spellId = { 694, 7400, 7402, 20559, 20560 },
        name = "Mocking Blow",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        list = WINDOW.OFFENSIVE,
        category = "bars",
        cooldown = true,
        taunt = true,
        duration = 6,
        color = {246/256, 122/256, 0},
        visible = QA.isWarrior,
    },
    battleShout = {
        spellId = { 25289, 11551, 11550, 11549, 6192, 5242, 6673, 25101 },
        name = "Battle Shout",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        aura = true,
        dontWatch = true,
        crucial = QA.isWarrior or QA.isRogue,
        OnClick = function()
            QA.battleShoutClickTime = GetTime()
            SendChatMessage("Battle Shout dropped!", "PARTY")
        end,
        OnSpellDetectCombatLog = function(conf, subevent, sourceGuid, sourceName, destGuid, destName, ...)
            if subevent == "SPELL_AURA_APPLIED" and destGuid == QA.playerGuid then
                local timeSinceClick = QA.battleShoutClickTime and (GetTime() - QA.battleShoutClickTime) or 999
                if timeSinceClick <= 10 then
                    local cleanName = strsplit("-", sourceName)
                    SendChatMessage("BS applied by " .. cleanName .. ", thanks!! <3", "PARTY")
                end
            end
        end,
        CrucialCond = function()
            return QA.db.profile.battleShoutMissing and (not QA.isWarrior or QA.inCombat or IsInGroup()) and (QA.isWarrior or QA.hasWarriorInParty)
        end,
        visible = QA.isWarrior or QA.isRogue,
    },
    deathWish = {
        spellId = { 12328 },
        name = "Death Wish",
        icon = "Interface\\Icons\\spell_shadow_deathpact",
        list = WINDOW.WATCH,
        category = "bars",
        raidBars = true,
        cooldown = true,
        duration = 30,
        color = {0.902, 0.357, 0.055},
        visible = QA.isWarrior,
    },
    challengingShout = {
        spellId = { 1161 },
        name = "Challenging Shout",
        icon = "Interface\\Icons\\ability_bullrush",
        list = WINDOW.OFFENSIVE,
        category = "bars",
        raidBars = true,
        cooldown = true,
        taunt = true,
        aoe = true,
        duration = 6,
        color = {0.671, 0.251, 0.024},
        visible = QA.isWarrior,
    },
}

spells.rogue = {
    bladeFlurry = {
        spellId = { 13877 },
        aura = true,
        raidBars = true,
        duration = 15,
        name = "Blade Flurry",
        icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",
        color = {246/256, 122/256, 0},
        list = WINDOW.WATCH,
        category = "bars",
        cooldown = 120,
        visible = QA.isRogue,
    },
    adrenalineRush = {
        spellId = { 13750 },
        aura = true,
        raidBars = true,
        duration = 15,
        name = "Adrenaline Rush",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
        color = {246/256, 220/256, 0},
        list = WINDOW.WATCH,
        category = "bars",
        cooldown = 300,
        visible = QA.isRogue,
    },
    sliceAndDice = {
        spellId = { 6774 },
        aura = true,
        buff = true,
        selfBuff = true,
        visibleFunc = function()
            return QA.inCombat and UnitExists("target") and not UnitIsDead("target") and not UnitIsPlayer("target") and QA.db.profile.rogueSndMissing and QA.comboPoints > 0
        end,
        name = "Slice and Dice",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        color = {0, 0.9, 0.2},
        list = WINDOW.WATCH,
        category = "bars",
        flashOnEnd = 3,
        visible = QA.isRogue,
    },
    exposeArmor = {
        spellId = { 8647, 8649, 8650, 11197, 11198 },
        name = "Expose Armor",
        icon = "Interface\\Icons\\Ability_Warrior_Riposte",
        color = {0.6784, 0.6706, 0.8706},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 30,
        flashOnEnd = 5,
        visible = QA.isRogue,
    },
    riposte = {
        spellId = { 14251 },
        name = "Riposte",
        icon = "Interface\\Icons\\ability_warrior_challange",
        proc = "combatLog",
        procFadeCheck = true,
        procFrameOption = "rogueRiposte",
        triggers = {
            PARRY = true,
        },
        bySpellId = { -- mandatory for CLUE proc
            [14251] = 14251,
        },
        CheckProc = function(spell, subevent, sourceGuid, sourceName, destGuid, destName, extra)
            if destGuid ~= QA.playerGuid then return false end

            return  subevent == "SWING_MISSED" and spell.triggers[extra[1]]
                    or subevent == "SPELL_MISSED" and spell.triggers[extra[4]]
        end ,
        visible = QA.isRogue,
    },
    gouge = {
        spellId = { 1776, 1777, 8629, 11285, 11286 },
        name = "Gouge",
        icon = "Interface\\Icons\\Ability_Gouge",
        color = {0.9333, 0.1255, 0.2941},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 6,
        cooldown = 10,
        visible = QA.isRogue,
    },
    cheapShot = {
        spellId = { 1833 },
        name = "Cheap Shot",
        icon = "Interface\\Icons\\Ability_CheapShot",
        color = {0.7961, 0.5922, 0.3529},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 4,
        visible = QA.isRogue,
    },
    kidneyShot = {
        spellId = { 408, 8643 },
        name = "Kidney Shot",
        icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
        color = {1.000, 0.318, 0.227},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 6,
        cooldown = 20,
        visible = QA.isRogue,
    },
    vanish = {
        spellId = { 1856, 1857 },
        name = "Vanish",
        icon = "Interface\\Icons\\Ability_Vanish",
        color = {0.5, 0.5, 0.5},
        cooldown = true,
        visible = QA.isRogue,
    },
    sprint = {
        spellId = { 2983, 8696, 11305 },
        aura = true,
        name = "Sprint",
        icon = "Interface\\Icons\\Ability_Rogue_Sprint",
        color = {1.0, 0.4195, 0.0000},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
        cooldown = true,
        visible = QA.isRogue,
    },
    stealth = {
        spellId = { 1784, 1785, 1786, 1787 },
        name = "Stealth",
        icon = "Interface\\Icons\\Ability_Stealth",
        color = {0.4451, 0.7882, 0.8000},
        cooldown = true,
        ignoreCooldownInStealth = true,
        visible = QA.isRogue,
    },
    kick = {
        spellId = { 1766, 1767, 1768, 1769 },
        name = "Kick",
        icon = "Interface\\Icons\\Ability_Kick",
        color = {0.7, 0.7, 0.7},
        cooldown = true,
        visible = QA.isRogue,
    },
    blind = {
        spellId = { 2094 },
        name = "Blind",
        icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
        color = {0.9059, 0.7451, 0.5804},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 10,
        cooldown = true,
        visible = QA.isRogue,
    },
    evasion = {
        spellId = { 5277 },
        aura = true,
        name = "Evasion",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
        color = {1.0, 0.0606, 1.0},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
        cooldown = true,
        visible = QA.isRogue,
    },
    sap = {
        spellId = { 6770, 2070, 11297 },
        name = "Sap",
        icon = "Interface\\Icons\\Ability_Sap",
        color = {0.8941, 0.2157, 0.0627},
        list = WINDOW.OFFENSIVE,
        category = "bars",
        duration = 45,
        visible = QA.isRogue,
    },
}

spells.shaman = {
    windfuryWeapon = {
        spellId = { 8232, 8235, 10486, 16362 },
        aura = true,
        name = "Windfury Weapon",
        icon = "Interface\\Icons\\Spell_Nature_Cyclone",
        visible = QA.isShaman,
    },
    windfuryTotem = {
        spellId = { 8512, 10613, 10614 },
        name = "Windfury Totem",
        icon = "Interface\\Icons\\Spell_Nature_Windfury",
        visible = QA.isShaman,
    },
    flurry = {
        spellId = { 16280 },
        aura = true,
        name = "Flurry",
        icon = "Interface\\Icons\\ability_ghoulfrenzy",
        color = {0.933, 0.471, 0.373},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 60*4,
        visible = QA.isShaman,
    },
    chainLightning = {
        spellId = { 10605 },
        name = "Chain Lightning",
        icon = "Interface\\Icons\\spell_nature_chainlightning",
        cooldown = 6,
        visible = QA.isShaman,
    },
    naturesSwiftness = {
        spellId = { 16188 },
        name = "Nature's Swiftness",
        icon = "Interface\\Icons\\Spell_nature_ravenform",
        readyTexture = "DruidEclipse-SolarSun",
        readyThings = true,
        color = {0.5, 0.5, 0.5},
        cooldown = 180,
        visible = QA.isShaman,
    },
    manaTide = {
        spellId = { 16190 },
        name = "Mana Tide",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        readyThings = true,
        cooldown = 300,
        duration = 12,
        visible = QA.isShaman,
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
        visible = QA.isShaman,
        cooldown = 6
    },
    frostResistanceTotem = {
        spellId = { 10479, 10477 },
        name = "Frost Resistance Totem",
        icon = "Interface\\Icons\\spell_frostresistancetotem_01",
        crucial = true,
        OnClick = function()
            if not QA.isShaman then
                SendChatMessage("Frost Resistance Totem Mssing!", "PARTY")
            end
        end,
        CrucialCond = function()
            return QA.isHorde and QA.db.profile.frostResistanceTotemMissing and #QA.partyShamans > 0
                    and (QA.boss.KT.phase == 2 or QA.boss.Sapphiron.active)
        end
    },
    reincarnation = {
        spellId = { 20608 },
        name = "Reincarnation",
        icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
        color = {0.5, 0.5, 0.5},
        cooldown = 1800,
        visible = QA.isShaman,
    },
    elementalMastery = {
        spellId = { 16166 },
        name = "Elemental Mastery",
        icon = "Interface\\Icons\\Spell_Nature_WispHeal",
        color = {0.3, 0.6, 0.9},
        cooldown = 180,
        visible = QA.isShaman,
    },
    stormstrike = {
        spellId = { 17364 },
        name = "Stormstrike",
        icon = "Interface\\Icons\\spell_holy_sealofmight",
        cooldown = 20,
        visible = QA.isShaman,
    }
}

spells.trinkets = {
    jomGabbar = {
        spellId = { 29604 },
        aura = true,
        name = "Jom Gabbar",
        icon = "Interface\\Icons\\inv_misc_enggizmos_19",
        color = {0.8039, 0.6667, 0.4000},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 20,
        manualExpTime = true,
    },
    kissOfTheSpider = {
        spellId = { 28866 },
        aura = true,
        name = "Kill of the Spider",
        icon = "Interface\\Icons\\inv_trinket_naxxramas04",
        color = {0.8745, 0.7373, 0.4745},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
    },
    earthStrike = {
        spellId = { 25891 },
        aura = true,
        name = "Earth Strike",
        icon = "Interface\\Icons\\spell_nature_abolishmagic",
        color = {0.3686, 0.8824, 0.7608},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 20,
    },
    slayersCrest = {
        spellId = { 28777 },
        aura = true,
        name = "Slayer's Crest",
        icon = "Interface\\Icons\\inv_trinket_naxxramas03",
        color = {0.4314, 0.8745, 0.5373},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 20,
    },
}

spells.iconAlerts = {
    --weakTrollsBloodPotion = {
    --    spellId = { 3219 },
    --    color = {0.667, 0.988, 0.455},
    --    raidBars = true,
    --    duration = 10,
    --    name = "Weak Troll's Blood Potion",
    --},
    limitedInvulnerabilityPotion = {
        spellId = { 3169 },
        color = {0.914, 0.651, 0.086},
        aura = true,
        raidBars = true,
        list = WINDOW.ALERT,
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
        list = WINDOW.ALERT,
        option = "manaTideAura",
        category = "iconAlerts",
        name = "Mana Tide Aura",
        desc = "Notify when you or someone in your group uses a Mana Tide. Useful to know since they don't stack.",
        icon = "Interface\\Icons\\spell_frost_summonwaterelemental",
        visible = QA.isManaClass,
    },
    innervateAura = {
        spellId = { 29166 },
        aura = true,
        list = WINDOW.ALERT,
        option = "innervateAura",
        category = "iconAlerts",
        name = "Innervate Buff",
        icon = "Interface\\Icons\\spell_nature_lightning",
        visible = QA.isManaClass,
        OnSpellDetectCombatLog = function(self, subevent, sourceGuid, sourceName, destGuid, destName, ...)
            if subevent == "SPELL_AURA_APPLIED" and destGuid == QA.playerGuid then
                local name = strsplit("-", sourceName)
                out("Innervated by "..QA.colors.bold..name)
            end
        end,
    },
    powerInfusion = {
        spellId = { 10060 },
        aura = true,
        list = WINDOW.ALERT,
        option = "powerInfusionAura",
        category = "iconAlerts",
        name = "Power Infusion Buff",
        duration = 15,
        icon = "Interface\\Icons\\Spell_Holy_PowerInfusion",
    },
    itchDebuff = {
        spellId = { 26077 },
        aura = true,
        list = WINDOW.ALERT,
        option = "itchDebuff",
        category = "iconAlerts",
        name = "AQ40 Itch",
        desc = "Shows when you have the itch debuff from AQ40, before the lethal poison. Poison needs to be instantly cleansed.",
        duration = 6,
        icon = "Interface\\Icons\\spell_nature_naturetouchdecay",
    },
    naxxDeathknightCaptainCleave = {
        spellId = { 28334 },
        npcId = 16145,
        list = WINDOW.ALERT,
        option = "naxxDeathknightCaptainCleave",
        category = "naxxramas",
        name = "Deathknight Captain Cleave",
        desc = "Alert when Deathknight Captain cleaves in Naxxramas",
        duration = 6,
        icon = "Interface\\Icons\\ability_whirlwind",
    },
}

spells.racials = {
    wotf = { -- ability
        spellId = { 7744 },
        name = "Will of the Forsaken",
        icon = "Interface\\Icons\\spell_shadow_raisedead",
        cooldown = true,
        visible = QA.isUndead,
    },
    bloodFury = { -- ability
        spellId = { 20572 },
        name = "Blood Fury",
        icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
        cooldown = true,
        visible = QA.isOrc,
    },
    berserking = { -- ability
        spellId = { 20554 },
        name = "Berserking",
        icon = "Interface\\Icons\\racial_troll_berserk",
        list = WINDOW.WATCH,
        category = "bars",
        cooldown = true,
        visible = QA.isTroll,
    },
    bloodFuryBuff = { -- buff
        spellId = { 23234 },
        aura = true,
        name = "Blood Fury",
        icon = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
        color = {0.9451, 0.6863, 0.5333},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 15,
        visible = QA.isOrc,
    },
}

spells.other = {
    potion = {
        -- placed here for cooldown support, even that it's an item
        -- itemId and icon are set based on class (healer = Major Mana Potion, others = Limited Invulnerability Potion)
        itemId = (QA.isPriest or QA.isShaman or QA.isPaladin or QA.isDruid) and 13444 or 3387,
        name = "Potion",
        icon = (QA.isPriest or QA.isShaman or QA.isPaladin or QA.isDruid) and "Interface\\Icons\\inv_potion_76" or "Interface\\Icons\\inv_potion_62",
        cooldown = true,
        readyThings = true,
        evenIfNotInBag = true,
    },
    freeActionPotion = {
        name = "Free Action",
        spellIds = { 6615 },
        itemId = 5634,
        list = WINDOW.WATCH,
        category = "bars",
        duration = 30,
    },
    chicken = {
        spellId = { 23060 },
        name = "Squawk",
        aura = true,
        icon = "Interface\\Icons\\inv_misc_birdbeck_01",
        color = {0.847, 0.686, 0.541},
        list = WINDOW.WATCH,
        category = "bars",
        duration = 60*4,
        OnDetectAura = function(self, aura, duration, expTime)
            if QA.db.profile.announceSquawk then
                SendChatMessage("Squawk!", "PARTY")
            end
        end,
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
        list = WINDOW.REMINDER,
        visible = IsSpellKnown(2383),
    },
    findMinerals = {
        spellId = { 2580 },
        textureId = 136025,
        category = "reminders",
        name = "Find Minerals",
        icon = "Interface\\Icons\\inv_misc_flower_02",
        list = WINDOW.REMINDER,
        visible = IsSpellKnown(2580),
    },
}

spells.transmutes = {
    saltShaker = {
        spellId = { 10662 },
        itemId = 15846,
        name = "Salt Shaker",
        transmute = true,
        list = WINDOW.REMINDER,
        icon = "Interface\\Icons\\inv_misc_armorkit_17",
    },
    arcanite = {
        spellId = { 17187 },
        name = "Arcanite Transmute",
        transmute = true,
        list = WINDOW.REMINDER,
        icon = "Interface\\Icons\\inv_misc_stonetablet_05",
    },
    mooncloth = {
        spellId = { 18560 },
        name = "Mooncloth",
        transmute = true,
        list = WINDOW.REMINDER,
        icon = "Interface\\Icons\\inv_fabric_moonrag_01",
    },
}

function QA:InitSpells()
    for class, cspells in pairs(spells) do
        for ability, obj in pairs(cspells) do
            if not obj.option then
                obj.option = class.."_"..ability
            end
        end
    end
    QA.stealthAbilities = {}
    if QA.isRogue then
        for _, id in ipairs(spells.rogue.stealth.spellId) do
            QA.stealthAbilities[id] = true
        end
    elseif QA.isDruid then
        --for _, id in ipairs(spells.druid.stealth.spellId) do
        --    QA.stealthAbilities[id] = true
        --end
    end
end
