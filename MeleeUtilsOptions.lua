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

------------------------------------------------
-- Build Options UI
------------------------------------------------

local InterfacePanel = CreatePanelFrame("MeleeUtilsInterfacePanel", "MeleeUtils")
local category = Settings.RegisterCanvasLayoutCategory(InterfacePanel, "MeleeUtils")
MeleeUtils.InterfacePanel = InterfacePanel
MeleeUtils.InterfacePanel.category = Settings.RegisterAddOnCategory(category)

local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
local L = MeleeUtils.L
local font = SharedMedia.MediaTable.font[SharedMedia.DefaultMedia.font]

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

function InterfacePanel:InitWindow()
	self:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	self:SetBackdropColor(0.06, 0.06, 0.06, .7)

	self.Label:SetFont(font, 20)
	self.Label:SetPoint("TOPLEFT", self, "TOPLEFT", 16+6, -16-4)

	self.Version = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	self.Version:SetPoint("TOPRIGHT", self, "TOPRIGHT", -20, -26)
	self.Version:SetHeight(15)
	self.Version:SetWidth(350)
	self.Version:SetJustifyH("RIGHT")
	self.Version:SetJustifyV("TOP")
	self.Version:SetText(MeleeUtils.Version)
	self.Version:SetFont(font, 12)

	self.DividerLine = self:CreateTexture(nil, 'ARTWORK')
	self.DividerLine:SetTexture("Interface\\Addons\\MeleeUtils\\assets\\ThinBlackLine")
	self.DividerLine:SetSize(500, 12)
	self.DividerLine:SetPoint("TOPLEFT", self.Label, "BOTTOMLEFT", -6, -8)

	-- Main Scrolled Frame
	------------------------------
	self.MainFrame = CreateFrame("Frame")
	self.MainFrame:SetWidth(500)
	self.MainFrame:SetHeight(100) 		-- If the items inside the frame overflow, it automatically adjusts the height.

	-- Scrollable Panel Window
	------------------------------
	self.ScrollFrame = CreateFrame("ScrollFrame","MeleeUtils_Scrollframe", self, "UIPanelScrollFrameTemplate")
	self.ScrollFrame:EnableMouse(true)
	self.ScrollFrame:EnableMouseWheel(true)
	self.ScrollFrame:SetPoint("LEFT", 8)
	self.ScrollFrame:SetPoint("TOP", self.DividerLine, "BOTTOM", 0, -8)
	self.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 8)
	self.ScrollFrame:SetScrollChild(self.MainFrame)
	-- self.ScrollFrame:SetScript("OnMouseWheel", OnMouseWheelScrollFrame)

	-- Scroll Frame Border
	------------------------------
	self.ScrollFrameBorder = CreateFrame("Frame", "MeleeUtilsScrollFrameBorder", self.ScrollFrame, "BackdropTemplate")
	self.ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	self.ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	self.ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												--tile = true, tileSize = 16,
												edgeSize = 16,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	self.ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	self.ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 0)
end

function InterfacePanel:BuildOptions()
	local mfpanel = self.MainFrame

	mfpanel.TopHelp = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.TopHelp:SetFont(font, 12)
	mfpanel.TopHelp:SetText(L["options-help-sessions"])
	mfpanel.TopHelp:SetPoint("TOPLEFT", 25, 0)
	mfpanel.TopHelp:SetPoint("RIGHT", -20, 0)
	mfpanel.TopHelp:SetJustifyH("LEFT")
	mfpanel.TopHelp:SetJustifyV("TOP")
	mfpanel.TopHelp:SetTextColor(1, 1, 1, 1)

	----------------------------------------------
	-- General
	----------------------------------------------
	mfpanel.GeneralCategoryTitle = mfpanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mfpanel.GeneralCategoryTitle:SetFont(font, 16)
	mfpanel.GeneralCategoryTitle:SetText(L["General"])
	mfpanel.GeneralCategoryTitle:SetPoint("TOPLEFT", mfpanel.TopHelp, "BOTTOMLEFT", 0, -20)

	mfpanel.AutoSwitchInstances = CreateCheckButton("MeleeUtilsOptions_AutoSwitchInstances", mfpanel, L["autoSwitchInstances"])
	mfpanel.AutoSwitchInstances:SetPoint("TOPLEFT", mfpanel.GeneralCategoryTitle, "BOTTOMLEFT", 0, -8)
	mfpanel.AutoSwitchInstances:SetScript("OnClick", function(self) MeleeUtilsGlobalVars.autoSwitchInstances = self:GetChecked() end)
	mfpanel.AutoSwitchInstances.tooltipText = L["autoSwitchInstances-tooltip"]
end


----------------------------------------------
-- Init
----------------------------------------------

function InterfacePanel:AddonLoaded()
	--InterfacePanel.MainFrame.AutoSwitchInstances:SetChecked(MeleeUtilsGlobalVars.autoSwitchInstances)
	--InterfacePanel.MainFrame.ResumeSessionOnSwitch:SetChecked(MeleeUtilsGlobalVars.resumeSessionOnSwitch)
	--
	--UIDropDownMenu_SetText(InterfacePanel.MainFrame.AHMinQualityDropdown, L["ah-quality-"..MeleeUtilsGlobalVars.ahMinQuality])
	--UIDropDownMenu_SetText(InterfacePanel.MainFrame.TSMPriceSourceDropdown, TSM_PRICE_SOURCES["tsm-price-source-"..MeleeUtilsGlobalVars.tsmPriceSource])
end

InterfacePanel:InitWindow()
InterfacePanel:BuildOptions()
