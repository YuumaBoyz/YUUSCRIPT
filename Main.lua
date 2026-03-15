local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ 1. CONFIGURATION INITIALE ]] --
_G.TweenSpeed = 300
_G.AutoFarmEnabled = false
_G.SniperEnabled = false
_G.FruitESP = false
_G.AntiAFK = true
_G.BypassGates = true
_G.SafeMode = false
_G.SelectedWeapon = "Combat"

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ 2. MOTEUR D'AUTOFARM ]] --
local AutofarmPro = {}
_G.AutofarmPro = AutofarmPro -- Enregistrement global immédiat pour éviter l'erreur NIL

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
    {Level = 375, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 400, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Commando", QuestID = 2, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 450, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "God's Guard", QuestID = 1, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 650, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Captain", QuestID = 2, Pos = CFrame.new(5259, 38, 4050)},
}

-- Outils de combat interne
local function EquipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon)
    if tool then Player.Character.Humanoid:EquipTool(tool) end
end

local function GetClosestMob(targetName)
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local d = (Player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d closest = v end
        end
    end
    return closest
end

function AutofarmPro.GetTargetData()
    local lvl = Player.Data.Level.Value
    local target = _G.QuestsData[1]
    for _, data in ipairs(_G.QuestsData) do
        if lvl >= data.Level then target = data end
    end
    return target
end

function AutofarmPro.Start()
    -- NoClip Loop
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                for _, v in pairs(Player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end)
            task.wait()
        end
    end)

    -- Farm Loop
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local target = AutofarmPro.GetTargetData()
                local pGui = Player:FindFirstChild("PlayerGui")
                local hasQuest = pGui.Main.Quest.Visible and pGui.Main.Quest.Container.QuestTitle.Text ~= ""

                if not hasQuest then
                    Player.Character.HumanoidRootPart.CFrame = target.Pos
                    task.wait(0.3)
                    Remote:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    local mob = GetClosestMob(target.Mob)
                    if mob then
                        EquipWeapon()
                        Player.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        Player.Character.HumanoidRootPart.CFrame = target.Pos * CFrame.new(0, 50, 0)
                    end
                end
            end)
            task.wait()
        end
    end)
end

-- [[ 3. FONCTIONS UTILITAIRES ]] --
if _G.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- [[ 4. INTERFACE GRAPHIQUE (FLUENT) ]] --
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT", SubTitle = "By YUUMA - Fix Edition",
    TabWidth = 160, Size = UDim2.fromOffset(580, 520), Acrylic = true,
    Theme = "Dark", MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "Visuels", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Serveur", Icon = "shield" })
}

local Options = Fluent.Options

Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme à utiliser",
    Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass", "Dual Katana", "Iron Mace"},
    Default = "Combat",
    Callback = function(Value) _G.SelectedWeapon = Value end
})

local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false })
FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        _G.AutofarmPro.Start()
    end
end)

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Vol", Default = 300, Min = 50, Max = 800, Rounding = 1,
    Callback = function(Value) _G.TweenSpeed = Value end
})

Tabs.Main:AddToggle("BypassGates", {Title = "Bypass Gates", Default = true}):OnChanged(function(v) _G.BypassGates = v end)

-- Finalisation
Window:SelectTab(1)
Fluent:Notify({Title = "YUUSCRIPT", Content = "Script chargé avec succès ! ⚔️"})