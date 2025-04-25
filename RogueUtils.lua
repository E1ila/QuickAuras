function MeleeUtils_Rogue:InitRogueUI()
    MUGLOBAL.Debug("Initializing Rogue UI")
    MeleeUtils_Combo_Texture:SetScale(1.5)
    MeleeUtils_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)
end

function MeleeUtils_Rogue:Rogue_SetCombo(n)
    if n < 5 then
        MeleeUtils_Combo:Hide()
    else
        MeleeUtils_Combo:Show()
    end
end
