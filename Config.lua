local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

QA.optionalEvents = {
    "UNIT_POWER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_AURA",
    "UI_ERROR_MESSAGE",
    "SPELL_UPDATE_COOLDOWN",
    "PLAYER_EQUIPMENT_CHANGED",
    "PLAYER_TARGET_CHANGED",
    "BAG_UPDATE",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "MINIMAP_UPDATE_TRACKING",
    "PLAYER_ALIVE",
    "PLAYER_UNGHOST",
    "PLAYER_LEVEL_UP",
    "BANKFRAME_OPENED",
    "BANKFRAME_CLOSED",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "GROUP_ROSTER_UPDATE",
    "PARTY_MEMBER_ENABLE",
    --"SPELL_UPDATE_USABLE",
    "UPDATE_SHAPESHIFT_FORM",
    "UNIT_HEALTH",
    "PLAYER_XP_UPDATE",
    "QUEST_TURNED_IN",
    "UNIT_THREAT_LIST_UPDATE",
    "UNIT_SPELLCAST_SENT",
    --"ACTIONBAR_SLOT_CHANGED",
    --"ACTIONBAR_PAGE_CHANGED",
    --"ACTIONBAR_UPDATE_STATE",
}

QA.warrior = {
    stance = {
        battle = 1,
        defensive = 2,
        berserker = 3,
    },
}

QA.adjustableFrames = {
    QuickAuras_WatchBars,
    QuickAuras_OffensiveBars,
    QuickAuras_Cooldowns,
    QuickAuras_MissingBuffs,
    QuickAuras_IconWarnings,
    QuickAuras_IconAlerts,
    QuickAuras_Reminders,
    QuickAuras_WeaponEnchants,
    QuickAuras_Crucial,
    QuickAuras_RangeIndicator,
    QuickAuras_RaidBars,
    QuickAuras_SpellQueue,
}

--QuickAuras.adjustableFrames = {
--    ["QuickAuras_Parry"] = {
--        visible = QuickAuras.isRogue,
--    },
--    ["QuickAuras_Combo"] = {
--        visible = QuickAuras.isRogue,
--    },
--    ["QuickAuras_Flurry"] = {
--        visible = QuickAuras.isRogue,
--    },
--}

QA.colors = {
    alert = "|cffff0000",
    yellow = "|cffffde00",
    bold = "|cffff99cc",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
    purple = "|cffcc99ff",
}

QA.trackedGear = {
    [15138] = {
        name = "Onyxia Scale Cloak",
    },
    [4984] = {
        name = "Skull of Impending Doom",
    },
    [23206] = markOfTheChampion,
    [17067] = {
        name = "Ancient Cornerstone Grimoire",
    },
    [10588] = {
        name = "Goblin Rocket Helmet",
    },
}

QA.capitalCities = {
    ["Stormwind"] = true,
    ["Ironforge"] = true,
    ["Darnassus"] = true,
    ["Orgrimmar"] = true,
    ["Thunder Bluff"] = true,
    ["Undercity"] = true,
}

-- these will be detected through UNIT_AURA event
QA.trackedAuras = {}
QA.trackedCrucialAuras = {}

-- these will be detected through COMBAT_LOG_EVENT_UNFILTERED
QA.trackedCombatLog = {}

-- these will be detected through SPELL_UPDATE_COOLDOWN
QA.trackedSpellCooldowns = {}
QA.trackedItemCooldowns = {}

QA.trackedMissingBuffs = {}

QA.trackedLowConsumes = {}

QA.trackedTracking = {}

QA.trackedProcAbilities = {
    combatLog = {},
    unitHealth = {},
    aura = {},
}

QA.trackedEnemyAurasBySpellId = {}
QA.trackedEnemyAuras = {}

-- custom events

function QA:BuildTrackedGear()
    debug(2, "BuildTrackedGear...")
    local MARK_OF_THE_CHAMPION_ITEM_ID = { 23206, 23207 }
    for _, itemId in ipairs(MARK_OF_THE_CHAMPION_ITEM_ID) do
        QA.trackedGear[itemId] = {
            name = "Mark of the Champion",
            desc = "Smart warning - shows if you need to use the trinket, or if you need to remove it (non undead/demon).",
            targetDependant = true,
            visibleFunc = function(equipped)
                local targetExists = UnitExists("target") and not UnitIsDead("target") and not UnitPlayerControlled("target") and UnitIsEnemy("target", "player")
                local isUndeadOrDemon = UnitCreatureType("target") == "Undead" or UnitCreatureType("target") == "Demon"

                if equipped then
                    return targetExists and not isUndeadOrDemon
                else
                    return targetExists and isUndeadOrDemon and QA.bags[itemId]
                end
            end,
        }
    end
end

function QA:BuildTrackedSpells()
    debug(2, "BuildTrackedSpells...")
    for category, cspells in pairs(QA.spells) do
        --debug(3, "BuildTrackedSpells", ">>", string.upper(category))
        for key, spell in pairs(cspells) do
            --debug(3, "BuildTrackedSpells", "  - ", key)
            if spell.crucial then
                local obj = {
                    spellIds = spell.spellId,
                    conf = spell,
                }
                table.insert(QA.trackedCrucialAuras, obj)
            end
            if spell.raidBars then
                for _, spellId in ipairs(spell.spellId) do
                    QA.trackedCombatLog[spellId] = spell
                end
            end
            if spell.enemyAura then
                table.insert(QA.trackedEnemyAuras, spell)
                for _, spellId in ipairs(spell.spellId) do
                    QA.trackedEnemyAurasBySpellId[spellId] = spell
                end
            end

            if spell.visible == nil or spell.visible then
                if spell.spellId then
                    if not spell.icon then
                        spell.icon = GetSpellTexture(spell.spellId[1])
                    end
                    if spell.proc then
                        table.insert(QA.trackedProcAbilities[spell.proc], spell)
                        if spell.procFadeCheck then
                            QA.procCheck.FadeCheck[spell.spellId[1]] = QA:Debounce(function()
                                QA:CheckProcSpellUsable(spell)
                            end, 1)
                        end
                    end
                    for _, spellId in ipairs(spell.spellId) do
                        --debug(3, "BuildTrackedSpells", "    -- ", spell.name, "["..tostring(spellId).."]", spell.aura and "AURA" or "-", "[option:", tostring(spell.option).."]")
                        if spell.aura then
                            QA.trackedAuras[spellId] = spell
                        elseif spell.duration then
                            QA.trackedCombatLog[spellId] = spell -- offensive
                        end
                        if spell.cooldown then
                            QA.trackedSpellCooldowns[spellId] = spell
                        end
                    end
                elseif spell.itemId then
                    if spell.cooldown then
                        QA.trackedItemCooldowns[spell.itemId] = spell
                    end
                end
            end
        end
    end
end

function QA:BuildTrackedTracking()
    QA.trackedTracking[QA.spells.reminders.findHerbs.spellId[1]] = QA.spells.reminders.findHerbs
    QA.trackedTracking[QA.spells.reminders.findMinerals.spellId[1]] = QA.spells.reminders.findMinerals
end
