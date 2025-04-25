
-- Question dialog

function MeleeUtils:AskQuestion(titleText, questionText, onYes, onNo, yesText, noText)
    MeleeUtils_QuestionDialog_Yes:SetScript("OnClick", function()
        MeleeUtils_QuestionDialog:Hide()
        onYes()
    end)
    MeleeUtils_QuestionDialog_No:SetScript("OnClick", function()
        MeleeUtils_QuestionDialog:Hide()
        if onNo then
            onNo()
        end
    end)
    MeleeUtils_QuestionDialog_Title_Text:SetText(titleText)
    MeleeUtils_QuestionDialog_Question:SetText(questionText)
    MeleeUtils_QuestionDialog_Yes:SetText(yesText or L["Yes"])
    MeleeUtils_QuestionDialog_No:SetText(noText or L["No"])
    MeleeUtils_QuestionDialog:Show()
end
