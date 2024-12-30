local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/sxlent404/ModdedOrion/main/source.lua')))()

local Window = OrionLib:MakeWindow({
    Name = "Bear Hub | ".. identifyexecutor(), 
    HidePremium = false,
    SaveConfig = false, 
    ConfigFolder = "GOFISHING"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local function pressButton()
    local targetFrame = game:GetService("Players").LocalPlayer.PlayerGui.fishing.targetFrame
    for _, target in pairs(targetFrame:GetChildren()) do
        if target.Name == "target" then
            local imageButton = target:FindFirstChild("ImageButton")
            if imageButton then
                task.spawn(function()
                    for _, v in pairs(getconnections(imageButton.MouseButton1Click)) do
                        v:Fire()
                    end
                    for _, v in pairs(getconnections(imageButton.MouseButton1Down)) do
                        v:Fire()
                    end
                    for _, v in pairs(getconnections(imageButton.MouseButton1Up)) do
                        v:Fire()
                    end
                    for _, v in pairs(getconnections(imageButton.Activated)) do
                        v:Fire()
                    end
                end)
            end
        end
    end
end

local function clickFight()
    local fightFrame = game:GetService("Players").LocalPlayer.PlayerGui.fishing.fightFrame
    if fightFrame.Visible then
        mouse1click()
    end
end

local autoPress = false
local autoFight = false
local pressConnection = nil
local fightConnection = nil

Tab:AddToggle({
    Name = "Auto Shake",
    Default = false,
    Flag = "autoPress",
    Save = true,
    Callback = function(Value)
        autoPress = Value
        if autoPress then
            if pressConnection then
                pressConnection:Disconnect()
            end
            pressConnection = game:GetService("RunService").RenderStepped:Connect(pressButton)
        else
            if pressConnection then
                pressConnection:Disconnect()
                pressConnection = nil
            end
        end
    end    
})

Tab:AddToggle({
    Name = "Auto Fight",
    Default = false,
    Flag = "autoFight",
    Save = true,
    Callback = function(Value)
        autoFight = Value
        if autoFight then
            if fightConnection then
                fightConnection:Disconnect()
            end
            fightConnection = game:GetService("RunService").RenderStepped:Connect(clickFight)
        else
            if fightConnection then
                fightConnection:Disconnect()
                fightConnection = nil
            end
        end
    end    
})

OrionLib:Init()
