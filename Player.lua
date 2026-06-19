local WML = WoWMusicLibrary

local Player = {
	trackId = nil,
	playlistId = nil,
	soundHandle = nil,
	isPlaying = false,
}

WML.Player = Player

function Player:Initialize()
	self.playlistId = WML.db.profile.selectedPlaylistId
end

function Player:PlayTrack(trackId, playlistId)
	local track = WML.Library:GetTrack(trackId)
	if not track then
		WML:Print("Track not found: " .. tostring(trackId))
		return
	end

	self:Stop(true)

	local willPlay, soundHandle = PlaySoundFile(track.value, "Music")
	if not willPlay then
		WML:Print("Could not play: " .. track.title)
		WML:NotifyChanged()
		return
	end

	self.trackId = track.id
	self.playlistId = playlistId or WML.db.profile.selectedPlaylistId
	self.soundHandle = soundHandle
	self.isPlaying = true

	WML:NotifyChanged()
	return true
end

function Player:Stop(silent)
	if self.soundHandle then
		StopSound(self.soundHandle)
	end

	self.soundHandle = nil
	self.isPlaying = false

	if not silent then
		WML:NotifyChanged()
	end
end

function Player:TogglePlay()
	if self.isPlaying then
		self:Stop()
		return
	end

	local track = self:GetCurrentOrFirstTrack()
	if track then
		self:PlayTrack(track.id, self.playlistId or WML.db.profile.selectedPlaylistId)
	end
end

function Player:Next()
	local track, playlistId = self:GetRelativeTrack(1)
	if track then
		self:PlayTrack(track.id, playlistId)
	end
end

function Player:Previous()
	local track, playlistId = self:GetRelativeTrack(-1)
	if track then
		self:PlayTrack(track.id, playlistId)
	end
end

function Player:GetState()
	return {
		isPlaying = self.isPlaying,
		trackId = self.trackId,
		track = WML.Library:GetTrack(self.trackId),
		playlistId = self.playlistId,
		soundHandle = self.soundHandle,
	}
end

function Player:GetCurrentOrFirstTrack()
	if self.trackId and WML.Library:GetTrack(self.trackId) then
		return WML.Library:GetTrack(self.trackId)
	end

	local tracks = WML.Library:GetPlaylistTracks(WML.db.profile.selectedPlaylistId)
	if #tracks == 0 then
		tracks = WML.Library:GetPlaylistTracks("official-main")
		self.playlistId = "official-main"
	end

	return tracks[1]
end

function Player:GetRelativeTrack(delta)
	local playlistId = self.playlistId or WML.db.profile.selectedPlaylistId
	local tracks = WML.Library:GetPlaylistTracks(playlistId)

	if #tracks == 0 then
		playlistId = "official-main"
		tracks = WML.Library:GetPlaylistTracks(playlistId)
	end

	if #tracks == 0 then
		return nil, playlistId
	end

	if WML.db.profile.shuffle and #tracks > 1 then
		local track
		repeat
			track = tracks[math.random(#tracks)]
		until track.id ~= self.trackId
		return track, playlistId
	end

	local index = 1
	for i, track in ipairs(tracks) do
		if track.id == self.trackId then
			index = i
			break
		end
	end

	if WML.db.profile.repeatMode ~= "track" then
		index = index + delta
	end

	if index < 1 then
		index = #tracks
	elseif index > #tracks then
		index = 1
	end

	return tracks[index], playlistId
end
