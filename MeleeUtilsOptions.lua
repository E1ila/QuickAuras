local InterfacePanel = CreatePanelFrame("MeleeUtilsInterfacePanel", "MeleeUtils")
local category = Settings.RegisterCanvasLayoutCategory(InterfacePanel, "MeleeUtils")
Settings.RegisterAddOnCategory(category)
MeleeUtils.InterfacePanel = InterfacePanel

local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
local panel = InterfacePanel
local L = MeleeUtils.L
local font = SharedMedia.MediaTable.font[SharedMedia.DefaultMedia.font]

local function CreatePanelFrame(reference, title)
	local panelframe = CreateFrame( "Frame", reference, UIParent, "BackdropTemplate");
	panelframe.name = title
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title)
	return panelframe
end

local function CreateHelpFrame(reference, text)
	local helpframe = CreateFrame( "Frame", reference, UIParent);
	helpframe.name = reference
	helpframe.Label = helpframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	helpframe.Label:SetPoint("TOPLEFT", helpframe, "TOPLEFT", 16, -16)
	helpframe.Label:SetPoint("RIGHT", helpframe, "RIGHT", -16, 16)
	helpframe.Label:SetJustifyH("LEFT")
	helpframe.Label:SetJustifyV("TOP")
	helpframe.Label:SetText(text)
	return helpframe
end

local function CreateCheckButton(reference, parent, label)
	local checkbutton = CreateFrame("CheckButton", reference, parent, "MeleeUtilsCheckButtonTemplate")
	checkbutton.Label = _G[reference.."Text"]
	checkbutton.Label:SetText(label)
	return checkbutton
end

local function SetTrackFlag(flag, state, recalc)
	MeleeUtilsGlobalVars.track[flag] = state
	if recalc then
		MeleeUtils_MainWindow:RecalcTotals()
	end
	MeleeUtils_MainWindow:Refresh()
end

local function InitWindow()
	panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	panel:SetBackdropColor(0.06, 0.06, 0.06, .7)

	panel.Label:SetFont(font, 20)
	panel.Label:SetPoint("TOPLEFT", panel, "TOPLEFT", 16+6, -16-4)

	panel.Version = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panel.Version:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -26)
	panel.Version:SetHeight(15)
	panel.Version:SetWidth(350)
	panel.Version:SetJustifyH("RIGHT")
	panel.Version:SetJustifyV("TOP")
	panel.Version:SetText(MeleeUtils.Version)
	panel.Version:SetFont(font, 12)

	panel.DividerLine = panel:CreateTexture(nil, 'ARTWORK')
	panel.DividerLine:SetTexture("Interface\\Addons\\MeleeUtils\\assets\\ThinBlackLine")
	panel.DividerLine:SetSize(500, 12)
	panel.DividerLine:SetPoint("TOPLEFT", panel.Label, "BOTTOMLEFT", -6, -8)

	-- Main Scrolled Frame
	------------------------------
	panel.MainFrame = CreateFrame("Frame")
	panel.MainFrame:SetWidth(500)
	panel.MainFrame:SetHeight(100) 		-- If the items inside the frame overflow, it automatically adjusts the height.

	-- Scrollable Panel Window
	------------------------------
	panel.ScrollFrame = CreateFrame("ScrollFrame","MeleeUtils_Scrollframe", panel, "UIPanelScrollFrameTemplate")
	panel.ScrollFrame:EnableMouse(true)
	panel.ScrollFrame:EnableMouseWheel(true)
	panel.ScrollFrame:SetPoint("LEFT", 8)
	panel.ScrollFrame:SetPoint("TOP", panel.DividerLine, "BOTTOM", 0, -8)
	panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 8)
	panel.ScrollFrame:SetScrollChild(panel.MainFrame)
	-- panel.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

	-- Scroll Frame Border
	------------------------------
	panel.ScrollFrameBorder = CreateFrame("Frame", "MeleeUtilsScrollFrameBorder", panel.ScrollFrame, "BackdropTemplate")
	panel.ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	panel.ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	panel.ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
										 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		--tile = true, tileSize = 16,
										 edgeSize = 16,
										 insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	panel.ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	panel.ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 0)
end

local function BuildGeneralSection(mfpanel)
	mfpanel.GeneralCategoryTitle = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.GeneralCategoryTitle:SetFont(font, 16)
	mfpanel.GeneralCategoryTitle:SetText(L["General"])
	mfpanel.GeneralCategoryTitle:SetPoint("TOPLEFT", mfpanel.TopHelp, "BOTTOMLEFT", 0, -20)

	mfpanel.AutoSwitchInstances = CreateCheckButton("MeleeUtilsOptions_AutoSwitchInstances", mfpanel, L["autoSwitchInstances"])
	mfpanel.AutoSwitchInstances:SetPoint("TOPLEFT", mfpanel.GeneralCategoryTitle, "BOTTOMLEFT", 0, -8)
	mfpanel.AutoSwitchInstances:SetScript("OnClick", function(self) MeleeUtilsGlobalVars.autoSwitchInstances = self:GetChecked() end)
	mfpanel.AutoSwitchInstances.tooltipText = L["autoSwitchInstances-tooltip"]
end

local function BuildPricesSection(mfpanel)
	mfpanel.PricesCategoryTitle = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.PricesCategoryTitle:SetFont(font, 16)
	mfpanel.PricesCategoryTitle:SetText(L["Prices"])
	mfpanel.PricesCategoryTitle:SetPoint("TOPLEFT", mfpanel.ShowBlackLotusTimer, "BOTTOMLEFT", 0, -20)

	mfpanel.AHMinQuality = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.AHMinQuality:SetPoint("TOPLEFT", mfpanel.PricesCategoryTitle, "BOTTOMLEFT", 0, -12)
	mfpanel.AHMinQuality:SetWidth(170)
	mfpanel.AHMinQuality:SetJustifyH("LEFT")
	mfpanel.AHMinQuality:SetText(L["AH Min Quality"])

	local function AHMinQualityDropdown_OnClick(self)
		for i = 0,4 do
			if L["ah-quality-"..i] == self.value then
				MeleeUtilsGlobalVars.ahMinQuality = i
				UIDropDownMenu_SetText(mfpanel.AHMinQualityDropdown, L["ah-quality-"..i])
				MeleeUtils_MainWindow:RecalcTotals()
				MeleeUtils_MainWindow:Refresh()
				break
			end
		end
	end
	mfpanel.AHMinQualityDropdown = CreateFrame("Frame", "MeleeUtilsAHMinQualityDropdown", mfpanel, "UIDropDownMenuTemplate")
	mfpanel.AHMinQualityDropdown:SetPoint("TOPLEFT", mfpanel.AHMinQuality, "BOTTOMLEFT", -20, -2)
	UIDropDownMenu_SetWidth(mfpanel.AHMinQualityDropdown, 200)
	UIDropDownMenu_Initialize(mfpanel.AHMinQualityDropdown, function (frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = AHMinQualityDropdown_OnClick
		for i = 0,4 do
			info.text, info.checked = L["ah-quality-"..i], i == MeleeUtilsGlobalVars.ahMinQuality
			UIDropDownMenu_AddButton(info)
		end
	end)

	mfpanel.TSMPriceSource = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.TSMPriceSource:SetPoint("TOPLEFT", mfpanel.AHMinQuality, "BOTTOMLEFT", 0, -40)
	mfpanel.TSMPriceSource:SetWidth(170)
	mfpanel.TSMPriceSource:SetJustifyH("LEFT")
	mfpanel.TSMPriceSource:SetText(L["TSM Price Source"])

	local function TSMPriceSourceDropdown_OnClick(self)
		for i = 0,5 do
			if TSM_PRICE_SOURCES["tsm-price-source-"..i] == self.value then
				MeleeUtilsGlobalVars.tsmPriceSource = i
				UIDropDownMenu_SetText(mfpanel.TSMPriceSourceDropdown, TSM_PRICE_SOURCES["tsm-price-source-"..i])
				MeleeUtils_MainWindow:RecalcTotals()
				MeleeUtils_MainWindow:Refresh()
				break
			end
		end
	end
	mfpanel.TSMPriceSourceDropdown = CreateFrame("Frame", "MeleeUtilsTSMPriceSourceDropdown", mfpanel, "UIDropDownMenuTemplate")
	mfpanel.TSMPriceSourceDropdown:SetPoint("TOPLEFT", mfpanel.TSMPriceSource, "BOTTOMLEFT", -20, -2)
	UIDropDownMenu_SetWidth(mfpanel.TSMPriceSourceDropdown, 200)
	UIDropDownMenu_Initialize(mfpanel.TSMPriceSourceDropdown, function (frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = TSMPriceSourceDropdown_OnClick
		for i = 0,5 do
			info.text, info.checked = TSM_PRICE_SOURCES["tsm-price-source-"..i], i == MeleeUtilsGlobalVars.tsmPriceSource
			UIDropDownMenu_AddButton(info)
		end
	end)
end

local function BuildTrackingSection(mfpanel)
	mfpanel.TrackingCategoryTitle = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.TrackingCategoryTitle:SetFont(font, 16)
	mfpanel.TrackingCategoryTitle:SetText(L["Tracking"])
	mfpanel.TrackingCategoryTitle:SetPoint("TOPLEFT", mfpanel.TSMPriceSourceDropdown, "BOTTOMLEFT", 20, -20)

	mfpanel.TrackKills = CreateCheckButton("MeleeUtilsOptions_TrackKills", mfpanel, L["Mobs Kill Count"])
	mfpanel.TrackKills:SetPoint("TOPLEFT", mfpanel.TrackingCategoryTitle, "BOTTOMLEFT", 0, -8)
	mfpanel.TrackKills:SetScript("OnClick", function(self)
		SetTrackFlag("kills", self:GetChecked())
		if not self:GetChecked() then
			SetTrackFlag("drops", false)
			mfpanel.TrackLoot:SetChecked(false)
		end
		mfpanel.TrackLoot:SetEnabled(self:GetChecked())
	end)

	mfpanel.TrackLoot = CreateCheckButton("MeleeUtilsOptions_TrackLoot", mfpanel, L["Received Loot"])
	mfpanel.TrackLoot:SetPoint("TOPLEFT", mfpanel.TrackKills, "TOPLEFT", 0, -25)
	mfpanel.TrackLoot:SetScript("OnClick", function(self) SetTrackFlag("drops", self:GetChecked()) end)
end

local function InitMainPanel()
	local mfpanel = panel.MainFrame
	mfpanel.TopHelp = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.TopHelp:SetFont(font, 12)
	mfpanel.TopHelp:SetText(L["options-help-sessions"])
	mfpanel.TopHelp:SetPoint("TOPLEFT", 25, 0)
	mfpanel.TopHelp:SetPoint("RIGHT", -20, 0)
	mfpanel.TopHelp:SetJustifyH("LEFT")
	mfpanel.TopHelp:SetJustifyV("TOP")
	mfpanel.TopHelp:SetTextColor(1, 1, 1, 1)

	BuildGeneralSection(mfpanel)
	BuildPricesSection(mfpanel)
	BuildTrackingSection(mfpanel)
end

InitWindow()
InitMainPanel()

function InterfacePanel:LoadConfig()
	--InterfacePanel.MainFrame.AutoSwitchInstances:SetChecked(MeleeUtilsGlobalVars.autoSwitchInstances)

	--UIDropDownMenu_SetText(InterfacePanel.MainFrame.AHMinQualityDropdown, L["ah-quality-"..MeleeUtilsGlobalVars.ahMinQuality])
	--UIDropDownMenu_SetText(InterfacePanel.MainFrame.TSMPriceSourceDropdown, TSM_PRICE_SOURCES["tsm-price-source-"..MeleeUtilsGlobalVars.tsmPriceSource])
end 
