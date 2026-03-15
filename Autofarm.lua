-- [[ 1. INITIALISATION DES TABLES ET SERVICES ]] --
local AutofarmPro = {}
_G.AutofarmPro = AutofarmPro 
_G.AutoFarmEnabled = false
_G.TweenSpeed = 300

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local _NoClipConnection = nil

-- [[ 2. BASE DE DONNÉES DES QUÊTES (Globale) ]] --
_G.QuestsData = {
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 30, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1922, 5, 3918)},
    {Level = 45, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1922, 5, 3918)},
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(896, 6, 4390)},
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 120, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 150, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Warden", QuestID = 2, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 190, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Warden", QuestID = 3, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 210, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Swan", QuestID = 4, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 225, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-1240, 357, -5912)},
    {Level = 250, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Dark Steward", QuestID = 2, Pos = CFrame.new(-1240, 357, -5912)},
    {Level = 300, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Soldier", QuestID = 1, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 330, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Spy", QuestID = 2, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 350, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Magma Village", QuestID = 3, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 375, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 400, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Commando", QuestID = 2, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 425, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Lord", QuestID = 3, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 450, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "God's Guard", QuestID = 1, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 475, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Shanda", QuestID = 2, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 525, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Royal Squad", QuestID = 3, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 550, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Royal Soldier", QuestID = 4, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 650, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Captain", QuestID = 2, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 700, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Cyborg", QuestID = 3, Pos = CFrame.new(5259, 38, 4050)},
}

-- [[ 3. MOTEUR PHYSIQUE ET LOGIQUE ]] --

local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT V3.0] : %s***", emoji, msg)) 
end

local function Stabilize(root, enable)
    if enable then
        if not root:FindFirstChild("YuuVelocity") then
            local bv = Instance.new("BodyVelocity", root)
            bv.Name = "YuuVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        if not root:FindFirstChild("YuuGyro") then
            local bg = Instance.new("BodyGyro", root)
            bg.Name = "YuuGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = root.CFrame
        end
    else
        if root:FindFirstChild("YuuVelocity") then root.YuuVelocity:Destroy() end
        if root:FindFirstChild("YuuGyro") then root.YuuGyro:Destroy() end
    end
end

local function SetNoClip(state)
    if _NoClipConnection then _NoClipConnection:Disconnect() end
    if state then
        _NoClipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end

local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mRoot then
                local dist = (mRoot.Position - spawnPos.Position).Magnitude
                if dist < 350 and dist < shortestDistance then
                    shortestDistance = dist
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

-- [[ 4. FONCTIONS DU MOTEUR EXPORTÉES ]] --

function AutofarmPro.GetTargetData()
    local currentLevel = Player.Data.Level.Value
    local target = _G.QuestsData[1]
    for _, data in ipairs(_G.QuestsData) do
        if currentLevel >= data.Level then target = data end
    end
    return target
end

function AutofarmPro.Start()
    if _NoClipConnection == nil then SetNoClip(true) end
    Log("⚡", "IA Lancée.")
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local targetData = AutofarmPro.GetTargetData()
                local pGui = Player:FindFirstChild("PlayerGui")
                local hasQuest = pGui.Main.Quest.Visible and pGui.Main.Quest.Container.QuestTitle.Text ~= ""

                if not hasQuest then
                    Stabilize(root, false)
                    if _G.TweenModule then 
                        _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed).Completed:Wait()
                    else
                        root.CFrame = targetData.Pos
                    end
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        Stabilize(root, true)
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Attaque
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0,0))
                    else
                        Stabilize(root, true)
                        root.CFrame = targetData.Pos * CFrame.new(0, 30, 0)
                    end
                end
            end)
            if not success then warn("Erreur IA: " .. err) end
            task.wait()
        end
        Stabilize(Player.Character.HumanoidRootPart, false)
    end)
end

-- [[ 5. CHARGEMENT DE L'INTERFACE FLUENT ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT V3.0",
    SubTitle = "Fix Edition",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }) }

Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false }):OnChanged(function(Value)
    _G.AutoFarmEnabled = Value
    if _G.AutoFarmEnabled then
        if _G.AutofarmPro and _G.AutofarmPro.Start then
            _G.AutofarmPro.Start()
        else
            Fluent:Notify({Title = "Erreur", Content = "Module non chargé !"})
        end
    end
end)

Window:SelectTab(1)