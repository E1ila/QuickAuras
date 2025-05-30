local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local _useTeaShown = false
local USE_TEA_ENERGY_THRESHOLD = 6
local THISTLE_TEA_ITEMID = 7676
local BLADE_FLURRY_SPELLID = 13877
local WINDOW = QA.WINDOW
local _c = QA.colors
local _aurasCombatState = false

QA.targetInRange = false

local targetAggro = {}

function QA:GroupCompoChanged()
    QA.isMainTank = QA.isWarrior and IsInRaid() and (GetPartyAssignment("MAINTANK", "player") or GetPartyAssignment("MAINASSIST", "player"))
    QA:CheckIfWarriorInParty()
    QA:CheckForShaman()
    QA:CheckAuras()
end

function QA:CheckTargetAuras(targetChanged)
    local shouldCheck = UnitExists("target") and not UnitIsDead("target") and not UnitIsPlayer("target") and QA.inCombat
    local window = QA.db.profile.targetMissingDebuffFrame
    if targetChanged or not shouldCheck then
        -- reset
        for _, spell in ipairs(QA.trackedEnemyAuras) do
            QA:RemoveIcon(window, spell.spellId[1])
        end
    end
    if shouldCheck then
        local seen = {}
        debug(2, "CheckTargetAuras", "target", UnitName("target"))
        for i = 1, 32 do
            local name, _, count, dispelType, duration, expires, isStealable, _, _, spellId = UnitDebuff("target", i)
            if not name then break end
            local spell = QA.trackedEnemyAurasBySpellId[spellId]
            --debug(3, "CheckTargetAuras", "(scan)", i, name, spellId, count)
            if spell then
                seen[spellId] = { count = count, expires = expires, spell = spell, spellId = spellId, duration = duration }
            end
        end

        for _, spell in ipairs(QA.trackedEnemyAuras) do
            local key = spell.option.."_enemy"
            if QA.db.profile[key] and (not spell.enemyAura.ShowCond or spell.enemyAura.ShowCond()) then
                local found
                for _, spellId in ipairs(spell.spellId) do
                    found = seen[spellId]
                    if found then
                        break
                    end
                end
                local stackCount = found and found.count or 0
                local missing = stackCount < spell.enemyAura.requiredStacks
                --debug(3, "CheckTargetAuras", "(check)", spell.name, "missing", missing, "count", found and found.count or 0)
                if missing then
                    QA:AddIcon(window, "spell", spell.spellId[1], spell, found and found.count or 0)
                else
                    QA:RemoveIcon(window, spell.spellId[1])
                    if stackCount == spell.enemyAura.requiredStacks then
                        --:AddTimer(window,       conf,  id,               duration,       expTime,       showAtTime,    text,      keyExtra)
                        QA:AddTimer(window, spell, spell.spellId[1], found.duration, found.expires, QA.db.profile.targetAuraExpireTime)
                    end
                end
            end
        end
    end
end

-- warrior spell queue ---------------------------------------------------------------------------

function QA:CheckSpellQueue(unit, spellGuid)
    if not QA.db.profile.spellQueueEnabled or not QA.isWarrior then return end
    local id = QA:GetSpellIdFromGuid(spellGuid)
    local spell = QA.spells.warrior.heroicStrike.bySpellId[id] and QA.spells.warrior.heroicStrike
            or QA.spells.warrior.cleave.bySpellId[id] and QA.spells.warrior.cleave
    --debug(3, "UNIT_SPELLCAST_SENT", unit, spellGuid, id)
    if unit == "player" and spell then
        QA:QueuedSpell(spell, id)
    end
end

QA.queuedSpell = {}

local function MonitorQueued(spellId, callback)
    -- in case of /stopcasting
    C_Timer.After(0.25, function()
        if spellId ~= QA.queuedSpell.usedId then return end -- spell replaced/removed
        local is = IsCurrentSpell(spellId)
        if not is then
            callback()
        else
            MonitorQueued(spellId, callback)
        end
    end)
end

function QA:QueuedSpell(spell, spellId)
    --debug(3, "Queued spell: " .. spell.name)
    if QA.queuedSpell.id and QA.queuedSpell.id ~= spell.spellId[1] then
        QA:RemoveIcon(WINDOW.QUEUE, QA.queuedSpell.id)
    end
    QA.queuedSpell = {
        id = spell.spellId[1],
        usedId = spellId,
        spell = spell,
    }
    MonitorQueued(spellId, function() QA:UnQueuedSpell(spell) end)
    QA:AddIcon(WINDOW.QUEUE, "spell", spell.spellId[1], spell)
end

function QA:UnQueuedSpell(spell)
    --debug(3, "Removed spell from queue: " .. spell.name)
    QA.queuedSpell = {}
    QA:RemoveIcon(WINDOW.QUEUE, spell.spellId[1])
end

-- aggro ---------------------------------------------------------------------------

function QA:CheckPlayerAggro()
    if not QA.inCombat then targetAggro = {} return end
    if not QA.db.profile.overaggroWarning or (not IsInRaid() and not IsInGroup()) then return end
    if not UnitExists("target") or UnitIsDead("target") or UnitIsPlayer("target") then return end

    local status = UnitThreatSituation("player", "target")
    local targetGuid = UnitGUID("target")
    local targettargetGuid = UnitGUID("targettarget")
    --debug(3, "UNIT_THREAT_LIST_UPDATE", status, UnitName("targettarget"))

    if      targetAggro.targetGuid == targetGuid
            and targettargetGuid == QA.playerGuid
            and targetAggro.targettargetGuid ~= QA.playerGuid
    then
        if targetAggro.targettargetClass == "Warrior" and not QA.isMainTank and (QA.hasTaunted == 0 or QA.hasTaunted < GetTime()) then
            QA:BlinkGotAggro()
        end
    elseif QA.blinkingAggro and targettargetGuid ~= QA.playerGuid then
        QA:StopBlinkingAggro()
    end
    targetAggro.targetGuid = targetGuid
    targetAggro.targettargetGuid = targettargetGuid
    targetAggro.targettargetClass = UnitClass("targettarget")
end

function QA:CheckIfWarriorInParty()
    QA.hasWarriorInParty = false
    for i = 1, GetNumGroupMembers() do
        local unitId = "party"..i
        debug(2, "CheckIfWarriorInParty", unitId, UnitClass(unitId))
        if UnitClass(unitId) == "Warrior" and UnitIsConnected(unitId) then
            QA.hasWarriorInParty = true
            break
        end
    end
end

function QA:CheckTargetRange()
    if not QA.db.profile.targetInRangeIndication or not QA.db.profile.rangeSpellId then return end
    local spellName = GetSpellInfo(QA.db.profile.rangeSpellId)
    local inRange = IsSpellInRange(spellName, "target") == 1
    if inRange ~= QA.targetInRange then
        QA.targetInRange = inRange
        debug(2, "inRange", spellName, inRange)
        if inRange then
            QuickAuras_RangeIndicator:Show()
        else
            QuickAuras_RangeIndicator:Hide()
        end
    end
end

function QA:CheckHearthstone()
    if not QA.db.profile.hsNotCapitalWarning or QA.playerLevel < 60 then return end
    local bindLocation = GetBindLocation()
    if QA.inCapital and not QA.capitalCities[bindLocation] then
        QA:AddIcon(WINDOW.WARNING, "item", 6948, { name = "Hearthstone" })
        out("|cffff0000Warning:|r Your Hearthstone is set to ".._c.bold..bindLocation.."|r!")
    else
        QA:RemoveIcon(WINDOW.WARNING, 6948)
    end
end

function QA:CheckAllProcs()
    for _, spell in ipairs(QA.trackedProcAbilities.unitHealth) do
        QA:CheckProcSpellUsable(spell)
    end
    for _, spell in ipairs(QA.trackedProcAbilities.combatLog) do
        QA:CheckProcSpellUsable(spell)
    end
    QA:CheckAuras()
end

-- Currently supported only target based proc spells
function QA:CheckProcSpellUsable(spell)
    if not QA.db.profile[spell.procFrameOption] then return end
    local spellId = spell.spellId[1]
    local usable, notEnoughMana = IsUsableSpell(spellId)
    local iconType = spell.procFrameOption and QA.db.profile[spell.procFrameOption.."Frame"] or "warning"
    --debug(3, "Checking proc spell usable: "..spell.name, usable, notEnoughMana)
    if usable and not notEnoughMana and UnitExists("target") and not UnitIsDead("target") then
        local start, duration = GetSpellCooldown(spellId)
        if start > 0 and duration > 0 then
            -- has cooldown, check again later
            QA:RemoveIcon(iconType, spellId)
            if spell.procFadeCheck and not QA.procCheck.cooldown[spellId] then
                QA.procCheck.cooldown[spellId] = true
                C_Timer.After(start + duration - GetTime() + 0.1, function()
                    QA.procCheck.cooldown[spellId] = nil
                    QA:CheckProcSpellUsable(spell)
                end)
            end
        else
            local button = QA:AddIcon(iconType, "spell", spellId, spell)
            if button then
                button.glowInCombat = true
            end
            local FadeCheck = QA.procCheck.FadeCheck[spellId]
            if FadeCheck then
                FadeCheck(QA) -- if not used, it fades. check within 1 sec
            end
        end
    else
        QA:RemoveIcon(iconType, spellId)
    end
end

function QA:CheckProcAura(spell, seen)
    if not QA.db.profile[spell.procFrameOption] then return end
    local spellId = spell.spellId[1]
    local hasIt = QA:HasSeenAny(spell.spellId, seen)
    local window = spell.procFrameOption and QA.db.profile[spell.procFrameOption.."Frame"] or "warning"
    debug(2, "Checking proc aura: "..spell.name, hasIt)
    if hasIt then
        local button = QA:AddIcon(window, "spell", spellId, spell)
        --                AddTimer(window, conf, id, duration, expTime, showAtTime, text, keyExtra)
        --local button = QA:AddTimer(iconType, spell, spellId, hasIt.duration, hasIt.expTime)
        if button then
            button.glowInCombat = true
        end
    else
        QA:RemoveIcon(window, spellId)
    end
end

function QA:CheckRogueTeaTime()
    local currentEnergy = UnitPower("player", Enum.PowerType.Energy)
    if _useTeaShown then
        -- hide
        if currentEnergy >= USE_TEA_ENERGY_THRESHOLD then
            _useTeaShown = false
            QA:RemoveIcon(QA.db.profile.rogueTeaTimeFrame, THISTLE_TEA_ITEMID)
        end
    else
        -- show
        if  currentEnergy < USE_TEA_ENERGY_THRESHOLD and
                (QA.db.profile.rogueTeaTime == "always" or
                        QA.db.profile.rogueTeaTime == "flurry" and QA.playerBuffs[BLADE_FLURRY_SPELLID])
        then
            local start = QA:GetItemCooldown(THISTLE_TEA_ITEMID)
            local foundItemId = QA:FindInBags(THISTLE_TEA_ITEMID)
            if start == 0 and foundItemId then
                _useTeaShown = true
                local button = QA:AddIcon(QA.db.profile.rogueTeaTimeFrame, "item", THISTLE_TEA_ITEMID, { name = "Thistle Tea"})
                button.glowInCombat = true
            end
        end
    end
end

function QA:CheckPower(unit, powerType)
    if not unit == "player" then return end
    --debug(3, "CheckPower", unit, powerType)
    if QA.isRogue then
        if powerType == "ENERGY" then
            QA:CheckRogueTeaTime()
        elseif powerType == "COMBO_POINTS" then
            local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
            QA:Rogue_SetCombo(comboPoints)
        end
    end
end

-- debounce CheckTransmuteCooldown
QA.CheckTransmuteCooldownDebounce = QA:Debounce(function()
    QA:CheckTransmuteCooldown()
end, 0.25)

function QA:CheckTransmuteCooldown()
    if not QA.db.profile.remindersEnabled or not QA.db.profile.reminderTransmute then return end
    for _, spell in pairs(QA.spells.transmutes) do
        local hasIt = true
        local id = spell.spellId[1]
        if spell.spellId and not IsPlayerSpell(id) then hasIt = false end
        if spell.itemId and not (QA:FindInBags(spell.itemId) or QA:FindInBags(spell.itemId, true)) then hasIt = false end
        if hasIt then
            local start, duration
            if spell.itemId then
                start, duration = QA:GetItemCooldown(spell.itemId)
            else
                start, duration = GetSpellCooldown(id)
            end
            local timeLeft = math.floor((start + duration - GetTime()) / 60)
            --debug(3, "CheckTransmuteCooldown", "(scan)", spell.name, "start", start, "duration", duration, "timeLeft", timeLeft)
            if start == 0 then
                local TransmuteClick = function()
                    out("|cffff0000Transmute|r "..spell.name.." is ready!")
                end
                --               :AddIcon(iconType,        idType,  id, conf, count, showTooltip, onClick)
                local button = QA:AddIcon(WINDOW.REMINDER, "spell", id, spell, nil, nil, "cast "..tostring(id))
                if button then
                    C_Timer.After(0.1, function()
                        ActionButton_ShowOverlayGlow(button.frame)
                    end)
                end
            elseif timeLeft <= QA.db.profile.transmutePreReadyTime then
                QA:AddTimer(WINDOW.REMINDER, spell, id, duration, start+duration)
            else
                QA:RemoveIcon(WINDOW.REMINDER, id)
            end
        else
            --debug(3, "CheckTransmuteCooldown", "(scan)", spell.name, "hasIt", hasIt)
        end
    end
end

function QA:CheckWeaponEnchant()
    local mh, expiration, _, enchid, _, _, _, _ = GetWeaponEnchantInfo("player")
    local mhItemId = GetInventoryItemID("player", 16)
    debug("CheckWeaponEnchant", "mh", mh, "expiration", expiration, "enchid", enchid, "mhItemId", mhItemId)
    QA:SetWeaponEnchantIcon(1, mhItemId)
end

function QA:CheckLowConsumes()
    if not QA.db.profile.remindersEnabled or not QA.db.profile.reminderLowConsumes then return end
    if QA.db.profile.lowConsumesInCapital and not QA.inCapital then return end
    for _, consume in pairs(QA.trackedLowConsumes) do
        if not consume.option or QA.db.profile[consume.option] then
            local foundItemId, details = QA:FindInBags(consume.itemIds or consume.itemId)
            local minCount = consume.minCount or QA.db.profile.lowConsumesMinCount
            --debug(3, "CheckLowConsumes", "(scan)", consume.name, "foundItemId", foundItemId, "option", consume.option, consume.option and QA.db.profile[consume.option])
            if
                (not foundItemId or details.count < minCount)
                and QA.db.profile.lowConsumesMinLevel <= QA.playerLevel
            then
                QA:AddIcon(WINDOW.REMINDER, "item", consume.itemId, consume, details and details.count or 0)
            else
                QA:RemoveIcon(WINDOW.REMINDER, consume.itemId)
            end
            if minCount and QA.db.profile.outOfConsumeWarning then
                if foundItemId then
                    QA.existingConsumes[consume.itemId] = true
                elseif QA.existingConsumes[consume.itemId] then
                    -- no more item
                    QA.existingConsumes[consume.itemId] = nil
                    if IsInInstance() then
                        QA:AddIcon(WINDOW.REMINDER, "item", consume.itemId, consume, 0)
                    end
                end
            end
        end
    end
end

function QA:CheckTrackingStatus()
    if not QA.db.profile.remindersEnabled then return end
    local trackingType = GetTrackingTexture()
    local found, missingSpellId = false, nil
    for spellId, conf in pairs(QA.trackedTracking) do
        --debug(3, "CheckTrackingStatus", "(scan)", conf.name, "spellId", spellId, "option", conf.option, conf.option and QA.db.profile[conf.option])
        if IsSpellKnown(spellId) and QA.db.profile[conf.option] then
            if conf.textureId == trackingType then
                QAG:RemoveIcon(WINDOW.REMINDER, spellId)
                found = true
                break
            else
                missingSpellId = spellId
            end
        end
    end
    debug(2, "CheckTrackingStatus", "trackingType", trackingType, "found", found, "missingSpellId", missingSpellId)
    if not found and missingSpellId then
        --debug(3, "CheckTrackingStatus", "missingSpellId", missingSpellId)
        QAG:AddIcon(WINDOW.REMINDER, "spell", missingSpellId, QAG.trackedTracking[missingSpellId])
    end
end

function QA:CheckGear(eventType, ...)
    if QA.db.profile.trackedGear then
        local equippedItems = {}

        for slotId = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local equippedItemId = GetInventoryItemID("player", slotId)
            if equippedItemId then
                equippedItems[equippedItemId] = true
            end
        end

        for itemId, conf in pairs(QA.trackedGear) do
            if not conf.option or QA.db.profile[conf.option] then
                local isEquipped = equippedItems[itemId]
                local shouldShow = isEquipped
                if conf.visibleFunc then shouldShow = conf.visibleFunc(isEquipped) end
                --debug("Checking gear", itemId, QA.colors.bold, conf.name, "|r", "isEquipped", isEquipped, "shouldShow", shouldShow)
                if shouldShow then
                    QA:AddIcon(WINDOW.WARNING, "item", itemId, conf)
                else
                    QA:RemoveIcon(WINDOW.WARNING, itemId)
                end
            end
        end
    end
end

local function _checkCooldown(conf, idType, id, start, duration)
    --debug(4, "_checkCooldown", idType, id, conf.name, start, duration, "option", conf.option)
    if start and start > 0 and duration and duration > 2 and (not conf.option or QA.db.profile[conf.option.."_cd"]) then
        local updatedDuration = duration - (GetTime() - start)
        --debug(3, "_checkCooldown", "FOUND", conf.name)
        QA:AddTimer(WINDOW.COOLDOWNS, conf, id, updatedDuration, start + duration)
    end
end

local function isItemReady(item)
    local start, duration = QA:GetItemCooldown(item.itemId)
    return start == 0 and duration == 0
end

function QA:CheckCooldowns()
    if not QA.db.profile.cooldowns then return end
    for spellId, conf in pairs(QA.trackedSpellCooldowns) do
        if not (conf.ignoreCooldownInStealth and QA.playerIsStealthed) then
            local start, duration = GetSpellCooldown(spellId)
            _checkCooldown(conf, "spell", spellId, start, duration)
        end
    end
    for itemId, conf in pairs(QA.trackedItemCooldowns) do
        -- show cooldown only if item is in bags
        if conf.evenIfNotInBag or QA.bags[conf.itemId] then
            local start, duration = QA:GetItemCooldown(itemId)
            _checkCooldown(conf, "item", itemId, start, duration)
        end
    end
    -- check ready items
    if QA.db.profile.notifyExplosivesReady then
        local sapper = QA.explosives.goblinSapperCharge
        local sapperReady = QA.bags[sapper.itemId] and isItemReady(sapper)
        local otherReady
        for _, conf in pairs(QA.explosives) do
            if QA.bags[conf.itemId] and conf.itemId ~= sapper.itemId then
                local start, duration = QA:GetItemCooldown(conf.itemId)
                if start == 0 and duration == 0 then
                    otherReady = conf
                else
                    QA:RemoveIcon(WINDOW.READY, conf.itemId)
                end
            else
                QA:RemoveIcon(WINDOW.READY, conf.itemId)
            end
        end
        if sapperReady then
            --:AddIcon(window,       idType, id, conf, count, showTooltip, onClick)
            QA:AddIcon(WINDOW.READY, "item", sapper.itemId, sapper)
        elseif otherReady then
            QA:AddIcon(WINDOW.READY, "item", otherReady.itemId, otherReady)
        end
    end
end

local manualExpTime = {}
local function FixAuraExpTime(duration, expTime, aura, spellId)
    if aura.manualExpTime then
        duration = QA:GetDuration(aura, spellId)
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

local lastSeen = {}

function QA:CheckAuras()
    local i = 1
    local seen = {}
    QA.playerBuffs = seen
    QA.playerIsStealthed = false
    while true do
        local name, icon, _, _, duration, expTime, _, _, _, spellId = UnitAura("player", i)
        if not name then break end -- Exit the loop when no more auras are found
        --debug(3, "CheckAuras", "(scan)", i, name, icon, duration, expTime, spellId)
        seen[spellId] = { duration = duration, expTime = expTime, spellId = spellId }
        if QA.stealthAbilities[spellId] then QA.playerIsStealthed = true end
        -- timer auras -----------------------------------------
        local aura = QA.trackedAuras[spellId]
        --debug(3, "CheckAuras", "(scan)", "spellId", spellId, name, "aura", aura, "option", aura and aura.option)
        if aura and (not aura.option or QA.db.profile[aura.option]) and QA.db.profile.watchBars then
            duration, expTime = FixAuraExpTime(duration, expTime, aura, spellId)
            debug(2, "CheckAuras", "aura", aura.name, "duration", duration, "expTime", expTime, "option", aura.option, QA.db.profile[aura.option])
            local timer = QA:AddTimer(aura.list or WINDOW.WATCH, aura, spellId, duration, expTime)
            if timer then
                seen[timer.key] = true
            end
            if aura.OnDetectAura and not lastSeen[spellId] then
                aura.OnDetectAura(aura, duration, expTime)
            end
        end
        i = i + 1
    end
    -- remove missing auras
    for _, timer in pairs(QA.list_timers) do
        if not seen[timer.key] and timer.window == "auras" then
            QA:RemoveTimer(timer, "unseen")
        end
    end
    lastSeen = seen
    local combatStateChanged = _aurasCombatState ~= QA.inCombat
    _aurasCombatState = QA.inCombat
    if combatStateChanged then
        debug(2, "CheckAuras", "combat", QA.inCombat)
    end
    for _, spell in pairs(QA.trackedProcAbilities.aura) do
        QA:CheckProcAura(spell, seen)
    end
    QA:CheckMissingBuffs(seen, combatStateChanged)
    QA:CheckCrucialBuffs(seen, combatStateChanged)
    QA:CheckStealthInInstance(seen)
end

function QA:CheckMissingBuffs(activeAuras, combatStateChanged)
    if not QA.db.profile.missingConsumes then return end
    local showNonSelfBuffs = QA.db.profile.forceShowMissing or
            QA.db.profile.missingBuffsMode == "instance" and IsInInstance() or
            QA.db.profile.missingBuffsMode == "raid" and IsInInstance() and IsInRaid()
    for _, buff in ipairs(QA.trackedMissingBuffs) do
        --debug(3, "CheckMissingBuffs", "(pre)", buff.name, "option", buff.option, buff.option and QA.db.profile[buff.option])
        if (not buff.option or QA.db.profile[buff.option]) and (showNonSelfBuffs or buff.selfBuff) then
            if buff.itemIds or buff.itemId then
                -- missing consume buff
                local foundBuff = QA:HasSeenAny(buff.spellIds, activeAuras or QA.playerBuffs)
                local foundItemId = QA:FindInBags(buff.itemIds or buff.itemId)
                --debug(3, "CheckMissingBuffs", "(scan)", buff.name, "found", foundBuff, "foundItemId", foundItemId)
                if  foundBuff
                        or buff.visibleFunc and not buff.visibleFunc()
                        or not foundItemId
                then
                    QA:RemoveIcon(WINDOW.MISSING, buff.usedItemId or buff.itemId)
                else
                    -- QA:AddIcon(window,         idType, id,          conf, count, showTooltip, onClick)
                    if QA:AddIcon(WINDOW.MISSING, "item", foundItemId, buff, nil, nil, "use "..tostring(foundItemId)) then
                        buff.usedItemId = foundItemId
                    end
                end
            else
                -- missing spell buff
                local foundBuff = QA:HasSeenAny(buff.spellId, activeAuras or QA.playerBuffs)
                local visible = buff.visibleFunc == nil or buff.visibleFunc()
                --debug(3, "CheckMissingBuffs", "(scan)", buff.name, "found", foundBuff, "visible", visible)
                if foundBuff or not visible then
                    QA:RemoveIcon(WINDOW.QUEUE, buff.spellId[1])
                else
                    local button = QA:AddIcon(WINDOW.QUEUE, "spell", buff.spellId[1], buff)
                    if button then
                        button.glowInCombat = true
                    end
                end
            end
        end
    end
end

function QA:CheckCrucialBuffs(activeAuras, combatStateChanged)
    for _, buff in ipairs(QA.trackedCrucialAuras) do
        local spellId = buff.spellIds[1]
        if buff.conf.CrucialCond() then
            local hasIt, aura = QA:HasSeenAny(buff.spellIds, activeAuras)
            local timeLeft = aura and aura.expTime or 0
            local existing = QA.list_crucial[spellId] -- not necessarly a timer
            debug("CheckCrucialBuffs", "(scan)", buff.conf.name, "hasIt", hasIt, "timeLeft", timeLeft, "existing", existing ~= nil)
            if not hasIt then
                if existing and existing.isTimer then
                    -- convert from timer to icon
                    QA:RemoveTimer(existing, "crucial")
                end
                local OnClick = buff.conf.OnClick
                for _, id in ipairs(buff.spellIds) do
                    if IsSpellKnown(id) then
                        OnClick = "cast "..tostring(id)
                        break
                    end
                end
                --:AddIcon(window,         idType,  id,      conf,    count, showTooltip, onClick)
                QA:AddIcon(WINDOW.CRUCIAL, "spell", spellId, buff.conf, nil, false, OnClick)
            else
                -- has buff, display time to expire
                if existing and not existing.isTimer then
                    -- remove icon
                    debug("CheckCrucialBuffs", "removing existing icon", spellId)
                    QA:RemoveIcon(WINDOW.CRUCIAL, spellId)
                end
                if timeLeft > 0 then -- duration, expTime
                    local timer, isNew = QA:AddTimer(WINDOW.CRUCIAL, buff.conf, spellId, aura.duration, aura.expTime, QA.db.profile.crucialExpireTime)
                    timer.glowOnEnd = false -- no need, the icon will glow
                end
            end
        else
            QA:RemoveIcon(WINDOW.CRUCIAL, spellId)
        end
    end
end

function QA:CheckStealthInInstance(seen)
    if not QA.db.profile.stealthInInstance or not QA.InstanceName then return end
    local stealth = QA.spells.rogue.stealth
    local found = false
    for spellId, _ in pairs(QA.stealthAbilities) do
        found = seen[spellId]
        if found then
            QA:AddIcon(WINDOW.WARNING, "spell", stealth.spellId[1], stealth)
            break
        end
    end
    if not found then
        QA:RemoveIcon(WINDOW.WARNING, stealth.spellId[1])
    end
end

function QA:CheckForShaman()
    if QA.isAlliance then return end
    QA.partyShamans = {}
    if QA.isShaman then
        table.insert(QA.partyShamans, "player")
    end
    if GetNumGroupMembers() == 0 then return end
    for index = 1, 4 do
        local pstring = "party" .. index
        local gclass = select(2, UnitClass(pstring))
        if (gclass == "SHAMAN") then
            table.insert(QA.partyShamans, pstring)
        end
    end
end


-- Other

function QA:UpdateZone()
    local newZoneName = GetRealZoneText()
    local zoneChanged = newZoneName ~= QA.ZoneName
    QA.ZoneName = newZoneName
    if zoneChanged then
        local inInstance, instanceType = IsInInstance()
        if not inInstance then
            -- in case player HS'd out of an instance
            QA:ENCOUNTER_END()
        end
        QA.InstanceName = nil
        if inInstance and (instanceType == "raid" or instanceType == "party") then
            QA.InstanceName = select(1, GetInstanceInfo()) -- Get the instance name
        end
        QA.inCapital = QA.capitalCities[newZoneName]
        debug(2, "UpdateZone", "inInstance", inInstance, "instanceType", instanceType, "instanceName", QA.InstanceName, "zoneName", QA.ZoneName, "inCapital", QA.inCapital)
        -- zone dependant checks
        QA:RefreshReminders()
        QA:RefreshMissing()
        QA:RefreshWarnings()
    end
end

function QA:PlayerDied()
    QA:ENCOUNTER_END()
    QA:ClearTimers()
    for _, iconType in pairs(WINDOW) do
        QA:ClearIcons(iconType)
    end
end


-- Icon management

function QA:RefreshCooldowns()
    for _, timer in pairs(QA.list_cooldowns) do
        QA:RemoveTimer(timer, "refresh")
    end
    QA:CheckCooldowns()
end

function QA:RefreshMissing()
    QA:ClearIcons(WINDOW.MISSING)
    QA:CheckMissingBuffs()
end

function QA:RefreshReminders()
    QA:ClearIcons(WINDOW.REMINDER)
    QA:CheckTrackingStatus()
    QA:CheckLowConsumes()
    QA:CheckTransmuteCooldown()
end

function QA:RefreshWarnings()
    QA:ClearIcons(WINDOW.WARNING)
    QA:CheckGear()
    QA:CheckHearthstone()
end

function QA:RefreshAlerts()
    QA:ClearIcons(WINDOW.ALERT)
end

function QA:RefreshCrucial()
    QA:ClearIcons(WINDOW.CRUCIAL)
    QA:CheckAuras()
end

function QA:RefreshReady()
    QA:ClearIcons(WINDOW.READY)
    QA:CheckCooldowns()
end

function QA:RefreshAll()
    QA:RefreshWarnings()
    QA:RefreshMissing()
    QA:RefreshAlerts()
    QA:RefreshReminders()
end

-- DEBOUNCE FUNCTIONS

QA.BagsChanged = QA:Debounce(function()
    debug(2, "BAG_UPDATE", bagId)
    QA:ScanBags()
    QA:ScanBank()
    QA:CheckMissingBuffs()
    QA:CheckLowConsumes()
    QA:CheckTransmuteCooldown()
end, 0.5)

QA.ZoneChanged = QA:Debounce(function()
    --debug(2, "Zone Update")
    QA:UpdateZone()
end, 2)

-- Utils

function QA:FindInBags(itemIds, inBank)
    local lookup = inBank and QA.bank or QA.bags
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

function QA:HasSeenAny(ids, seenHash)
    for _, id in ipairs(ids) do
        if seenHash[id] then
            return id, seenHash[id]
        end
    end
end

function QA:GetItemCooldown(itemId)
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown(itemId)
    else
        return GetItemCooldown(itemId)
    end
end
