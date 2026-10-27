local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

local LSM = LibStub("LibSharedMedia-3.0")
local HEIGHT = 14
local FAIL_DISPLAY_TIME = 0.5
-- an estimate is dropped if no result event arrives this long after it should have ended
local ESTIMATE_GRACE = 0.5

local colors = {
    cast = { 1, 0.7, 0 },
    channel = { 0.3, 0.8, 0.3 },
    estimated = { 1, 0.45, 0.1 },
    failed = { 1, 0.15, 0.15 },
}

local noEstimateSpells = {
    [75] = true, -- Auto Shot
    [5019] = true, -- Shoot (wand)
}

local cb = {
    frame = nil,
    eventFrame = nil,
    state = nil, -- "cast", "channel", "estimated", "failed"
    startTime = 0,
    endTime = 0,
    castGuid = nil,
    spellId = nil,
}
QA.castBar = cb

local function GetCast()
    if UnitCastingInfo then return UnitCastingInfo("player") end
    if CastingInfo then return CastingInfo() end
end

local function GetChannel()
    if UnitChannelInfo then return UnitChannelInfo("player") end
    if ChannelInfo then return ChannelInfo() end
end

local function GetBlizzardCastBar()
    return PlayerCastingBarFrame or CastingBarFrame
end

local function SetColor(state)
    cb.frame.bar:SetStatusBarColor(unpack(colors[state]))
end

local function Stop()
    cb.state = nil
    cb.castGuid = nil
    cb.spellId = nil
    cb.frame:SetScript("OnUpdate", nil)
    if QA.uiLocked then
        cb.frame:Hide()
    end
end

local function OnUpdate()
    local now = GetTime()
    local state = cb.state
    if not state then
        Stop()
        return
    end
    if state == "failed" then
        if now >= cb.endTime then Stop() end
        return
    end
    if state == "estimated" and now >= cb.endTime + ESTIMATE_GRACE then
        Stop()
        return
    end
    local duration = cb.endTime - cb.startTime
    local remaining = math.max(0, cb.endTime - now)
    local progress = duration > 0 and (1 - remaining / duration) or 1
    if state == "channel" then progress = 1 - progress end
    cb.frame.bar:SetValue(progress)
    cb.frame.time:SetText(string.format("%.1f", remaining))
end

local function Show(state, name, icon, startTime, endTime)
    cb.state = state
    cb.startTime = startTime
    cb.endTime = endTime
    SetColor(state)
    cb.frame.icon:SetTexture(icon)
    cb.frame.name:SetText(state == "estimated" and "~ "..(name or "") or name)
    cb.frame:SetScript("OnUpdate", OnUpdate)
    cb.frame:Show()
    OnUpdate()
end

local function ReadCast()
    local name, _, icon, startMS, endMS, _, castGuid, _, spellId = GetCast()
    if name then
        cb.castGuid = castGuid
        cb.spellId = spellId
        Show("cast", name, icon, startMS / 1000, endMS / 1000)
        return true
    end
    local chName, _, chIcon, chStartMS, chEndMS, _, _, chSpellId = GetChannel()
    if chName then
        cb.castGuid = nil
        cb.spellId = chSpellId
        Show("channel", chName, chIcon, chStartMS / 1000, chEndMS / 1000)
        return true
    end
    return false
end

local function Fail(text)
    if not cb.state or cb.state == "failed" then return end
    cb.state = "failed"
    cb.endTime = GetTime() + FAIL_DISPLAY_TIME
    SetColor("failed")
    cb.frame.bar:SetValue(1)
    cb.frame.name:SetText(text)
    cb.frame.time:SetText("")
end

local function IsCurrent(castGuid, spellId)
    if castGuid and cb.castGuid then return castGuid == cb.castGuid end
    return not spellId or not cb.spellId or spellId == cb.spellId
end

-- Some casts (Aimed Shot) aren't reported by the casting APIs; estimate them from the sent event.
-- A reported cast starts a round trip after the sent event, so wait that long before estimating.
local function EstimateCast(castGuid, spellId)
    if not spellId or noEstimateSpells[spellId] or cb.state == "cast" or cb.state == "channel" then return end
    local name, _, icon, castTimeMS = GetSpellInfo(spellId)
    if not castTimeMS or castTimeMS <= 0 then return end
    local sentTime = GetTime()
    local _, _, _, latency = GetNetStats()
    cb.pendingGuid = castGuid
    C_Timer.After(math.min(0.5, (latency or 0) / 1000 + 0.1), function()
        if cb.pendingGuid ~= castGuid then return end
        cb.pendingGuid = nil
        if ReadCast() or cb.state == "cast" or cb.state == "channel" then return end
        debug(2, "CastBar", "estimating", name, "castTime", castTimeMS)
        cb.castGuid = castGuid
        cb.spellId = spellId
        Show("estimated", name, icon, sentTime, sentTime + castTimeMS / 1000)
    end)
end

local function OnEvent(_, event, unit, ...)
    if not QA.db.profile.castBarEnabled or unit ~= "player" then return end
    if event == "UNIT_SPELLCAST_SENT" then
        local _, castGuid, spellId = ...
        EstimateCast(castGuid, spellId)
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"
        or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
    then
        ReadCast()
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        local castGuid, spellId = ...
        if castGuid == cb.pendingGuid then cb.pendingGuid = nil end
        if cb.state and cb.state ~= "channel" and IsCurrent(castGuid, spellId) then
            Fail(event == "UNIT_SPELLCAST_INTERRUPTED" and "Interrupted" or "Failed")
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_STOP" then
        local castGuid, spellId = ...
        if castGuid == cb.pendingGuid then cb.pendingGuid = nil end
        if (cb.state == "cast" or cb.state == "estimated") and IsCurrent(castGuid, spellId) then
            Stop()
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if cb.state == "channel" then Stop() end
    end
end

function QA:UpdateBlizzardCastBar()
    local frame = GetBlizzardCastBar()
    if not frame then return end
    if not cb.hooked then
        frame:HookScript("OnShow", function(self)
            if QA.db.profile.castBarHideBlizzard then self:Hide() end
        end)
        cb.hooked = true
    end
    if QA.db.profile.castBarHideBlizzard then frame:Hide() end
end

function QA:UpdateCastBar()
    if not cb.frame then return end
    if not QA.uiLocked then
        cb.frame:SetScript("OnUpdate", nil)
        cb.state = nil
        SetColor("cast")
        cb.frame.bar:SetValue(0.6)
        cb.frame.icon:SetTexture(GetSpellTexture(QA.spells.hunter.aimedShot.spellId[1]))
        cb.frame.name:SetText("Cast Bar")
        cb.frame.time:SetText("1.2")
        cb.frame:SetShown(QA.db.profile.castBarEnabled)
    elseif not QA.db.profile.castBarEnabled or not cb.state then
        Stop()
        cb.frame:Hide()
    end
end

function QA:InitCastBar()
    local frame = CreateFrame("Frame", "QuickAuras_CastBar", UIParent, "BackdropTemplate")
    frame:SetHeight(HEIGHT)
    frame:SetPoint("TOPLEFT", QuickAuras_SwingTimer, "BOTTOMLEFT", HEIGHT, -2)
    frame:SetPoint("TOPRIGHT", QuickAuras_SwingTimer, "BOTTOMRIGHT", 0, -2)
    QA:SetDarkBackdrop(frame)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(HEIGHT, HEIGHT)
    frame.icon:SetPoint("RIGHT", frame, "LEFT", 0, 0)
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetAllPoints(frame)
    frame.bar:SetStatusBarTexture(LSM:Fetch("statusbar", "Minimalist"))
    frame.bar:SetMinMaxValues(0, 1)

    frame.name = frame.bar:CreateFontString(nil, "OVERLAY")
    frame.name:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    frame.name:SetPoint("LEFT", frame, "LEFT", 3, 0)
    frame.name:SetPoint("RIGHT", frame, "RIGHT", -28, 0)
    frame.name:SetJustifyH("LEFT")
    frame.name:SetWordWrap(false)

    frame.time = frame.bar:CreateFontString(nil, "OVERLAY")
    frame.time:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    frame.time:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

    frame:Hide()
    cb.frame = frame

    cb.eventFrame = CreateFrame("Frame")
    for _, event in ipairs({
        "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_DELAYED",
        "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_CHANNEL_STOP",
    }) do
        cb.eventFrame:RegisterUnitEvent(event, "player")
    end
    cb.eventFrame:SetScript("OnEvent", OnEvent)

    QA:UpdateBlizzardCastBar()
end
