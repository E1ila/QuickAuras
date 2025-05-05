local ADDON_NAME, addon = ...
local QuickAuras = addon.root

local function InEncounters(ids)
    if not QuickAuras.encounter then return false end
    for _, id in ipairs(ids) do
        if QuickAuras.encounter.id == id then
            return true
        end
    end
end

QuickAuras.consumes = {
    {
        name = "Arcane Elixir",
        spellIds = { 17539, 11390 },
        itemIds = { 13454, 9155 },
        itemId = 13454,
        default = QuickAuras.isManaClass,
    },
    {
        name = "Firepower Elixir",
        spellIds = { 26276, 7844 },
        itemIds = { 21546, 6373 },
        itemId = 21546,
        default = QuickAuras.isFireClass,
    },
    {
        name = "Mongoose Elixir",
        spellIds = { 17538, 11334, 11328 },
        itemIds = { 13452, 9187, 8949 },
        itemId = 13452,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
    },
    {
        name = "Zanza",
        spellIds = { 24382, 24383, 24417, 27669, 10669, 10693, 10668, 10667, 27671 },
        itemIds = { 20079, 20081, 20080, 22175, 8412, 8424, 8411, 8410 },
        itemId = 20079,
    },
    {
        name = "Juju Power",
        spellIds = { 16323 },
        itemId = 12451,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
    },
    {
        name = "Juju Chill",
        spellIds = { 16325 },
        itemId = 12457,
        visibleFunc = function()
            return InEncounters({1119, 1114})
        end -- default naxx attuned
    },
    {
        name = "Juju Might",
        spellIds = { 16329 },
        itemId = 12460,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
    },
    {
        name = "Juju Ember",
        spellIds = { 16326 },
        itemId = 12455,
        visibleFunc = function()
            return InEncounters({613, 672})
        end
    },
    {
        name = "Troll's Blood Potion",
        spellIds = { 24361 },
        itemId = 20004,
    },
    {
        name = "Elixir of Fortitude",
        spellIds = { 3593 },
        itemId = 3825,
    },
    {
        name = "Food Buff",
        spellIds = { 24800, 18192, 22730, 18194, 18191, 18193, 25661 },
        itemIds = { 20452, 13928, 18254, 13931, 13927, 13934, 13929, 21023 },
        itemId = 20452,
    },
    {
        name = "Winterfall Firewater",
        spellIds = { 17038 },
        itemId = 12820,
        default = QuickAuras.isRogue or QuickAuras.isWarrior,
    },
    {
        name = "Frost Power",
        spellIds = { 21920 },
        itemId = 17708,
        default = QuickAuras.isMage,
    },
    {
        name = "Mageblood Potion",
        spellIds = { 24363 },
        itemId = 20007,
        default = QuickAuras.isManaClass,
    },
    {
        name = "Sweet Surprise",
        spellIds = { 27722 },
        itemId = 22239,
        default = QuickAuras.isShaman or QuickAuras.isPriest or QuickAuras.isDruid or QuickAuras.isPaladin,
    },
    {
        name = "Buttermilk Delight",
        spellIds = { 27720 },
        itemId = 22236,
    },
    {
        name = "Dark Desire",
        spellIds = { 27723 },
        itemId = 22237,
    },
    {
        name = "Very Berry Cream",
        spellIds = { 27721 },
        itemId = 22238,
    },
    {
        name = "Ankh",
        itemId = 17030,
        minCount = 2,
        visible = QuickAuras.isShaman,
    },
    {
        name = "Chronoboons",
        itemId = 184937,
        minCount = 3,
    },
    {
        name = "Mana Potions",
        itemId = 13444,
        minCount = 10,
        visible = QuickAuras.isManaClass,
    },
}

function QuickAuras:BuildTrackedMissingBuffs()
    for _, buff in ipairs(self.consumes) do
        buff.option = "mb_"..buff.name:gsub("%s+", "")
        if buff.spellIds then
            buff.list = "missing"
            --buff.tooltip = false
            table.insert(self.trackedMissingBuffs, buff)

            if (buff.visible == nil or buff.visible) then
                buff.list = "reminder"
                table.insert(self.trackedLowConsumes, buff)
            end
        end
    end
end
