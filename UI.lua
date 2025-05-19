local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug
local pbId = 0
local _c
local ICON = QA.ICON

QA.uiLocked = true

local LSM = LibStub("LibSharedMedia-3.0")
local cleanTexture = LSM:Fetch("statusbar", "Clean")

local function FormatNumberWithCommas(n)
    local str = tostring(n)
    local result = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if result:sub(1,1) == "," then
        result = result:sub(2)
    end
    return result
end

-- General -----------------------------------------------------------

function QA:InitUI()
    debug("Initializing UI")
    _c = QA.colors
    QA:ParentFramesNormalState()
    QA:InitWeaponEnchants()
    QA:InitSwingTimers()
    --QA:InitCrucialBuffMissing()
    QA:InitRangeIndication()
    QuickAuras_Parry_Texture:SetVertexColor(1, 0, 0)
    QuickAuras_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    QA:Rogue_SetCombo(0)
    --QA:CheckWeaponEnchant()

    QA:ConfigureXpFrame()
    QA:UpdateXpFrame()
end

function QA:InitWeaponEnchants()
    QuickAuras_WeaponEnchant1.icon = QuickAuras_WeaponEnchant1:CreateTexture(nil, "BACKGROUND")
    QuickAuras_WeaponEnchant1.icon:SetAllPoints(QuickAuras_WeaponEnchant1)
    QuickAuras_WeaponEnchant2.icon = QuickAuras_WeaponEnchant2:CreateTexture(nil, "BACKGROUND")
    QuickAuras_WeaponEnchant2.icon:SetAllPoints(QuickAuras_WeaponEnchant2)
end

function QA:SetWeaponEnchantIcon(slot, itemId)
    local itemIcon = GetItemIcon(itemId)
    local frame = slot == 1 and QuickAuras_WeaponEnchant1 or QuickAuras_WeaponEnchant2
    frame.icon:SetTexture(itemIcon)
    frame:SetSize(QA.db.profile.weaponEnchantSize, QA.db.profile.weaponEnchantSize)
end

function QA:InitRangeIndication(frame)
    QuickAuras_RangeIndicator.icon = QuickAuras_RangeIndicator:CreateTexture(nil, "BACKGROUND")
    QuickAuras_RangeIndicator.icon:SetAllPoints(QuickAuras_RangeIndicator)
    QuickAuras_RangeIndicator:Hide()
    QA:UpdateRangeIndication()
end

function QA:UpdateRangeIndication()
    QuickAuras_RangeIndicator:SetSize(QA.db.profile.rangeIconSize, QA.db.profile.rangeIconSize)
    if QA.db.profile.rangeSpellId then
        local texture = GetSpellTexture(QA.db.profile.rangeSpellId)
        QuickAuras_RangeIndicator.icon:SetTexture(texture)
    end
end

function QA:InitSwingTimers()
    QuickAuras_SwingTimer:SetBackdrop({
        bgFile = "Interface\\AddOns\\QuickAuras\\assets\\background", -- Optional background
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Blizzard Tooltip border
        edgeSize = 8, -- Border thickness
        insets = { left = 1, right = 1, top = 1, bottom = 1 } -- Padding
    })
    QuickAuras_SwingTimer:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    QuickAuras_SwingTimer:SetBackdropBorderColor(0, 0, 0, 0.9)

    QuickAuras_SwingTimer_Text:Hide()

    local texture = QuickAuras_SwingTimer_MH:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(QuickAuras_SwingTimer_MH)
    texture:SetColorTexture(1, 0.2, 0.2, 1)
    QuickAuras_SwingTimer_MH.texture = texture

    texture = QuickAuras_SwingTimer_OH:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(QuickAuras_SwingTimer_OH)
    texture:SetColorTexture(0.2, 0.2, 1, 1)
    QuickAuras_SwingTimer_OH.texture = texture

    if QA.db.profile.swingTimersEnabled then
        QuickAuras_SwingTimer:Show()
    else
        QuickAuras_SwingTimer:Hide()
    end
end

function QA:ResetRogueWidgets()
    --QuickAuras_Combo_Texture:ClearAllPoints()
    --QuickAuras_Combo_Texture:SetSize(384, 384) -- Set the frame size
    --QuickAuras_Combo_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, -30)

    --QuickAuras_Parry_Texture:ClearAllPoints()
    --QuickAuras_Parry_Texture:SetSize(128, 128)
    --QuickAuras_Parry_Texture:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

end

function QA:SetDarkBackdrop(frame, border)
    if border then
        frame:SetBackdrop({
            bgFile = "Interface\\AddOns\\QuickAuras\\assets\\background", -- Optional background
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Blizzard Tooltip border
            edgeSize = 8, -- Border thickness
            insets = { left = 1, right = 1, top = 1, bottom = 1 } -- Padding
        })
    else
        frame:SetBackdrop ({
            bgFile = [[Interface\AddOns\QuickAuras\assets\background]],
            tile = true,
            tileSize = 16,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        })
    end
    frame:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function QA:DisableDarkBackdrop(frame)
    frame:SetBackdrop (nil)
end

-- xp frame -----------------------------------------

function QA:ConfigureXpFrame()
    QA:SetDarkBackdrop(QuickAuras_XP, true)
    QuickAuras_XP_Text:Show()
    QuickAuras_XP_Left_Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    QuickAuras_XP_Right_Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    QuickAuras_XP_Bottom_Text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    QuickAuras_XP_Bar1:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar1:SetStatusBarColor(0.204, 0.302, 0.471)
    QuickAuras_XP_Bar2:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar2:SetStatusBarColor(0.784, 0.467, 0)
    QuickAuras_XP_Bar3:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar3:SetStatusBarColor(0.337, 0.388, 1.0)
    if QA.db.profile.xpFrameEnabled and QA.playerLevel < 60 then
        QuickAuras_XP:Show()
    else
        QuickAuras_XP:Hide()
    end
end

function QA:UpdateXpFrame()
    if QA.db.profile.xpFrameEnabled and QA.playerLevel < 60 then
        QA.xp.UpdateQuestXP(self)

        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local restedXP = GetXPExhaustion() or 0

        local p_current = currentXP / maxXP
        local p_completed = QA.xp.completeXP / maxXP
        local p_rested = restedXP / maxXP

        local s_current = tostring(math.floor(p_current*1000)/10).."%"
        local s_completed = tostring(math.floor(p_completed*1000)/10).."%"
        local s_rested = tostring(math.floor(p_rested*1000)/10).."%"

        QuickAuras_XP_Bar3:SetValue(p_current)
        QuickAuras_XP_Bar2:SetValue(p_current+p_completed)
        QuickAuras_XP_Bar1:SetValue(p_current+p_completed+p_rested)

        QuickAuras_XP_Left_Text:SetText(FormatNumberWithCommas(currentXP).." / "..FormatNumberWithCommas(maxXP))
        QuickAuras_XP_Right_Text:SetText(s_current)
        QuickAuras_XP_Bottom_Text:SetText("Completed: |cffff9700"..s_completed.."|r - Rested: |cff4f90ff"..s_rested.."|r")
    end
end

-- frame creation -----------------------------------

QA.ignoredIcons = {}

function QA:CreateItemWarningIcon(itemId, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick)
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
    debug(3, "CreateItemWarningIcon", frameName, "itemId", itemId, "icon", itemIcon)

    if showCount then
        local counterText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        counterText:SetFont("Fonts\\FRIZQT__.TTF", math.floor(QA.db.profile.reminderIconSize/2), "OUTLINE")
        counterText:SetTextColor(1, 1, 1, 1)
        counterText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2) -- Position the counter
        counterText:SetText("0") -- Default value
        frame.counterText = counterText -- Store the counter for later updates
    end

    if showTooltip then
        -- Add a tooltip to show the item's name
        frame:SetScript("OnEnter", function(QA)
            GameTooltip:SetOwner(QA, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(itemId)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if onRightClick or onClick then
        frame:SetScript("OnMouseDown", function(QA, button)
            if onRightClick and button == "RightButton" then
                onRightClick()
            elseif onClick and button == "LeftButton" then
                onClick()
            end
        end)
    end

    return frame
end

function QA:CreateSpellWarningIcon(spellId, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick)
    -- Create a button frame
    local frame = CreateFrame("Frame", frameName, parentFrame)

    -- Get the item's icon texture
    --local spellIcon = GetItemIcon(12457)
    local spellIcon = GetSpellTexture(spellId)
    if not spellIcon then
        print("Invalid spellId:", spellId)
        return nil
    end

    -- Set the button's normal texture to the item's icon
    local iconTexture = frame:CreateTexture(nil, "BACKGROUND")
    iconTexture:SetTexture(spellIcon)
    iconTexture:SetAllPoints(frame)
    frame.icon = iconTexture
    debug(3, "CreateSpellWarningIcon", frameName, "spellId", spellId, "icon", spellIcon)

    if showTooltip then
        -- Add a tooltip to show the item's name
        frame:SetScript("OnEnter", function(QA)
            GameTooltip:SetOwner(QA, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if onRightClick or onClick then
        frame:SetScript("OnMouseDown", function(QA, button)
            if onRightClick and button == "RightButton" then
                onRightClick()
            elseif onClick and button == "LeftButton" then
                onClick()
            end
        end)
    end

    return frame
end

function QA:CreateTextureIcon(texture, parentFrame, frameName)
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

local function GetIconList(type, idType)
    local list, parent, Refresh, glowInCombat
    local Create = idType == "item" and QA.CreateItemWarningIcon or QA.CreateSpellWarningIcon
    if type == ICON.WARNING then
        list = QA.list_iconWarnings
        parent = QuickAuras_IconWarnings
        Refresh = QA.RefreshWarnings
    elseif type == ICON.MISSING then
        list = QA.list_missingBuffs
        parent = QuickAuras_MissingBuffs
        Refresh = QA.RefreshMissing
        glowInCombat = true
    elseif type == ICON.ALERT then
        list = QA.list_iconAlerts
        parent = QuickAuras_IconAlerts
        Refresh = QA.RefreshAlerts
    elseif type == ICON.REMINDER then
        list = QA.list_reminders
        parent = QuickAuras_Reminders
        Refresh = QA.RefreshReminders
    elseif type == ICON.CRUCIAL then
        list = QA.list_crucial
        parent = QuickAuras_Crucial
        glowInCombat = true
        --Refresh = QuickAuras.RefreshReminders
    elseif type == ICON.RANGE then
        list = QA.list_range
        parent = QuickAuras_RangeIndicator
        --Refresh = QuickAuras.RefreshReminders
    elseif type == ICON.QUEUE then
        list = QA.list_queue
        parent = QuickAuras_SpellQueue
        --Refresh = QuickAuras.RefreshReminders
    end
    return list, parent, Create, Refresh, glowInCombat
end

function QA:AddIcon(iconType, idType, id, conf, count, showTooltip, onClick)
    local key = iconType.."-"..idType.."-"..tostring(id)
    if QA.ignoredIcons[key] then return nil end
    local list, parent, Create, Refresh, glowInCombat = GetIconList(iconType, idType)
    if not list[id] then
        debug(2, "AddIcon", id, "parent", parent:GetName(), "count", count)
        local showCount = iconType == ICON.REMINDER and (conf.minCount or QA.db.profile.lowConsumesMinCount)
        local onRightClick = iconType ~= ICON.ALERT and Refresh and function()
            QA.ignoredIcons[key] = true
            Refresh(QA)
        end or nil
        if showTooltip == nil then showTooltip = conf.tooltip == nil or conf.tooltip end
        local frame = Create(QA, id, parent, iconType .."-".. id, showTooltip, showCount, onRightClick, onClick)
        local button = {
            name = conf.name,
            conf = conf,
            id = id,
            idType = idType,
            frame = frame,
            list = list,
            parent = parent,
            count = count,
            glowInCombat = glowInCombat
        }
        list[id] = button
        return button
    elseif count ~= nil then
        list[id].count = count
        return list[id]
    end
end

function QA:RemoveIcon(iconType, id)
    local list = GetIconList(iconType)
    local obj = list[id]
    if obj then
        if obj.isTimer then
            QA:RemoveTimer(obj, "removeicon")
        else
            local frame = obj.frame
            frame:Hide()
            frame:SetParent(nil)
            frame:ClearAllPoints()
            list[id] = nil
        end
        return true
    end
end

function QA:ClearIcons(iconType)
    --debug("Clearing icon warnings")
    local list = GetIconList(iconType)
    for id, obj in pairs(list) do
        QA:RemoveIcon(iconType, id)
    end
end

function QA:ArrangeIcons(iconType)
    --debug("Arranging icon warnings")
    local list = GetIconList(iconType)
    local lastFrame = nil
    local count = 0
    for _, obj in pairs(list) do
        count = count + 1
        local frame = obj.frame
        frame:ClearAllPoints()
        debug(3, "ArrangeIcons", iconType, obj.id, "frame", frame:GetName(), "parent", frame:GetParent():GetName())
        if frame.counterText and obj.count and type(obj.count) == "number" then
            --debug(3, "ArrangeIcons", "count", obj.count)
            frame.counterText:SetText(obj.count)
        end
        if iconType == ICON.WARNING then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", -5, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(QA.db.profile.gearWarningSize, QA.db.profile.gearWarningSize) -- Width, Height
        elseif iconType == ICON.MISSING then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(QA.db.profile.missingBuffsSize, QA.db.profile.missingBuffsSize) -- Width, Height
        elseif iconType == ICON.REMINDER then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(QA.db.profile.reminderIconSize, QA.db.profile.reminderIconSize) -- Width, Height
        elseif iconType == ICON.ALERT then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 2, 0) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(QA.db.profile.iconAlertSize, QA.db.profile.iconAlertSize) -- Width, Height
        elseif iconType == ICON.CRUCIAL then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(QA.db.profile.crucialIconSize, QA.db.profile.crucialIconSize) -- Width, Height
        elseif iconType == ICON.QUEUE then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:GetParent():SetSize(QA.db.profile.spellQueueIconSize * count, QA.db.profile.spellQueueIconSize) -- Width, Height
            frame:SetSize(QA.db.profile.spellQueueIconSize, QA.db.profile.spellQueueIconSize) -- Width, Height
        elseif iconType == ICON.RANGE then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 2, 0) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(QA.db.profile.rangeIconSize, QA.db.profile.rangeIconSize) -- Width, Height
        end
        if obj.glowInCombat then
            if QA.inCombat and not obj.frame.glow then
                ActionButton_ShowOverlayGlow(obj.frame)
                obj.frame.glow = true
            elseif not QA.inCombat and obj.frame.glow then
                ActionButton_HideOverlayGlow(obj.frame)
                obj.frame.glow = false
            end
        end
        lastFrame = frame
    end
end


-- Widget Positioning -----------------------------------------------------------

function QA:ParentFramesNormalState()
    QuickAuras_XP:EnableMouse(false)
    QuickAuras_SwingTimer_MH:EnableMouse(false)
    QuickAuras_SwingTimer_Text:Hide()
    for _, frame in ipairs(QA.adjustableFrames) do
        QA:DisableDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Hide()
        frame:EnableMouse(false)
    end
end

function QA:ParentFramesEditState()
    QuickAuras_XP:EnableMouse(true)
    QuickAuras_SwingTimer_MH:EnableMouse(true)
    QuickAuras_SwingTimer_Text:Show()
    for _, frame in ipairs(QA.adjustableFrames) do
        QA:SetDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Show()
        frame:EnableMouse(true)
    end
end

function QA:ToggleLockedState()
    QA.uiLocked = not QA.uiLocked

    if QA.uiLocked then
        QA:ParentFramesNormalState()
    else
        QA:ParentFramesEditState()
    end
    out("Frames are now "..(_uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))
end

function QA:ResetWidgets()
    debug("Resetting widgets")
    QA:ResetGeneralWidgets()
    QA:ResetRogueWidgets()
end



-- Progress Bar -----------------------------------------------------------

function QA:CreateTimerBar(parent, index, padding, color, icon, text)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "QuickAuras_PBAR"..tostring(pbId), parent, "QuickAuras_ProgressBar")
    --debug("Created progress bar", "name", frame:GetName(), "index", index, "parent", parent)
    frame:SetBackdrop({
        bgFile   = "Interface\\AddOns\\QuickAuras\\assets\\background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8, -- Border thickness
        insets   = { left = padding, right = padding, top = padding, bottom = padding } -- Padding
    })
    frame:SetBackdropBorderColor(unpack(color)) -- Red border
    frame:SetBackdropColor(0, 0, 0, 0.5) -- Black background with 50% opacity

    frame.iconFrame = _G[frame:GetName().."_Icon"]
    local progFrame = _G[frame:GetName().."_Progress"]
    frame.icon = frame.iconFrame.icon
    frame.iconFrame.icon:SetAllPoints(frame.iconFrame)

    progFrame:ClearAllPoints()
    progFrame:SetPoint("TOPLEFT", frame.iconFrame, "TOPRIGHT", 0, 0)
    progFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, 2)

    frame.barFrame  = _G[frame:GetName().."_Progress_Bar"]
    frame.barFrame:SetStatusBarColor(unpack(color))

    frame.iconFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    frame.iconFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, padding)
    frame.iconFrame.icon:SetTexture(icon)

    local textLayer = _G[frame:GetName().."_Progress_Bar_Text"];
    if text then
        frame.text = textLayer
        textLayer:SetText(text)
    else
        textLayer:SetText("")
    end

    return frame
end

function QA:CreateTimerButton(parent, index, padding, color, icon)
    local frame
    pbId = pbId + 1
    frame = CreateFrame("Frame", "QuickAuras_PBTN"..tostring(pbId), parent, "QuickAuras_ProgressButton")
    debug(2, "Created progress button", "name", frame:GetName(), "index", index, "parent", parent)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints(frame)
    frame.icon:SetTexture(icon)

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints(frame)

    frame.cooldownText = frame.cooldown:GetRegions() -- Get the font region
    if frame.cooldownText and frame.cooldownText.SetFont then
        frame.cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE") -- Set font, size, and style
    end

    return frame
end

function QA:ArrangeTimerBars(list, parent)
    local sortedList = {}
    for _, timer in pairs(list) do
        table.insert(sortedList, timer)
    end
    table.sort(sortedList, function(a, b)
        return a.expTime > b.expTime
    end)
    debug(2, "Arranging timer bars", parent:GetName())
    local lastFrame
    for _, timer in pairs(sortedList) do
        debug(3, "Arranging progress frames", timer.key, timer.uiType)
        timer.frame:ClearAllPoints()
        if timer.uiType == "bar" then
            if lastFrame then
                timer.frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -QA.db.profile.barGap+4)
            else
                timer.frame:SetPoint("TOP", parent, "TOP", 0, 0)
            end
            local height = timer.height or QA.db.profile.barHeight or 25
            local padding = 2
            timer.frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
            timer.frame:SetSize(QA.db.profile.barWidth * (timer.widthMul or 1), height)
            timer.frame.iconFrame:SetSize(height-padding*2, height-padding*2)
            timer.frame.iconFrame.icon:SetSize(height-padding*2, height-padding*2)
        elseif timer.uiType == "button" then
            if lastFrame then
                timer.frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", -QA.db.profile.barGap+4, 0)
            else
                timer.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            end
            local height = timer.height or QA.db.profile.buttonHeight or 50
            timer.frame:SetSize(height, height)
        end
        lastFrame = timer.frame
    end
end


-------------------------------------------------------------

function QA:Rogue_SetCombo(n)
    if n < 5 then
        QuickAuras_Combo:Hide()
    else
        QuickAuras_Combo:Show()
    end
end

function QA:ShowParry()
    QuickAuras_Parry:Show()
    C_Timer.After(1, function()
        QuickAuras_Parry:Hide()
    end)
end

local lastErrorTime = 0
local errorCount = 0
local OOR_TIMEOUT_SEC = 10
local OOR_CYCLE = 6
local OOR_SOUND = 3
function QA:ShowNoticableError(text)
    QuickAuras_OutOfRange_Text:SetText(string.upper(text))
    QuickAuras_OutOfRange:Show()
    if QA.db.profile.outOfRangeSound then
        if GetTime() - lastErrorTime > OOR_TIMEOUT_SEC then
            errorCount = 0
        end
        lastErrorTime = GetTime()
        if errorCount == OOR_SOUND then
            PlaySoundFile("Interface\\AddOns\\QuickAuras\\assets\\sonar.ogg", "Master")
        elseif errorCount == OOR_CYCLE then
            errorCount = 0
        end
        errorCount = errorCount + 1
    end
    C_Timer.After(1, function()
        QuickAuras_OutOfRange:Hide()
    end)
end

function QA:ResetErrorCount()
    lastErrorTime = GetTime()
    errorCount = 0
end

local abortBlinkingAggro = false
function QA:StopBlinkingAggro()
    abortBlinkingAggro = true
end

local function _BlinkAggro(count)
    if count == 0 then
        QA.blinkingAggro = false
        return
    end
    QuickAuras_Aggro:Show()
    C_Timer.After(0.5, function()
        QuickAuras_Aggro:Hide()
        if abortBlinkingAggro then QA.blinkingAggro = false return end
        C_Timer.After(0.5, function()
            _BlinkAggro(count-1)
        end)
    end)
end

function QA:BlinkGotAggro()
    if QA.blinkingAggro then return end
    QA.blinkingAggro = true
    abortBlinkingAggro = false
    _BlinkAggro(QA.db.profile.aggroBlinkCount)
end


-- Test UI -----------------------------------------------------------

function QA:TestProgressBar(spells, limit, includeRaidBars)
    local count1 = 0
    local count2 = 0
    local seen = {}
    for key, conf in pairs(spells) do
        if (conf.list == "watch" or conf.list == "offensive") and not seen[conf.name] then
            if count1 < limit then
                debug(3, "TestProgressBar", "conf", conf.name, conf.list, limit)
                seen[conf.name] = true
                local duration = 15 - (count1*2)
                local expTime = GetTime() + duration
                QA:AddTimer("test", conf, key, duration, expTime)
                count1 = count1 + 1
            end
        elseif conf.raidBars and includeRaidBars then
            if count2 < limit then
                debug(3, "TestProgressBar", "conf", conf.name, conf.list, limit)
                -- we'll inject raidbars separately
                local duration = math.min(conf.duration, 10)
                --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
                QA:AddTimer("raidbar", conf, conf.spellId[1], duration, GetTime()+duration, nil, "Text", tostring(count2))
                count2 = count2 + 1
            end
        end
    end
end

function QA:TestBars()
    QA:TestProgressBar(QA.trackedAuras, 5)
    QA:TestProgressBar(QA.trackedCombatLog, 3, true)
end

function QA:TestFlashBar()
    local snd = QA.trackedAuras[6774]
    QA:AddTimer("test", snd, "test", 5, GetTime()+5)
end

function QA:TestCooldowns()
    local t = 0
    for i, conf in pairs(QA.trackedSpellCooldowns) do
        --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
        if conf.spellId then
            QA:AddTimer("test-cooldowns", conf, conf.spellId[1], 15-t, GetTime()+15-t)
            t = t + 1
        end
    end
end

local DelayedReset_Reminders = QA:Debounce(function()
    --debug("TestReminders timer ended")
    QA:RefreshReminders()
end, 3)

function QA:TestReminders()
    QA:ClearIcons(ICON.REMINDER)
    --QA:AddIcon(ICON.REMINDER, "spell", 2383, QA.trackedAuras[2383])
    for i, conf in ipairs(QA.trackedLowConsumes) do
        QA:AddIcon(ICON.REMINDER, "item", conf.itemId, conf, i)
        if i == 3 then break end
    end
    QA:ArrangeIcons(ICON.REMINDER)
    DelayedReset_Reminders()
end

local DelayedReset_IconMissingBuffs = QA:Debounce(function()
    --debug("TestIconMissingBuffs timer ended")
    QA:RefreshMissing()
end, 3)

function QA:TestIconMissingBuffs()
    QA:ClearIcons(ICON.MISSING)
    local count = 0
    for _, conf in ipairs(QA.trackedMissingBuffs) do
        count = count + 1
        QA:AddIcon(ICON.MISSING, "item", conf.itemId, conf)
    end
    QA:ArrangeIcons(ICON.MISSING)
    DelayedReset_IconMissingBuffs()
end

local DelayedReset_IconWarnings = QA:Debounce(function()
    --debug("TestIconWarnings timer ended")
    QA:RefreshWarnings()
end, 3)

function QA:TestIconWarnings()
    QA:ClearIcons(ICON.WARNING)
    local count = 0
    for itemId, conf in pairs(QA.trackedGear) do
        count = count + 1
        QA:AddIcon(ICON.WARNING, "item", itemId, conf)
        if count == 3 then break end
    end
    QA:ArrangeIcons(ICON.WARNING)
    DelayedReset_IconWarnings()
end

local DelayedReset_IconAlerts = QA:Debounce(function()
    --debug("TestIconAlerts timer ended")
    QA:ClearIcons(ICON.ALERT)
end, 6)

function QA:TestIconAlerts()
    local lip = QA.spells.iconAlerts.limitedInvulnerabilityPotion
    --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
    QA:AddTimer("auras", lip, lip.spellId[1], 6, GetTime()+6)
    DelayedReset_IconAlerts()
end

local DelayedReset_CrucialAlerts = QA:Debounce(function()
    QA:ClearIcons(ICON.CRUCIAL)
end, 3)

function QA:TestCrucial()
    local bs = QA.spells.warrior.battleShout
    local frr = QA.spells.shaman.frostResistanceTotem
    --  :AddIcon(iconType, idType, id, conf, count, showTooltip, onClick)
    QA:AddIcon(ICON.CRUCIAL, "spell", bs.spellId[1], bs)
    QA:AddIcon(ICON.CRUCIAL, "spell", frr.spellId[1], frr)
    QA:ArrangeIcons(ICON.CRUCIAL)
    DelayedReset_CrucialAlerts()
end

local DelayedReset_SpellQueue = QA:Debounce(function()
    QA:ClearIcons(ICON.QUEUE)
end, 3)

function QA:TestSpellQueue()
    local hs = QA.spells.warrior.heroicStrike
    local cleave = QA.spells.warrior.cleave
    QA:AddIcon(ICON.QUEUE, "spell", hs.spellId[1], hs)
    QA:AddIcon(ICON.QUEUE, "spell", cleave.spellId[1], cleave)
    QA:ArrangeIcons(ICON.QUEUE)
    DelayedReset_SpellQueue()
end


local function fixLogInput(...)
    local args = { ... }
    for i = 1, #args do
        local x = args[i]
        if i == 1 or i == 2 or i == 6 then
        elseif #x > 0 and string.sub(x, 1, 1) == '"' then
            args[i] = string.sub(x, 2, -2)
        elseif x:match("^0x") then
            args[i] = tonumber(x, 16)
        else
            args[i] = tonumber(x)
        end
        --debug("fixed", "#"..tostring(i), x, "=>", args[i], "("..type(args[i])..")")
    end
    return unpack(args)
end

function QA:InjectLog(log)
    for i, line in ipairs(log) do
        if line and #line > 0 then
            local subevent, sourceGuid, sourceName, _, _, destGuid, destName, _, _, p1, p2, p3, p4, p5, p6 = fixLogInput(strsplit(",", line))
            QA:HandleCombatLogEvent("", subevent, "", sourceGuid, sourceName, "", "", destGuid, destName, "", "", p1, p2, p3, p4, p5, p6)
        end
    end
end

function QA:TestInject()
    local log = {
        "SPELL_AURA_APPLIED,Player-5233-018ED242,\"Aivengard-Earthshaker-EU\",0x512,0x0,Player-5233-018ED242,\"Aivengard-Earthshaker-EU\",0x512,0x0,3169,\"Invulnerability\",0x1,BUFF",
        "SPELL_AURA_APPLIED,Player-5233-024D46FB,\"Rähan-Firemaw-EU\",0x514,0x0,Player-5233-024D46FB,\"Rähan-Firemaw-EU\",0x514,0x0,3169,\"Invulnerability\",0x1,BUFF",
        --"SPELL_AURA_APPLIED,Player-5233-01CD0550,\"Ayablackpaw-Gandling-EU\",0x514,0x0,Player-5233-01CD0550,\"Ayablackpaw-Gandling-EU\",0x514,0x0,3169,\"Invulnerability\",0x1,BUFF",
        "SPELL_AURA_APPLIED,Player-5233-01F4ABDF,\"Defchad-Firemaw-EU\",0x40514,0x0,Creature-0-5253-533-7736-16453-00019CF387,\"Necro Stalker\",0x10a48,0x80,355,\"Taunt\",0x1,DEBUFF",
        "SPELL_AURA_APPLIED,Player-5233-033F9882,\"Dirge-Firemaw-EU\",0x514,0x0,Player-5233-033F9882,\"Dirge-Firemaw-EU\",0x514,0x0,12328,\"Death Wish\",0x1,DEBUFF",
        --"SPELL_AURA_APPLIED,Player-5233-026BAE34,\"Brucice-Firemaw-EU\",0x514,0x0,Player-5233-026BAE34,\"Brucice-Firemaw-EU\",0x514,0x0,12328,\"Death Wish\",0x1,DEBUFF",
        --"SPELL_AURA_APPLIED,Player-5233-02671588,\"Shorukh-Firemaw-EU\",0x514,0x0,Player-5233-02671588,\"Shorukh-Firemaw-EU\",0x514,0x0,12328,\"Death Wish\",0x1,DEBUFF",
        "SPELL_AURA_APPLIED,Player-5233-027AEBDF,\"Blenders-Firemaw-EU\",0x514,0x0,Player-5233-027AEBDF,\"Blenders-Firemaw-EU\",0x514,0x0,13877,\"Blade Flurry\",0x1,BUFF",
        "SPELL_AURA_APPLIED,Player-5233-029401E9,\"Derpymcderp-Skullflame-EU\",0x514,0x0,Player-5233-029401E9,\"Derpymcderp-Skullflame-EU\",0x514,0x0,13750,\"Adrenaline Rush\",0x1,BUFF"
    }
    QA:InjectLog(log)
end

function QA:DemoUI()
    QA:TestBars()
    QA:TestCooldowns()
    QA:TestIconWarnings()
    QA:TestIconAlerts()
    QA:TestReminders()
    QA:TestCrucial()
    QA:TestSpellQueue()
end

function QA:DemoUI2()
    QuickAuras_Parry:Show()
    QuickAuras_Combo:Show()
    QuickAuras_OutOfRange:Show()
    C_Timer.After(3, function()
        QuickAuras_Parry:Hide()
        QuickAuras_Combo:Hide()
        QuickAuras_OutOfRange:Hide()
    end)
end
