local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug
local out = QuickAuras.Print
local _useTeaShown = false
local USE_TEA_ENERGY_THRESHOLD = 6
local ICON = QuickAuras.ICON
local _c = QuickAuras.colors
QuickAuras.targetInRange = false

function QuickAuras:CheckIfWarriorInParty()
    self.hasWarriorInParty = false
    for i = 1, GetNumGroupMembers() do
        local unitId = "party"..i
        debug(2, "CheckIfWarriorInParty", unitId, UnitClass(unitId))
        if UnitClass(unitId) == "Warrior" then
            self.hasWarriorInParty = true
            debug("Found a warrior" , unitId, UnitName(unitId))
            break
        end
    end
end

function QuickAuras:CheckTargetRange()
    if not self.db.profile.targetInRangeIndication or not self.db.profile.rangeSpellId then return end
    local spellName = GetSpellInfo(self.db.profile.rangeSpellId)
    local inRange = IsSpellInRange(spellName, "target") == 1
    if inRange ~= self.targetInRange then
        self.targetInRange = inRange
        debug(2, "inRange", spellName, inRange)
        if inRange then
            QuickAuras_RangeIndicator:Show()
        else
            QuickAuras_RangeIndicator:Hide()
        end
    end
end

function QuickAuras:CheckHearthstone()
    if not self.db.profile.hsNotCapitalWarning then return end
    local bindLocation = GetBindLocation()
    local changed
    if self.inCapital and not self.capitalCities[bindLocation] then
        changed = self:AddIcon(ICON.WARNING, "item", 6948, { name = "Hearthstone" })
        out("|cffff0000Warning:|r Your Hearthstone is set to ".._c.bold..bindLocation.."|r!")
    else
        changed = self:RemoveIcon(ICON.WARNING, 6948)
    end
    if changed then
        self:ArrangeIcons(ICON.WARNING)
    end
end

function QuickAuras:CheckPower(unit, powerType)
    if self.isRogue and unit == "player" then
        if powerType == "ENERGY" then
            local currentEnergy = UnitPower("player", Enum.PowerType.Energy)
            if _useTeaShown then
                if currentEnergy >= USE_TEA_ENERGY_THRESHOLD then
                    _useTeaShown = false
                    self:RemoveIcon(self.db.profile.rogueTeaTimeFrame, 7676)
                end
            else
                if  currentEnergy < USE_TEA_ENERGY_THRESHOLD and
                        (self.db.profile.rogueTeaTime == "always" or
                                self.db.profile.rogueTeaTime == "flurry" and self.playerBuffs[13877])
                then
                    _useTeaShown = true
                    self:AddIcon(self.db.profile.rogueTeaTimeFrame, "item", 7676, { name = "Thistle Tea"})
                    self:ArrangeIcons(self.db.profile.rogueTeaTimeFrame)
                end
            end
        elseif powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            self:Rogue_SetCombo(comboPoints)
        end
    end
end

-- debounce CheckTransmuteCooldown
QuickAuras.CheckTransmuteCooldownDebounce = QuickAuras:Debounce(function()
    QuickAuras:CheckTransmuteCooldown()
end, 0.25)

function QuickAuras:CheckTransmuteCooldown()
    if not self.db.profile.remindersEnabled or not self.db.profile.reminderTransmute then return end
    local changed = false
    for _, spell in pairs(self.spells.transmutes) do
        local hasIt = true
        local id = spell.spellId[1]
        if spell.spellId and not IsPlayerSpell(id) then hasIt = false end
        if spell.itemId and not (self:FindInBags(spell.itemId) or self:FindInBags(spell.itemId, true)) then hasIt = false end
        if hasIt then
            local start, duration
            if spell.itemId then
                start, duration = QuickAuras:GetItemCooldown(spell.itemId)
            else
                start, duration = GetSpellCooldown(id)
            end
            local timeLeft = math.floor((start + duration - GetTime()) / 60)
            debug(3, "CheckTransmuteCooldown", "(scan)", spell.name, "start", start, "duration", duration, "timeLeft", timeLeft)
            if start == 0 then
                if self:AddIcon(ICON.REMINDER, "spell", id, spell) then changed = true end
            elseif timeLeft <= self.db.profile.transmutePreReadyTime then
                local timer = self:AddTimer("reminder", spell, id, duration, start+duration)
                local fontSize = math.floor(self.db.profile.reminderIconSize/2)
                timer.frame.cooldownText:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE") -- Set font, size, and style
            else
                if self:RemoveIcon(ICON.REMINDER, id) then changed = true end
            end
        else
            debug(3, "CheckTransmuteCooldown", "(scan)", spell.name, "hasIt", hasIt)
        end
    end
    if changed then
        self:ArrangeIcons(ICON.REMINDER)
    end
end

function QuickAuras:CheckWeaponEnchant()
    local mh, expiration, _, enchid, _, _, _, _ = GetWeaponEnchantInfo("player")
    local mhItemId = GetInventoryItemID("player", 16)
    debug("CheckWeaponEnchant", "mh", mh, "expiration", expiration, "enchid", enchid, "mhItemId", mhItemId)
    self:SetWeaponEnchantIcon(1, mhItemId)
end

function QuickAuras:CheckLowConsumes()
    if not self.db.profile.remindersEnabled or not self.db.profile.reminderLowConsumes then return end
    if self.db.profile.lowConsumesInCapital and not self.inCapital then return end
    local changed = false
    for _, consume in pairs(self.trackedLowConsumes) do
        if not consume.option or self.db.profile[consume.option] then
            local foundItemId, details = self:FindInBags(consume.itemIds or consume.itemId)
            local minCount = consume.minCount or self.db.profile.lowConsumesMinCount
            debug(3, "CheckLowConsumes", "(scan)", consume.name, "foundItemId", foundItemId, "option", consume.option, consume.option and self.db.profile[consume.option])
            if
                (not foundItemId or details.count < minCount)
                and self.db.profile.lowConsumesMinLevel <= self.playerLevel
            then
                if self:AddIcon(ICON.REMINDER, "item", consume.itemId, consume, details and details.count or 0) then changed = true end
            else
                if self:RemoveIcon(ICON.REMINDER, consume.itemId) then changed = true end
            end
            if minCount and self.db.profile.outOfConsumeWarning then
                if foundItemId then
                    self.existingConsumes[consume.itemId] = true
                elseif self.existingConsumes[consume.itemId] then
                    -- no more item
                    self.existingConsumes[consume.itemId] = nil
                    if IsInInstance() then
                        self:AddIcon(ICON.REMINDER, "item", consume.itemId, consume, 0)
                        changed = true
                    end
                end
            end
        end
    end
    if changed then
        self:ArrangeIcons(ICON.REMINDER)
    end
end

function QuickAuras:CheckTrackingStatus()
    if not self.db.profile.remindersEnabled then return end
    local trackingType = GetTrackingTexture()
    local changed, found, missingSpellId = false, false, nil
    for spellId, conf in pairs(QuickAuras.trackedTracking) do
        debug(3, "CheckTrackingStatus", "(scan)", conf.name, "spellId", spellId, "option", conf.option, conf.option and self.db.profile[conf.option])
        if IsSpellKnown(spellId) and self.db.profile[conf.option] then
            if conf.textureId == trackingType then
                if QAG:RemoveIcon(ICON.REMINDER, spellId) then changed = true end
                found = true
                break
            else
                missingSpellId = spellId
            end
        end
    end
    debug(2, "CheckTrackingStatus", "trackingType", trackingType, "found", found, "missingSpellId", missingSpellId)
    if not found and missingSpellId then
        debug(3, "CheckTrackingStatus", "missingSpellId", missingSpellId)
        if QAG:AddIcon(ICON.REMINDER, "spell", missingSpellId, QAG.trackedTracking[missingSpellId]) then changed = true end
    end
    if changed then
        QAG:ArrangeIcons(ICON.REMINDER)
    end
end

function QuickAuras:CheckGear(eventType, ...)
    if self.db.profile.trackedGear then
        local equippedItems = {}
        local changed = false

        for slotId = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local equippedItemId = GetInventoryItemID("player", slotId)
            if equippedItemId then
                equippedItems[equippedItemId] = true
            end
        end

        for itemId, conf in pairs(QuickAuras.trackedGear) do
            if not conf.option or self.db.profile[conf.option] then
                local isEquipped = equippedItems[itemId]
                local shouldShow = isEquipped
                if conf.visibleFunc then shouldShow = conf.visibleFunc(isEquipped) end
                --debug("Checking gear", itemId, self.colors.bold, conf.name, "|r", "isEquipped", isEquipped, "shouldShow", shouldShow)
                if shouldShow then
                    if self:AddIcon(ICON.WARNING, "item", itemId, conf) then changed = true end
                else
                    if self:RemoveIcon(ICON.WARNING, itemId) then changed = true end
                end
            end
        end

        if changed then
            self:ArrangeIcons(ICON.WARNING)
        end
    end
end

local function _checkCooldown(conf, idType, id, start, duration)
    debug(4, "_checkCooldown", idType, id, conf.name, start, duration, "option", conf.option)
    if start and start > 0 and duration and duration > 2 and (not conf.option or QuickAuras.db.profile[conf.option.."_cd"]) then
        local updatedDuration = duration - (GetTime() - start)
        QuickAuras:AddTimer("cooldowns", conf, id, updatedDuration, start + duration)
    end
end

function QuickAuras:CheckCooldowns()
    if not self.db.profile.cooldowns then return end
    for spellId, conf in pairs(self.trackedSpellCooldowns) do
        local start, duration = GetSpellCooldown(spellId)
        _checkCooldown(conf, "spell", spellId, start, duration)
    end
    for itemId, conf in pairs(self.trackedItemCooldowns) do
        -- show cooldown only if item is in bags
        if conf.evenIfNotInBag or QuickAuras.bags[conf.itemId] then
            local start, duration = QuickAuras:GetItemCooldown(itemId)
            _checkCooldown(conf, "item", itemId, start, duration)
        end
    end
end

local manualExpTime = {}
local function FixAuraExpTime(duration, expTime, aura, spellId)
    if aura.manualExpTime then
        duration = aura.duration
        local _exp = manualExpTime[spellId]
        local now = GetTime()
        if _exp and _exp > now + 1 then
            expTime = manualExpTime[spellId]
        else
            expTime = now + duration
            manualExpTime[spellId] = expTime
        end
    end
    return duration, expTime
end

function QuickAuras:CheckAuras()
    local i = 1
    local seen = {}
    self.playerBuffs = seen
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellId = UnitAura("player", i)
        if not name then break end -- Exit the loop when no more auras are found
        debug(3, "CheckAuras", "(scan)", i, name, icon, duration, expTime, spellId)
        seen[spellId] = { duration, expTime }
        -- timer auras -----------------------------------------
        local aura = self.trackedAuras[spellId]
        --debug(3, "CheckAuras", "(scan)", "spellId", spellId, name, "aura", aura, "option", aura and aura.option)
        if aura and (not aura.option or self.db.profile[aura.option]) and self.db.profile.watchBars then
            duration, expTime = FixAuraExpTime(duration, expTime, aura, spellId)
            debug(2, "CheckAuras", "aura", aura.name, "duration", duration, "expTime", expTime, "option", aura.option, self.db.profile[aura.option])
            local timer = self:AddTimer("auras", aura, spellId, duration, expTime)
            if timer then
                seen[timer.key] = true
            end
        end
        i = i + 1
    end
    -- remove missing auras
    for _, timer in pairs(self.list_timers) do
        if not seen[timer.key] and timer.timerType == "auras" then
            self:RemoveTimer(timer, "unseen")
        end
    end
    self:CheckMissingBuffs(seen)
    self:CheckCrucialBuffs(seen)
    self:CheckStealthInInstance(seen)
end

function QuickAuras:CheckMissingBuffs(activeAuras)
    if not QuickAuras.db.profile.missingConsumes then return end
    local buffsChanged = false
    if  self.db.profile.forceShowMissing or
        self.db.profile.missingBuffsMode == "instance" and IsInInstance() or
        self.db.profile.missingBuffsMode == "raid" and IsInInstance() and IsInRaid()
    then
        for _, buff in ipairs(self.trackedMissingBuffs) do
            if not buff.option or self.db.profile[buff.option] then
                local foundBuff = self:HasSeenAny(buff.spellIds, activeAuras)
                local foundItemId = self:FindInBags(buff.itemIds or buff.itemId)
                debug(3, "CheckAuras", "(scan)", buff.name, "found", foundBuff, "foundItemId", foundItemId, "option", buff.option, buff.option and self.db.profile[buff.option])
                if  foundBuff
                    or buff.visibleFunc and not buff.visibleFunc()
                    or not foundItemId
                then
                    if self:RemoveIcon(ICON.MISSING, buff.usedItemId or buff.itemId) then buffsChanged = true end
                else
                    if self:AddIcon(ICON.MISSING, "item", foundItemId, buff) then
                        buffsChanged = true
                        buff.usedItemId = foundItemId
                    end
                end
            end
        end
    end
    if buffsChanged then
        self:ArrangeIcons(ICON.MISSING)
    end
end

local function BattleShoutMissingOnClick()
    if not QuickAuras.isWarrior then
        SendChatMessage("Battle Shout dropped!", "PARTY")
    end
end

function QuickAuras:CheckCrucialBuffs(activeAuras)
    debug(2, "CheckCrucialBuffs", "isWarrior", self.isWarrior, "inCombat", self.inCombat, "IsInGroup", IsInGroup(), "hasWarriorInParty", self.hasWarriorInParty)
    if not self.db.profile.battleShoutMissing or (self.isWarrior and not self.inCombat and not IsInGroup()) or (not self.isWarrior and not self.hasWarriorInParty) then
        self:ClearIcons(ICON.CRUCIAL)
        return
    end
    for _, crucial in pairs(self.trackedCrucialAuras) do
        local hasIt, aura = self:HasSeenAny(crucial.spellIds, activeAuras)
        local obj = self.list_crucial[crucial.spellIds[1]] -- not necessarly a timer
        debug(3, "CheckCrucialBuffs", "(scan)", crucial.conf.name, "hasIt", hasIt)
        if not hasIt then
            if obj and obj.isTimer then
                self:RemoveTimer(obj, "crucial")
            end
            if self:AddIcon(ICON.CRUCIAL, "spell", crucial.spellIds[1], crucial.conf, nil, false, BattleShoutMissingOnClick) then
                self:ArrangeIcons(ICON.CRUCIAL)
            end
            return
        elseif aura and aura[1] and aura[2] then
            -- has buff, display time to expire
            if obj and not obj.isTimer then
                self:ClearIcons(ICON.CRUCIAL)
            end
            self:AddTimer("crucial", crucial.conf, crucial.spellIds[1], aura[1], aura[2], self.db.profile.crucialExpireTime)
            return
        end
    end
    self:ClearIcons(ICON.CRUCIAL)
end

function QuickAuras:CheckStealthInInstance(seen)
    if not self.db.profile.stealthInInstance or not self.InstanceName then return end
    local stealth = self.spells.rogue.stealth
    local changed = false
    local found = false
    for _, spellId in ipairs(self.spells.rogue.stealth.spellId) do
        found = seen[spellId]
        if found then
            changed = self:AddIcon(ICON.WARNING, "spell", stealth.spellId[1], stealth)
            break
        end
    end
    if not found then
        changed = self:RemoveIcon(ICON.WARNING, stealth.spellId[1])
    end
    if changed then
        self:ArrangeIcons(ICON.WARNING)
    end
end


-- Zone change

function QuickAuras:UpdateZone()
    local newZoneName = GetRealZoneText()
    local zoneChanged = newZoneName ~= self.ZoneName
    self.ZoneName = newZoneName
    if zoneChanged then
        local inInstance, instanceType = IsInInstance()
        self.InstanceName = nil
        if inInstance and (instanceType == "raid" or instanceType == "party") then
            self.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
        end
        self.inCapital = self.capitalCities[newZoneName]
        debug(2, "UpdateZone", "inInstance", inInstance, "instanceType", instanceType, "instanceName", self.InstanceName, "zoneName", self.ZoneName, "inCapital", self.inCapital)
        -- zone dependant checks
        self:RefreshReminders()
        self:RefreshMissing()
        self:RefreshWarnings()
    end
end

-- Icon management

function QuickAuras:RefreshCooldowns()
    for _, timer in pairs(self.list_cooldowns) do
        self:RemoveTimer(timer, "refresh")
    end
    self:CheckCooldowns()
end

function QuickAuras:RefreshMissing()
    self:ClearIcons(ICON.MISSING)
    self:CheckMissingBuffs()
end

function QuickAuras:RefreshReminders()
    self:ClearIcons(ICON.REMINDER)
    self:CheckTrackingStatus()
    self:CheckLowConsumes()
    self:CheckTransmuteCooldown()
end

function QuickAuras:RefreshWarnings()
    self:ClearIcons(ICON.WARNING)
    self:CheckGear()
    self:CheckHearthstone()
end

function QuickAuras:RefreshAlerts()
    self:ClearIcons(ICON.ALERT)
end

function QuickAuras:RefreshAll()
    self:RefreshWarnings()
    self:RefreshMissing()
    self:RefreshAlerts()
    self:RefreshReminders()
end

-- DEBOUNCE FUNCTIONS

QuickAuras.BagsChanged = QuickAuras:Debounce(function()
    debug(2, "BAG_UPDATE", bagId)
    QuickAuras:ScanBags()
    QuickAuras:ScanBank()
    QuickAuras:CheckMissingBuffs()
    QuickAuras:CheckLowConsumes()
    QuickAuras:CheckTransmuteCooldown()
end, 0.5)

QuickAuras.ZoneChanged = QuickAuras:Debounce(function()
    --debug(2, "Zone Update")
    QuickAuras:UpdateZone()
end, 2)

-- Utils

function QuickAuras:FindInBags(itemIds, inBank)
    local lookup = inBank and self.bank or self.bags
    if type(itemIds) ~= "table" then
        return lookup[itemIds] and itemIds, lookup[itemIds]
    end
    for _, itemId in  ipairs(itemIds) do
        local f = lookup[itemId]
        if f then
            return itemId, f
        end
    end
end

function QuickAuras:HasSeenAny(ids, seenHash)
    for _, id in ipairs(ids) do
        if seenHash[id] then
            return id, seenHash[id]
        end
    end
end

function QuickAuras:GetItemCooldown(itemId)
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown(itemId)
    else
        return GetItemCooldown(itemId)
    end
end
