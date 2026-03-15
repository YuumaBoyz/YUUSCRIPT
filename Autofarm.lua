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

-- [[ CONFIGURATION DES QUÊTES (EXTRAIT) ]] --
local QuestsData = {
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    -- Ajoute tes autres données ici
}

local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT V2.1] : %s***", emoji, msg)) 
end

-- [[ 1. STABILISATION PHYSIQUE (ANTI-GLITCH) ]] --
local function Stabilize(root)
    if not root:FindFirstChild("YuuVelocity") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "YuuVelocity"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
    end
    if not root:FindFirstChild("YuuGyro") then
        local bg = Instance.new("BodyGyro")
        bg.Name = "YuuGyro"
        bg.CFrame = root.CFrame
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.Parent = root
    end
end

-- [[ 2. SYSTÈME NO-CLIP PERMANENT ]] --
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

-- [[ 3. CIBLAGE ULTRA-PRÉCIS ]] --
local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mRoot then
                -- On vérifie la distance par rapport au SPAWN (max 250 studs)
                local distFromSpawn = (mRoot.Position - spawnPos.Position).Magnitude
                if distFromSpawn < 250 then
                    local distFromPlayer = (mRoot.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if distFromPlayer < shortestDistance then
                        shortestDistance = distFromPlayer
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

-- [[ 4. LOGIQUE DE COMBAT ET ANTI-STUCK ]] --
function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    SetNoClip(true)
    Log("🔥", "***Protocole Elite activé. No-Clip et Stabilisation ON.***")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                Stabilize(root)
                local targetData = AutofarmPro.GetTargetData()

                -- GESTION DES QUÊTES
                local pGui = Player:FindFirstChild("PlayerGui")
                local hasQuest = pGui.Main.Quest.Visible and pGui.Main.Quest.Container.QuestTitle.Text ~= ""

                if not hasQuest then
                    if _G.TweenModule then _G.TweenModule.Stop() end
                    _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed).Completed:Wait()
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- COMBAT
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    if mob then
                        local mRoot = mob.HumanoidRootPart
                        -- Positionnement 20 studs au-dessus
                        root.CFrame = mRoot.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Attaque
                        if _G.FastAttack then _G.FastAttack.Attack() 
                        else 
                            VirtualUser:Button1Down(Vector2.new(0,0)) 
                        end
                    else
                        -- ANTI-STUCK : Si pas de mob, on monte de 2 studs et on attend au spawn
                        root.CFrame = targetData.Pos * CFrame.new(0, 2, 0)
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
    Log("🛑", "***Système Elite arrêté. Physique restaurée.***")
end

return AutofarmPro