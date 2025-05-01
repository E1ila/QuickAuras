local ADDON_NAME, addon = ...
local QuickAuras = addon.root

QuickAuras.consumes = {
    {
        name = "Greater Arcane Elixir",
        spellIds = { 17539 },
        default = QuickAuras.isManaClass,
    }
}
