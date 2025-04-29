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
}

QuickAuras.adjustableFrames = {
    "QuickAuras_Parry",
    "QuickAuras_Combo",
    "QuickAuras_Flurry",
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
    [23206] = {
        name = "Mark of the Champion",
        desc = "Smart warning - shows if you need to use the trinket, or if you need to remove it (non undead/demon).",
        targetDependant = true,
        shouldShow = function(equipped)
            local targetExists = UnitExists("target") and not UnitIsDead("target") and not UnitPlayerControlled("target") and UnitIsEnemy("target", "player")
            local isUndeadOrDemon = UnitCreatureType("target") == "Undead" or UnitCreatureType("target") == "Demon"

            if equipped then
                return targetExists and not isUndeadOrDemon
            else
                return targetExists and isUndeadOrDemon
            end
        end,
    },
    [17067] = {
        name = "Ancient Cornerstone Grimoire",
    },
    [10588] = {
        name = "Goblin Rocket Helmet",
    },
}

-- these will be detected through UNIT_AURA event
QuickAuras.trackedAuras = {}

-- these will be detected through COMBAT_LOG_EVENT_UNFILTERED
QuickAuras.trackedCombatLog = {}

-- these will be detected through SPELL_UPDATE_COOLDOWN
QuickAuras.trackedCooldowns = {}

function QuickAuras:BuildTrackedSpells()
    debug("Building config...")
    for classLower, classAbilities in pairs(QuickAuras.abilities) do
        for abilityId, ability in pairs(classAbilities) do
            if ability.spellId and ability.visible then
                for _, spellId in ipairs(ability.spellId) do
                    if ability.aura then
                        QuickAuras.trackedAuras[spellId] = ability
                    elseif ability.duration then -- combat log ability has to have duration
                        QuickAuras.trackedCombatLog[spellId] = ability
                    end
                    if ability.cooldown then
                        QuickAuras.trackedCooldowns[spellId] = ability
                    end
                end
            end
        end
    end
end
