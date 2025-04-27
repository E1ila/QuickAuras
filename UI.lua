local ADDON_NAME, addon = ...
local MeleeUtils = addon.root
local debug = MeleeUtils.Debug

function MeleeUtils:InitUI()
    debug("Initializing UI")
    MeleeUtils_Parry_Texture:SetVertexColor(1, 0, 0)
    MeleeUtils_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)

    --self:SetDarkBackdrop(MeleeUtils_WatchBars)
    --self:DisableDarkBackdrop(MeleeUtils_WatchBars)
    MeleeUtils_WatchBars_Text:Hide()

    --self:SetDarkBackdrop(MeleeUtils_OffensiveBars)
    --self:DisableDarkBackdrop(MeleeUtils_OffensiveBars)
    MeleeUtils_OffensiveBars_Text:Hide()

    self:SetDarkBackdrop(MeleeUtils_Cooldowns)
    --self:DisableDarkBackdrop(MeleeUtils_OffensiveBars)
    --MeleeUtils_OffensiveBars_Text:Hide()

    --self:CreateProgressBar(MeleeUtils_Flurry, 25, 2, {0.9, 0.6, 0}, "Interface\\Icons\\Ability_Warrior_PunishingBlow")
    --MeleeUtils_Flurry:Show()
    --MeleeUtils_Flurry_Progress_Bar:SetValue(1)
end

function MeleeUtils:ResetRogueWidgets()
    --MeleeUtils_Combo_Texture:ClearAllPoints()
    --MeleeUtils_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --MeleeUtils_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)

    --MeleeUtils_Parry_Texture:ClearAllPoints()
    --MeleeUtils_Parry_Texture:SetSize(128, 128)
    --MeleeUtils_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

end

function MeleeUtils:SetDarkBackdrop(frame)
    frame:SetBackdrop ({bgFile = [[Interface\AddOns\MeleeUtils\assets\background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function MeleeUtils:DisableDarkBackdrop(frame)
    frame:SetBackdrop (nil)
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

local lastErrorTime = 0
local errorCount = 0
function MeleeUtils:ShowNoticableError(text)
    MeleeUtils_OutOfRange_Text:SetText(string.upper(text))
    MeleeUtils_OutOfRange:Show()
    if self.db.profile.outOfRangeSound then
        if GetTime() - lastErrorTime > 6 then
            errorCount = 0
        end
        lastErrorTime = GetTime()
        if errorCount == 1 then
            PlaySoundFile("Interface\\AddOns\\MeleeUtils\\assets\\sonar.ogg", "Master")
        elseif errorCount == 4 then
            errorCount = 0
        end
        errorCount = errorCount + 1
    end
    C_Timer.After(1, function()
        MeleeUtils_OutOfRange:Hide()
    end)
end
