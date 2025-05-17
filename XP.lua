local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug

QA.xp = {}
local aura_env = QA.xp
aura_env.timerHandler = aura_env.timerHandler or nil

aura_env.GetSavedVars = function()
    local WAS = aura_env.saved or {}
    aura_env.saved = WAS

    WAS.session = WAS.session or {}

    WAS.session.gainedXP = WAS.session.gainedXP or 0
    WAS.session.lastXP = WAS.session.lastXP or UnitXP("player")
    WAS.session.maxXP = WAS.session.maxXP or UnitXPMax("player")
    WAS.session.startTime = WAS.session.startTime or time()
    WAS.session.realTotalTime = WAS.session.realTotalTime or 0
    WAS.session.realLevelTime = WAS.session.realLevelTime or 0
    WAS.session.lastTimePlayedRequest = WAS.session.lastTimePlayedRequest or 0

    return WAS
end

aura_env.GetMaxLevel = function(exp)
    exp = exp or GetExpansionLevel()

    return min(GetMaxPlayerLevel(), GetMaxLevelForExpansionLevel(exp))
end

aura_env.level = UnitLevel("player")
aura_env.isPlayerMaxLevel = aura_env.level >= aura_env.GetMaxLevel()

if not IsXPUserDisabled then
    IsXPUserDisabled = function() return false end
end

local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries
local GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex or function(i)
    return select(8, GetQuestLogTitle(i))
end
local SelectQuestLogEntry = SelectQuestLogEntry or function() end
local IsQuestComplete = C_QuestLog.IsComplete or IsQuestComplete
local QuestReadyForTurnIn = C_QuestLog.ReadyForTurnIn or function(questID) return false end

aura_env.UpdateQuestXP = function()
    local numQ = GetNumQuestLogEntries()
    local questXP = 0
    local completeXP = 0
    local incompleteXP = 0
    local questID, rewardXP
    local selQ = 0
    local GetQuestLogRewardXP = GetQuestLogRewardXP or function(questID)
        return 0
    end

    if GetQuestLogSelection then
        selQ = GetQuestLogSelection()
    end

    for i = 1, numQ do
        SelectQuestLogEntry(i)
        questID = GetQuestIDForLogIndex(i)

        if questID > 0 then
            rewardXP = GetQuestLogRewardXP(questID) or 0

            if rewardXP > 0 then
                questXP = questXP + rewardXP

                if IsQuestComplete(questID) or QuestReadyForTurnIn(questID) then
                    completeXP = completeXP + rewardXP
                else
                    incompleteXP = incompleteXP + rewardXP
                end
            end
        end
    end

    aura_env.questXP = questXP
    aura_env.completeXP = completeXP
    aura_env.incompleteXP = incompleteXP

    if selQ > 0 then
        SelectQuestLogEntry(selQ)
        StaticPopup_Hide("ABANDON_QUEST")
        StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")

        if QuestLogControlPanel_UpdateState then
            local SetAbandonQuest = SetAbandonQuest or function() end

            QuestLogControlPanel_UpdateState()
            SetAbandonQuest()
        end
    end
end

aura_env.UpdateQuestXP()

aura_env.round = function(num, decimals)
    local mult = 10^(decimals or 0)

    return Round(num * mult) / mult
end

aura_env.FormatTime = function(time, format)
    if time <= 59 then
        return "< 1m"
    end

    local d, h, m, s = ChatFrame_TimeBreakDown(time)
    local t = format or "%dd %hh %mm" --"%d:%H:%M:%S"


    local pad = function(v)
        return v < 10 and "0" .. v or v
    end

    local subs = {
        ["%%D([Dd]?)"] = d > 0 and (pad(d) .. "%1") or "",
        ["%%d([Dd]?)"] = d > 0 and (d .. "%1") or "",
        ["%%H([Hh]?)"] = (d > 0 or h > 0) and (pad(h) .. "%1") or "",
        ["%%h([Hh]?)"] = (d > 0 or h > 0) and (h .. "%1") or "",
        ["%%M([Mm]?)"] = pad(m) .. "%1",
        ["%%m([Mm]?)"] = m .. "%1",
        ["%%S([Ss]?)"] = pad(s) .. "%1",
        ["%%s([Ss]?)"] = s .. "%1",
    }

    for k,v in pairs(subs) do
        t = t:gsub(k, v)
    end

    -- Remove trailing spaces/zeroes/symbols
    return strtrim(t:gsub("^%s*0*", ""):gsub("^%s*[DdHhMm]", ""), " :/-|")
end

aura_env.tickerRTP = aura_env.tickerRTP or nil
aura_env.requestingTimePlayed = false

aura_env.ClearTickerRTP = function()
    if aura_env.tickerRTP then
        aura_env.tickerRTP:Cancel()
        aura_env.tickerRTP = nil
    end

    aura_env.requestingTimePlayed = false
end

aura_env.RequestTimePlayed = function()
    if not aura_env.requestingTimePlayed then
        aura_env.ClearTickerRTP()

        aura_env.requestingTimePlayed = true

        aura_env.tickerRTP = C_Timer.NewTimer(0.5, function() RequestTimePlayed() end)
    end
end

aura_env.customTexts = {
    c1 = "Level " .. aura_env.level,
    c2 = "0 / 0 (0)",
    c3 = "0%",
    c4 = "",
    c5 = "",
    c6 = "",
    c7 = "",
}

aura_env.UpdateCustomTexts = function(state)
    local c1, c2, c3, c4, c5, c6, c7
    local s = state or aura_env.state
    local cfg = aura_env.config or {
        ["showxphour-text"] = true,
        ["questrested-text"] = true,
        ["leveltime-text"] = true,
    }
    local round = aura_env.round
    local isMaxLevel = aura_env.isPlayerMaxLevel

    c1 = "Level " .. (s.level or UnitLevel("player"))

    if isMaxLevel then
        c2 = "Max Level"
    else
        c2 = string.format("%s / %s (%s)", FormatLargeNumber(s.currentXP or 0), FormatLargeNumber(s.totalXP or 0), FormatLargeNumber(s.remainingXP or 0))
    end

    c3 = string.format("%s%%" .. ((s.percentcomplete or 0) > 0 and " (%s%%)" or ""), round(s.percentXP or 0, 1), round(s.totalpercentcomplete or 0, 1))

    if not isMaxLevel then
        if cfg["showxphour-text"] then
            local hourlyXP = s.hourlyXP or 0

            c4 = string.format("Leveling in: %s (%s%s XP/Hour)", s.timeToLevelText or "", hourlyXP > 10000 and round(hourlyXP / 1000, 1) or FormatLargeNumber(hourlyXP), hourlyXP > 10000 and "K" or "")
        end

        if cfg["questrested-text"] then
            c5 = string.format("Completed: |cFFFF9700%s%%|r - Rested: |cFF4F90FF%s%%|r", round(s.percentcomplete or 0, 1), round(s.percentrested or 0, 1))
        end
    end

    if cfg["leveltime-text"] then
        if isMaxLevel then
            c6 = "Time played: " .. (s.totalTimeText or "")
        else
            c6 = "Time this level: " .. (s.levelTimeText or "")
        end
    end

    if cfg["sessiontime-text"] then
        c7 = "Time this session: " .. (s.sessionTimeText or "")
    end

    aura_env.customTexts = {
        c1 = c1,
        c2 = c2,
        c3 = c3,
        c4 = c4,
        c5 = c5,
        c6 = c6,
        c7 = c7,
    }
end
