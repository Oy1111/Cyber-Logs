-- Config all --

local webhookAll = "PLACER DIN WEBHOOK HER" -- Erstat med din Discord webhook-URL

-- Config one per one -- 
local webhookJoin = "PLACER DIN WEBHOOK HER" -- Erstat med din Discord webhook-URL
local webhookLeave = "PLACER DIN WEBHOOK HER" -- Erstat med din Discord webhook-URL
local name = "Cyber-Logs System"
local logo = "https://imgur.com/aZIMrO9.jpg" -- Replace if you want


-- Funktion til at sende den indlejrede besked til Discord webhook --
local function sendEmbedMessage(webhook, embed)
    PerformHttpRequest(webhook, function (err, text, headers) end, 'POST', json.encode({ username = name, embeds = { embed } }), { ['Content-Type'] = 'application/json' })
end

-- Funktion til at udtrække spilleridentifikatorer 
local function ExtractIdentifiers(playerId)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local id = GetPlayerIdentifier(playerId, i)

        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        end
    end

    return identifiers
end

-- Funktion til at formatere IP som spoiler --
local function formatSpoiler(text)
    return "||" .. text .. "||"
end

-- Begivenhed når en spiller opretter forbindelse til serveren --
AddEventHandler('playerConnecting', function()
    local playerId = source
    local playerName = GetPlayerName(playerId) -- Få spillerens navn
    local playerIp = GetPlayerEndpoint(playerId) -- Få spillerns Ip
    local playerPing = GetPlayerPing(playerId) --  Få spillerens ping
    local playerServerId = playerId -- Får spillerens server-id
    local identifiers = ExtractIdentifiers(playerId) -- Få spillerens identifikatorer

    -- Opret en indlejringsmeddelelse til den tilsluttede afspiller --
    local connectingEmbed = {
        title = ":arrow_right: | Player Connecting",
        color = 65280, -- Green
        fields = {
            { name = ":bust_in_silhouette: | Navn", value = playerName },
            { name = ":globe_with_meridians: | IP", value = formatSpoiler(playerIp) },
            { name = ":speech_balloon: | Discord", value = identifiers['discord'] or "N/A" },
            { name = ":video_game: | Steam", value = identifiers['steam'] or "N/A" },
            { name = ":signal_strength: | Ping", value = playerPing },
            { name = ":id: | Server ID", value = playerServerId },
            { name = ":key: | License", value = identifiers['license'] or "N/A" },
            { name = ":key2: | License 2", value = identifiers['license2'] or "N/A" }
        },
        footer = {
            text = name,
            icon_url = logo
        }
    }

    sendEmbedMessage(webhookJoin, connectingEmbed)
    sendEmbedMessage(webhookAll, connectingEmbed)
end)

-- Hændelse når en spiller afbryder forbindelsen fra serveren --
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local playerName = GetPlayerName(playerId) -- Få Spillerns Navn
    local playerIp = GetPlayerEndpoint(playerId) -- Få Spillerns Ip
    local playerPing = GetPlayerPing(playerId) -- Få spillerns Ping
    local playerServerId = playerId -- Få spillerns server id
    local identifiers = ExtractIdentifiers(playerId) -- Få spillerens identifikatorer

   -- Opret en indlejringsmeddelelse til afspilleren, der afbryder forbindelse --
    local disconnectingEmbed = {
        title = ":arrow_left: Player Leaved,
        color = 16711680, -- Red
        fields = {
            { name = ":bust_in_silhouette: | Navn", value = playerName },
            { name = ":globe_with_meridians: | IP", value = formatSpoiler(playerIp) },
            { name = ":speech_balloon: | Discord", value = identifiers['discord'] or "N/A" },
            { name = ":video_game: | Steam", value = identifiers['steam'] or "N/A" },
            { name = ":signal_strength: | Ping", value = playerPing },
            { name = ":id: | Server ID", value = playerServerId },
            { name = ":key: | License", value = identifiers['license'] or "N/A" },
            { name = ":key2: | License 2", value = identifiers['license2'] or "N/A" }
        },
        footer = {
            text = name,
            icon_url = logo
        }
    }

    sendEmbedMessage(webhookLeave, disconnectingEmbed)
    sendEmbedMessage(webhookAll, disconnectingEmbed)
end)
