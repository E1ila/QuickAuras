local ADDON_NAME, addon = ...
local QuickAuras = addon.root

QuickAuras.consumes = {
    {
        name = "Greater Arcane Elixir",
        spellIds = { 17539, 11390 },
        itemId = 13454,
        default = QuickAuras.isManaClass,
    },
    {
        name = "Elixir of Greater Firepower",
        spellIds = { 26276, 7844 },
        itemId = 21546,
        default = QuickAuras.isFireClass,
    },
    {
        name = "Elixir of the Mongoose",
        spellIds = { 17538, 11334, 11328 },
        itemId = 13452,
        default = QuickAuras.isRogue or QuickAuras.isWarrior or QuickAuras.isHunter,
    },
    {
        name = "Zanza",
        spellIds = { 24382, 24383, 27669, 20080, 10669, 10693, 10668, 10667 },
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
    },
    {
        name = "Major Troll's Blood Potion",
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
        spellIds = { 24799, 18192, 24799, 22730, 18194, 18191, 18193, 25661, 18191, 18192 },
        itemId = 13755,
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
    }

}

function QuickAuras:BuildTrackedMissingBuffs()
    for _, buff in ipairs(self.consumes) do
        local itemName = GetItemInfo(buff.itemId)
        buff.name = itemName
        buff.option = "mb_"..itemName:gsub("%s+", "")
        buff.list = "missing"
        --buff.tooltip = false
        self.trackedMissingBuffs[buff.itemId] = buff
    end
end
