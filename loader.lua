if not game:IsLoaded() then
    game.Loaded:Wait()
end

local supportedGames = {
    [6403373529] = "Slap Battles",
    [9431156611] = "Slap Royale",
    [17625359962] = "Rivals",
    [621129760] = "KAT"
}

local gameId = game.PlaceId
local gameName = supportedGames[gameId]

if not gameName then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Game Not Supported",
        Text = "This game is not supported by the script.",
        Icon = "rbxassetid://74112517454380",
        Duration = 5
    })
    return
end

local function loadScript()
    local success, result = pcall(function()
        if gameId == 6403373529 then -- Slap Royale
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/main/SlapBattles/slapbattles.lua"))()
        elseif gameId == 9431156611 then -- Slap Battles
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/main/SlapBattles/slaproyale.lua"))()
        elseif gameId == 17625359962 then -- Rivals
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/main/Others/rivals.lua"))()
        elseif gameId == 621129760 then -- KAT
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/main/Others/KAT.lua"))()
        end
    end)
    
    if not success then
        warn("Failed to load script:", result)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Script Error",
            Text = "Failed to load script. Check console for details.",
            Icon = "rbxassetid://74112517454380",
            Duration = 5
        })
    end
end

loadScript()
