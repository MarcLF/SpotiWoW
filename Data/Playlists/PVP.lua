local WML = SpotiWoW

WML.Data = WML.Data or {}
WML.Data.Playlists = WML.Data.Playlists or {}

local TERMS = {
    "pvp",
    "battleground",
    "arena",
    "arathi basin",
    "arathibasin",
    "warsong gulch",
    "warsonggulch",
    "alterac valley",
    "eye of the storm",
    "isle of conquest",
    "strand of the ancients",
    "battle for gilneas",
    "twin peaks",
    "silvershard",
    "temple of kotmogu",
    "deepwind",
    "seething shore",
    "wintergrasp",
    "tol barad",
    "ashran",
    "mugambala",
    "hook point",
    "robodrome",
    "enigma arena",
    "black rook hold arena",
    "nagrand arena",
    "blade's edge arena",
    "blades edge arena",
    "dalaran sewers",
    "ruins of lordaeron",
    "tiger's peak",
}

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

local function HasTerm(text)
    for _, term in ipairs(TERMS) do
        if string.find(text, term, 1, true) then
            return true
        end
    end

    return false
end

for _, track in ipairs(WML.Data.Tracks or {}) do
    if HasTag(track, "pvp") or HasTerm(TrackText(track)) then
        tracks[#tracks + 1] = track.id
    end
end

WML.Data.Playlists[#WML.Data.Playlists + 1] = {
    id = "official-pvp",
    name = "PVP",
    official = true,
    description = "Battleground, arena, and PVP music.",
    tracks = tracks,
}
