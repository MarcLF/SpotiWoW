local ADDON_NAME = ...

local WML = LibStub("AceAddon-3.0"):NewAddon("SpotiWoW", "AceConsole-3.0", "AceEvent-3.0")
_G.SpotiWoW = WML
WML.addonName = ADDON_NAME
WML.displayName = "|cff54ff8aS|r|cff45f27fp|r|cff36e874o|r|cff2edf69t|r|cff25d45fi|r|cff1dca56W|r|cff16bd4eo|r|cff0eaa44W|r"
WML.settingsPlaylistId = "__settings"
WML.projectUrl = "https://github.com/MarcLF/SpotiWoW"

local defaults = {
	profile = {
		audioChannel = "Master",
		shuffle = false,
		selectedPlaylistId = "official-kalimdor",
		playlistCounter = 0,
		playlists = {},
		window = {},
		miniWindow = {},
		miniCollapsed = false,
		miniBackgroundOpacity = 1,
		uiScale = 1,
	},
}

function WML:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("SpotiWoWDB", defaults, true)

	self.Library:Initialize()
	self.Player:Initialize()
	self.UI:Initialize()

	self:RegisterChatCommand("spotiwow", "SlashCommand")
	self:RegisterChatCommand("swow", "SlashCommand")
	self:RegisterChatCommand("sminiplayer", "OpenMiniPlayer")
end

function WML:SlashCommand(input)
	input = strtrim(strlower(input or ""))

	if input == "settings" or input == "options" or input == "config" then
		self:OpenOptions()
	elseif input == "mini" or input == "miniplayer" then
		self:OpenMiniPlayer()
	elseif input == "stop" then
		self.Player:Stop()
	else
		self:Toggle()
	end
end

function WML:Toggle()
	if self.UI:IsShown() then
		self.UI:Hide()
	else
		self.UI:Show()
	end
end

function WML:OpenOptions()
	self.db.profile.selectedPlaylistId = self.settingsPlaylistId
	self.UI:Show()
end

function WML:OpenMiniPlayer()
	self.UI:ShowMiniPlayer()
end

function WML:OpenProjectPage()
	if not StaticPopupDialogs or not StaticPopup_Show then
		self:Print(self.projectUrl)
		return
	end

	StaticPopupDialogs.SPOTIWOW_PROJECT_URL = StaticPopupDialogs.SPOTIWOW_PROJECT_URL or {
		text = "Feedback or bugs:",
		button1 = OKAY,
		hasEditBox = 1,
		editBoxWidth = 320,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		OnShow = function(dialog)
			local editBox = dialog.editBox or (dialog.GetEditBox and dialog:GetEditBox())
			if editBox then
				editBox:SetText(WML.projectUrl)
				editBox:HighlightText()
				editBox:SetFocus()
			end
		end,
	}

	StaticPopup_Show("SPOTIWOW_PROJECT_URL")
end

function SpotiWoW_OnAddonCompartmentClick(_, buttonName)
	if buttonName == "RightButton" then
		WML:OpenOptions()
	else
		WML:Toggle()
	end
end

function SpotiWoW_OnAddonCompartmentEnter(_, button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(WML.displayName or "SpotiWoW")
	GameTooltip:AddLine("Left click: toggle")
	GameTooltip:AddLine("Right click: settings")
	GameTooltip:Show()
end

function SpotiWoW_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end

function WML:NotifyChanged()
	if self.UI and self.UI.Refresh then
		self.UI:Refresh()
	end
end
