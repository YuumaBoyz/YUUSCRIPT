-- [[ 🛡️ YUUSCRIPT V3.0 - ULTIMATE ENGINE (FRUIT SNIPER EDITION) ]] --

local function SafeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then warn("⚠️ Erreur de réseau : " .. url) return nil end
    return result
end

-- **CHARGEMENT DES LIBRAIRIES**
local Fluent = SafeLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
if not Fluent then return end -- Arrêt si Fluent ne charge pas
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local AutofarmLogic = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/YUUSCRIPT/main/Autofarm.lua"))()

-- [[ 1. CONFIGURATION ET VARIABLES GLOBALES ]] --
_G.AutoFarmEnabled = false
_G.InstantSniper = false
_G.SelectedWeapon = "Combat"
_G.AntiAFK = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- **SÉCURISATION DE L'INTERFACE JEU**
local pGui = Player:WaitForChild("PlayerGui", 10)
local mainGui = pGui and pGui:WaitForChild("Main", 10)

-- [[ 2. BASE DE DONNÉES DES QUÊTES ]] --
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
    {Level = 300, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Soldier", QuestID = 1, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 375, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
}

-- [[ 3. MODULE FRUIT SNIPER ]] --
local FruitSniper = { DEBOUNCE = false }
_G.FruitSniper = FruitSniper

function FruitSniper.Snap(item)
    if FruitSniper.DEBOUNCE or not _G.InstantSniper then return end
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part") or item:FindFirstChildOfClass("MeshPart")
    
    if not root or not handle then return end

    FruitSniper.DEBOUNCE = true
    pcall(function()
        local oldCFrame = root.CFrame
        local wasFarmEnabled = _G.AutoFarmEnabled
        _G.AutoFarmEnabled = false 
        
        Fluent:Notify({Title = "🍎 FRUIT DÉTECTÉ", Content = "Collecte de : " .. item.Name, Duration = 5})

        root.Velocity = Vector3.new(0,0,0)
        root.CFrame = handle.CFrame * CFrame.new(0, 2, 0)
        task.wait(0.2)
        firetouchinterest(root, handle, 0)
        firetouchinterest(root, handle, 1)
        task.wait(0.2)

        root.CFrame = oldCFrame
        _G.AutoFarmEnabled = wasFarmEnabled
    end)
    FruitSniper.DEBOUNCE = false
end

-- Boucle Sniper
task.spawn(function()
    while true do
        if _G.InstantSniper and not FruitSniper.DEBOUNCE then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
                    FruitSniper.Snap(obj)
                    break
                end
            end
        end
        task.wait(1)
    end
end)

local function GetMainGui()
    local pGui = Player:FindFirstChild("PlayerGui")
    if pGui then
        return pGui:WaitForChild("Main", 5) -- Attend 5 secondes max
    end
    return nil
end

-- [[ 4. MOTEUR D'AUTOFARM ]] --
local AutofarmPro = {}
_G.AutofarmPro = AutofarmPro

local function EquipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon)
    if tool then Player.Character.Humanoid:EquipTool(tool) end
end

-- **CORRECTIF : Éviter "Text is not a valid member of Frame"**
local function IsQuestActive()
    local main = GetMainGui()
    if not main then return false end
    
    local questFrame = main:FindFirstChild("Quest")
    if questFrame and questFrame.Visible then
        local container = questFrame:FindFirstChild("Container")
        if container then
            -- On cherche n'importe quel TextLabel dans le container au lieu d'un nom fixe
            local title = container:FindFirstChildWhichIsA("TextLabel")
            return title and title.Text ~= ""
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
            local root = v:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (Player.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

-- **DÉTECTION DE QUÊTE SÉCURISÉE (Correction Frame/Text)**
local function CheckQuestActive()
    if not mainGui then return false end
    local success, result = pcall(function()
        local qFrame = mainGui:FindFirstChild("Quest")
        if qFrame and qFrame.Visible then
            local container = qFrame:FindFirstChild("Container")
            local title = container and container:FindFirstChildWhichIsA("TextLabel")
            return title and title.Text ~= ""
        end
        return false
    end)
    return success and result
end

function AutofarmPro.Start()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                -- Choix de la quête par niveau
                local lvl = Player.Data.Level.Value
                local target = _G.QuestsData[1]
                for _, data in ipairs(_G.QuestsData) do
                    if lvl >= data.Level then target = data end
                end

                if not IsQuestActive() then
                    -- Aller prendre la quête
                    char.HumanoidRootPart.CFrame = target.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    -- Tuer les monstres
                    local mob = GetClosestMob(target.Mob)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        -- Equip weapon
                        local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon)
                        if tool then char.Humanoid:EquipTool(tool) end
                        
                        -- Position de combat (au dessus)
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        -- Attente spawn
                        char.HumanoidRootPart.CFrame = target.Pos * CFrame.new(0, 40, 0)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- [[ 5. INTERFACE GRAPHIQUE ]] --
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT V3.0", SubTitle = "Fruit Sniper Edition",
    TabWidth = 160, Size = UDim2.fromOffset(580, 520), Acrylic = true, Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Items = Window:AddTab({ Title = "Items & Fruits", Icon = "apple" }),
    Misc = Window:AddTab({ Title = "Serveur", Icon = "shield" })
}

-- TAB : AUTOFARM
Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme", Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass"},
    Default = "Combat", Callback = function(v) _G.SelectedWeapon = v end
})

Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false }):OnChanged(function()
    _G.AutoFarmEnabled = Fluent.Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        AutofarmLogic.Start() -- On appelle la fonction du module !
    end
end)

-- TAB : ITEMS & FRUITS
Tabs.Items:AddParagraph({Title = "Sniper", Content = "Téléportation et collecte immédiate des fruits spawnés."})
Tabs.Items:AddToggle("FruitSniper", {Title = "Fruit Sniper (Instant TP)", Default = false }):OnChanged(function()
    _G.InstantSniper = Fluent.Options.FruitSniper.Value
end)

Tabs.Items:AddToggle("FruitESP", {Title = "Afficher l'ESP Fruits", Default = false }):OnChanged(function()
    local Visuals = require(game:GetService("ReplicatedStorage"):WaitForChild("Visuals")) -- Ou ton chemin vers le fichier
    Visuals.UpdateESP(Fluent.Options.FruitESP.Value)
end)

-- TAB : MISC
Tabs.Misc:AddButton({
    Title = "Server Hop", Callback = function()
        local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(Servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end
})

-- ANTI-AFK INITIALISATION
if _G.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

Window:SelectTab(1)
Fluent:Notify({Title = "YUUSCRIPT", Content = "Système complet chargé avec succès ! 🍎", Duration = 5})