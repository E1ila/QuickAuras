local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug
local pbId = 0
local _uiLocked = true
local _c
local ICON = QA.ICON

-- General -----------------------------------------------------------

function QA:InitUI()
    debug("Initializing UI")
    _c = self.colors
    self:ParentFramesNormalState()
    self:InitWeaponEnchants()
    --self:InitCrucialBuffMissing()
    self:InitRangeIndication()
    QuickAuras_Parry_Texture:SetVertexColor(1, 0, 0)
    QuickAuras_Combo_Texture:SetVertexColor(0, 0.9, 0.2)
    self:Rogue_SetCombo(0)
    --self:CheckWeaponEnchant()
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
    frame:SetSize(self.db.profile.weaponEnchantSize, self.db.profile.weaponEnchantSize)
end

function QA:InitRangeIndication(frame)
    QuickAuras_RangeIndicator.icon = QuickAuras_RangeIndicator:CreateTexture(nil, "BACKGROUND")
    QuickAuras_RangeIndicator.icon:SetAllPoints(QuickAuras_RangeIndicator)
    QuickAuras_RangeIndicator:Hide()
    self:UpdateRangeIndication()
end

function QA:UpdateRangeIndication()
    QuickAuras_RangeIndicator:SetSize(self.db.profile.rangeIconSize, self.db.profile.rangeIconSize)
    if self.db.profile.rangeSpellId then
        local texture = GetSpellTexture(self.db.profile.rangeSpellId)
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

function QA:SetDarkBackdrop(frame)
    frame:SetBackdrop ({bgFile = [[Interface\AddOns\QuickAuras\assets\background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor (0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function QA:DisableDarkBackdrop(frame)
    frame:SetBackdrop (nil)
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
        counterText:SetFont("Fonts\\FRIZQT__.TTF", math.floor(self.db.profile.reminderIconSize/2), "OUTLINE")
        counterText:SetTextColor(1, 1, 1, 1)
        counterText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2) -- Position the counter
        counterText:SetText("0") -- Default value
        frame.counterText = counterText -- Store the counter for later updates
    end

    if showTooltip then
        -- Add a tooltip to show the item's name
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(itemId)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if onRightClick or onClick then
        frame:SetScript("OnMouseDown", function(self, button)
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
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    if onRightClick or onClick then
        frame:SetScript("OnMouseDown", function(self, button)
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
    end
    return list, parent, Create, Refresh, glowInCombat
end

function QA:AddIcon(iconType, idType, id, conf, count, showTooltip, onClick)
    local key = iconType.."-"..idType.."-"..tostring(id)
    if QA.ignoredIcons[key] then return nil end
    local list, parent, Create, Refresh, glowInCombat = GetIconList(iconType, idType)
    if not list[id] then
        debug(2, "AddIcon", id, "parent", parent:GetName(), "count", count)
        local showCount = iconType == ICON.REMINDER and (conf.minCount or self.db.profile.lowConsumesMinCount)
        local onRightClick = iconType ~= ICON.ALERT and Refresh and function()
            QA.ignoredIcons[key] = true
            Refresh(QA)
        end or nil
        if showTooltip == nil then showTooltip = conf.tooltip == nil or conf.tooltip end
        local frame = Create(self, id, parent, iconType .."-".. id, showTooltip, showCount, onRightClick, onClick)
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
            self:RemoveTimer(obj, "removeicon")
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
        self:RemoveIcon(iconType, id)
    end
end

function QA:ArrangeIcons(iconType)
    --debug("Arranging icon warnings")
    local list = GetIconList(iconType)
    local lastFrame = nil
    for _, obj in pairs(list) do
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
            frame:SetSize(self.db.profile.gearWarningSize, self.db.profile.gearWarningSize) -- Width, Height
        elseif iconType == ICON.MISSING then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(self.db.profile.missingBuffsSize, self.db.profile.missingBuffsSize) -- Width, Height
        elseif iconType == ICON.REMINDER then
            if lastFrame then
                frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", 0, 0)
            else
                frame:SetPoint("TOPRIGHT", frame:GetParent(), "TOPRIGHT", 0, 0)
            end
            frame:SetSize(self.db.profile.reminderIconSize, self.db.profile.reminderIconSize) -- Width, Height
        elseif iconType == ICON.ALERT then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 2, 0) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(self.db.profile.iconAlertSize, self.db.profile.iconAlertSize) -- Width, Height
        elseif iconType == ICON.CRUCIAL then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(self.db.profile.crucialIconSize, self.db.profile.crucialIconSize) -- Width, Height
        elseif iconType == ICON.RANGE then
            if lastFrame then
                frame:SetPoint("TOP", lastFrame, "BOTTOM", 2, 0) -- vertical layout
            else
                frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, 0)
            end
            frame:SetPoint("CENTER", frame:GetParent(), "CENTER", 0, 0)
            frame:SetSize(self.db.profile.rangeIconSize, self.db.profile.rangeIconSize) -- Width, Height
        end
        if obj.glowInCombat then
            if self.inCombat and not obj.frame.glow then
                ActionButton_ShowOverlayGlow(obj.frame)
                obj.frame.glow = true
            elseif not self.inCombat and obj.frame.glow then
                ActionButton_HideOverlayGlow(obj.frame)
                obj.frame.glow = false
            end
        end
        lastFrame = frame
    end
end


-- Widget Positioning -----------------------------------------------------------

function QA:ParentFramesNormalState()
    for _, frame in ipairs(self.adjustableFrames) do
        self:DisableDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Hide()
        frame:EnableMouse(false)
    end
end

function QA:ParentFramesEditState()
    for _, frame in ipairs(self.adjustableFrames) do
        self:SetDarkBackdrop(frame)
        _G[frame:GetName().."_Text"]:Show()
        frame:EnableMouse(true)
    end
end

function QA:ToggleLockedState()
    _uiLocked = not _uiLocked

    if  _uiLocked then
        self:ParentFramesNormalState()
    else
        self:ParentFramesEditState()
    end

    --for name, obj in ipairs(self.adjustableFrames) do
    --    if obj.visible == nil or obj.visible then
    --        local f = _G[name]
    --        if f then
    --            f:EnableMouse(not _uiLocked)
    --            if _uiLocked then f:Hide() else f:Show() end
    --        end
    --    end
    --end
    out("Frames are now "..(_uiLocked and _c.disabled.."locked|r" or _c.enabled.."unlocked|r"))
end

function QA:ResetWidgets()
    debug("Resetting widgets")
    self:ResetGeneralWidgets()
    self:ResetRogueWidgets()
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
                timer.frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -self.db.profile.barGap+4)
            else
                timer.frame:SetPoint("TOP", parent, "TOP", 0, 0)
            end
            local height = timer.height or self.db.profile.barHeight or 25
            local padding = 2
            timer.frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
            timer.frame:SetSize(self.db.profile.barWidth * (timer.widthMul or 1), height)
            timer.frame.iconFrame:SetSize(height-padding*2, height-padding*2)
            timer.frame.iconFrame.icon:SetSize(height-padding*2, height-padding*2)
        elseif timer.uiType == "button" then
            if lastFrame then
                timer.frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", -self.db.profile.barGap+4, 0)
            else
                timer.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            end
            local height = timer.height or self.db.profile.buttonHeight or 50
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
    if self.db.profile.outOfRangeSound then
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



-- Test UI -----------------------------------------------------------

function QA:TestProgressBar(spells, limit, includeRaidBars)
    local count1 = 0
    local count2 = 0
    local seen = {}
    for key, conf in pairs(spells) do
        if (conf.list == "watch" or conf.list == "offensive") and not seen[conf.name] then
            if count1 < limit then
                debug("TestProgressBar", "conf", conf.name, conf.list, limit)
                seen[conf.name] = true
                local duration = 15 - (count1*2)
                local expTime = GetTime() + duration
                self:AddTimer("test", conf, key, duration, expTime)
                count1 = count1 + 1
            end
        elseif conf.raidBars and includeRaidBars then
            if count2 < limit then
                debug("TestProgressBar", "conf", conf.name, conf.list, limit)
                -- we'll inject raidbars separately
                local duration = math.min(conf.duration, 10)
                --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
                self:AddTimer("raidbar", conf, conf.spellId[1], duration, GetTime()+duration, nil, "Text", tostring(count2))
                count2 = count2 + 1
            end
        end
    end
end

function QA:TestBars()
    self:TestProgressBar(self.trackedAuras, 5)
    self:TestProgressBar(self.trackedCombatLog, 3, true)
end

function QA:TestFlashBar()
    local snd = self.trackedAuras[6774]
    self:AddTimer("test", snd, "test", 5, GetTime()+5)
end

function QA:TestCooldowns()
    local t = 0
    for i, conf in pairs(self.trackedSpellCooldowns) do
        --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
        if conf.spellId then
            self:AddTimer("test-cooldowns", conf, conf.spellId[1], 15-t, GetTime()+15-t)
            t = t + 1
        end
    end
end

local DelayedReset_Reminders = QA:Debounce(function()
    debug("TestReminders timer ended")
    QA:RefreshReminders()
end, 3)

function QA:TestReminders()
    self:ClearIcons(ICON.REMINDER)
    --self:AddIcon(ICON.REMINDER, "spell", 2383, self.trackedAuras[2383])
    for i, conf in ipairs(self.trackedLowConsumes) do
        self:AddIcon(ICON.REMINDER, "item", conf.itemId, conf, i)
        if i == 3 then break end
    end
    self:ArrangeIcons(ICON.REMINDER)
    DelayedReset_Reminders()
end

local DelayedReset_IconMissingBuffs = QA:Debounce(function()
    debug("TestIconMissingBuffs timer ended")
    QA:RefreshMissing()
end, 3)

function QA:TestIconMissingBuffs()
    self:ClearIcons(ICON.MISSING)
    local count = 0
    for _, conf in ipairs(self.trackedMissingBuffs) do
        count = count + 1
        self:AddIcon(ICON.MISSING, "item", conf.itemId, conf)
    end
    self:ArrangeIcons(ICON.MISSING)
    DelayedReset_IconMissingBuffs()
end

local DelayedReset_IconWarnings = QA:Debounce(function()
    debug("TestIconWarnings timer ended")
    QA:RefreshWarnings()
end, 3)

function QA:TestIconWarnings()
    self:ClearIcons(ICON.WARNING)
    local count = 0
    for itemId, conf in pairs(self.trackedGear) do
        count = count + 1
        self:AddIcon(ICON.WARNING, "item", itemId, conf)
        if count == 3 then break end
    end
    self:ArrangeIcons(ICON.WARNING)
    DelayedReset_IconWarnings()
end

local DelayedReset_IconAlerts = QA:Debounce(function()
    debug("TestIconAlerts timer ended")
    QA:ClearIcons(ICON.ALERT)
end, 6)

function QA:TestIconAlerts()
    local lip = self.spells.iconAlerts.limitedInvulnerabilityPotion
    --   AddTimer(timerType, conf, id, duration, expTime, showAtTime, text, keyExtra)
    self:AddTimer("auras", lip, lip.spellId[1], 6, GetTime()+6)
    DelayedReset_IconAlerts()
end

local DelayedReset_CrucialAlerts = QA:Debounce(function()
    QA:ClearIcons(ICON.CRUCIAL)
end, 3)

function QA:TestCrucial()
    local bs = self.spells.warrior.battleShout
    local frr = self.spells.shaman.frostResistanceTotem
    --  :AddIcon(iconType, idType, id, conf, count, showTooltip, onClick)
    self:AddIcon(ICON.CRUCIAL, "spell", bs.spellId[1], bs)
    self:AddIcon(ICON.CRUCIAL, "spell", frr.spellId[1], frr)
    self:ArrangeIcons(ICON.CRUCIAL)
    DelayedReset_CrucialAlerts()
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
            self:HandleCombatLogEvent("", subevent, "", sourceGuid, sourceName, "", "", destGuid, destName, "", "", p1, p2, p3, p4, p5, p6)
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
    self:InjectLog(log)
end

function QA:DemoUI()
    self:TestBars()
    self:TestCooldowns()
    self:TestIconWarnings()
    self:TestIconAlerts()
    self:TestReminders()
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
