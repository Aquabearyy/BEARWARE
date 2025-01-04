local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

if not getgenv().BearHubLoaded then
    getgenv().BearHubLoaded = false
end

local supportedGames = {
    -- Slap Battles
    [6403373529] = {
        name = "Slap Battles",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Slap%20Battles/slapbattles.lua"
    },
    
    [9431156611] = {
        name = "Slap Royale",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Slap%20Battles/slaproyale.lua"
    },
    -- Rivals
    [17625359962] = {
        name = "Rivals",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Rivals/rivals.lua"
    },
    [71874690745115] = {
        name = "Rivals FFA",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Rivals/rivals.lua"
    },
    [621129760] = {
        name = "KAT",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/KAT/kat.lua"
    },
    [286090429] = {
        name = "Arsenal",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Arsenal/arsenal.lua"
    },
    [116605585218149] = {
        name = "Go Fishing",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Go-Fishing/Go-Fishing.lua"
    },
    [537413528] = {
        name = "Build A Boat For Treasure",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Build-A-Boat-For-Treasure/babft.lua"
    },
    [16732694052] = {
        name = "Fisch",
        url = "https://raw.githubusercontent.com/sxlent404/Bear-Hub/main/Games/Fisch/fisch.lua"
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
