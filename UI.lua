local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local pbId = 0
local _uiLocked = true

-- General -----------------------------------------------------------

function QuickAuras:InitUI()
    debug("Initializing UI")
    QuickAuras_Parry_Texture:SetVertexColor(1, 0, 0)
    QuickAuras_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)

    --self:SetDarkBackdrop(QuickAuras_WatchBars)
    --self:DisableDarkBackdrop(QuickAuras_WatchBars)
    QuickAuras_WatchBars_Text:Hide()

    --self:SetDarkBackdrop(QuickAuras_OffensiveBars)
    --self:DisableDarkBackdrop(QuickAuras_OffensiveBars)
    QuickAuras_OffensiveBars_Text:Hide()

    --self:SetDarkBackdrop(QuickAuras_Cooldowns)
    --self:DisableDarkBackdrop(QuickAuras_Cooldowns)
    QuickAuras_Cooldowns_Text:Hide()

    --self:SetDarkBackdrop(QuickAuras_IconWarnings)
    --self:DisableDarkBackdrop(QuickAuras_IconWarnings)
    QuickAuras_IconWarnings_Text:Hide()

    --self:SetDarkBackdrop(QuickAuras_IconAlerts)
    --self:DisableDarkBackdrop(QuickAuras_IconAlerts)
    QuickAuras_IconAlerts_Text:Hide()

    --self:CreateProgressBar(QuickAuras_Flurry, 25, 2, {0.9, 0.6, 0}, "Interface\\Icons\\Ability_Warrior_PunishingBlow")
    --QuickAuras_Flurry:Show()
    --QuickAuras_Flurry_Progress_Bar:SetValue(1)
end

function QuickAuras:ResetRogueWidgets()
    --QuickAuras_Combo_Texture:ClearAllPoints()
    --QuickAuras_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --QuickAuras_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)

    --QuickAuras_Parry_Texture:ClearAllPoints()
    --QuickAuras_Parry_Texture:SetSize(128, 128)
    --QuickAuras_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

end

function QuickAuras:SetDarkBackdrop(frame)
    frame:SetBackdrop ({bgFile = [[Interface\AddOns\QuickAuras\assets\background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function QuickAuras:DisableDarkBackdrop(frame)
    frame:SetBackdrop (nil)
end


-- Icon warnings ------------------------------------

function QuickAuras:CreateWarningIcon(itemId, parentFrame, frameName)
    -- Create a button frame
    local frame = CreateFrame("Frame", frameName, parentFrame)

    -- Get the item's icon texture
    local itemIcon = GetItemIcon(itemId)
    if not itemIcon then
        print("Invalid itemId:", itemId)
        return nil
    end

    -- Set the button's normal texture to the item's icon
    local iconTexture = frame:CreateTexture(nil, "BACKGROUND")
    iconTexture:SetTexture(itemIcon)
    iconTexture:SetAllPoints(frame)
    frame.icon = iconTexture

    -- Add a tooltip to show the item's name
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(itemId)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return frame
end

function QuickAuras:AddIconGearWarning(itemId, conf)
    if not self.iconWarnings[itemId] then
        --debug("AddIconGearWarning", itemId)
        local frame = self:CreateWarningIcon(itemId, QuickAuras_IconWarnings, "GearWarning"..itemId)
        self.iconWarnings[itemId] = {
            name = conf.name,
            frame = frame,
        }
        return true
    end
end

function QuickAuras:RemoveIconWarning(itemId)
    if self.iconWarnings[itemId] then
        --debug("RemoveIconWarning", itemId)
        local frame = self.iconWarnings[itemId].frame
        frame:Hide()
        frame:SetParent(nil)
        frame:ClearAllPoints()
        self.iconWarnings[itemId] = nil
        return true
    end
end

function QuickAuras:AddIconAuraAlert(spellId, conf)
    if not self.iconAlerts[spellId] then
        --debug("AddIconGearWarning", itemId)
        local frame = self:CreateWarningIcon(spellId, QuickAuras_IconAlerts, "AuraAlert"..spellId)
        self.iconAlerts[spellId] = {
            name = conf.name,
            frame = frame,
        }
        return true
    end
end

function QuickAuras:RemoveIconAlert(spellId)
    if self.iconAlerts[spellId] then
        --debug("RemoveIconAlert", itemId)
        local frame = self.iconAlerts[spellId].frame
        frame:Hide()
        frame:SetParent(nil)
        frame:ClearAllPoints()
        self.iconAlerts[spellId] = nil
        return true
    end
end

function QuickAuras:ClearIconWarnings()
    --debug("Clearing icon warnings")
    for itemId, obj in pairs(self.iconWarnings) do
        self:RemoveIconWarning(itemId)
    end
end

function QuickAuras:ArrangeIconWarnings()
    --debug("Arranging icon warnings")
    local lastFrame = nil
    for itemId, obj in pairs(self.iconWarnings) do
        local frame = obj.frame
        frame:ClearAllPoints()
        if lastFrame then
            frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 2, 0)
        else
            frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
        end
        frame:SetSize(self.db.profile.iconWarningSize, self.db.profile.iconWarningSize) -- Width, Height
        lastFrame = frame
    end
end


-- Widget Positioning -----------------------------------------------------------

function QuickAuras:ToggleLockedState()
    _uiLocked = not _uiLocked
    for _, frame in ipairs(self.adjustableFrames) do
        local f = _G[frame]
        if f then
            f:EnableMouse(not _uiLocked)
            if _uiLocked then f:Hide() else f:Show() end
        end
    end
    out("Frames are now "..(_uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))
end

function QuickAuras:ResetWidgets()
    debug("Resetting widgets")
    self:ResetGeneralWidgets()
    self:ResetRogueWidgets()
end



-- Progress Bar -----------------------------------------------------------

function QuickAuras:CreateProgressBar(parent, index, padding, color, icon)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "QuickAuras_PBAR"..tostring(pbId), parent, "QuickAuras_ProgressBar")
    --debug("Created progress bar", "name", frame:GetName(), "index", index, "parent", parent)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8, -- Border thickness
        insets   = { left = padding, right = padding, top = padding, bottom = padding } -- Padding
    })
    frame:SetBackdropBorderColor(unpack(color)) -- Red border
    frame:SetBackdropColor(0, 0, 0, 0.5) -- Black background with 50% opacity

    local iconFrame = _G[frame:GetName().."_Icon"]
    local barFrame  = _G[frame:GetName().."_Progress_Bar"]
    local progFrame = _G[frame:GetName().."_Progress"]

    progFrame:ClearAllPoints()
    progFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 0, 0)
    progFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, 2)

    barFrame:SetStatusBarColor(unpack(color))

    local height = self.db.profile.barHeight or 25
    iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    iconFrame.icon:SetTexture(icon)
    iconFrame:SetSize(height-padding*2, height-padding*2)
    iconFrame.icon:SetSize(height-padding*2, height-padding*2)

    return frame
end

function QuickAuras:CreateProgressButton(parent, index, padding, color, icon)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "QuickAuras_PBTN"..tostring(pbId), parent, "QuickAuras_ProgressButton")
    --debug("Created progress button", "name", frame:GetName(), "index", index, "parent", parent)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints(frame)
    frame.icon:SetTexture(icon)

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints(frame)

    return frame
end

function QuickAuras:ArrangeProgressFrames(list, parent, gap)
    local lastFrame = nil
    for i, timer in ipairs(list) do
        timer.frame:ClearAllPoints()
        if timer.uiType == "bar" then
            if lastFrame then
                timer.frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -(gap or -2))
            else
                timer.frame:SetPoint("TOP", parent, "TOP", 0, 0)
            end
            timer.frame:SetPoint("LEFT", parent, "LEFT", 0, 0)
            timer.frame:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
            local height = self.db.profile.barHeight or 25
            timer.frame:SetHeight(height)

        elseif timer.uiType == "button" then
            if lastFrame then
                timer.frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", -(gap or -2), 0)
            else
                timer.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            end
            local height = self.db.profile.buttonHeight or 50
            timer.frame:SetSize(height, height)
        end
        lastFrame = timer.frame
    end
end

function QuickAuras:UpdateProgressBar(timer)
    --debug("Updating progress for", timer.name, "expTime", timer.expTime, "duration", timer.duration)
    if timer.expTime == 0 or (timer.duration > 0 and timer.expTime > GetTime()) then
        timer.frame:Show()
        if timer.duration then
            local progress = (timer.expTime - GetTime()) / timer.duration
            if timer.uiType == "bar" then
                _G[timer.frame:GetName().."_Progress_Bar"]:SetValue(progress)
            elseif timer.uiType == "button" then
                timer.frame.cooldown:SetCooldown(timer.expTime - timer.duration, timer.duration)
            end
        end
        return true
    else
        timer.frame:Hide()
        return false
    end
end


-------------------------------------------------------------

function QuickAuras:Rogue_SetCombo(n)
    if n < 5 then
        QuickAuras_Combo:Hide()
    else
        QuickAuras_Combo:Show()
    end
end

function QuickAuras:ShowParry()
    QuickAuras_Parry:Show()
    C_Timer.After(1, function()
        QuickAuras_Parry:Hide()
    end)
end

local lastErrorTime = 0
local errorCount = 0
function QuickAuras:ShowNoticableError(text)
    QuickAuras_OutOfRange_Text:SetText(string.upper(text))
    QuickAuras_OutOfRange:Show()
    if self.db.profile.outOfRangeSound then
        if GetTime() - lastErrorTime > 6 then
            errorCount = 0
        end
        lastErrorTime = GetTime()
        if errorCount == 1 then
            PlaySoundFile("Interface\\AddOns\\QuickAuras\\assets\\sonar.ogg", "Master")
        elseif errorCount == 4 then
            errorCount = 0
        end
        errorCount = errorCount + 1
    end
    C_Timer.After(1, function()
        QuickAuras_OutOfRange:Hide()
    end)
end



-- Test UI -----------------------------------------------------------

function QuickAuras:TestProgressBar(abilities)
    for i, conf in pairs(abilities) do
        if conf.list then
            local duration = math.min(conf.duration or 10, 15)
            local expTime = GetTime() + duration
            self:SetProgressTimer("test", "bar", nil, nil, conf, duration, expTime)
        end
    end
end

function QuickAuras:TestWatchBars()
    self:TestProgressBar(self.trackedAuras)
    self:TestProgressBar(self.trackedCombatLog)
end

function QuickAuras:TestCooldowns()
    local t = 0
    for i, conf in pairs(self.trackedCooldowns) do
        self:SetProgressTimer("test", "button", self.cooldowns, QuickAuras_Cooldowns, conf, 15-t, GetTime()+15-t)
        t = t + 1
    end
end

local TestIconWarnings_Timer_Id = 0
function QuickAuras:TestIconWarnings()
    self:ClearIconWarnings()
    for i, conf in pairs(self.trackedGear) do
        self:AddIconGearWarning(i, conf)
        if i == 3 then break end
    end
    QuickAuras:ArrangeIconWarnings()

    TestIconWarnings_Timer_Id = TestIconWarnings_Timer_Id + 1
    local timerId = TestIconWarnings_Timer_Id
    C_Timer.After(2, function()
        if timerId ~= TestIconWarnings_Timer_Id then return end
        debug("TestIconWarnings timer ended")
        QuickAuras:ClearIconWarnings()
        QuickAuras:CheckGear()
    end)
end
