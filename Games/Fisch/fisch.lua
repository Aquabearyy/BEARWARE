local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local httpService = game:GetService("HttpService")

local Config = {}
local AllFuncs = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

AllFuncs['Farm Fish'] = function()
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    while Config['Farm Fish'] and task.wait() do
        if Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
        end
        if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
            XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
            XyzClone.Name = "Lure"
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: 0%"
            repeat
                pcall(function()
                    PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                end)
                XyzClone.Text = "<font color='#ff4949'>Lure </font>: "..tostring(math.floor(LocalPlayer.Character:FindFirstChild(RodName).values.lure.Value * 100) / 100).."%"
                RunService.Heartbeat:Wait()
            until not LocalPlayer.Character:FindFirstChild(RodName) or LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
            XyzClone.Text = "<font color='#ff4949'>FISHING!</font>"
            delay(1.5, function()
                XyzClone:Destroy()
            end)
            repeat
                ReplicatedStorage.events.reelfinished:FireServer(1000000000000000000000000, true)
                task.wait(.5)
            until not LocalPlayer.Character:FindFirstChild(RodName) or not LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
        else
            LocalPlayer.Character:FindFirstChild(RodName).events.cast:FireServer(1000000000000000000000000)
            task.wait(2)
        end
    end
end

local Window = OrionLib:MakeWindow({
    Name = "Bear Hub",
    HidePremium = false,
    SaveConfig = false, 
    ConfigFolder = "BearHub",
    IntroEnabled = false
})

local MainTab = Window:MakeTab({
    Name = "Main",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Auto Farm Fish",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config['Farm Fish'] = Value
        if Value then
            task.spawn(AllFuncs['Farm Fish'])
        end
    end
})

OrionLib:Init()
