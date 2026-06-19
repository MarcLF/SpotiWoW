local WML = WoWMusicLibrary

local UI = {
	sidebarButtons = {},
	trackRows = {},
}

WML.UI = UI

local colors = {
	bg = { 0.04, 0.04, 0.05, 0.98 },
	panel = { 0.08, 0.08, 0.09, 0.95 },
	row = { 0.12, 0.12, 0.13, 0.95 },
	rowActive = { 0.18, 0.28, 0.20, 0.95 },
	border = { 0.18, 0.18, 0.20, 1 },
	accent = { 0.32, 0.78, 0.45, 1 },
}

local function SetBackdrop(frame, color)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	frame:SetBackdropColor(color[1], color[2], color[3], color[4])
	frame:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], colors.border[4])
end

local function StyleButton(button)
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")
end

local function SaveSize(frame)
	if not WML.db then
		return
	end

	WML.db.profile.window.width = frame:GetWidth()
	WML.db.profile.window.height = frame:GetHeight()
end

function UI:Initialize()
	self:CreateFrame()
	self:Refresh()
end

function UI:CreateFrame()
	local frame = CreateFrame("Frame", "WoWMusicLibraryFrame", UIParent, "BackdropTemplate")
	self.frame = frame

	SetBackdrop(frame, colors.bg)
	frame:SetSize(WML.db.profile.window.width or 860, WML.db.profile.window.height or 560)
	frame:SetPoint("CENTER")
	frame:SetClampedToScreen(true)
	frame:SetResizable(true)
	frame:SetResizeBounds(700, 430, 1100, 800)
	frame:EnableMouse(true)
	frame:Hide()

	local LibWindow = LibStub("LibWindow-1.1", true)
	if LibWindow then
		LibWindow.RegisterConfig(frame, WML.db.profile.window)
		LibWindow.RestorePosition(frame)
		LibWindow.MakeDraggable(frame)
	else
		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", frame.StartMoving)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	end

	frame:SetScript("OnSizeChanged", SaveSize)

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", -4, -4)

	local resizeButton = CreateFrame("Button", nil, frame)
	resizeButton:SetSize(16, 16)
	resizeButton:SetPoint("BOTTOMRIGHT", -5, 5)
	resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	resizeButton:SetScript("OnMouseDown", function()
		frame:StartSizing("BOTTOMRIGHT")
	end)
	resizeButton:SetScript("OnMouseUp", function()
		frame:StopMovingOrSizing()
		SaveSize(frame)
	end)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 18, -16)
	title:SetText("WoW Music Library")

	local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	self.sidebar = sidebar
	SetBackdrop(sidebar, colors.panel)
	sidebar:SetPoint("TOPLEFT", 12, -46)
	sidebar:SetPoint("BOTTOMLEFT", 12, 92)
	sidebar:SetWidth(220)

	local main = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	self.main = main
	SetBackdrop(main, colors.panel)
	main:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
	main:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 92)

	local bottom = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	self.bottom = bottom
	SetBackdrop(bottom, colors.panel)
	bottom:SetPoint("LEFT", 12, 0)
	bottom:SetPoint("RIGHT", -12, 0)
	bottom:SetPoint("BOTTOM", 0, 12)
	bottom:SetHeight(70)

	self:CreateSidebar()
	self:CreateMain()
	self:CreatePlayerBar()
end

function UI:CreateSidebar()
	local header = self.sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	header:SetPoint("TOPLEFT", 12, -12)
	header:SetText("Official Playlists")
	self.officialHeader = header

	local userHeader = self.sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	userHeader:SetText("User Playlists")
	self.userHeader = userHeader

	local newBox = CreateFrame("EditBox", nil, self.sidebar, "InputBoxTemplate")
	self.newBox = newBox
	newBox:SetSize(132, 24)
	newBox:SetAutoFocus(false)
	newBox:SetPoint("BOTTOMLEFT", 12, 46)

	local newButton = CreateFrame("Button", nil, self.sidebar, "UIPanelButtonTemplate")
	StyleButton(newButton)
	newButton:SetSize(54, 24)
	newButton:SetPoint("LEFT", newBox, "RIGHT", 6, 0)
	newButton:SetText("New")
	newButton:SetScript("OnClick", function()
		WML.Library:CreatePlaylist(newBox:GetText())
		newBox:SetText("")
	end)

	local settingsButton = CreateFrame("Button", nil, self.sidebar, "UIPanelButtonTemplate")
	StyleButton(settingsButton)
	settingsButton:SetSize(188, 24)
	settingsButton:SetPoint("BOTTOMLEFT", 12, 14)
	settingsButton:SetText("Settings")
	settingsButton:SetScript("OnClick", function()
		WML:OpenOptions()
	end)
end

function UI:CreateMain()
	local playlistTitle = self.main:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.playlistTitle = playlistTitle
	playlistTitle:SetPoint("TOPLEFT", 14, -14)
	playlistTitle:SetPoint("RIGHT", -14, 0)
	playlistTitle:SetJustifyH("LEFT")

	local search = CreateFrame("EditBox", nil, self.main, "InputBoxTemplate")
	self.searchBox = search
	search:SetSize(220, 24)
	search:SetPoint("TOPLEFT", 14, -44)
	search:SetAutoFocus(false)
	search:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			UI:RefreshTracks()
		end
	end)

	local rename = CreateFrame("EditBox", nil, self.main, "InputBoxTemplate")
	self.renameBox = rename
	rename:SetSize(170, 24)
	rename:SetPoint("LEFT", search, "RIGHT", 14, 0)
	rename:SetAutoFocus(false)

	local renameButton = CreateFrame("Button", nil, self.main, "UIPanelButtonTemplate")
	self.renameButton = renameButton
	StyleButton(renameButton)
	renameButton:SetSize(70, 24)
	renameButton:SetPoint("LEFT", rename, "RIGHT", 6, 0)
	renameButton:SetText("Rename")
	renameButton:SetScript("OnClick", function()
		WML.Library:RenamePlaylist(WML.db.profile.selectedPlaylistId, rename:GetText())
	end)

	local deleteButton = CreateFrame("Button", nil, self.main, "UIPanelButtonTemplate")
	self.deleteButton = deleteButton
	StyleButton(deleteButton)
	deleteButton:SetSize(62, 24)
	deleteButton:SetPoint("LEFT", renameButton, "RIGHT", 6, 0)
	deleteButton:SetText("Delete")
	deleteButton:SetScript("OnClick", function()
		WML.Library:DeletePlaylist(WML.db.profile.selectedPlaylistId)
	end)

	local scroll = CreateFrame("ScrollFrame", nil, self.main, "UIPanelScrollFrameTemplate")
	self.trackScroll = scroll
	scroll:SetPoint("TOPLEFT", 14, -78)
	scroll:SetPoint("BOTTOMRIGHT", -30, 14)

	local content = CreateFrame("Frame", nil, scroll)
	self.trackContent = content
	content:SetSize(1, 1)
	scroll:SetScrollChild(content)
end

function UI:CreatePlayerBar()
	local prev = CreateFrame("Button", nil, self.bottom, "UIPanelButtonTemplate")
	StyleButton(prev)
	prev:SetSize(34, 28)
	prev:SetPoint("LEFT", 14, 0)
	prev:SetText("<<")
	prev:SetScript("OnClick", function()
		WML.Player:Previous()
	end)

	local play = CreateFrame("Button", nil, self.bottom, "UIPanelButtonTemplate")
	self.playButton = play
	StyleButton(play)
	play:SetSize(52, 28)
	play:SetPoint("LEFT", prev, "RIGHT", 6, 0)
	play:SetScript("OnClick", function()
		WML.Player:TogglePlay()
	end)

	local stop = CreateFrame("Button", nil, self.bottom, "UIPanelButtonTemplate")
	StyleButton(stop)
	stop:SetSize(44, 28)
	stop:SetPoint("LEFT", play, "RIGHT", 6, 0)
	stop:SetText("Stop")
	stop:SetScript("OnClick", function()
		WML.Player:Stop()
	end)

	local next = CreateFrame("Button", nil, self.bottom, "UIPanelButtonTemplate")
	StyleButton(next)
	next:SetSize(34, 28)
	next:SetPoint("LEFT", stop, "RIGHT", 6, 0)
	next:SetText(">>")
	next:SetScript("OnClick", function()
		WML.Player:Next()
	end)

	local nowPlaying = self.bottom:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.nowPlaying = nowPlaying
	nowPlaying:SetPoint("LEFT", next, "RIGHT", 14, 0)
	nowPlaying:SetPoint("RIGHT", -18, 0)
	nowPlaying:SetJustifyH("LEFT")

	local progress = CreateFrame("StatusBar", nil, self.bottom)
	self.progress = progress
	progress:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	progress:SetStatusBarColor(colors.accent[1], colors.accent[2], colors.accent[3], 1)
	progress:SetMinMaxValues(0, 1)
	progress:SetValue(0)
	progress:SetPoint("LEFT", nowPlaying, 0, -22)
	progress:SetPoint("RIGHT", nowPlaying, 0, -22)
	progress:SetHeight(4)
end

function UI:IsShown()
	return self.frame and self.frame:IsShown()
end

function UI:Show()
	self.frame:Show()
	self:Refresh()
end

function UI:Hide()
	self.frame:Hide()
end

function UI:ResetPosition()
	wipe(WML.db.profile.window)
	self.frame:ClearAllPoints()
	self.frame:SetSize(860, 560)
	self.frame:SetPoint("CENTER")
	SaveSize(self.frame)
end

function UI:GetSidebarButton(index)
	local button = self.sidebarButtons[index]
	if button then
		return button
	end

	button = CreateFrame("Button", nil, self.sidebar, "BackdropTemplate")
	self.sidebarButtons[index] = button
	SetBackdrop(button, colors.row)
	button:SetHeight(28)
	button:SetPoint("LEFT", 12, 0)
	button:SetPoint("RIGHT", -12, 0)
	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.text:SetPoint("LEFT", 8, 0)
	button.text:SetPoint("RIGHT", -8, 0)
	button.text:SetJustifyH("LEFT")

	return button
end

function UI:RefreshSidebar()
	local selectedPlaylistId = WML.db.profile.selectedPlaylistId
	local y = -36
	local index = 1

	for _, playlist in ipairs(WML.Library:GetOfficialPlaylists()) do
		local playlistId = playlist.id
		local button = self:GetSidebarButton(index)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT", 12, y)
		button:SetPoint("RIGHT", self.sidebar, "RIGHT", -12, 0)
		button.text:SetText(playlist.name)
		SetBackdrop(button, playlistId == selectedPlaylistId and colors.rowActive or colors.row)
		button:SetScript("OnClick", function()
			WML.Library:SelectPlaylist(playlistId)
		end)
		button:Show()
		y = y - 32
		index = index + 1
	end

	self.userHeader:ClearAllPoints()
	self.userHeader:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT", 12, y - 10)
	y = y - 34

	for _, playlist in ipairs(WML.Library:GetUserPlaylists()) do
		local playlistId = playlist.id
		local button = self:GetSidebarButton(index)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT", 12, y)
		button:SetPoint("RIGHT", self.sidebar, "RIGHT", -12, 0)
		button.text:SetText(playlist.name)
		SetBackdrop(button, playlistId == selectedPlaylistId and colors.rowActive or colors.row)
		button:SetScript("OnClick", function()
			WML.Library:SelectPlaylist(playlistId)
		end)
		button:Show()
		y = y - 32
		index = index + 1
	end

	for i = index, #self.sidebarButtons do
		self.sidebarButtons[i]:Hide()
	end
end

function UI:GetTrackRow(index)
	local row = self.trackRows[index]
	if row then
		return row
	end

	row = CreateFrame("Frame", nil, self.trackContent, "BackdropTemplate")
	self.trackRows[index] = row
	SetBackdrop(row, colors.row)
	row:SetHeight(38)

	row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.title:SetPoint("LEFT", 46, 7)
	row.title:SetPoint("RIGHT", -98, 7)
	row.title:SetJustifyH("LEFT")

	row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	row.meta:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)
	row.meta:SetPoint("RIGHT", row.title, "RIGHT", 0, 0)
	row.meta:SetJustifyH("LEFT")

	row.play = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	StyleButton(row.play)
	row.play:SetSize(30, 22)
	row.play:SetPoint("LEFT", 8, 0)
	row.play:SetText(">")

	row.action = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	StyleButton(row.action)
	row.action:SetSize(72, 22)
	row.action:SetPoint("RIGHT", -8, 0)

	return row
end

function UI:AddHeader(rows, text)
	rows[#rows + 1] = { kind = "header", text = text }
end

function UI:AddTrackRows(rows, sourceTracks, action, playlistId)
	for _, track in ipairs(sourceTracks) do
		rows[#rows + 1] = {
			kind = "track",
			track = track,
			action = action,
			playlistId = playlistId,
		}
	end
end

function UI:GetRowsForPlaylist(playlist, isOfficial)
	local rows = {}
	local query = self.searchBox:GetText()

	if isOfficial then
		self:AddTrackRows(rows, WML.Library:FilterTracks(WML.Library:GetPlaylistTracks(playlist.id), query), "add", playlist.id)
		return rows
	end

	local playlistTracks = WML.Library:FilterTracks(WML.Library:GetPlaylistTracks(playlist.id), query)
	if #playlistTracks > 0 then
		self:AddHeader(rows, "Playlist Tracks")
		self:AddTrackRows(rows, playlistTracks, "remove", playlist.id)
	end

	self:AddHeader(rows, "Add Tracks")
	self:AddTrackRows(rows, WML.Library:FilterTracks(WML.Library:GetTracks(), query), "add", playlist.id)

	return rows
end

function UI:RefreshTracks()
	local playlist, isOfficial = WML.Library:GetPlaylist(WML.db.profile.selectedPlaylistId)
	if not playlist then
		WML.Library:EnsureSelectedPlaylist()
		playlist = WML.Library:GetPlaylist(WML.db.profile.selectedPlaylistId)
		isOfficial = true
	end

	self.playlistTitle:SetText(playlist.name)
	self.renameBox:SetShown(not isOfficial)
	self.renameButton:SetShown(not isOfficial)
	self.deleteButton:SetShown(not isOfficial)
	if not isOfficial then
		self.renameBox:SetText(playlist.name)
	end

	local rows = self:GetRowsForPlaylist(playlist, isOfficial)
	local y = 0

	for index, rowData in ipairs(rows) do
		local row = self:GetTrackRow(index)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", self.trackContent, "TOPLEFT", 0, y)
		row:SetPoint("RIGHT", self.trackScroll, "RIGHT", -2, 0)

		if rowData.kind == "header" then
			SetBackdrop(row, colors.panel)
			row:SetHeight(26)
			row.play:Hide()
			row.action:Hide()
			row.title:ClearAllPoints()
			row.title:SetPoint("LEFT", 8, 0)
			row.title:SetPoint("RIGHT", -8, 0)
			row.title:SetText(rowData.text)
			row.meta:ClearAllPoints()
			row.meta:SetText("")
			row:Show()
			y = y - 30
		else
			local track = rowData.track
			local action = rowData.action
			local trackId = track.id
			local playlistId = rowData.playlistId
			local rowIsOfficial = isOfficial
			SetBackdrop(row, track.id == WML.Player.trackId and colors.rowActive or colors.row)
			row:SetHeight(38)
			row.title:ClearAllPoints()
			row.title:SetPoint("LEFT", 46, 7)
			row.title:SetPoint("RIGHT", -98, 7)
			row.title:SetText(track.title)
			row.meta:ClearAllPoints()
			row.meta:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)
			row.meta:SetPoint("RIGHT", row.title, "RIGHT", 0, 0)
			row.meta:SetText(track.artist .. " - " .. track.expansion)
			row.play:Show()
			row.play:SetScript("OnClick", function()
				WML.Player:PlayTrack(trackId, playlistId)
			end)
			row.action:Show()
			if action == "remove" then
				row.action:SetText("Remove")
				row.action:SetScript("OnClick", function()
					WML.Library:RemoveTrackFromPlaylist(playlistId, trackId)
				end)
			else
				row.action:SetText("Add")
				row.action:SetScript("OnClick", function()
					local targetPlaylistId = playlistId
					if rowIsOfficial then
						targetPlaylistId = WML.Library:GetOrCreateDefaultUserPlaylist().id
					end
					WML.Library:AddTrackToPlaylist(targetPlaylistId, trackId)
				end)
			end
			row:Show()
			y = y - 42
		end
	end

	for i = #rows + 1, #self.trackRows do
		self.trackRows[i]:Hide()
	end

	self.trackContent:SetSize(self.trackScroll:GetWidth() - 22, math.max(1, -y))
end

function UI:RefreshPlayerBar()
	local state = WML.Player:GetState()

	self.playButton:SetText(state.isPlaying and "Pause" or "Play")
	self.progress:SetValue(state.isPlaying and 1 or 0)

	if state.track then
		self.nowPlaying:SetText(state.track.title .. " - " .. state.track.artist)
	else
		self.nowPlaying:SetText("No track selected")
	end
end

function UI:Refresh()
	if not self.frame then
		return
	end

	self:RefreshSidebar()
	self:RefreshTracks()
	self:RefreshPlayerBar()
end
