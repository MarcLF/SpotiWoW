local WML = WoWMusicLibrary

local Options = {}
WML.Options = Options

function Options:Initialize()
	local AceConfig = LibStub("AceConfig-3.0", true)
	local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
	if not AceConfig or not AceConfigDialog then
		return
	end

	AceConfig:RegisterOptionsTable("WoWMusicLibrary", {
		type = "group",
		name = "WoW Music Library",
		args = {
			minimap = {
				type = "toggle",
				name = "Hide minimap icon",
				order = 10,
				get = function()
					return WML.db.profile.minimap.hide
				end,
				set = function(_, value)
					WML:SetMinimapHidden(value)
				end,
			},
			volume = {
				type = "range",
				name = "Default volume",
				order = 20,
				min = 0,
				max = 1,
				step = 0.05,
				get = function()
					return WML.db.profile.volume
				end,
				set = function(_, value)
					WML.db.profile.volume = value
				end,
			},
			shuffle = {
				type = "toggle",
				name = "Shuffle",
				order = 30,
				get = function()
					return WML.db.profile.shuffle
				end,
				set = function(_, value)
					WML.db.profile.shuffle = value and true or false
				end,
			},
			repeatMode = {
				type = "select",
				name = "Repeat mode",
				order = 40,
				values = {
					none = "None",
					playlist = "Playlist",
					track = "Track",
				},
				get = function()
					return WML.db.profile.repeatMode
				end,
				set = function(_, value)
					WML.db.profile.repeatMode = value
				end,
			},
			resetWindow = {
				type = "execute",
				name = "Reset window position",
				order = 50,
				func = function()
					WML.UI:ResetPosition()
				end,
			},
		},
	})

	AceConfigDialog:AddToBlizOptions("WoWMusicLibrary", "WoW Music Library")
end
