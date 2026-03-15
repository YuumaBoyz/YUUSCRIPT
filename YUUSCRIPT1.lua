--[[ 🛠️ YUUSCRIPT PARTIE 1 : LOGIQUE & FONCTIONS ]]
_G.WeaponToUse = "Melee"
_G.BlacklistedServers = _G.BlacklistedServers or {}
_G.FastAttack, _G.BringMobs = true, true
_G.AutoFarm, _G.AutoStats, _G.AutoChest = false, false, false
_G.FarmDistance, _G.CurrentTarget = 10, nil
_G.OrbitSpeed, _G.OrbitRadius, _G.VerticalOffset = 7, 8, 10
_G.FastAttackSpeed = 0.1

local LP = game.Players.LocalPlayer
local RS, TS, RunService = game:GetService("ReplicatedStorage"), game:GetService("TweenService"), game:GetService("RunService")

-- // 📐 SYSTÈME DE TÉLÉPORTATION
_G.SafeTeleport = function(targetCFrame)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetCFrame then return end
    root.Velocity = Vector3.new(0, 0, 0)
    local tween = TS:Create(root, TweenInfo.new((targetCFrame.p - root.Position).Magnitude / 250, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- // ⚔️ MOTEUR D'ATTAQUE
_G.FastAttackFunc = function()
    local rem = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("validator") or RS:FindFirstChild("MainEvent")
    if rem then if rem.Name == "validator" then rem:FireServer() else rem:FireServer("SelfDefense") end end
end

-- // 🍎 DÉTECTION DE FRUITS
_G.GrabFruit = function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
            _G.SafeTeleport(obj.Handle.CFrame)
            return true
        end
    end
    return false
end

-- // 🔄 REJOINDRE UNE ÉQUIPE AUTOMATIQUEMENT
task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    local joinRemote = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("get_team") or RS:FindFirstChild("MainEvent")
    if joinRemote and LP.Team == nil then
        if joinRemote.Name == "get_team" then joinRemote:InvokeServer("Pirates") else RS.MainEvent:FireServer("SetTeam", "Pirates") end
    end
end)
--[[ 👑 YUUSCRIPT PARTIE 2 : INTERFACE & B_OUCLES ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local LP = game.Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "👑 YUUSCRIPT [V2]",
    SubTitle = "by YUUMA",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460),
    Acrylic = false, Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Main", Icon = "home" }) }

-- // 🔘 TOGGLES INTERFACE
Tabs.Main:AddToggle("AutoFarm", {Title = "🌾 Auto Farm", Default = false}):OnChanged(function(v) _G.AutoFarm = v end)
Tabs.Main:AddToggle("AutoChest", {Title = "💰 Auto Chest", Default = false}):OnChanged(function(v) _G.AutoChest = v end)

-- // 🌀 BOUCLE GOD-MODE & ORBIT
local angle = 0
game:GetService("RunService").Stepped:Connect(function(dt)
    if _G.GodMode and _G.CurrentTarget then
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            angle = angle + (dt * _G.OrbitSpeed)
            root.CFrame = CFrame.new(_G.CurrentTarget.Position.X + math.cos(angle)*_G.OrbitRadius, _G.CurrentTarget.Position.Y + _G.VerticalOffset, _G.CurrentTarget.Position.Z + math.sin(angle)*_G.OrbitRadius) * CFrame.lookAt(Vector3.new(0,0,0), Vector3.new(0,-1,0))
            root.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- // ⚔️ BOUCLE ATTACK
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm and _G.CurrentTarget then
            pcall(function()
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() _G.FastAttackFunc() end
            end)
            task.wait(_G.FastAttackSpeed)
        end
    end
end)

Fluent:Notify({Title = "YUUSCRIPT", Content = "Interface chargée avec succès !", Duration = 5})