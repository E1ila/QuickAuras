local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

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
        name = "Ankh",
        itemId = 17030,
        minCount = 2,
        visible = QuickAuras.isShaman,
    },
    {
        name = "Arcane Elixir",
        spellIds = { 17539, 11390 },
        itemIds = { 13454, 9155 },
        itemId = 13454,
        default = QuickAuras.isManaClass,
        minCount = 5,
    },
    {
        name = "Blinding Powder",
        itemId = 5530,
        minCount = 5,
        visible = QuickAuras.isRogue,
    },
    {
        name = "Buttermilk Delight",
        spellIds = { 27720 },
        itemId = 22236,
    },
    {
        name = "Chronoboons",
        itemId = 184937,
        minCount = 3,
    },
    {
        name = "Dark Desire",
        spellIds = { 27723 },
        itemId = 22237,
    },
    {
        name = "Elixir of Fortitude",
        spellIds = { 3593 },
        itemId = 3825,
        minCount = 5,
    },
    {
        name = "Firepower Elixir",
        spellIds = { 26276, 7844 },
        itemIds = { 21546, 6373 },
        itemId = 21546,
        default = QuickAuras.isFireClass,
        minCount = 5,
    },
    {
        name = "Flash Powder",
        itemId = 5140,
        minCount = 10,
        visible = QuickAuras.isRogue,
    },
    {
        name = "Food Buff",
        spellIds = { 24800, 18192, 22730, 18194, 18191, 18193, 25661 },
        itemIds = { 20452, 13928, 18254, 13931, 13927, 13934, 13929, 21023 },
        itemId = 20452,
        minCount = 10,
    },
    {
        name = "Frost Power",
        spellIds = { 21920 },
        itemId = 17708,
        default = QuickAuras.isMage,
        minCount = 5,
    },
    {
        name = "Juju Chill",
        spellIds = { 16325 },
        itemId = 12457,
        minCount = 5,
        visibleFunc = function()
            return InEncounters({1119, 1114})
        end -- default naxx attuned
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
        name = "Juju Might",
        spellIds = { 16329 },
        itemId = 12460,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
        minCount = 10,
    },
    {
        name = "Juju Power",
        spellIds = { 16323 },
        itemId = 12451,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
        minCount = 10,
    },
    {
        name = "Mageblood Potion",
        spellIds = { 24363 },
        itemId = 20007,
        default = QuickAuras.isManaClass,
    },
    {
        name = "Mana Potions",
        itemId = 13444,
        minCount = 10,
        visible = QuickAuras.isManaClass,
        minCount = 10,
    },
    {
        name = "Mongoose Elixir",
        spellIds = { 17538, 11334, 11328 },
        itemIds = { 13452, 9187, 8949 },
        itemId = 13452,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
    },
    {
        name = "Sweet Surprise",
        spellIds = { 27722 },
        itemId = 22239,
        default = QuickAuras.isShaman or QuickAuras.isPriest or QuickAuras.isDruid or QuickAuras.isPaladin,
    },
    {
        name = "Thistle Tea",
        itemId = 7676,
        cooldown = true,
        minCount = 10,
    },
    {
        name = "Troll's Blood Potion",
        spellIds = { 24361 },
        itemId = 20004,
    },
    {
        name = "Very Berry Cream",
        spellIds = { 27721 },
        itemId = 22238,
    },
    {
        name = "Winterfall Firewater",
        spellIds = { 17038 },
        itemId = 12820,
        default = QuickAuras.isRogue or QuickAuras.isWarrior,
        minCount = 5,
    },
    {
        name = "Zanza",
        spellIds = { 24382, 24383, 24417, 27669, 10669, 10693, 10668, 10667, 27671 },
        itemIds = { 20079, 20081, 20080, 22175, 8412, 8424, 8411, 8410 },
        itemId = 20079,
    },
}

function QuickAuras:BuildTrackedItems()
    local p = QuickAuras.defaultOptions.profile
    debug(2, "BuildTrackedItems...")
    for _, item in ipairs(self.consumes) do
        item.option = "item_".. item.name:gsub("%s+", "")
        debug(3, "BuildTrackedItems", item.name, item.option, item.spellIds, item.visible)
        if item.spellIds then
            item.list = "missing"
            --buff.tooltip = false
            table.insert(self.trackedMissingBuffs, item)
        end
        if (item.visible == nil or item.visible) then
            item.list = "reminder"
            table.insert(self.trackedLowConsumes, item)
        end
        if item.cooldown then
            self.trackedSpellCooldowns[item.itemId] = item
        end
    end
end
