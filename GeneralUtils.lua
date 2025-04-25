function MeleeUtils_UI:InitGeneralUI()
    MUGLOBAL.Debug("Initializing General UI")
    MeleeUtils_Parry_Texture:SetVertexColor(1, 0, 0)
end

function MeleeUtils_UI:ShowParry()
    MeleeUtils_Parry:Show()
    C_Timer.After(1, function()
        MeleeUtils_Parry:Hide()
    end)
end
