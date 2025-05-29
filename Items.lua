local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

local function InEncounters(ids)
    if not QA.encounter.id then return false end
    for _, id in ipairs(ids) do
        if QA.encounter.id == id then
            return true
        end
    end
end

QA.explosives = {
    thoriumGrenade = {
        name = "Thorium Grenade",
        itemId = 15993,
        minCount = 5,
        icon = "Interface\\Icons\\inv_misc_bomb_08",
    },
    ironGranade = {
        name = "Iron Grenade",
        itemId = 4390,
        minCount = 5,
        icon = "Interface\\Icons\\inv_misc_bomb_08",
    },
    denseDynamite = {
        name = "Dense Dynamite",
        itemId = 18641,
        minCount = 10,
        icon = "Interface\\Icons\\inv_misc_bomb_06",
    },
    goblinSapperCharge = {
        name = "Goblin Sapper Charge",
        itemId = 10646,
        minCount = 5,
        icon = "Interface\\Icons\\spell_fire_selfdestruct",
    },
}

QA.consumes = {
    QA.explosives.denseDynamite,
    QA.explosives.goblinSapperCharge,
    QA.explosives.ironGranade,
    QA.explosives.thoriumGrenade,
    {
        name = "Ankh",
        itemId = 17030,
        minCount = 2,
        visible = QA.isShaman,
    },
    {
        name = "Arcane Elixir",
        spellIds = { 17539, 11390 },
        itemIds = { 13454, 9155 },
        itemId = 13454,
        default = QA.isManaClass,
        minCount = 5,
    },
    {
        name = "Blinding Powder",
        itemId = 5530,
        minCount = 5,
        visible = QA.isRogue,
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
        default = QA.isFireClass,
        minCount = 5,
    },
    {
        name = "Flash Powder",
        itemId = 5140,
        minCount = 10,
        visible = QA.isRogue,
    },
    {
        name = "Flask of Chromatic Resistance",
        itemId = 13513,
        minCount = 1,
        default = false,
    },
    {
        name = "Flask of Distilled Wisdom",
        itemId = 13511,
        minCount = 1,
        default = QA.isShaman or QA.isPriest or QA.isDruid or QA.isPaladin,
    },
    {
        name = "Flask of Petrification",
        itemId = 13506,
        minCount = 1,
        default = false,
    },
    {
        name = "Flask of Supreme Power",
        itemId = 13512,
        minCount = 1,
        default = QA.isWarlock or QA.isMage,
    },
    {
        name = "Flask of the Titans",
        itemId = 13510,
        minCount = 1,
        default = QA.isRogue or QA.isWarrior,
    },
    {
        name = "Food Buff",
        spellIds = { 24800, 18192, 22730, 18194, 18191, 18193, 25661 },
        itemIds = { 20452, 13928, 18254, 13931, 13927, 13934, 13929, 21023 },
        itemId = 20452,
        minCount = 10,
    },
    {
        name = "Free Action Potion",
        itemId = 5634,
        minCount = 5,
    },
    {
        name = "Frost Power",
        spellIds = { 21920 },
        itemId = 17708,
        default = QA.isMage,
        minCount = 5,
    },
    {
        name = "Greater Arcane Protection Potion",
        itemId = 13461,
        minCount = 2,
    },
    {
        name = "Greater Fire Protection Potion",
        itemId = 13457,
        minCount = 2,
    },
    {
        name = "Greater Frost Protection Potion",
        itemId = 13456,
        minCount = 5,
    },
    {
        name = "Greater Nature Protection Potion",
        itemId = 13458,
        minCount = 5,
    },
    {
        name = "Greater Shadow Protection Potion",
        itemId = 13459,
        minCount = 5,
    },
    {
        name = "Heavy Runecloth Bandage",
        itemId = 14530,
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
        default = QA.isRogue or QA.isWarrior or QA.isHunter,
        minCount = 10,
    },
    {
        name = "Juju Power",
        spellIds = { 16323 },
        itemId = 12451,
        default = QA.isRogue or QA.isWarrior or QA.isHunter,
        minCount = 10,
    },
    {
        name = "Mageblood Potion",
        spellIds = { 24363 },
        itemId = 20007,
        default = QA.isManaClass,
    },
    {
        name = "Mana Potions",
        itemId = 13444,
        minCount = 10,
        visible = QA.isManaClass,
        minCount = 10,
    },
    {
        name = "Mongoose Elixir",
        spellIds = { 17538, 11334, 11328 },
        itemIds = { 13452, 9187, 8949 },
        itemId = 13452,
        default = QA.isRogue or QA.isWarrior or QA.isHunter,
    },
    {
        name = "Sweet Surprise",
        spellIds = { 27722 },
        itemId = 22239,
        default = QA.isShaman or QA.isPriest or QA.isDruid or QA.isPaladin,
    },
    {
        name = "Thistle Tea",
        itemId = 7676,
        cooldown = true,
        minCount = 10,
        icon = "Interface\\Icons\\inv_drink_milk_05",
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
        default = QA.isRogue or QA.isWarrior,
        minCount = 5,
    },
    {
        name = "Zanza",
        spellIds = { 24382, 24383, 24417, 27669, 10669, 10693, 10668, 10667, 27671 },
        itemIds = { 20079, 20081, 20080, 22175, 8412, 8424, 8411, 8410 },
        itemId = 20079,
        minCount = 1,
    },
}

function QA:SortConsumes()
    table.sort(QA.consumes, function(a, b)
        return a.name < b.name
    end)
end

function QA:BuildTrackedItems()
    QA:SortConsumes()
    local p = QA.defaultOptions.profile
    debug(2, "BuildTrackedItems...")
    for _, item in ipairs(QA.consumes) do
        item.option = "item_".. item.name:gsub("%s+", "")
        --debug(3, "BuildTrackedItems", item.name, item.option, item.spellIds, item.visible)
        if item.spellIds then
            table.insert(QA.trackedMissingBuffs, item)
        end
        if (item.visible == nil or item.visible) then
            table.insert(QA.trackedLowConsumes, item)
        end
        if item.cooldown then
            QA.trackedItemCooldowns[item.itemId] = item
        end
    end
end
