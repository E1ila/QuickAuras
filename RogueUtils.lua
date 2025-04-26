local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug

function MeleeUtils:InitRogueUI()
    debug("Initializing Rogue UI")
    MeleeUtils_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)
end

function MeleeUtils:ResetRogueWidgets()
    --MeleeUtils_Combo_Texture:ClearAllPoints()
    --MeleeUtils_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --MeleeUtils_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)
end

function MeleeUtils:Rogue_SetCombo(n)
    if n < 5 then
        MeleeUtils_Combo:Hide()
    else
        MeleeUtils_Combo:Show()
    end
end
