local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug

local MAX_ROWS = 8
local LIFETIME = 3.4
local FADE_IN = 0.12
local FADE_OUT = 0.8
local SPAWN_INTERVAL = 0.48
local SIDE_OFFSET = 155
local DRIFT_X = 9
local RISE_Y = 48
local START_Y = -45

local loot = {
    queue = {},
    active = {},
    rows = {},
    serial = 0,
    nextAt = 0,
}
QA.floatingLoot = loot

-- Multiple-count formats must be tried before their single-item variants,
-- since "%s" would otherwise swallow the "x%d" suffix.
local LOOT_FORMATS = {
    "LOOT_ITEM_SELF_MULTIPLE",
    "LOOT_ITEM_CREATED_SELF_MULTIPLE",
    "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
    "LOOT_ITEM_SELF",
    "LOOT_ITEM_CREATED_SELF",
    "LOOT_ITEM_PUSHED_SELF",
}
local lootPatterns

-- Turns a localized Blizzard format string into a Lua pattern, e.g.
-- "You receive loot: %sx%d." -> "^You receive loot: (.+)x(%d+)%.$"
local function FormatToPattern(format)
    local pattern = format:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
    return "^"..pattern.."$"
end

local function BuildPatterns()
    lootPatterns = {}
    for _, key in ipairs(LOOT_FORMATS) do
        local format = _G[key]
        if type(format) == "string" then
            table.insert(lootPatterns, FormatToPattern(format))
        end
    end
end

local function ParseLootMessage(message)
    if not lootPatterns then BuildPatterns() end
    for _, pattern in ipairs(lootPatterns) do
        local link, count = message:match(pattern)
        if link and link:find("|Hitem:", 1, true) then
            return link, tonumber(count) or 1
        end
    end
end

local function CreateRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(280, 32)
    row:EnableMouse(false)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetPoint("LEFT")
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    row.text:SetPoint("LEFT", row.icon, "RIGHT", 7, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(false)
    row.text:SetShadowOffset(1, -1)
    row:Hide()
    return row
end

local function ApplyRowSize(row)
    local size = QA.db.profile.floatingLootIconSize
    row.icon:SetSize(size, size)
    row:SetHeight(size + 4)
    row.text:SetWidth(row:GetWidth() - size - 7)
end

local function ShowEntry(row, entry)
    local itemId = tonumber(entry.link:match("item:(%d+)"))
    row.icon:SetTexture(itemId and GetItemIcon(itemId) or "Interface\\Icons\\INV_Misc_QuestionMark")
    row.text:SetText(entry.link..(entry.count > 1 and (" |cffffffffx"..entry.count.."|r") or ""))
    ApplyRowSize(row)
    row:Show()
end

local function Tick()
    local now = GetTime()

    for i = #loot.active, 1, -1 do
        if now - loot.active[i].at >= LIFETIME then
            table.remove(loot.active, i)
        end
    end

    if #loot.queue > 0 and #loot.active < MAX_ROWS and now >= loot.nextAt then
        local entry = table.remove(loot.queue, 1)
        loot.serial = loot.serial + 1
        entry.at = now
        entry.side = loot.serial % 2 == 0 and 1 or -1
        table.insert(loot.active, entry)
        loot.nextAt = now + SPAWN_INTERVAL
    end

    for i, row in ipairs(loot.rows) do
        local entry = loot.active[i]
        if entry then
            if row.entry ~= entry then
                row.entry = entry
                ShowEntry(row, entry)
            end
            local age = now - entry.at
            row:ClearAllPoints()
            row:SetPoint("CENTER", QuickAuras_FloatingLoot, "CENTER", entry.side * (SIDE_OFFSET + age * DRIFT_X), START_Y + age * RISE_Y)
            row:SetAlpha(math.min(1, age / FADE_IN) * math.min(1, (LIFETIME - age) / FADE_OUT))
        else
            row.entry = nil
            row:Hide()
        end
    end

    if #loot.queue == 0 and #loot.active == 0 then
        loot.driver:SetScript("OnUpdate", nil)
    end
end

function QA:InitFloatingLoot()
    for i = 1, MAX_ROWS do
        loot.rows[i] = CreateRow(QuickAuras_FloatingLoot)
    end
    loot.driver = CreateFrame("Frame")
end

function QA:AddFloatingLoot(link, count)
    table.insert(loot.queue, { link = link, count = count or 1 })
    loot.driver:SetScript("OnUpdate", Tick)
end

function QA:OnLootMessage(message)
    if not QA.db.profile.floatingLoot or type(message) ~= "string" then return end
    local link, count = ParseLootMessage(message)
    debug(2, "OnLootMessage", "link", link, "count", count)
    if link then
        QA:AddFloatingLoot(link, count)
    end
end

function QA:ClearFloatingLoot()
    loot.queue = {}
    loot.active = {}
    for _, row in ipairs(loot.rows) do
        row.entry = nil
        row:Hide()
    end
    loot.driver:SetScript("OnUpdate", nil)
end

function QA:TestFloatingLoot()
    -- Hearthstone, Runecloth and Major Healing Potion
    for _, test in ipairs({ { 6948, 1 }, { 14047, 4 }, { 13446, 2 } }) do
        local _, link = GetItemInfo(test[1])
        QA:AddFloatingLoot(link or ("|cffffffff|Hitem:"..test[1].."::::::::60:::::|h[Item "..test[1].."]|h|r"), test[2])
    end
end
