local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

function QuickAuras:CheckWeaponEnchant()
    local mh, expiration, _, enchid, _, _, _, _ = GetWeaponEnchantInfo("player")
    local mhItemId = GetInventoryItemID("player", 16)
    debug("CheckWeaponEnchant", "mh", mh, "expiration", expiration, "enchid", enchid, "mhItemId", mhItemId)
    self:SetWeaponEnchantIcon(1, mhItemId)
end

function QuickAuras:CheckLowConsumes()
    if not self.db.profile.remindersEnabled or not self.db.profile.lowConsumesReminder then return end
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
                if self:AddIcon("reminder", "item", consume.itemId, consume, details and details.count or 0) then changed = true end
            else
                if self:RemoveIcon("reminder", consume.itemId) then changed = true end
            end
            if minCount and self.db.profile.outOfConsumeWarning then
                if foundItemId then
                    self.existingConsumes[consume.itemId] = true
                elseif self.existingConsumes[consume.itemId] then
                    -- no more item
                    self.existingConsumes[consume.itemId] = nil
                    if IsInInstance() then
                        self:AddIcon("reminder", "item", consume.itemId, consume, 0)
                        changed = true
                    end
                end
            end
        end
    end
    if changed then
        self:ArrangeIcons("reminder")
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
                if QAG:RemoveIcon("reminder", spellId) then changed = true end
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
        if QAG:AddIcon("reminder", "spell", missingSpellId, QAG.trackedTracking[missingSpellId]) then changed = true end
    end
    if changed then
        QAG:ArrangeIcons("reminder")
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
                    if self:AddIcon("warning", "item", itemId, conf) then changed = true end
                else
                    if self:RemoveIcon("warning", itemId) then changed = true end
                end
            end
        end

        if changed then
            self:ArrangeIcons("warning")
        end
    end
end

local function _checkCooldown(conf, start, duration)
    if start > 0 and duration > 2 and (not conf.option or QuickAuras.db.profile[conf.option.."_cd"]) then
        --debug("Cooldown", spellId, conf.name, start, duration, enabled)
        local updatedDuration = duration - (GetTime() - start)
        QuickAuras:AddTimer("cooldowns", conf, updatedDuration, start + duration)
    end
end

function QuickAuras:CheckCooldowns()
    if not self.db.profile.cooldowns then return end
    for spellId, conf in pairs(self.trackedSpellCooldowns) do
        local start, duration = GetSpellCooldown(spellId)
        _checkCooldown(conf, start, duration)
    end
    for itemId, conf in pairs(self.trackedItemCooldowns) do
        -- show cooldown only if item is in bags
        if QuickAuras.bags[conf.itemId] then
            local start, duration = GetItemCooldown(itemId)
            _checkCooldown(conf, start, duration)
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
        seen[spellId] = true
        -- timer auras -----------------------------------------
        local aura = self.trackedAuras[spellId]
        --debug(3, "CheckAuras", "(scan)", "spellId", spellId, name, "aura", aura, "option", aura and aura.option)
        if aura and (not aura.option or self.db.profile[aura.option]) and self.db.profile.watchBars then
            duration, expTime = FixAuraExpTime(duration, expTime, aura, spellId)
            --debug(2, "CheckAuras", "aura", aura.name, "duration", duration, "expTime", expTime, "option", aura.option, self.db.profile[aura.option])
            local timer = self:AddTimer("auras", aura, duration, expTime)
            if timer then
                seen[timer.key] = true
            end
        end
        i = i + 1
    end
    -- remove missing auras
    for _, timer in pairs(self.timers) do
        if not seen[timer.key] and timer.timerType == "auras" then
            self:RemoveTimer(timer, "unseen")
        end
    end
    self:CheckMissingBuffs()
end

function QuickAuras:CheckMissingBuffs()
    if not QuickAuras.db.profile.missingConsumes then return end
    local buffsChanged = false
    if  self.db.profile.forceShowMissing or
        self.db.profile.missingBuffsMode == "instance" and IsInInstance() or
        self.db.profile.missingBuffsMode == "raid" and IsInInstance() and IsInRaid()
    then
        for _, buff in ipairs(self.trackedMissingBuffs) do
            if not buff.option or self.db.profile[buff.option] then
                local foundBuff = self:HasSeenAny(buff.spellIds, self.playerBuffs)
                local foundItemId = self:FindInBags(buff.itemIds or buff.itemId)
                debug(3, "CheckAuras", "(scan)", buff.name, "found", foundBuff, "foundItemId", foundItemId, "option", buff.option, buff.option and self.db.profile[buff.option])
                if  foundBuff
                    or buff.visibleFunc and not buff.visibleFunc()
                    or not foundItemId
                then
                    if self:RemoveIcon("missing", buff.usedItemId or buff.itemId) then buffsChanged = true end
                else
                    if self:AddIcon("missing", "item", foundItemId, buff) then
                        buffsChanged = true
                        buff.usedItemId = foundItemId
                    end
                end
            end
        end
    end
    if buffsChanged then
        self:ArrangeIcons("missing")
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
    end
end

-- Icon management

function QuickAuras:RefreshMissing()
    self:ClearIcons("missing")
    self:CheckMissingBuffs()
end

function QuickAuras:RefreshReminders()
    self:ClearIcons("reminder")
    self:CheckTrackingStatus()
    self:CheckLowConsumes()
end

function QuickAuras:RefreshWarnings()
    self:ClearIcons("warning")
    self:CheckGear()
end

function QuickAuras:RefreshAlerts()
    self:ClearIcons("alert")
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
    QuickAuras:CheckMissingBuffs()
    QuickAuras:CheckLowConsumes()
end, 0.5)

QuickAuras.ZoneChanged = QuickAuras:Debounce(function()
    debug(2, "Zone Update")
    QuickAuras:UpdateZone()
end, 2)

-- Utils

function QuickAuras:FindInBags(itemIds)
    if type(itemIds) ~= "table" then
        return self.bags[itemIds] and itemIds, self.bags[itemIds]
    end
    for _, itemId in  ipairs(itemIds) do
        local f = self.bags[itemId]
        if f then
            return itemId, f
        end
    end
end

function QuickAuras:HasSeenAny(ids, seenHash)
    for _, id in ipairs(ids) do
        if seenHash[id] then
            return true
        end
    end
end
