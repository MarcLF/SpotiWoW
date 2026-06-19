local WML = WoWMusicLibrary

local Library = {}
WML.Library = Library

-- ponytail: keep the seed library tiny; expand only after FileDataIDs are verified in-game.
local tracks = {
	{
		id = "diablo_tristram_guitar",
		title = "Tristram Guitar",
		artist = "Blizzard Entertainment",
		expansion = "Event",
		source = "fileDataID",
		value = 1538384,
		duration = nil,
	},
	{
		id = "darkmoon_l70etc",
		title = "Power of the Horde",
		artist = "L70ETC",
		expansion = "Darkmoon Faire",
		source = "fileDataID",
		value = 53438,
		duration = nil,
	},
	{
		id = "wowtools_sample",
		title = "FileDataID Sample",
		artist = "World of Warcraft",
		expansion = "World of Warcraft",
		source = "fileDataID",
		value = 554297,
		duration = nil,
	},
}

local officialPlaylists = {
	{
		id = "official-main",
		name = "Official Mix",
		tracks = { "diablo_tristram_guitar", "darkmoon_l70etc", "wowtools_sample" },
	},
	{
		id = "official-darkmoon",
		name = "Darkmoon Faire",
		tracks = { "darkmoon_l70etc" },
	},
}

local trackById = {}

function Library:Initialize()
	wipe(trackById)
	for _, track in ipairs(tracks) do
		trackById[track.id] = track
	end

	self:EnsureSelectedPlaylist()
end

function Library:GetTracks()
	return tracks
end

function Library:GetTrack(trackId)
	return trackById[trackId]
end

function Library:GetOfficialPlaylists()
	return officialPlaylists
end

function Library:GetUserPlaylists()
	return WML.db.profile.playlists
end

function Library:GetPlaylist(playlistId)
	for _, playlist in ipairs(officialPlaylists) do
		if playlist.id == playlistId then
			return playlist, true
		end
	end

	for _, playlist in ipairs(WML.db.profile.playlists) do
		if playlist.id == playlistId then
			return playlist, false
		end
	end
end

function Library:EnsureSelectedPlaylist()
	if self:GetPlaylist(WML.db.profile.selectedPlaylistId) then
		return
	end

	WML.db.profile.selectedPlaylistId = "official-main"
end

function Library:SelectPlaylist(playlistId)
	if not self:GetPlaylist(playlistId) then
		return
	end

	WML.db.profile.selectedPlaylistId = playlistId
	WML:NotifyChanged()
end

function Library:GetPlaylistTracks(playlistId)
	local playlist = self:GetPlaylist(playlistId)
	local result = {}

	if not playlist then
		return result
	end

	for _, trackId in ipairs(playlist.tracks) do
		local track = trackById[trackId]
		if track then
			result[#result + 1] = track
		end
	end

	return result
end

function Library:CreatePlaylist(name)
	name = strtrim(name or "")
	if name == "" then
		name = "My Playlist"
	end

	local profile = WML.db.profile
	profile.playlistCounter = (profile.playlistCounter or 0) + 1

	local playlist = {
		id = "user-" .. profile.playlistCounter,
		name = name,
		tracks = {},
	}

	profile.playlists[#profile.playlists + 1] = playlist
	profile.selectedPlaylistId = playlist.id
	WML:NotifyChanged()

	return playlist
end

function Library:RenamePlaylist(playlistId, name)
	local playlist, isOfficial = self:GetPlaylist(playlistId)
	name = strtrim(name or "")

	if not playlist or isOfficial or name == "" then
		return
	end

	playlist.name = name
	WML:NotifyChanged()
end

function Library:DeletePlaylist(playlistId)
	for index, playlist in ipairs(WML.db.profile.playlists) do
		if playlist.id == playlistId then
			table.remove(WML.db.profile.playlists, index)
			if WML.db.profile.selectedPlaylistId == playlistId then
				WML.db.profile.selectedPlaylistId = "official-main"
			end
			WML:NotifyChanged()
			return true
		end
	end
end

function Library:AddTrackToPlaylist(playlistId, trackId)
	local playlist, isOfficial = self:GetPlaylist(playlistId)
	if not playlist or isOfficial or not trackById[trackId] then
		return
	end

	for _, existingTrackId in ipairs(playlist.tracks) do
		if existingTrackId == trackId then
			return
		end
	end

	playlist.tracks[#playlist.tracks + 1] = trackId
	WML:NotifyChanged()
	return true
end

function Library:RemoveTrackFromPlaylist(playlistId, trackId)
	local playlist, isOfficial = self:GetPlaylist(playlistId)
	if not playlist or isOfficial then
		return
	end

	for index, existingTrackId in ipairs(playlist.tracks) do
		if existingTrackId == trackId then
			table.remove(playlist.tracks, index)
			WML:NotifyChanged()
			return true
		end
	end
end

function Library:GetFirstUserPlaylist()
	return WML.db.profile.playlists[1]
end

function Library:GetOrCreateDefaultUserPlaylist()
	return self:GetFirstUserPlaylist() or self:CreatePlaylist("My Playlist")
end

function Library:FilterTracks(sourceTracks, query)
	query = strtrim(strlower(query or ""))
	if query == "" then
		return sourceTracks
	end

	local result = {}
	for _, track in ipairs(sourceTracks) do
		local haystack = strlower(table.concat({ track.title, track.artist, track.expansion }, " "))
		if string.find(haystack, query, 1, true) then
			result[#result + 1] = track
		end
	end

	return result
end
