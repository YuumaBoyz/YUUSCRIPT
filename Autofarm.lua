local Autofarm = {}
local Tween = _G.TweenModule 

-- [[ CONFIGURATION ]] --
local DISTANCE_ABOVE_MOB = 5

-- [[ BASE DE DONNÉES SEA 1 (INCLUANT BOSS) ]] --
local QuestData = {
    {Level = 0,   Mob = "Bandit",             NPC = "Bandit Quest Giver", QuestName = "BanditQuest1", Pos = Vector3.new(1059, 16, 1547)},
    {Level = 10,  Mob = "Monkey",             NPC = "Monkey Quest Giver", QuestName = "MonkeyQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 15,  Mob = "Gorilla",            NPC = "Monkey Quest Giver", QuestName = "GorillaQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 30,  Mob = "Pirate",             NPC = "Pirate Island",      QuestName = "PirateIslandQuest1", Pos = Vector3.new(-1141, 4, 3832)},
    {Level = 60,  Mob = "Desert Bandit",      NPC = "Desert Adventurer",  QuestName = "DesertQuest1", Pos = Vector3.new(894, 6, 4390)},
    {Level = 90,  Mob = "Snow Bandit",        NPC = "Snow Adventurer",    QuestName = "SnowQuest1", Pos = Vector3.new(1389, 15, -1299)},
    -- [[ BOSS : YETI (LEVEL 110) ]] --
    {Level = 110, Mob = "Yeti",               NPC = "Snow Adventurer",    QuestName = "SnowQuest3", Pos = Vector3.new(1389, 15, -1299)},
    {Level = 120, Mob = "Chief Petty Officer",NPC = "Marine Officer",      QuestName = "MarineFordQuest1", Pos = Vector3.new(-4894, 20, 4265)},
    -- [[ BOSS : VICE ADMIRAL (LEVEL 130) ]] --
    {Level = 130, Mob = "Vice Admiral",       NPC = "Marine Officer",      QuestName = "MarineFordQuest2", Pos = Vector3.new(-4894, 20, 4265)},
    {Level = 150, Mob = "Sky Bandit",         NPC = "Sky Adventurer",     QuestName = "SkyQuest1", Pos = Vector3.new(-4840, 718, -2620)},
    {Level = 200, Mob = "Warden",             NPC = "Chief Warden",       QuestName = "PrisonQuest1", Pos = Vector3.new(4879, 6, 734)},
    -- [[ BOSS : CHIEF WARDEN (LEVEL 230) ]] --
    {Level = 230, Mob = "Chief Warden",       NPC = "Chief Warden",       QuestName = "PrisonQuest2", Pos = Vector3.new(4879, 6, 734)},
    {Level = 250, Mob = "Toga Warrior",       NPC = "Head Chef",          QuestName = "UnderwaterQuest1", Pos = Vector3.new(613, 31, 5953)},
    {Level = 300, Mob = "Military Soldier",   NPC = "Military Detective", QuestName = "MagmaQuest1", Pos = Vector3.new(-5314, 12, 8515)},
    {Level = 425, Mob = "Fishman Warrior",    NPC = "Fishman Warrior",    QuestName = "FishmanQuest1", Pos = Vector3.new(-3683, 7, -5282)},
    -- [[ BOSS : ARLONG (LEVEL 475) ]] --
    {Level = 475, Mob = "Sawfish",            NPC = "Fishman Warrior",    QuestName = "FishmanQuest3", Pos = Vector3.new(-3683, 7, -5282)},
    {Level = 525, Mob = "God's Guard",        NPC = "Mole",               QuestName = "SkyExp1Quest1", Pos = Vector3.new(-4545, 843, -5283)},
    {Level = 625, Mob = "Galley Pirate",      NPC = "Cyborg",             QuestName = "FountainQuest1", Pos = Vector3.new(5259, 38, 4050)},
    -- [[ BOSS : CYBORG (LEVEL 675) ]] --
    {Level = 675, Mob = "Cyborg",             NPC = "Cyborg",             QuestName = "FountainQuest3", Pos = Vector3.new(5259, 38, 4050)}
}

-- [[ LOGIQUE DE SÉLECTION ]] --
local function GetMyQuest()
    local level = game.Players.LocalPlayer.Data.Level.Value
    local best = QuestData[1]
    for _, q in ipairs(QuestData) do
        if level >= q.Level then
            best = q
        end
    end
    return best
end

-- [[ BOUCLE PRINCIPALE ]] --
function Autofarm.Start()
    if not Tween then warn("❌ TweenModule manquant !") return end
    _G.AutoFarmEnabled = true
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            task.wait(0.1)
            local player = game.Players.LocalPlayer
            local playerGui = player:WaitForChild("PlayerGui")
            
            -- Vérification si la fenêtre de quête est visible
            local mainGui = playerGui:FindFirstChild("Main")
            local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
            
            local current = GetMyQuest()

            if not hasQuest then
                -- ÉTAPE 1 : PRENDRE LA QUÊTE
                print("✨ Direction NPC : " .. current.NPC .. " pour " .. current.Mob)
                Tween.MoveTo(CFrame.new(current.Pos), _G.TweenSpeed).Completed:Wait()
                task.wait(0.5)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", current.QuestName, 1)
            else
                -- ÉTAPE 2 : COMBAT
                local enemies = workspace:FindFirstChild("Enemies")
                local targetFound = false
                
                -- On vérifie aussi dans workspace au cas où le Boss n'est pas dans le dossier Enemies
                local targets = enemies and enemies:GetChildren() or {}
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == current.Mob then table.insert(targets, obj) end
                end

                for _, mob in pairs(targets) do
                    if mob.Name == current.Mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        targetFound = true
                        print("⚔️ Combat contre : " .. mob.Name)
                        
                        repeat
                            if not _G.AutoFarmEnabled then break end
                            if not mob:FindFirstChild("HumanoidRootPart") then break end
                            
                            -- Position de sécurité au-dessus
                            Tween.MoveTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0), _G.TweenSpeed)
                            
                            -- Click automatique
                            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            
                            task.wait(0.1)
                        until not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0
                    end
                end
                
                if not targetFound then
                    task.wait(1) -- Attente du spawn
                end
            end
        end
    end)
end

function Autofarm.Stop()
    _G.AutoFarmEnabled = false
    print("🛑 Autofarm désactivé.")
end

return Autofarm