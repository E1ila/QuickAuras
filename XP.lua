local ADDON_NAME, addon = ...
local QA = addon.root
local out = QA.Print
local debug = QA.Debug

QA.xp = {}
local aura_env = QA.xp

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
