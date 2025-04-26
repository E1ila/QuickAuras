local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug

function MeleeUtils:InitUI()
    debug("Initializing UI")
    MeleeUtils_Parry_Texture:SetVertexColor(1, 0, 0)
    MeleeUtils_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)
end

function MeleeUtils:ResetRogueWidgets()
    --MeleeUtils_Combo_Texture:ClearAllPoints()
    --MeleeUtils_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --MeleeUtils_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)

    --MeleeUtils_Parry_Texture:ClearAllPoints()
    --MeleeUtils_Parry_Texture:SetSize(128, 128)
    --MeleeUtils_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

end

function MeleeUtils:Rogue_SetCombo(n)
    if n < 5 then
        MeleeUtils_Combo:Hide()
    else
        MeleeUtils_Combo:Show()
    end
end

function MeleeUtils:ShowParry()
    MeleeUtils_Parry:Show()
    C_Timer.After(1, function()
        MeleeUtils_Parry:Hide()
    end)
end
