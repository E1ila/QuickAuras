local ADDON_NAME, addon = ...
local QuickAuras = addon.root

QuickAuras.consumes = {
    {
        name = "Greater Arcane Elixir",
        spellIds = { 17539 },
        itemId = 13454,
        default = QuickAuras.isManaClass,
    }
}

function QuickAuras:BuildTrackedMissingBuffs()
    for _, buff in ipairs(self.consumes) do
        for _, spellId in ipairs(buff.spellIds) do
            local spellName = GetSpellInfo(spellId)
            buff.name = spellName
            buff.option = "mb_"..spellName:gsub("%s+", "")
            buff.list = "missing"
            buff.tooltip = false
            self.trackedMissingBuffs[spellId] = buff
        end
    end
end
