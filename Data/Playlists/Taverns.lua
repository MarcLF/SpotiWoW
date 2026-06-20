local WML = SpotiWoW

WML.Data = WML.Data or {}
WML.Data.Playlists = WML.Data.Playlists or {}

local tracks = {}

local function HasTag(track, tag)
    for _, value in ipairs(track.tags or {}) do
        if value == tag then
            return true
        end
    end

    return false
end

local function TrackText(track)
    return string.lower(table.concat({
        track.id or "",
        track.title or "",
        track.zone or "",
        track.biome or "",
    }, " "))
end

local function HasWord(text, word)
    return string.find(text, "%f[%a]" .. word .. "%f[%A]") ~= nil
end

for _, track in ipairs(WML.Data.Tracks or {}) do
    local text = TrackText(track)

    if HasTag(track, "tavern")
        or track.biome == "Tavern"
        or string.find(text, "tavern", 1, true)
        or HasWord(text, "inn") then
        tracks[#tracks + 1] = track.id
    end
end

WML.Data.Playlists[#WML.Data.Playlists + 1] = {
    id = "official-taverns",
    name = "Taverns",
    official = true,
    description = "Tavern and inn music from across Azeroth.",
    tracks = tracks,
}
