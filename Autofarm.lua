-- [[ 🛡️ YUUSCRIPT V3.0 - ENGINE MODULE ]] --
local AutofarmPro = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- **BASE DE DONNÉES** 🗺️
AutofarmPro.QuestsData = {
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    -- ... (Garde toute ta liste ici)
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
}

-- **FONCTIONS UTILES** 🔍
local function GetActiveQuest()
    local pGui = Player:FindFirstChild("PlayerGui")
    local mainGui = pGui and pGui:FindFirstChild("Main")
    if mainGui then
        local questFrame = mainGui:FindFirstChild("Quest")
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            return container and container:FindFirstChildWhichIsA("TextLabel") and container:FindFirstChildWhichIsA("TextLabel").Text ~= ""
        end
    end
    return false
end

local function GetClosestMob(targetName)
    local closest, dist = nil, math.huge
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, v in pairs(enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local r = v:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (Player.Character.HumanoidRootPart.Position - r.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

-- **LOGIQUE DE DÉMARRAGE** ⚔️
function AutofarmPro.Start()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local lvl = Player.Data.Level.Value
                local targetData = AutofarmPro.QuestsData[1]
                for _, data in ipairs(AutofarmPro.QuestsData) do
                    if lvl >= data.Level then targetData = data end
                end

                if not GetActiveQuest() then
                    char.HumanoidRootPart.CFrame = targetData.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    local mob = GetClosestMob(targetData.Mob)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        -- Équiper l'arme choisie dans l'UI
                        local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon)
                        if tool then char.Humanoid:EquipTool(tool) end
                        
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        char.HumanoidRootPart.CFrame = targetData.Pos * CFrame.new(0, 40, 0)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

return AutofarmPro