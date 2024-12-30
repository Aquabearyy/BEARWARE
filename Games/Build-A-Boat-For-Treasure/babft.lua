if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Script = {
    AutoFarmStagePositions = {},
    DisableAutoFarm = false,
    BoatStages = workspace:WaitForChild("BoatStages"),
    NormalStages = nil,
    ClaimGold = workspace:WaitForChild("ClaimRiverResultsGold"),
    AutoFarmPart = Instance.new("Part")
}

Script.NormalStages = Script.BoatStages:WaitForChild("NormalStages")
Script.AutoFarmPart.CanCollide = false
Script.AutoFarmPart.Anchored = true
Script.AutoFarmPart.Transparency = 1

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Bear Hub | " .. identifyexecutor(),
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BearHub"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local autoFarmEnabled = false
local autoFarmSpeed = 5
local autoFarmPriority = "Gold Blocks"

MainTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            Script.Functions.AutoFarm()
        end
    end
})

MainTab:AddSlider({
    Name = "Auto Farm Speed",
    Min = 1,
    Max = 6,
    Default = 5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    Callback = function(Value)
        autoFarmSpeed = Value
    end    
})

MainTab:AddDropdown({
    Name = "Auto Farm Priority",
    Default = "Gold Blocks",
    Options = {"Gold Blocks", "Gold"},
    Callback = function(Value)
        autoFarmPriority = Value
    end    
})

Script.Functions = {}

function Script.Functions.SetupAutoFarmVariables()
    for i = 1, 10 do
        table.insert(Script.AutoFarmStagePositions, Script.NormalStages:FindFirstChild("CaveStage" .. tostring(i)).DarknessPart.Position)
    end
    table.insert(Script.AutoFarmStagePositions, Script.NormalStages.TheEnd.GoldenChest.Trigger.Position + Vector3.new(0, 350, 0))
    table.insert(Script.AutoFarmStagePositions, Script.NormalStages.TheEnd.GoldenChest.Trigger.Position)
end

function Script.Functions.AutoFarm()
    while autoFarmEnabled do
        local character = Players.LocalPlayer.Character
        if not character then 
            Players.LocalPlayer.CharacterAdded:Wait()
            character = Players.LocalPlayer.Character
        end

        for idx, stagePosition in pairs(Script.AutoFarmStagePositions) do
            if not autoFarmEnabled then break end
            character = Players.LocalPlayer.Character
            if not character then 
                Players.LocalPlayer.CharacterAdded:Wait()
                character = Players.LocalPlayer.Character
            end

            if idx >= 11 and autoFarmPriority == "Gold" then
                Script.ClaimGold:FireServer()
                Script.DisableAutoFarm = true
                task.wait(0.1)
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
                Players.LocalPlayer.CharacterAdded:Wait()
                Script.DisableAutoFarm = false
                break
            end

            Script.DisableAutoFarm = false
            Script.AutoFarmPart.Position = character:GetPivot().Position

            local partTween = TweenService:Create(Script.AutoFarmPart, TweenInfo.new((character:GetPivot().Position - stagePosition).Magnitude / (autoFarmSpeed * 100), Enum.EasingStyle.Linear), {
                Position = stagePosition
            })

            partTween:Play()
            partTween.Completed:Wait()

            if autoFarmPriority == "Gold" then
                Script.ClaimGold:FireServer()
            end

            if idx == 12 then
                Script.DisableAutoFarm = true
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
                Players.LocalPlayer.CharacterAdded:Wait()
                character = Players.LocalPlayer.Character
                Script.AutoFarmPart.Position = character:GetPivot().Position
                Script.DisableAutoFarm = false
                task.wait(0.25)
            end
        end
        task.wait()
    end
end

RunService.RenderStepped:Connect(function()
    local character = Players.LocalPlayer.Character
    if character and autoFarmEnabled and not Script.DisableAutoFarm then
        if character.PrimaryPart then
            character.PrimaryPart.Velocity = Vector3.zero
        end
        character:PivotTo(Script.AutoFarmPart.CFrame)
    end
end)

Script.Functions.SetupAutoFarmVariables()

OrionLib:Init()
