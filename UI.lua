local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug
local pbId = 0
local _c
local WINDOW = QA.WINDOW

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
    QA:InitWindowAttr()
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
    QuickAuras_XP_Text:Hide()
    QuickAuras_XP_Left_Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    QuickAuras_XP_Right_Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    QuickAuras_XP_Bottom_Text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    QuickAuras_XP_Bar_Rested:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar_Rested:SetStatusBarColor(0.304, 0.402, 0.771, 0.6)
    QuickAuras_XP_Bar_Completed:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar_Completed:SetStatusBarColor(0.784, 0.467, 0)
    QuickAuras_XP_Bar_Current:SetStatusBarTexture(cleanTexture)
    QuickAuras_XP_Bar_Current:SetStatusBarColor(0.337, 0.388, 1.0)
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

        QuickAuras_XP_Bar_Current:SetValue(p_current)
        QuickAuras_XP_Bar_Completed:SetValue(p_current+p_completed)
        QuickAuras_XP_Bar_Rested:SetValue(p_current+p_completed+p_rested)

        QuickAuras_XP_Left_Text:SetText(FormatNumberWithCommas(currentXP).." / "..FormatNumberWithCommas(maxXP))
        QuickAuras_XP_Right_Text:SetText(s_current)
        QuickAuras_XP_Bottom_Text:SetText("Completed: |cffff9700"..s_completed.."|r - Rested: |cff4f90ff"..s_rested.."|r")
    end
end

-- frame creation -----------------------------------

QA.ignoredIcons = {}

function QA:CreateItemIcon(itemId, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick)
    local itemIcon = GetItemIcon(itemId)
    if not itemIcon then
        print("Invalid itemId:", itemId)
        return nil
    end
    return QA:CreateIconFrame(itemIcon, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick, itemId)
end

function QA:CreateSpellIcon(spellId, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick)
    local spellIcon = GetSpellTexture(spellId)
    if not spellIcon then
        print("Invalid spellId:", spellId)
        return nil
    end
    return QA:CreateIconFrame(spellIcon, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick, nil, spellId)
end

function QA:CreateIconFrame(texture, parentFrame, frameName, showTooltip, showCount, onRightClick, onClick, itemId, spellId)
    local frame = QA:CreateTextureIcon(texture, parentFrame, frameName)
    --debug(3, "CreateIconFrame", frameName, "texture", texture, "showCount", showCount, "itemId", itemId, "spellId", spellId)

    if showCount then
        local counterText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        counterText:SetTextColor(1, 1, 1, 1)
        counterText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2) -- Position the counter
        counterText:SetText("0") -- Default value
        frame.counterText = counterText -- Store the counter for later updates
    end

    if showTooltip and (itemId or spellId) then
        -- Add a tooltip to show the item's name
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if itemId then
                GameTooltip:SetItemByID(itemId)
            elseif spellId then
                GameTooltip:SetSpellByID(spellId)
            end
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if onRightClick or onClick then
        if type(onClick) == "number" then
            frame:RegisterForClicks("AnyUp")
            local spellName = GetSpellInfo(onClick)
            frame:SetAttribute("type", "spell")
            frame:SetAttribute("spell", spellName)
        else
            frame:SetScript("OnMouseDown", function(self, button)
                if onRightClick and button == "RightButton" then
                    onRightClick()
                elseif onClick and button == "LeftButton" then
                    onClick()
                end
            end)
        end
    end

    return frame
end

function QA:CreateTextureIcon(texture, parentFrame, frameName)
    -- Create a button frame
    local frame = CreateFrame("Button", frameName, parentFrame, "SecureActionButtonTemplate")

    local iconTexture = frame:CreateTexture(nil, "BACKGROUND")
    iconTexture:SetTexture(texture)
    iconTexture:SetAllPoints(frame)
    frame.icon = iconTexture

    return frame
end


-- Icon warnings ------------------------------------

function QA:InitWindowAttr()
    QA.windowAttributes = {
        [WINDOW.SWING] = {
            widthMul = 1,
            parent = UIParent,
            height = 10,
            list = QA.list_swingTimers,
            bar = true,
        },
        [WINDOW.RAIDBARS] = {
            widthMul = 1,
            parent = QuickAuras_RaidBars,
            height = QA.db.profile.raidBarHeight,
            list = QA.list_raidBars,
            bar = true,
            align = "vbars",
        },
        [WINDOW.COOLDOWNS] = {
            widthMul = 1,
            parent = QuickAuras_Cooldowns,
            height = QA.db.profile.cooldownIconSize,
            list = QA.list_cooldowns,
            align = "right",
        },
        [WINDOW.WARNING] = {
            widthMul = 1,
            parent = QuickAuras_IconWarnings,
            height = QA.db.profile.gearWarningSize,
            list = QA.list_iconWarnings,
            Refresh = QA.RefreshWarnings,
            align = "left",
        },
        [WINDOW.MISSING] = {
            widthMul = 1,
            parent = QuickAuras_MissingBuffs,
            height = QA.db.profile.missingBuffsSize,
            list = QA.list_missingBuffs,
            Refresh = QA.RefreshMissing,
            glowInCombat = true,
            align = "right",
        },
        [WINDOW.ALERT] = {
            widthMul = 1,
            parent = QuickAuras_IconAlerts,
            height = QA.db.profile.iconAlertSize,
            list = QA.list_iconAlerts,
            Refresh = QA.RefreshAlerts,
            align = "down",
        },
        [WINDOW.REMINDER] = {
            widthMul = 1,
            parent = QuickAuras_Reminders,
            height = QA.db.profile.reminderIconSize,
            list = QA.list_reminders,
            Refresh = QA.RefreshReminders,
            align = "left",
        },
        [WINDOW.CRUCIAL] = {
            widthMul = 1,
            parent = QuickAuras_Crucial,
            height = QA.db.profile.crucialIconSize,
            list = QA.list_crucial,
            glowInCombat = true,
            align = "down",
        },
        [WINDOW.RANGE] = {
            widthMul = 1,
            parent = QuickAuras_RangeIndicator,
            height = QA.db.profile.rangeIconSize,
            list = QA.list_range,
            align = "hcenter",
        },
        [WINDOW.QUEUE] = {
            widthMul = 1,
            parent = QuickAuras_SpellQueue,
            height = QA.db.profile.spellQueueIconSize,
            list = QA.list_queue,
            align = "hcenter",
        },
        [WINDOW.OFFENSIVE] = {
            widthMul = 1.5,
            parent = QuickAuras_OffensiveBars,
            height = QA.db.profile.raidBarHeight,
            list = QA.list_offensiveBars,
            bar = true,
            align = "vbars",
        },
        [WINDOW.WATCH] = {
            widthMul = 1,
            parent = QuickAuras_WatchBars,
            height = QA.db.profile.raidBarHeight,
            list = QA.list_watchBars,
            bar = true,
            align = "vbars",
        },
    }
end

function QA:GetWindowAttr(window, idType)
    local attr = QA.windowAttributes[window]
    if idType then
        attr.Create = idType == "item" and QA.CreateItemIcon or QA.CreateSpellIcon
    end
    return attr
end

function QA:AddIcon(window, idType, id, conf, count, showTooltip, onClick)
    local key = window .."-"..idType.."-"..tostring(id)
    if QA.ignoredIcons[key] then return nil end
    local attr = QA:GetWindowAttr(window, idType)
    local button = attr.list[id]
    if not button then
        local showCount = window == WINDOW.REMINDER and (conf.minCount or QA.db.profile.lowConsumesMinCount) and count ~= nil or type(count) == "number" and count >= 0
        debug(2, _c.bold.."AddIcon|r", conf.name, id, "parent", attr.parent:GetName(), "count", count, "showCount", showCount)
        local onRightClick = window ~= WINDOW.ALERT and attr.Refresh and function()
            QA.ignoredIcons[key] = true
            attr.Refresh(QA)
        end or nil
        if showTooltip == nil then showTooltip = conf.tooltip == nil or conf.tooltip end
        local frame = attr.Create(QA, id, attr.parent, window .."-".. id, showTooltip, showCount, onRightClick, onClick)
        button = {
            name = conf.name,
            conf = conf,
            id = id,
            idType = idType,
            frame = frame,
            list = attr.list,
            parent = attr.parent,
            count = count,
            glowInCombat = attr.glowInCombat
        }
        attr.list[id] = button
        QA.arrangeQueue[window] = true
        return button
    elseif count ~= nil then
        debug(2, _c.bold.."AddIcon|r", id, "updating count", count)
        button.count = count
        QA.arrangeQueue[window] = true
        return button
    end
end

function QA:RemoveIcon(iconType, id)
    local attr = QA:GetWindowAttr(iconType)
    local obj = attr.list[id]
    if obj then
        if obj.isTimer then
            QA:RemoveTimer(obj, "removeicon")
        else
            local frame = obj.frame
            frame:Hide()
            frame:SetParent(nil)
            frame:ClearAllPoints()
            attr.list[id] = nil
        end
        return true
    end
end

function QA:ClearIcons(iconType)
    --debug("Clearing icon warnings")
    local attr = QA:GetWindowAttr(iconType)
    for id, obj in pairs(attr.list) do
        QA:RemoveIcon(iconType, id)
    end
end

function QA:ArrangeIcons(window)
    local attr = QA:GetWindowAttr(window)

    local sortedList = {}
    if not attr.list then
        debug(_c.alert, "ArrangeIcons", "No list for window", window)
        return
    end
    for key, timer in pairs(attr.list) do
        if key ~= "size" then
            table.insert(sortedList, timer)
        end
    end
    table.sort(sortedList, function(a, b)
        return (a.expTime or 0) > (b.expTime or 0)
    end)

    local lastFrame
    local count = 0
    for _, obj in pairs(sortedList) do
        count = count + 1
        local frame = obj.frame
        frame:ClearAllPoints()
        --debug(3, _c.purple.."ArrangeIcons|r", window, obj.id, parent, frame:GetParent():GetName(), "counterText", frame.counterText, "obj.count", obj.count)
        if frame.counterText and obj.count and type(obj.count) == "number" then
            frame.counterText:SetText(obj.count)
        end
        if attr.align == "vbars" then
            -- progress bar, down
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -QA.db.profile.barGap+4)
            else
                frame:SetPoint("TOP", attr.parent, "TOP", 0, 0)
            end
            --if window == WINDOW.RAIDBARS and height * QA.list_raidBars
            local padding = 2
            frame:SetPoint("CENTER", attr.parent, "CENTER", 0, 0)
            frame:SetSize(QA.db.profile.barWidth * (obj.widthMul or 1), attr.height)
            frame.iconFrame:SetSize(attr.height-padding*2, attr.height-padding*2)
            frame.iconFrame.icon:SetSize(attr.height-padding*2, attr.height-padding*2)
        else
            frame:SetSize(attr.height, attr.height)
            if attr.align == "right" then
                -- right
                if lastFrame then
                    frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", 2, 0)
                else
                    frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
                end
                frame:GetParent():SetSize((attr.height + 2) * count, attr.height)
            elseif attr.align == "left" then
                -- left
                if lastFrame then
                    frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", -2, 0)
                else
                    frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
                end
                frame:GetParent():SetSize((attr.height + 2) * count, attr.height)
            elseif attr.align == "down" then
                -- down
                if lastFrame then
                    frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, 0) -- vertical layout
                else
                    frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
                end
                frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
                frame:GetParent():SetSize(attr.height, attr.height * count)
            elseif attr.align == "hcenter" then
                if lastFrame then
                    frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
                else
                    frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
                end
                frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
                frame:GetParent():SetSize(attr.height * count, attr.height)
            end
        end
        if frame.counterText then
            frame.counterText:SetFont("Fonts\\FRIZQT__.TTF", math.floor(attr.height/2), "OUTLINE")
        end
        if frame.cooldownText then
            frame.cooldownText:SetFont("Fonts\\FRIZQT__.TTF", math.floor(attr.height/2), "OUTLINE") -- Set font, size, and style
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

function QA:ArrangeWindows()
    for window, _ in pairs(QA.arrangeQueue) do
        QA:ArrangeIcons(window)
    end
    QA.arrangeQueue = {}
end


-- Widget Positioning -----------------------------------------------------------

function QA:ParentFramesNormalState()
    QuickAuras_XP:EnableMouse(false)
    QuickAuras_SwingTimer:EnableMouse(false)
    QuickAuras_SwingTimer_Text:Hide()
    QuickAuras_SwingTimer:Hide()
    for _, frame in ipairs(QA.adjustableFrames) do
        QA:DisableDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Hide()
        frame:EnableMouse(false)
    end
    QA:RefreshAll()
end

function QA:ParentFramesEditState()
    QuickAuras_XP:EnableMouse(true)
    QuickAuras_SwingTimer:Show()
    QuickAuras_SwingTimer:EnableMouse(true)
    QuickAuras_SwingTimer_Text:Show()
    for window, _ in pairs(QA.windowAttributes) do
        QA:ClearIcons(window)
    end
    for _, frame in ipairs(QA.adjustableFrames) do
        QA:SetDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Show()
        frame:EnableMouse(true)
    end
end

function QA:ToggleLockedState()
    QA.uiLocked = not QA.uiLocked
    out("Frames are now "..(QA.uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))

    if QA.uiLocked then
        QA:ParentFramesNormalState()
    else
        QA:ParentFramesEditState()
        out("")
        out("  |cFF00FFaa Uptime Bars|r - Time on special buffs or things you need to keep up |cffaaaaaa(AR, BF, etc)")
        out("  |cFF00FFaa Offensive Bars|r - Time on enemy related debuffs |cffaaaaaa(CC, curses, etc.)")
        out("  |cFF00FFaa Alerts|r - Short buffs/debuffs you must be aware of |cffaaaaaa(LIP, Innervate, Itch, etc.)")
        out("  |cFF00FFaa Queue|r - Warrior queue |cffaaaaaa(HS, Cleave)|r, or combat related alerts |cffaaaaaa(Tea, missing SnD, etc.)")
        out("  |cFF00FFaa Crucial|r - Important missing buffs |cffaaaaaa(Battle Shout, Resistance Totem, etc.)")
        out("  |cFF00FFaa Warnings|r - Things to be aware of |cffaaaaaa(Onyxia Cloak on, Rocket Helmet on, etc.)")
        out("  |cFF00FFaa Missing Buffs|r - Missing consumes on raids")
        out("  |cFF00FFaa Reminders|r - Consumes you're low of, when located at a capital city.")
        out("  |cFF00FFaa Swing|r - Swing timer for melee classes, MH and OH")
        out("  |cFF00FFaa Raid Bars|r - Time on important raid player buffs |cffaaaaaa(Taunt, LIP, Death Wish, etc.)")
        out("  |cFF00FFaa Cooldowns|r - Time on cooldowns")
    end
end

function QA:ResetWidgets()
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


-- Swing -------------------------------------------------------------

local _swing = {
    mh = {
        unqueue = { 1.000, 0.000, 0.302, 1 },
        queue = { 1.000, 1.000, 0.302, 1 },
        unqueueTime = 0.3,
    },
    oh = {0.2, 0.2, 1, 1},
    ranged = {0.2, 1, 0.2, 1},
}

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
    QuickAuras_SwingTimer_TimeText:SetText("")
    QuickAuras_SwingTimer_TimeText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

    local texture = QuickAuras_SwingTimer_MH:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(QuickAuras_SwingTimer_MH)
    texture:SetColorTexture(unpack(_swing.mh.unqueue)) -- ff004d
    QuickAuras_SwingTimer_MH.texture = texture
    QuickAuras_SwingTimer_MH:Hide()

    texture = QuickAuras_SwingTimer_Ranged:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(QuickAuras_SwingTimer_Ranged)
    texture:SetColorTexture(unpack(_swing.ranged))
    QuickAuras_SwingTimer_Ranged.texture = texture
    QuickAuras_SwingTimer_Ranged:Hide()

    texture = QuickAuras_SwingTimer_OH:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(QuickAuras_SwingTimer_OH)
    texture:SetColorTexture(unpack(_swing.oh))
    QuickAuras_SwingTimer_OH.texture = texture
    QuickAuras_SwingTimer_OH:Hide()

    QuickAuras_SwingTimer:Hide()
end

function QA:SetSwingProgress(hand, progress, timeLeft)
    local isMain = hand == "main"
    local frame = isMain and QuickAuras_SwingTimer_MH or (hand == "oh" and QuickAuras_SwingTimer_OH or QuickAuras_SwingTimer_Ranged)
    if progress == 0 then
        if isMain then QuickAuras_SwingTimer_TimeText:SetText("") end
        frame:Hide()
    else
        local width = QuickAuras_SwingTimer:GetWidth()-frame:GetWidth()
        local offset = width * progress
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", frame:GetParent(), "LEFT", offset, 0)
        frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, -2)
        frame:SetPoint("BOTTOM", frame:GetParent(), "BOTTOM", 0, 2)
        frame:Show()
        if isMain then
            QuickAuras_SwingTimer_TimeText:SetText(string.format("%.1f", timeLeft or 0))
        end
    end
end

local function CreateSwingConf(hand)
    return {
        name = "swing-"..hand,
        hand = hand,
        onUpdate = function(timer)
            if timer.expTime and timer.expTime < 4294967 then
                local timeLeft = timer.expTime - GetTime()
                if timeLeft > 0 then
                    local progress = timeLeft / timer.duration
                    QA:SetSwingProgress(hand, progress, timeLeft)
                else
                    QA:SetSwingProgress(hand, 0, 0)
                end
                --debug("update", hand, "timeLeft", timeLeft, "progress", progress, "timer.expTime", timer.expTime)
            else
                QA:SetSwingProgress(hand, 0, 0)
            end
            --return timeLeft > 0
            return true
        end,
        onEnd = function(timer)
            QA:SetSwingProgress(hand, 0, 0)
        end,
    }
end
local swingConf = {
    main = CreateSwingConf("main"),
    off = CreateSwingConf("off"),
    ranged = CreateSwingConf("ranged"),
}

QA.HideSwingTimers = QA:Debounce(function()
    local found = false
    if not QuickAuras_SwingTimer_MH:IsShown() and not QuickAuras_SwingTimer_OH:IsShown() and not QuickAuras_SwingTimer_Ranged:IsShown() then
        QuickAuras_SwingTimer:Hide()
    else
        -- check again in 1 sec
        QA.HideSwingTimers()
    end
end, 1)

function QA:UpdateSwingTimers(hand, source)
    if not QA.db.profile.swingTimersEnabled then return end
    local mh = (hand == nil or hand == "main") and QA:UpdateSwingTimer("main", source)
    local oh = false
    if QA.db.profile.swingTimerOH and (hand == nil or hand == "off") then
        oh = QA:UpdateSwingTimer("off", source)
    end
    local ranged = false
    if QA.db.profile.swingTimerRanged and (hand == nil or hand == "ranged") then
        ranged = QA:UpdateSwingTimer("ranged", source)
    end
    if mh or oh or ranged then
        QuickAuras_SwingTimer:Show()
    end
    QA.HideSwingTimers()
end

function QA:UpdateSwingTimer(hand, source)
    local duration, expTime, weaponName, icon = QA.GetSwingTimerInfo(hand)
    --local duration, expTime = 2.7, GetTime() + 2.7
    local id = "swing-"..hand
    local conf = swingConf[hand]
    debug(QA.db.profile.swingDebug or 3, "UpdateSwingTimer", _c.bold..hand.."|r", _c.yellow..tostring(source).."|r", math.floor(duration*100)/100, math.floor(expTime))
    if not duration or duration == 0 or not expTime then
        --QA:RemoveTimer(id)
    else
        QA:AddTimer(WINDOW.SWING, conf, id, duration, expTime)
    end
    return true
end



-- Test UI -----------------------------------------------------------

function QA:TestProgressBar(spells, limit, onlyRaidBars)
    local count1 = 0
    local count2 = 0
    local seen = {}
    for key, conf in pairs(spells) do
        if not onlyRaidBars and (conf.list == "watch" or conf.list == "offensive") and not seen[conf.name] then
            if count1 < limit then
                --debug(3, "TestProgressBar", "conf", conf.name, conf.list, limit)
                seen[conf.name] = true
                local duration = 15 - (count1*2)
                local expTime = GetTime() + duration
                QA:AddTimer(conf.list, conf, key, duration, expTime)
                count1 = count1 + 1
            end
        elseif conf.raidBars and onlyRaidBars then
            if count2 < limit then
                --debug(3, "TestProgressBar", "conf", conf.name, conf.list, limit)
                -- we'll inject raidbars separately
                local duration = math.min(QA:GetDuration(conf), 10)
                --   AddTimer(window, conf, id, duration, expTime, showAtTime, text, keyExtra)
                QA:AddTimer(WINDOW.RAIDBARS, conf, conf.spellId[1], duration, GetTime()+duration, nil, "Text", tostring(count2))
                count2 = count2 + 1
            end
        end
    end
end

function QA:TestBars()
    QA:TestProgressBar(QA.trackedAuras, 5)
    QA:TestProgressBar(QA.trackedCombatLog, 3)
    QA:TestProgressBar(QA.trackedCombatLog, 5, true)
end

function QA:TestFlashBar()
    local snd = QA.trackedAuras[6774]
    QA:AddTimer(snd.list, snd, "test", 5, GetTime()+5)
end

function QA:TestCooldowns()
    local t = 0
    for i, conf in pairs(QA.trackedSpellCooldowns) do
        --   AddTimer(window, conf, id, duration, expTime, showAtTime, text, keyExtra)
        if conf.spellId then
            QA:AddTimer(WINDOW.COOLDOWNS, conf, conf.spellId[1], 15-t, GetTime()+15-t)
            t = t + 1
        end
    end
end

local DelayedReset_Reminders = QA:Debounce(function()
    --debug("TestReminders timer ended")
    QA:RefreshReminders()
end, 3)

function QA:TestReminders()
    QA:ClearIcons(WINDOW.REMINDER)
    --QA:AddIcon(WINDOW.REMINDER, "spell", 2383, QA.trackedAuras[2383])
    for i, conf in ipairs(QA.trackedLowConsumes) do
        QA:AddIcon(WINDOW.REMINDER, "item", conf.itemId, conf, i)
        if i == 3 then break end
    end
    DelayedReset_Reminders()
end

local DelayedReset_IconMissingBuffs = QA:Debounce(function()
    --debug("TestIconMissingBuffs timer ended")
    QA:RefreshMissing()
end, 3)

function QA:TestIconMissingBuffs()
    QA:ClearIcons(WINDOW.MISSING)
    local count = 0
    for _, conf in ipairs(QA.trackedMissingBuffs) do
        count = count + 1
        QA:AddIcon(WINDOW.MISSING, "item", conf.itemId, conf)
    end
    DelayedReset_IconMissingBuffs()
end

local DelayedReset_IconWarnings = QA:Debounce(function()
    --debug("TestIconWarnings timer ended")
    QA:RefreshWarnings()
end, 3)

function QA:TestIconWarnings()
    QA:ClearIcons(WINDOW.WARNING)
    local count = 0
    for itemId, conf in pairs(QA.trackedGear) do
        count = count + 1
        QA:AddIcon(WINDOW.WARNING, "item", itemId, conf)
        if count == 3 then break end
    end
    DelayedReset_IconWarnings()
end

local DelayedReset_IconAlerts = QA:Debounce(function()
    --debug("TestIconAlerts timer ended")
    QA:ClearIcons(WINDOW.ALERT)
end, 6)

function QA:TestIconAlerts()
    local lip = QA.spells.iconAlerts.limitedInvulnerabilityPotion
    --   AddTimer(window, conf, id, duration, expTime, showAtTime, text, keyExtra)
    QA:AddTimer(WINDOW.ALERT, lip, lip.spellId[1], 6, GetTime()+6)
    DelayedReset_IconAlerts()
end

local DelayedReset_CrucialAlerts = QA:Debounce(function()
    QA:ClearIcons(WINDOW.CRUCIAL)
end, 3)

function QA:TestCrucial()
    local bs = QA.spells.warrior.battleShout
    local frr = QA.spells.shaman.frostResistanceTotem
    --  :AddIcon(iconType, idType, id, conf, count, showTooltip, onClick)
    QA:AddIcon(WINDOW.CRUCIAL, "spell", bs.spellId[1], bs)
    QA:AddIcon(WINDOW.CRUCIAL, "spell", frr.spellId[1], frr)
    DelayedReset_CrucialAlerts()
end

local DelayedReset_SpellQueue = QA:Debounce(function()
    QA:ClearIcons(WINDOW.QUEUE)
end, 3)

function QA:TestSpellQueue()
    local hs = QA.spells.warrior.heroicStrike
    local cleave = QA.spells.warrior.cleave
    QA:AddIcon(WINDOW.QUEUE, "spell", hs.spellId[1], hs)
    QA:AddIcon(WINDOW.QUEUE, "spell", cleave.spellId[1], cleave)
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
