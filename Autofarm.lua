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

-- [[ LOGS ]] --
local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT V2.5] : %s***", emoji, msg)) 
end

-- [[ INTELLIGENCE : RÉCUPÉRATION CIBLE ]] --
function AutofarmPro.GetTargetData()
    -- Utilise la table globale définie dans Main.lua pour éviter les doublons
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

-- [[ PHYSIQUE : STABILISATION DYNAMIQUE ]] --
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

-- [[ COLLISIONS : NO-CLIP & BYPASS GATES ]] --
local function SetNoClip(state)
    if _NoClipConnection then _NoClipConnection:Disconnect() end
    if state then
        _NoClipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
                
                -- Système Bypass Gates : Ouvre les portes à proximité
                if _G.BypassGates then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:find("Gate") or obj.Name:find("Door")) then
                            local dist = (Player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                            if dist < 40 then
                                obj.CanCollide = false
                                obj.CanTouch = false
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- [[ CIBLAGE : SCAN AVANCÉ ]] --
local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
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
    end
    
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

-- [[ BOUCLE PRINCIPALE ]] --
function AutofarmPro.Start()
    if _G.AutoFarmEnabled then return end
    _G.AutoFarmEnabled = true
    SetNoClip(true)
    Log("⚡", "***IA Fusionnée lancée. Prête au combat.***")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local targetData = AutofarmPro.GetTargetData()
                if not targetData then return end

                local pGui = Player:FindFirstChild("PlayerGui")
                local hasQuest = pGui.Main.Quest.Visible and pGui.Main.Quest.Container.QuestTitle.Text ~= ""

                if not hasQuest then
                    -- 📍 NAVIGATION PNJ
                    Stabilize(root, false)
                    Log("📍", "Route vers PNJ : " .. targetData.NPC)
                    
                    if _G.TweenModule then 
                        _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed).Completed:Wait()
                    else
                        root.CFrame = targetData.Pos
                    end
                    
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- ⚔️ MODE COMBAT
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        Stabilize(root, true)
                        local mRoot = mob.HumanoidRootPart
                        
                        -- Positionnement stratégique : Au dessus avec angle d'attaque
                        root.CFrame = mRoot.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        if _G.FastAttack then 
                            _G.FastAttack.Attack() 
                        else 
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0,0)) 
                        end
                    else
                        -- ⏳ ATTENTE RESPAWN
                        Stabilize(root, true)
                        root.CFrame = targetData.Pos * CFrame.new(0, 30, 0)
                    end
                end
            end)
            if not success then warn("Erreur IA: " .. err) end
            task.wait()
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    SetNoClip(false)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Stabilize(Player.Character.HumanoidRootPart, false)
    end
    Log("🛑", "***Système fusionné arrêté.***")
end

_G.AutofarmPro = AutofarmPro
return AutofarmPro