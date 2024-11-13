if not game:IsLoaded() then
    game.Loaded:Wait()
end

local supportedGames = {
    [6403373529] = "Slap Battles",
    [17625359962] = "Rivals"
}

local gameId = game.PlaceId
local gameName = supportedGames[gameId]

if not gameName then
    game.Players.LocalPlayer:Kick("Game not supported! Only Slap Battles and Rivals are supported.")
    return
end

local scriptUrls = {
    ["Main Slap Battles"] = "https://your-main-slap-battles-script-url.com",
    ["Rivals"] = "https://your-rivals-script-url.com"
}

local function loadScript()
    local success, result = pcall(function()
        if gameId == 6403373529 then -- Slap Battles
            loadstring(game:HttpGet("soon"))()
        elseif gameId == 17625359962 then -- Rivals
            loadstring(game:HttpGet("soon"))()
        end
    end)
    
    if not success then
        warn("Failed to load script:", result)
        game.Players.LocalPlayer:Kick("Failed to load script. Error: " .. tostring(result))
    end
end

loadScript()
