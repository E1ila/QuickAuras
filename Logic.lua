local ADDON_NAME, addon = ...
local QuickAuras = addon.root
local debug = QuickAuras.Debug

function QuickAuras:CheckGear()
    if self.db.profile.trackedGear then
        local equippedItems = {}
        local changed = false

        -- Track all currently equipped items
        for slotId = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local equippedItemId = GetInventoryItemID("player", slotId)
            if equippedItemId then
                local conf = self.trackedGear[equippedItemId]
                if conf and (not conf.option or self.db.profile[conf.option]) then
                    equippedItems[equippedItemId] = true
                    if QuickAuras:AddIconWarning(equippedItemId, conf) then
                        changed = true
                    end
                end
            end
        end

        -- Remove icon warnings for items no longer equipped
        for itemId, _ in pairs(QuickAuras.iconWarnings) do
            if not equippedItems[itemId] then
                QuickAuras:RemoveIconWarning(itemId)
                changed = true
            end
        end

        if changed then
            self:ArrangeIconWarnings()
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
            self:SetProgressTimer("button", self.cooldowns, QuickAuras_Cooldowns, conf, updatedDuration, start + duration)
        end
    end
end

function QuickAuras:CheckAuras()
    if not self.db.profile.watchBars then return end
    local i = 1
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        --debug(UnitAura("player", i, "HELPFUL"))
        if not name then break end -- Exit the loop when no more auras are found
        local conf = self.trackedAuras[spellID]
        if conf and (not conf.option or self.db.profile[conf.option]) then
            --debug("Aura", name, icon, duration, expTime)
            self:SetProgressTimer("bar", nil, nil, conf, duration, expTime)
        end
        i = i + 1
    end
end

function QuickAuras:UpdateZone()
    local inInstance, instanceType = IsInInstance()
    self.InstanceName = nil
    if inInstance and (instanceType == "raid" or instanceType == "party") then
        self.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
    end
    self.ZoneName = GetRealZoneText()
    debug("Updating Zone:", QAG.ZoneName)
end
