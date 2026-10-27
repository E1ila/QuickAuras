local ADDON_NAME, addon = ...
local QA = addon.root
local debug = QA.Debug
local out = QA.Print
local _c = QA.colors

local SCAN_INTERVAL = 0.2
local MAX_NAMEPLATES = 40
local PENDING_TIMEOUT = 1.5

QA.raidMarks = {
    star = 1,
    circle = 2,
    diamond = 3,
    triangle = 4,
    moon = 5,
    square = 6,
    cross = 7,
    x = 7,
    skull = 8,
}

QA.markPresets = {
    naxx = {
        name = "Naxxramas",
        rules = [[
# Naxxramas trash
Living Monstrosity: skull
Necro Knight: skull, cross
Deathknight Captain: skull, cross
Death Lord: skull
Tomb Horror: skull
Venom Stalker: skull, cross
Necro Stalker: skull, cross
Shade of Naxxramas: skull, cross
Stoneskin Gargoyle: skull, cross
Plagued Gargoyle: skull, cross, square
Deathknight Cavalier: skull, cross
Deathknight Vindicator: skull, cross
Unholy Axe: skull, cross
Unholy Staff: skull, cross
Unholy Swords: skull, cross
Patchwork Golem: skull, cross, square, moon
Bile Retcher: skull, cross
Sludge Belcher: skull, cross
Stitched Spewer: skull, cross
Plague Beast: skull, cross
Infectious Ghoul: skull, cross, square
Dread Creeper: skull, cross, square, moon
Carrion Spinner: skull, cross, square, moon
Naxxramas Acolyte: skull, cross, square, moon, triangle
Naxxramas Cultist: skull, cross, square
Necropolis Acolyte: skull, cross
Skeletal Smith: square, moon
# Boss adds
Crypt Guard: skull, cross
Naxxramas Follower: skull, cross
Naxxramas Worshipper: square, moon, triangle, diamond
Deathknight Understudy: skull, cross, square, moon
]],
    },
    aq40 = {
        name = "Ahn'Qiraj",
        rules = [[
# Temple of Ahn'Qiraj trash
Qiraji Mindslayer: skull, cross, square, moon
Qiraji Slayer: skull, cross, square, moon
Qiraji Brainwasher: skull
Qiraji Champion: skull, cross
Anubisath Sentinel: skull, cross, square, moon, triangle
Anubisath Defender: skull
Anubisath Warder: skull
Obsidian Eradicator: skull, cross, square
Obsidian Nullifier: skull, cross
Qiraji Lasher: skull, cross, square
Vekniss Guardian: skull, cross, square
Vekniss Warrior: skull, cross, square
Vekniss Hive Crawler: skull, cross
# Boss adds
Sartura's Royal Guard: skull, cross, square
]],
    },
    bwl = {
        name = "Blackwing Lair",
        rules = [[
# Blackwing Lair trash
Death Talon Captain: skull
Death Talon Wyrmguard: skull, cross, square
Death Talon Overseer: skull, cross
Death Talon Flamescale: skull, cross
Death Talon Seether: skull, cross
Blackwing Spellbinder: skull, cross
Blackwing Warlock: skull, cross
Blackwing Taskmaster: skull, cross
Blackwing Technician: skull, cross, square, moon
Chromatic Elite Guard: skull, cross, square
Death Talon Dragonspawn: skull, cross
]],
    },
    mc = {
        name = "Molten Core",
        rules = [[
# Molten Core trash
Molten Destroyer: skull, cross
Molten Giant: skull, cross
Lava Annihilator: skull, cross
Ancient Core Hound: skull, cross
Firelord: skull, cross
Lava Surger: skull, cross
Core Hound: square, moon, triangle, diamond, circle
# Boss adds
Flamewaker Protector: skull, cross
Flamewaker Priest: skull, cross, square, moon
Flamewaker Elite: skull, cross, square, moon
Flamewaker Healer: triangle, diamond, circle, star
]],
    },
}

local modifierChecks = {
    shift = IsShiftKeyDown,
    ctrl = IsControlKeyDown,
    alt = IsAltKeyDown,
}

QA.marking = {
    rulesText = nil,
    rules = { byName = {}, byNpcId = {} },
    owner = {}, -- mark index -> guid
    markOf = {}, -- guid -> mark index
    priorityOf = {}, -- guid -> rule priority
    claimedAt = {}, -- guid -> time SetRaidTarget was called
    lastScan = 0,
}
local mk = QA.marking

local function ParseMarks(text)
    local marks = {}
    for token in text:gmatch("[^,%s]+") do
        local mark = QA.raidMarks[token:lower()] or tonumber(token)
        if mark and mark >= 1 and mark <= 8 then
            table.insert(marks, mark)
        end
    end
    return marks
end

-- Each line is "Mob Name or NPC ID: mark, mark, ...". Lines higher up have higher priority.
function QA:ParseMarkRules(text)
    local rules = { byName = {}, byNpcId = {} }
    local priority = 0
    for line in (text or ""):gmatch("[^\r\n]+") do
        local mob, marksText = line:match("^%s*([^#:][^:]-)%s*:%s*(.-)%s*$")
        if mob and mob ~= "" then
            local marks = ParseMarks(marksText)
            if #marks > 0 then
                priority = priority + 1
                local rule = { name = mob, marks = marks, priority = priority }
                local npcId = tonumber(mob)
                if npcId then
                    rules.byNpcId[npcId] = rules.byNpcId[npcId] or rule
                else
                    rules.byName[mob:lower()] = rules.byName[mob:lower()] or rule
                end
            end
        end
    end
    return rules, priority
end

local function GetRules()
    local text = QA.db.profile.markRules or ""
    if mk.rulesText ~= text then
        mk.rulesText = text
        mk.rules = QA:ParseMarkRules(text)
    end
    return mk.rules
end

local function FindRule(unit, guid)
    local rules = GetRules()
    local npcId = QA:GetNpcIdFromGuid(guid)
    local rule = npcId and rules.byNpcId[npcId]
    if rule then return rule end
    local name = UnitName(unit)
    return name and rules.byName[name:lower()]
end

local function Release(guid)
    local mark = mk.markOf[guid]
    if mark and mk.owner[mark] == guid then
        mk.owner[mark] = nil
    end
    mk.markOf[guid] = nil
    mk.priorityOf[guid] = nil
    mk.claimedAt[guid] = nil
end

local function Claim(guid, mark, priority)
    local previous = mk.owner[mark]
    if previous and previous ~= guid then
        Release(previous)
    end
    Release(guid)
    mk.owner[mark] = guid
    mk.markOf[guid] = mark
    mk.priorityOf[guid] = priority
end

local function CanMark()
    if IsInRaid() then
        return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
    end
    return true
end

local function IsMarkable(unit)
    return UnitExists(unit)
        and not UnitIsDead(unit)
        and not UnitPlayerControlled(unit)
        and UnitCanAttack("player", unit)
end

-- Marks seen on visible units that this addon didn't place (manual marks, other addons)
local function CollectForeignMarks(units)
    local foreign = {}
    for _, unit in ipairs(units) do
        local mark = UnitExists(unit) and GetRaidTargetIndex(unit)
        if mark then
            local guid = UnitGUID(unit)
            if mk.owner[mark] ~= guid then
                if mk.markOf[guid] then
                    Release(guid)
                end
                if mk.owner[mark] then
                    Release(mk.owner[mark])
                end
                foreign[mark] = guid
            end
        end
    end
    return foreign
end

local function PickMark(rule, foreign)
    for _, mark in ipairs(rule.marks) do
        if not mk.owner[mark] and not foreign[mark] then
            return mark
        end
    end
    if QA.db.profile.markStealLowerPriority then
        for _, mark in ipairs(rule.marks) do
            local holder = mk.owner[mark]
            if holder and not foreign[mark] and (mk.priorityOf[holder] or 0) > rule.priority then
                return mark
            end
        end
    end
end

local function MarkUnit(unit, foreign)
    if not IsMarkable(unit) then return end
    local guid = UnitGUID(unit)
    local rule = FindRule(unit, guid)
    if not rule then return end

    local current = GetRaidTargetIndex(unit)
    if current then
        if foreign[current] == guid and tContains(rule.marks, current) then
            -- already wearing one of its marks, adopt it
            foreign[current] = nil
            Claim(guid, current, rule.priority)
        end
        return
    end

    if mk.markOf[guid] then
        -- the server hasn't applied our mark yet; after the timeout assume it was removed manually
        if GetTime() - (mk.claimedAt[guid] or 0) < PENDING_TIMEOUT then return end
        Release(guid)
    end

    local mark = PickMark(rule, foreign)
    if mark then
        debug(2, "MarkUnit", UnitName(unit), "mark", mark, "priority", rule.priority)
        Claim(guid, mark, rule.priority)
        mk.claimedAt[guid] = GetTime()
        SetRaidTarget(unit, mark)
    end
end

local function IsModifierDown()
    local check = modifierChecks[QA.db.profile.markModifier]
    return check == nil or check()
end

-- Called from OnUpdate
function QA:CheckMarking(currentTime)
    if not QA.db.profile.markingEnabled then return end
    if currentTime - mk.lastScan < SCAN_INTERVAL then return end
    mk.lastScan = currentTime
    if not IsModifierDown() or not CanMark() then return end

    local units = { "mouseover" }
    if QA.db.profile.markNameplates then
        for i = 1, MAX_NAMEPLATES do
            table.insert(units, "nameplate"..i)
        end
    end
    local foreign = CollectForeignMarks(units)
    for _, unit in ipairs(units) do
        MarkUnit(unit, foreign)
    end
end

function QA:MarkingUnitDied(guid)
    if mk.markOf[guid] then
        Release(guid)
    end
end

function QA:ResetMarking()
    mk.owner = {}
    mk.markOf = {}
    mk.priorityOf = {}
    mk.claimedAt = {}
end

function QA:ClearAllMarks()
    QA:ResetMarking()
    for mark = 8, 1, -1 do
        SetRaidTarget("player", mark)
    end
    SetRaidTarget("player", 0)
    out("Raid marks cleared.")
end

function QA:LoadMarkPreset(key)
    local preset = QA.markPresets[key]
    if not preset then return end
    QA.db.profile.markRules = preset.rules
    QA:ResetMarking()
    out(_c.bold.."Marking|r loaded "..preset.name.." preset.")
    QA:PrintMarkRules()
end

function QA:PrintMarkRules()
    local _, count = QA:ParseMarkRules(QA.db.profile.markRules)
    out(_c.bold.."Marking|r "..count.." mob rule(s) loaded.")
end
