local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

if not getgenv().BearHubLoaded then
    getgenv().BearHubLoaded = false
end

local supportedGames = {
    -- Cubination
    [91731139776520] = {
        name = "Cubination",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Slap%20Battles/slapbattles.lua"
    },
    -- Forsaken
    [18687417158] = {
        name = "Forsaken",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Slap%20Battles/slaproyale.lua"
    }
}

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 5})
end

local function fetchScript(url)
    local success, content = pcall(game.HttpGet, game, url)
    if not success then
        error(string.format("Failed to fetch script from URL: %s", content))
    end
    return content
end

local function main()
    if getgenv().BearHubLoaded then
        notify("Already Loaded", "Bear Hub is already running!", 3)
        return false
    end

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local gameInfo = supportedGames[game.PlaceId]
    local success, error = pcall(function()
        if gameInfo then
            notify("Loading Script", string.format("Loading script for %s...", gameInfo.name), 3)
            local scriptContent = fetchScript(gameInfo.url)
            loadstring(scriptContent)()
            notify("Script Loaded", string.format("Successfully loaded %s script!", gameInfo.name), 3)
        else
            notify("Game Not Supported", "Loading universal script...", 3)
            local universalScript = fetchScript("https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Universal/universal.lua")
            loadstring(universalScript)()
            notify("Script Loaded", "Universal script loaded successfully!", 3)
        end
    end)
    
    if not success then
        warn("Script Loading Error:", error)
        notify("Script Error", "Failed to load script. Check console for details.")
        return false
    end
    
    getgenv().BearHubLoaded = true
    return true
end

return main()
