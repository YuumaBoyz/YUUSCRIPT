--[[
    💎 YUUSCRIPT : ULTIMATE STATE-MACHINE AUTOFARM
    Expert : Expert Luau Developer
    Target : Blox Fruits (Standard Logic)
]]

local AutofarmPro = {}

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ VARIABLES LOCALES ]] --
local Player = Players.LocalPlayer
local Tween = _G.TweenModule -- Moteur de mouvement global
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_") -- Remote principal

-- [[ CONFIGURATION DES QUÊTES ]] --
local QuestsData = {
    -- [[ STARTER ISLAND ]] --
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", Pos = CFrame.new(1059, 16, 1549)},
    
    -- [[ JUNGLE ]] --
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", Pos = CFrame.new(-1610, 37, 153)},
    
    -- [[ PIRATE VILLAGE ]] --
    {Level = 30, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Pirate", Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 40, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Brute", Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 55, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Bobby", Pos = CFrame.new(-1141, 5, 3827)},
    
    -- [[ DESERT ]] --
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", Pos = CFrame.new(896, 6, 4390)},
    
    -- [[ FROZEN VILLAGE ]] --
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", Pos = CFrame.new(1385, 15, -1303)},
    
    -- [[ MARINE FORTRESS ]] --
    {Level = 120, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Chief Petty Officer", Pos = CFrame.new(-4942, 21, 4381)},
    {Level = 150, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Warden", Pos = CFrame.new(-4942, 21, 4381)},
    
    -- [[ SKY ISLANDS (BASSE) ]] --
    {Level = 150, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2620)},
    {Level = 175, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Dark Adventurer", Pos = CFrame.new(-4842, 718, -2620)},
    
    -- [[ PRISON ]] --
    {Level = 190, NPC = "Prison Warden", Name = "PrisonQuest", Mob = "Warden", Pos = CFrame.new(4875, 6, 735)},
    {Level = 210, NPC = "Prison Warden", Name = "PrisonQuest", Mob = "Chief Warden", Pos = CFrame.new(4875, 6, 735)},
    {Level = 230, NPC = "Prison Warden", Name = "PrisonQuest", Mob = "Swan", Pos = CFrame.new(4875, 6, 735)},
    
    -- [[ MAGMA VILLAGE ]] --
    {Level = 250, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Soldier", Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 275, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Spy", Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 300, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Magma Admiral", Pos = CFrame.new(-5315, 12, 8517)},
    
    -- [[ UNDERWATER CITY ]] --
    {Level = 375, NPC = "Water Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", Pos = CFrame.new(61122, 18, 1569)},
    {Level = 400, NPC = "Water Adventurer", Name = "FishmanQuest", Mob = "Fishman Commando", Pos = CFrame.new(61122, 18, 1569)},
    
    -- [[ SKY ISLANDS (HAUTE) ]] --
    {Level = 450, NPC = "Mole", Name = "SkyExp1Quest", Mob = "God's Guard", Pos = CFrame.new(-4607, 850, -1915)},
    {Level = 475, NPC = "Mole", Name = "SkyExp1Quest", Mob = "Shanda", Pos = CFrame.new(-4607, 850, -1915)},
    {Level = 525, NPC = "Mole", Name = "SkyExp2Quest", Mob = "Royal Squad", Pos = CFrame.new(-7852, 5545, -381)},
    {Level = 550, NPC = "Mole", Name = "SkyExp2Quest", Mob = "Royal Soldier", Pos = CFrame.new(-7852, 5545, -381)},
    
    -- [[ FOUNTAIN CITY ]] --
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", Pos = CFrame.new(5259, 39, 4050)},
    {Level = 650, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Captain", Pos = CFrame.new(5259, 39, 4050)}
}

-- [[ SYSTÈME DE LOGS ]] --
local function Log(emoji, msg)
    print(string.format("%s [YUUSCRIPT] : %s", emoji, msg))
end

-- [[ FONCTIONS DE SÉCURITÉ ]] --
local function CheckHealth()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and (hum.Health / hum.MaxHealth) < 0.25 then -- Se replier à 25% de PV
        Log("🛡️", "***Santé critique !*** Retrait stratégique.")
        return false
    end
    return true
end

local function GetActiveQuest()
    local pGui = Player:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("Quest") then
        return pGui.Main.Quest.Visible
    end
    return false
end

-- [[ LOGIQUE DE LA MACHINE À ÉTATS ]] --
function AutofarmPro.GetTargetData()
    local currentLevel = Player.Data.Level.Value
    local target = QuestsData[1]
    for _, data in ipairs(QuestsData) do
        if currentLevel >= data.Level then
            target = data
        end
    end
    return target
end

local function EquipWeapon()
    local weaponName = _G.SelectedWeapon
    local char = Player.Character
    if char and not char:FindFirstChild(weaponName) then
        local tool = Player.Backpack:FindFirstChild(weaponName)
        if tool then
            char.Humanoid:EquipTool(tool)
        end
    end
end

function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local currentTarget = AutofarmPro.GetTargetData() -- Utilise ta table QuestsData

                -- ÉTAPE : VÉRIFICATION QUÊTE
                if not GetActiveQuest() then
                    -- TP NPC et Acceptation
                    _G.TweenModule.MoveTo(currentTarget.Pos, _G.TweenSpeed).Completed:Wait()
                    
                    -- L'ID "1" correspond souvent au Mob A, "2" au Mob B, etc.
                    -- On s'assure d'invoquer la quête précise définie dans QuestsData
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", currentTarget.Name, 1)
                    task.wait(0.5)
                else
                    -- ÉTAPE : COMBAT CIBLÉ
                    EquipWeapon() -- On s'assure d'avoir l'arme en main

                    local mob = nil
                    -- On cherche UNIQUEMENT le mob défini dans QuestsData pour ce palier
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        -- Condition STRICTE : Nom du mob EXACT et Vie > 0
                        if v.Name == currentTarget.Mob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            mob = v
                            break
                        end
                    end

                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        -- TP sécurisé au-dessus du mob spécifique
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                        
                        -- Commande d'attaque (VirtualUser pour simuler le clic)
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                    end
                end
            end)
            task.wait()
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    Log("🛑", "***Système arrêté.***")
end

return AutofarmPro