-- [[ MODULE AUTOFARM PRO V3.0 ]] --
local AutofarmPro = {}

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- [[ VARIABLES ]] --
local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local _NoClipConnection = nil

-- [[ LOGS INTERNES ]] --
local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT ENGINE] : %s***", emoji, msg)) 
end

-- [[ PHYSIQUE : STABILISATION DYNAMIQUE ]] --
-- Empêche le personnage de tomber ou de tourner bizarrement pendant le farm
local function Stabilize(root, enable)
    if enable then
        if not root:FindFirstChild("YuuVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "YuuVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
        end
        if not root:FindFirstChild("YuuGyro") then
            local bg = Instance.new("BodyGyro")
            bg.Name = "YuuGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = root.CFrame
            bg.Parent = root
        end
    else
        if root:FindFirstChild("YuuVelocity") then root.YuuVelocity:Destroy() end
        if root:FindFirstChild("YuuGyro") then root.YuuGyro:Destroy() end
    end
end

-- [[ CIBLAGE : SCAN DES ENNEMIS ]] --
local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    
    -- Recherche prioritaire dans le dossier Enemies
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                if mRoot then
                    local dist = (mRoot.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    
    -- Recherche de secours dans le workspace global
    if not closestMob then
        for _, mob in pairs(workspace:GetChildren()) do
            if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                closestMob = mob
                break
            end
        end
    end
    return closestMob
end

-- [[ COMBAT : AUTO-EQUIP ]] --
local function EquipWeapon()
    local weaponName = _G.SelectedWeapon or "Combat"
    local tool = Player.Backpack:FindFirstChild(weaponName)
    if tool then
        Player.Character.Humanoid:EquipTool(tool)
    end
end

-- [[ LOGIQUE DE QUÊTE ]] --
function AutofarmPro.GetTargetData()
    local dataTable = _G.QuestsData or {} 
    local currentLevel = Player.Data.Level.Value
    local target = dataTable[1]
    
    for _, data in ipairs(dataTable) do
        if currentLevel >= data.Level then 
            target = data 
        end
    end
    return target
end

local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false })

FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        -- Vérification de sécurité avant lancement
        if _G.AutofarmPro and _G.AutofarmPro.Start then
            _G.AutofarmPro.Start()
        else
            warn("⚠️ ***[YUUSCRIPT] : Moteur AutofarmPro non prêt !***")
        end
    end
end)

-- [[ 2. MOTEUR DE COMBAT (FONCTION START FUSIONNÉE) ]] --
function AutofarmPro.Start()
    if not _G.AutoFarmEnabled then return end
    print("⚔️ ***[YUUSCRIPT] : Lancement du cycle de combat...***")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local targetData = AutofarmPro.GetTargetData()
                
                -- [[ DÉTECTION DE QUÊTE SÉCURISÉE FUSIONNÉE ]] --
                local pGui = Player:FindFirstChild("PlayerGui")
                local questFrame = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("Quest")
                local hasQuest = false

                if questFrame and questFrame.Visible then
                    local titleObj = questFrame.Container:FindFirstChild("QuestTitle")
                    -- On vérifie si l'objet existe ET si c'est bien un texte pour éviter les erreurs
                    if titleObj and (titleObj:IsA("TextLabel") or titleObj:IsA("TextBox")) then
                        if titleObj.Text ~= "" then
                            hasQuest = true
                        end
                    end
                end
                -- [[ FIN DÉTECTION SÉCURISÉE ]] --

                if not hasQuest then
                    -- ÉTAPE 1 : PRENDRE LA QUÊTE
                    Stabilize(root, false)
                    root.CFrame = targetData.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- ÉTAPE 2 : COMBAT
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        Stabilize(root, true)
                        EquipWeapon()
                        
                        -- Positionnement stratégique au-dessus de la cible
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Simulation d'attaque
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0,0))
                    else
                        -- ÉTAPE 3 : ATTENTE RESPAWN
                        Stabilize(root, true)
                        root.CFrame = targetData.Pos * CFrame.new(0, 30, 0)
                    end
                end
            end)
            
            if not success then warn("❌ ***Erreur Moteur : " .. err .. "***") end
            task.wait() 
        end
        
        -- Nettoyage automatique à l'arrêt
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Stabilize(Player.Character.HumanoidRootPart, false)
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    Log("🛑", "Arrêt du moteur de farm.")
end

-- Synchronisation Globale
_G.AutofarmPro = AutofarmPro
return AutofarmPro