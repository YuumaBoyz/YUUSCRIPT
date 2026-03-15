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

-- [[ LOGS STYLISÉS ]] --
local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT V2.1] : %s***", emoji, msg)) 
end

-- [[ 1. PHYSIQUE & COLLISIONS (ANTI-GLITCH) ]] --
local function Stabilize(root)
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
end

local function SetNoClip(state)
    if state then
        _NoClipConnection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if _NoClipConnection then _NoClipConnection:Disconnect() end
    end
end

-- [[ 2. INTELLIGENCE DE CIBLAGE (TP LOGIC) ]] --
local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mRoot then
                -- Intelligence : On vérifie que le mob n'est pas "égaré" (max 300 studs du spawn)
                local distFromSpawn = (mRoot.Position - spawnPos.Position).Magnitude
                if distFromSpawn < 300 then
                    local distFromPlayer = (mRoot.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if distFromPlayer < shortestDistance then
                        shortestDistance = distFromPlayer
                        closestMob = mob
                    end
                end
            end
        end
    end
    -- Si on ne trouve rien dans "Enemies", on cherche dans "Camera" (certains spawns buggés)
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

-- [[ 3. BOUCLE DE DÉCISION INTELLIGENTE ]] --
-- [[ MODIFICATION DE LA BOUCLE DE DÉCISION ]] --
function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    SetNoClip(true)
    Log("⚡", "***IA de combat débloquée.***")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local targetData = AutofarmPro.GetTargetData()
                local pGui = Player:FindFirstChild("PlayerGui")
                local hasQuest = pGui.Main.Quest.Visible and pGui.Main.Quest.Container.QuestTitle.Text ~= ""

                if not hasQuest then
                    -- 🔓 ON DÉBLOQUE LA PHYSIQUE POUR BOUGER
                    if root:FindFirstChild("YuuVelocity") then root.YuuVelocity:Destroy() end
                    if root:FindFirstChild("YuuGyro") then root.YuuGyro:Destroy() end
                    
                    Log("📍", "Route vers : " .. targetData.NPC)
                    if _G.TweenModule then 
                        _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed).Completed:Wait()
                    end
                    
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- ⚔️ MODE COMBAT : ON ACTIVE LA STABILISATION
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    
                    if mob then
                        Stabilize(root) -- On verrouille la physique seulement ici
                        local mRoot = mob.HumanoidRootPart
                        root.CFrame = mRoot.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Attaque
                        if _G.FastAttack then 
                            _G.FastAttack.Attack() 
                        else 
                            VirtualUser:Button1Down(Vector2.new(0,0)) 
                        end
                    else
                        -- Attente du respawn : On reste stable en l'air
                        Stabilize(root)
                        root.CFrame = targetData.Pos * CFrame.new(0, 30, 0)
                    end
                end
            end)
            task.wait()
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    SetNoClip(false)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if root:FindFirstChild("YuuVelocity") then root.YuuVelocity:Destroy() end
        if root:FindFirstChild("YuuGyro") then root.YuuGyro:Destroy() end
    end
    Log("🛑", "***Système arrêté.***")
end

return AutofarmPro