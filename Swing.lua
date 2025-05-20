-- Source: WeakAuras2 https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAuras/GenericTrigger.lua

local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug

QuickAurasTimers = setmetatable({}, { __tostring=function() return ADDON_NAME end})
LibStub("AceTimer-3.0"):Embed(QuickAurasTimers)
local timer = QuickAurasTimers
local maxTimerDuration = 604800; -- A week, in seconds
local maxUpTime = 4294967; -- 2^32 / 1000

function QuickAurasTimers:ScheduleTimerFixed(func, delay, ...)
    if (delay < maxTimerDuration) then
        if delay + GetTime() > maxUpTime then
            out("Can't schedule timer due to a World of Warcraft bug with high computer uptime. (Uptime: "..tostring(GetTime()).."). Please restart your computer.")
            return
        end
        return self:ScheduleTimer(func, delay, ...)
    end
end

local reset_ranged_swing_spells = {}
local reset_swing_spells = {}
local noreset_swing_spells = {}

-- Swing timer support code
do
    local mh = GetInventorySlotInfo("MainHandSlot")
    local oh = GetInventorySlotInfo("SecondaryHandSlot")
    local ranged = QA.IsClassicEra() and GetInventorySlotInfo("RangedSlot")

    local swingTimerFrame;
    local lastSwingMain, lastSwingOff, lastSwingRange;
    local swingDurationMain, swingDurationOff, swingDurationRange, mainSwingOffset;
    local mainTimer, offTimer, rangeTimer;
    local selfGUID;
    local mainSpeed, offSpeed = UnitAttackSpeed("player")
    local casting = false
    local skipNextAttack, skipNextAttackCount
    local isAttacking

    ---@param hand string
    ---@return number duration
    ---@return number expirationTime
    ---@return string? weaponName
    ---@return number? icon
    function QA.GetSwingTimerInfo(hand)
        if(hand == "main") then
            local itemId = GetInventoryItemID("player", mh);
            local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId or 0);
            if(lastSwingMain) then
                return swingDurationMain, lastSwingMain + swingDurationMain - mainSwingOffset, name, icon;
            elseif QA.IsRetail() and lastSwingRange then
                return swingDurationRange, lastSwingRange + swingDurationRange, name, icon;
            else
                return 0, math.huge, name, icon;
            end
        elseif(hand == "off") then
            local itemId = GetInventoryItemID("player", oh);
            local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId or 0);
            if(lastSwingOff) then
                return swingDurationOff, lastSwingOff + swingDurationOff, name, icon;
            else
                return 0, math.huge, name, icon;
            end
        elseif(hand == "ranged") then
            local itemId = GetInventoryItemID("player", ranged);
            local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId or 0);
            if (lastSwingRange) then
                return swingDurationRange, lastSwingRange + swingDurationRange, name, icon;
            else
                return 0, math.huge, name, icon;
            end
        end

        return 0, math.huge
    end

    local function swingTriggerUpdate()
        QA:UpdateSwingTimers()
    end

    local function swingEnd(hand)
        if(hand == "main") then
            lastSwingMain, swingDurationMain, mainSwingOffset = nil, nil, nil;
        elseif(hand == "off") then
            lastSwingOff, swingDurationOff = nil, nil;
        elseif(hand == "ranged") then
            lastSwingRange, swingDurationRange = nil, nil;
        end
        swingTriggerUpdate()
    end

    local function swingStart(hand)
        mainSpeed, offSpeed = UnitAttackSpeed("player")
        offSpeed = offSpeed or 0
        local currentTime = GetTime()
        if hand == "main" then
            lastSwingMain = currentTime
            swingDurationMain = mainSpeed
            mainSwingOffset = 0
            if mainTimer then
                timer:CancelTimer(mainTimer)
            end
            if mainSpeed and mainSpeed > 0 then
                mainTimer = timer:ScheduleTimerFixed(swingEnd, mainSpeed, hand)
            else
                swingEnd(hand)
            end
        elseif hand == "off" then
            lastSwingOff = currentTime
            swingDurationOff = offSpeed
            if offTimer then
                timer:CancelTimer(offTimer)
            end
            if offSpeed and offSpeed > 0 then
                offTimer = timer:ScheduleTimerFixed(swingEnd, offSpeed, hand)
            else
                swingEnd(hand)
            end
        elseif hand == "ranged" then
            local rangeSpeed = UnitRangedDamage("player")
            lastSwingRange = currentTime
            swingDurationRange = rangeSpeed
            if rangeTimer then
                timer:CancelTimer(rangeTimer)
            end
            if rangeSpeed and rangeSpeed > 0 then
                rangeTimer = timer:ScheduleTimerFixed(swingEnd, rangeSpeed, hand)
            else
                swingEnd(hand)
            end
        end
    end

    local function swingTimerCLEUCheck(ts, event, _, sourceGUID, _, _, _, destGUID, _, _, _, ...)
        --Private.StartProfileSystem("generictrigger swing");
        if(sourceGUID == selfGUID) then
            if event == "SPELL_EXTRA_ATTACKS" then
                skipNextAttack = ts
                skipNextAttackCount = select(4, ...)
            elseif(event == "SWING_DAMAGE" or event == "SWING_MISSED") then
                if tonumber(skipNextAttack) and (ts - skipNextAttack) < 0.04 and tonumber(skipNextAttackCount) then
                    if skipNextAttackCount > 0 then
                        skipNextAttackCount = skipNextAttackCount - 1
                        return
                    end
                end
                local isOffHand = select(event == "SWING_DAMAGE" and 10 or 2, ...);
                if not isOffHand then
                    swingStart("main")
                elseif(isOffHand) then
                    swingStart("off")
                end
                swingTriggerUpdate()
            end
        elseif (destGUID == selfGUID and (... == "PARRY" or select(4, ...) == "PARRY")) then
            if (lastSwingMain) then
                local timeLeft = lastSwingMain + swingDurationMain - GetTime() - (mainSwingOffset or 0);
                if (timeLeft > 0.2 * swingDurationMain) then
                    local offset = 0.4 * swingDurationMain
                    if (timeLeft - offset < 0.2 * swingDurationMain) then
                        offset = timeLeft - 0.2 * swingDurationMain
                    end
                    timer:CancelTimer(mainTimer);
                    mainTimer = timer:ScheduleTimerFixed(swingEnd, timeLeft - offset, "main");
                    mainSwingOffset = (mainSwingOffset or 0) + offset
                    swingTriggerUpdate()
                end
            end
        end
        --Private.StopProfileSystem("generictrigger swing");
    end

    local function swingTimerCheck(event, unit, guid, spell)
        if event ~= "PLAYER_EQUIPMENT_CHANGED" and unit and unit ~= "player" then return end
        --Private.StartProfileSystem("generictrigger swing");
        local now = GetTime()
        if event == "UNIT_ATTACK_SPEED" then
            local mainSpeedNew, offSpeedNew = UnitAttackSpeed("player")
            offSpeedNew = offSpeedNew or 0
            if lastSwingMain then
                if mainSpeedNew ~= mainSpeed then
                    timer:CancelTimer(mainTimer)
                    local multiplier = mainSpeedNew / mainSpeed
                    local timeLeft = (lastSwingMain + swingDurationMain - now) * multiplier
                    swingDurationMain = mainSpeedNew
                    mainSwingOffset = (lastSwingMain + swingDurationMain) - (now + timeLeft)
                    mainTimer = timer:ScheduleTimerFixed(swingEnd, timeLeft, "main")
                end
            end
            if lastSwingOff then
                if offSpeedNew ~= offSpeed then
                    timer:CancelTimer(offTimer)
                    local multiplier = offSpeedNew / mainSpeed
                    local timeLeft = (lastSwingOff + swingDurationOff - now) * multiplier
                    swingDurationOff = offSpeedNew
                    offTimer = timer:ScheduleTimerFixed(swingEnd, timeLeft, "off")
                end
            end
            mainSpeed, offSpeed = mainSpeedNew, offSpeedNew
            swingTriggerUpdate()
        elseif casting and (event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED") then
            casting = false
        elseif event == "PLAYER_EQUIPMENT_CHANGED" and isAttacking then
            swingStart("main")
            swingStart("off")
            swingStart("ranged")
            swingTriggerUpdate()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            if reset_swing_spells[spell] or casting then
                if casting then
                    casting = false
                end
                -- check next frame
                swingTimerFrame:SetScript("OnUpdate", function(self)
                    if isAttacking then
                        swingStart("main")
                        swingTriggerUpdate()
                    end
                    self:SetScript("OnUpdate", nil)
                end)
            end
            if reset_ranged_swing_spells[spell] then
                if QA.IsClassicEra() then
                    swingStart("ranged")
                else
                    swingStart("main")
                end
                swingTriggerUpdate()
            end
        elseif event == "UNIT_SPELLCAST_START" then
            if not noreset_swing_spells[spell] then
                -- pause swing timer
                casting = true
                lastSwingMain, swingDurationMain, mainSwingOffset = nil, nil, nil
                lastSwingOff, swingDurationOff = nil, nil
                swingTriggerUpdate()
            end
        elseif event == "PLAYER_ENTER_COMBAT" then
            isAttacking = true
        elseif event == "PLAYER_LEAVE_COMBAT" then
            isAttacking = nil
        end
        --Private.StopProfileSystem("generictrigger swing");
    end

    function QA.InitSwingTimer()
        if not(swingTimerFrame) then
            swingTimerFrame = CreateFrame("Frame");
            swingTimerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
            swingTimerFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
            swingTimerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
            swingTimerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
            swingTimerFrame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
            swingTimerFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
            if QA.IsClassicEra() then
                swingTimerFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
                swingTimerFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
                swingTimerFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
            end
            swingTimerFrame:SetScript("OnEvent",
                    function(_, event, ...)
                        if not QA.db.profile.swingTimersEnabled then return end
                        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                            swingTimerCLEUCheck(CombatLogGetCurrentEventInfo())
                        else
                            swingTimerCheck(event, ...)
                        end
                    end);
            selfGUID = UnitGUID("player");
        end
    end
end
