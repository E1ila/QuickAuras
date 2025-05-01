local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

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
                if conf.shouldShow then shouldShow = conf.shouldShow(isEquipped) end
                --debug("Checking gear", itemId, self.colors.bold, conf.name, "|r", "isEquipped", isEquipped, "shouldShow", shouldShow)
                if shouldShow then
                    if self:AddItemIcon("warning", itemId, conf) then changed = true end
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

function QuickAuras:CheckCooldowns()
    if not self.db.profile.cooldowns then return end
    for spellID, conf in pairs(self.trackedCooldowns) do
        local start, duration, enabled = GetSpellCooldown(spellID)
        if start > 0 and duration > 2 and (not conf.option or self.db.profile[conf.option.."_cd"]) then
            --debug("Cooldown", spellID, conf.name, start, duration, enabled)
            local updatedDuration = duration - (GetTime() - start)
            self:SetProgressTimer("cooldowns", "button", self.cooldowns, QuickAuras_Cooldowns, conf, updatedDuration, start + duration)
        end
    end
end

function QuickAuras:CheckAuras()
    if not self.db.profile.watchBars then return end
    local i = 1
    local seen = {}
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i)
        if not name then break end -- Exit the loop when no more auras are found
        --debug("CheckAuras", "(pre)", "spellID", spellID, name)
        -- bar auras -----------------------------------------
        local aura = self.trackedAuras[spellID]
        if aura and (not aura.option or self.db.profile[aura.option]) then
            --debug("CheckAuras", "conf", conf.name, "duration", duration, "expTime", expTime, "option", conf.option, self.db.profile[conf.option])
            local timer = self:SetProgressTimer("auras", "bar", nil, nil, aura, duration, expTime)
            if timer then
                seen[timer.key] = true
            end
        end
        -- missing buffs -----------------------------------------
        local buff = self.trackedMissingBuffs[spellID]
        if buff and (not buff.option or self.db.profile[buff.option]) then
            --debug("CheckAuras", "conf", conf.name, "duration", duration, "expTime", expTime, "option", conf.option, self.db.profile[conf.option])
            local timer = self:SetProgressTimer("auras", "button", nil, nil, buff, duration, expTime)
            if timer then
                seen[timer.key] = true
            end
        end
        i = i + 1
    end
    -- remove missing auras
    for _, timer in pairs(self.timers) do
        if not seen[timer.key] and timer.source == "auras" then
            self:RemoveProgressTimer(timer, "unseen")
        end
    end
end

function QuickAuras:UpdateZone()
    local inInstance, instanceType = IsInInstance()
    self.InstanceName = nil
    if inInstance and (instanceType == "raid" or instanceType == "party") then
        self.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
    end
    self.ZoneName = GetRealZoneText()
    --debug("Updating Zone:", QAG.ZoneName)
end
