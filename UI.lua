local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local out = QuickAuras.Print
local debug = QuickAuras.Debug
local pbId = 0
local _uiLocked = true
local _c
local _testIconWarnings_Timer_Id = 0
local _testIconAlerts_Timer_Id = 0

-- General -----------------------------------------------------------

function QuickAuras:InitUI()
    debug("Initializing UI")
    _c = self.colors
    self:ParentFramesNormalState()
    QuickAuras_Parry_Texture:SetVertexColor(1, 0, 0)
    QuickAuras_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)
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


-- frame creation -----------------------------------

function QuickAuras:CreateItemWarningIcon(itemId, parentFrame, frameName)
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

function QuickAuras:CreateTextureIcon(texture, parentFrame, frameName)
    -- Create a button frame
    local frame = CreateFrame("Frame", frameName, parentFrame)

    -- Set the button's normal texture to the item's icon
    local iconTexture = frame:CreateTexture(nil, "BACKGROUND")
    iconTexture:SetTexture(texture)
    iconTexture:SetAllPoints(frame)
    frame.icon = iconTexture

    return frame
end


-- Icon warnings ------------------------------------

local function GetIconList(type)
    local list, parent, Create
    if type == "warning" then
        list = QuickAuras.iconWarnings
        parent = QuickAuras_IconWarnings
        Create = QuickAuras.CreateItemWarningIcon
    elseif type == "alert" then
        list = QuickAuras.iconAlerts
        parent = QuickAuras_IconAlerts
    end
    return list, parent, Create
end

function QuickAuras:AddItemIcon(type, itemId, conf)
    local list, parent, Create = GetIconList(type)
    if not list[itemId] then
        --debug("AddItemIcon", itemId)
        local frame = Create(self, itemId, parent, type.."-"..itemId)
        list[itemId] = {
            name = conf.name,
            frame = frame,
            list = list,
            parent = parent,
        }
        return true
    end
end

function QuickAuras:RemoveIcon(type, id)
    local list = GetIconList(type)
    if list[id] then
        --debug("RemoveIconWarning", itemId)
        local frame = list[id].frame
        frame:Hide()
        frame:SetParent(nil)
        frame:ClearAllPoints()
        list[id] = nil
        return true
    end
end

function QuickAuras:ClearIcons(type)
    --debug("Clearing icon warnings")
    local list = GetIconList(type)
    for id, obj in pairs(list) do
        self:RemoveIcon(type, id)
    end
end

function QuickAuras:ArrangeIcons(type)
    --debug("Arranging icon warnings")
    local list, parent, Create = GetIconList(type)
    local lastFrame = nil
    for _, obj in pairs(list) do
        local frame = obj.frame
        frame:ClearAllPoints()
        if type == "warning" then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 2, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(self.db.profile.gearWarningSize, self.db.profile.gearWarningSize) -- Width, Height
        elseif type == "alert" then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 2, 0) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(self.db.profile.iconAlertSize, self.db.profile.iconAlertSize) -- Width, Height
        end
        lastFrame = frame
    end
end


-- Widget Positioning -----------------------------------------------------------

function QuickAuras:ParentFramesNormalState()
    self:DisableDarkBackdrop(QuickAuras_WatchBars)
    self:DisableDarkBackdrop(QuickAuras_OffensiveBars)
    self:DisableDarkBackdrop(QuickAuras_Cooldowns)
    self:DisableDarkBackdrop(QuickAuras_MissingConsumes)
    self:DisableDarkBackdrop(QuickAuras_IconWarnings)
    self:DisableDarkBackdrop(QuickAuras_IconAlerts)
    QuickAuras_WatchBars_Text:Hide()
    QuickAuras_OffensiveBars_Text:Hide()
    QuickAuras_Cooldowns_Text:Hide()
    QuickAuras_MissingConsumes_Text:Hide()
    QuickAuras_IconWarnings_Text:Hide()
    QuickAuras_IconAlerts_Text:Hide()
end

function QuickAuras:ParentFramesEditState()
    self:SetDarkBackdrop(QuickAuras_WatchBars)
    self:SetDarkBackdrop(QuickAuras_OffensiveBars)
    self:SetDarkBackdrop(QuickAuras_Cooldowns)
    self:SetDarkBackdrop(QuickAuras_MissingConsumes)
    self:SetDarkBackdrop(QuickAuras_IconWarnings)
    self:SetDarkBackdrop(QuickAuras_IconAlerts)
    QuickAuras_WatchBars_Text:Show()
    QuickAuras_OffensiveBars_Text:Show()
    QuickAuras_Cooldowns_Text:Show()
    QuickAuras_Missing_Text:Show()
    QuickAuras_IconWarnings_Text:Show()
    QuickAuras_IconAlerts_Text:Show()
end

function QuickAuras:ToggleLockedState()
    _uiLocked = not _uiLocked

    if  _uiLocked then
        self:ParentFramesNormalState()
    else
        self:ParentFramesEditState()
    end

    for name, obj in ipairs(self.adjustableFrames) do
        if obj.visible == nil or obj.visible then
            local f = _G[frame]
            if f then
                f:EnableMouse(not _uiLocked)
                if _uiLocked then f:Hide() else f:Show() end
            end
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

function QuickAuras:CreateProgressBar(parent, index, padding, color, icon, text)
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
    frame.icon = iconFrame.icon

    progFrame:ClearAllPoints()
    progFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 0, 0)
    progFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, 2)

    barFrame:SetStatusBarColor(unpack(color))

    local height = self.db.profile.barHeight or 25
    iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    iconFrame.icon:SetTexture(icon)
    iconFrame:SetSize(height-padding*2, height-padding*2)
    iconFrame.icon:SetSize(height-padding*2, height-padding*2)

    local textLayer = _G[frame:GetName().."_Progress_Bar_Text"];
    if text then
        frame.text = textLayer
        textLayer:SetText(text)
    else
        textLayer:SetText("")
    end

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

    local cooldownText = frame.cooldown:GetRegions() -- Get the font region
    if cooldownText and cooldownText.SetFont then
        cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE") -- Set font, size, and style
    end

    return frame
end

function QuickAuras:ArrangeProgressFrames(list, parent, gap)
    local lastFrame = nil
    for i, timer in ipairs(list) do
        --debug(3, "Arranging progress frames", timer.key, timer.uiType)
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
        if timer.duration > 1 then
            local progress = (timer.expTime - GetTime()) / timer.duration
            if timer.uiType == "bar" then
                _G[timer.frame:GetName().."_Progress_Bar"]:SetValue(progress)
                if timer.frame.text then
                    timer.frame.text:SetText(string.format("%.1f", timer.expTime - GetTime()))
                end
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

function QuickAuras:TestProgressBar(abilities, limit)
    local i = 0
    local seen = {}
    for _, conf in pairs(abilities) do
        if (conf.list == "watch" or conf.list == "offensive") and not seen[conf.name] then
            --debug("TestProgressBar", "conf", conf.name, limit)
            i = i + 1
            seen[conf.name] = true
            local duration = math.min(conf.duration or 10, 15)
            local expTime = GetTime() + duration
            self:SetProgressTimer("test", "bar", nil, nil, conf, duration, expTime)
            if i == limit then break end
        end
    end
end

function QuickAuras:TestBars()
    self:TestProgressBar(self.trackedAuras, 5)
    self:TestProgressBar(self.trackedCombatLog, 3)
end

function QuickAuras:TestCooldowns()
    local t = 0
    for i, conf in pairs(self.trackedCooldowns) do
        self:SetProgressTimer("test", "button", self.cooldowns, QuickAuras_Cooldowns, conf, 15-t, GetTime()+15-t)
        t = t + 1
    end
end

function QuickAuras:TestIconWarnings()
    self:ClearIcons("warning")
    local count = 0
    for itemId, conf in pairs(self.trackedGear) do
        count = count + 1
        self:AddItemIcon("warning", itemId, conf)
        if count == 3 then break end
    end
    self:ArrangeIcons("warning")

    _testIconWarnings_Timer_Id = _testIconWarnings_Timer_Id + 1
    local timerId = _testIconWarnings_Timer_Id
    C_Timer.After(2, function()
        if timerId ~= _testIconWarnings_Timer_Id then return end
        debug("TestIconWarnings timer ended")
        QuickAuras:ClearIcons("warning")
        QuickAuras:CheckGear()
    end)
end

function QuickAuras:TestIconAlerts()
    local seconds = 6
    self:SetProgressTimer("auras", "button", nil, nil, self.spells.iconAlerts.limitedInvulnerabilityPotion, seconds, GetTime()+seconds)
    self:SetProgressTimer("auras", "button", nil, nil, self.spells.iconAlerts.limitedInvulnerabilityPotion, seconds, GetTime()+seconds)

    _testIconAlerts_Timer_Id = _testIconAlerts_Timer_Id + 1
    local timerId = _testIconAlerts_Timer_Id
    C_Timer.After(seconds, function()
        if timerId ~= _testIconAlerts_Timer_Id then return end
        debug("TestIconAlerts timer ended")
        QuickAuras:ClearIcons("alert")
        --QuickAuras:CheckAura()
    end)
end

function QuickAuras:DemoUI()
    self:TestBars()
    self:TestCooldowns()
    self:TestIconWarnings()
    self:TestIconAlerts()
end

function QuickAuras:DemoUI2()
    QuickAuras_Parry:Show()
    QuickAuras_Combo:Show()
    QuickAuras_OutOfRange:Show()
    C_Timer.After(3, function()
        QuickAuras_Parry:Hide()
        QuickAuras_Combo:Hide()
        QuickAuras_OutOfRange:Hide()
    end)
end
