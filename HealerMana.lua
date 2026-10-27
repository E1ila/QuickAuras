local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

local LSM = LibStub("LibSharedMedia-3.0")
local MANA = Enum.PowerType.Mana
local ROW_HEIGHT = 14
local ROW_GAP = 1
local HEADER_HEIGHT = 16
local UPDATE_INTERVAL = 0.5
local IDLE_REFRESH_INTERVAL = 2

local healerClasses = {
    PRIEST = true,
    DRUID = true,
    PALADIN = true,
    SHAMAN = true,
}

local preview = {
    { name = "Priest", class = "PRIEST", pct = 86 },
    { name = "Druid", class = "DRUID", pct = 54 },
    { name = "Paladin", class = "PALADIN", pct = 31 },
    { name = "Shaman", class = "SHAMAN", pct = 12 },
}

QA.healerMana = {
    units = {}, -- tracked unit ids
    tracked = {}, -- unitId -> true
    lastPct = {}, -- guid -> last known mana %, kept for druids in forms
    rows = {},
    dirty = false,
    lastUpdate = 0,
}
local hm = QA.healerMana

local function IsTankOrDps(unit, raidIndex)
    local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned(unit)
    if role == "TANK" or role == "DAMAGER" then return true end
    if raidIndex then
        local _, _, _, _, _, _, _, _, _, raidRole, _, combatRole = GetRaidRosterInfo(raidIndex)
        if raidRole == "MAINTANK" or raidRole == "MAINASSIST" then return true end
        if combatRole == "TANK" or combatRole == "DAMAGER" then return true end
    end
    return false
end

local function ManaColor(pct)
    if pct < 20 then return 1, 0.2, 0.2 end
    if pct < 40 then return 1, 0.6, 0.1 end
    return 0.25, 0.5, 1
end

function QA:IsHealerManaVisible()
    if not QA.db.profile.healerManaEnabled then return false end
    local mode = QA.db.profile.healerManaMode
    if mode == "raid" then return IsInRaid() end
    return IsInGroup()
end

function QA:BuildHealerManaRoster()
    hm.units = {}
    hm.tracked = {}
    local function add(unit, raidIndex)
        if not UnitExists(unit) then return end
        local class = select(2, UnitClass(unit))
        if healerClasses[class] and not IsTankOrDps(unit, raidIndex) then
            table.insert(hm.units, unit)
            hm.tracked[unit] = true
        end
    end
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            add("raid"..i, i)
        end
    elseif IsInGroup() then
        add("player")
        for i = 1, GetNumSubgroupMembers() do
            add("party"..i)
        end
    end
    debug(2, "BuildHealerManaRoster", "healers", #hm.units)
    QA:UpdateHealerMana()
end

function QA:HealerManaPowerChanged(unit, powerType)
    if powerType == "MANA" and hm.tracked[unit] then
        hm.dirty = true
    end
end

-- Called from OnUpdate, throttles redraws caused by frequent power events
function QA:CheckHealerMana(currentTime)
    if not QuickAuras_HealerMana:IsShown() then return end
    local elapsed = currentTime - hm.lastUpdate
    if (hm.dirty and elapsed >= UPDATE_INTERVAL) or elapsed >= IDLE_REFRESH_INTERVAL then
        QA:UpdateHealerMana()
    end
end

local function GetRow(index)
    local row = hm.rows[index]
    if row then return row end
    local parent = QuickAuras_HealerMana
    row = CreateFrame("StatusBar", nil, parent)
    row:SetStatusBarTexture(LSM:Fetch("statusbar", "Minimalist"))
    row:SetMinMaxValues(0, 100)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -(HEADER_HEIGHT + (index - 1) * (ROW_HEIGHT + ROW_GAP)))
    row:SetPoint("RIGHT", parent, "RIGHT", -2, 0)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row)
    row.bg:SetColorTexture(0, 0, 0, 0.5)
    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    row.name:SetPoint("LEFT", row, "LEFT", 4, 0)
    row.value = row:CreateFontString(nil, "OVERLAY")
    row.value:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    row.value:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    hm.rows[index] = row
    return row
end

local function ReadUnit(unit)
    local entry = {
        name = UnitName(unit) or "?",
        class = select(2, UnitClass(unit)),
    }
    if not UnitIsConnected(unit) then
        entry.status = "Offline"
    elseif UnitIsDeadOrGhost(unit) then
        entry.status = "Dead"
    else
        local guid = UnitGUID(unit)
        local max = UnitPowerMax(unit, MANA)
        -- other players' mana isn't reported while a druid is shapeshifted
        if max and max > 0 and (UnitPowerType(unit) == MANA or UnitIsUnit(unit, "player")) then
            entry.pct = math.floor(UnitPower(unit, MANA) / max * 100)
            hm.lastPct[guid] = entry.pct
        else
            entry.pct = hm.lastPct[guid]
            entry.stale = true
        end
    end
    return entry
end

local function SortEntries(a, b)
    if a.pct and b.pct then
        if a.pct ~= b.pct then return a.pct < b.pct end
        return a.name < b.name
    end
    if a.pct or b.pct then return a.pct ~= nil end
    return a.name < b.name
end

function QA:UpdateHealerMana()
    hm.dirty = false
    hm.lastUpdate = GetTime()
    local frame = QuickAuras_HealerMana

    local entries
    if not QA.uiLocked then
        entries = preview
    elseif QA:IsHealerManaVisible() and #hm.units > 0 then
        entries = {}
        for _, unit in ipairs(hm.units) do
            table.insert(entries, ReadUnit(unit))
        end
        table.sort(entries, SortEntries)
    else
        frame:Hide()
        return
    end

    local sum, count = 0, 0
    for i, entry in ipairs(entries) do
        local row = GetRow(i)
        local cc = RAID_CLASS_COLORS[entry.class]
        row.name:SetText(entry.name)
        if cc then row.name:SetTextColor(cc.r, cc.g, cc.b) end
        if entry.status then
            row:SetValue(0)
            row.value:SetText(entry.status)
            row.value:SetTextColor(0.6, 0.6, 0.6)
        elseif entry.pct then
            local r, g, b = ManaColor(entry.pct)
            row:SetStatusBarColor(r, g, b, entry.stale and 0.4 or 0.9)
            row:SetValue(entry.pct)
            row.value:SetText(entry.pct.."%")
            row.value:SetTextColor(1, 1, 1)
            sum = sum + entry.pct
            count = count + 1
        else
            row:SetValue(0)
            row.value:SetText("?")
            row.value:SetTextColor(0.6, 0.6, 0.6)
        end
        row:Show()
    end
    for i = #entries + 1, #hm.rows do
        hm.rows[i]:Hide()
    end

    local avg = count > 0 and math.floor(sum / count) or 0
    local r, g, b = ManaColor(avg)
    QuickAuras_HealerMana_Title:SetText(string.format("Healers |cff%02x%02x%02x%d%%|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), avg))
    frame:SetHeight(HEADER_HEIGHT + #entries * (ROW_HEIGHT + ROW_GAP) + 2)
    frame:Show()
end

function QA:InitHealerMana()
    QuickAuras_HealerMana_Title:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
end
