
function MeleeUtils_UI:InitGeneralUI()
    MUGLOBAL.Debug("Initializing General UI")
    MeleeUtils_Parry_Texture:SetVertexColor(1, 0, 0)
end

function MeleeUtils_UI:ResetGeneralWidgets()
    --MeleeUtils_Parry_Texture:ClearAllPoints()
    --MeleeUtils_Parry_Texture:SetSize(128, 128)
    --MeleeUtils_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
end

function MeleeUtils_UI:UpdateZone()
    local inInstance, instanceType = IsInInstance()
    MUGLOBAL.InstanceName = nil
    if inInstance and (instanceType == "raid" or instanceType == "party") then
        MUGLOBAL.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
    end
    MUGLOBAL.ZoneName = GetRealZoneText()
    MUGLOBAL.Debug("Updating Zone:", MUGLOBAL.ZoneName)
end

function MeleeUtils_UI:ShowParry()
    MeleeUtils_Parry:Show()
    C_Timer.After(1, function()
        MeleeUtils_Parry:Hide()
    end)
end

