local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

QuickAuras.optionalEvents = {
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
    "UNIT_POWER_UPDATE",
}

QuickAuras.adjustableFrames = {
    ["QuickAuras_Parry"] = {
        visible = QuickAuras.isRogue,
    },
    ["QuickAuras_Combo"] = {
        visible = QuickAuras.isRogue,
    },
    ["QuickAuras_Flurry"] = {
        visible = QuickAuras.isRogue,
    },
}

QuickAuras.colors = {
    bold = "|cffff77aa",
    enabled = "|cff00ff00",
    disabled = "|cffffff00",
}

QuickAuras.trackedGear = {
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

QuickAuras.capitalCities = {
    ["Stormwind"] = true,
    ["Ironforge"] = true,
    ["Darnassus"] = true,
    ["Orgrimmar"] = true,
    ["Thunder Bluff"] = true,
    ["Undercity"] = true,
}

-- these will be detected through UNIT_AURA event
QuickAuras.trackedAuras = {}

-- these will be detected through COMBAT_LOG_EVENT_UNFILTERED
QuickAuras.trackedCombatLog = {}

-- these will be detected through SPELL_UPDATE_COOLDOWN
QuickAuras.trackedSpellCooldowns = {}
QuickAuras.trackedItemCooldowns = {}

QuickAuras.trackedMissingBuffs = {}

QuickAuras.trackedLowConsumes = {}

QuickAuras.trackedTracking = {}

-- custom events

function QuickAuras:BuildTrackedGear()
    local MARK_OF_THE_CHAMPION_ITEM_ID = { 23206, 23207 }
    for _, itemId in ipairs(MARK_OF_THE_CHAMPION_ITEM_ID) do
        QuickAuras.trackedGear[itemId] = {
            name = "Mark of the Champion",
            desc = "Smart warning - shows if you need to use the trinket, or if you need to remove it (non undead/demon).",
            targetDependant = true,
            visibleFunc = function(equipped)
                local targetExists = UnitExists("target") and not UnitIsDead("target") and not UnitPlayerControlled("target") and UnitIsEnemy("target", "player")
                local isUndeadOrDemon = UnitCreatureType("target") == "Undead" or UnitCreatureType("target") == "Demon"

                if equipped then
                    return targetExists and not isUndeadOrDemon
                else
                    return targetExists and isUndeadOrDemon and QuickAuras.bags[itemId]
                end
            end,
        }
    end
end

function QuickAuras:BuildTrackedSpells()
    debug(2, "BuildTrackedSpells...")
    for category, cspells in pairs(QuickAuras.spells) do
        --debug(3, "BuildTrackedSpells", ">>", string.upper(category))
        for key, spell in pairs(cspells) do
            --debug(3, "BuildTrackedSpells", "  - ", key)
            if spell.spellId and (spell.visible == nil or spell.visible) then
                for _, spellId in ipairs(spell.spellId) do
                    --debug(3, "BuildTrackedSpells", "    -- ", spell.name, "["..tostring(spellId).."]", spell.aura and "AURA" or "-", "[option:", tostring(spell.option).."]")
                    if spell.aura then
                        self.trackedAuras[spellId] = spell
                    elseif spell.duration then -- combat log ability has to have duration
                        self.trackedCombatLog[spellId] = spell
                    end
                    if spell.cooldown then
                        self.trackedSpellCooldowns[spellId] = spell
                    end
                end
            end
        end
    end
end

function QuickAuras:BuildTrackedTracking()
    self.trackedTracking[self.spells.reminders.findHerbs.spellId[1]] = self.spells.reminders.findHerbs
    self.trackedTracking[self.spells.reminders.findMinerals.spellId[1]] = self.spells.reminders.findMinerals
end
