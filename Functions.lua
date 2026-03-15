--[[ 🛠️ ENGINE MODULE (FUNCTIONS) ]]
local LP = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- 🚀 TP SÉCURISÉ AVEC BYPASS
_G.SafeTeleport = function(target)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LP.Character.HumanoidRootPart
    local speed = 250
    local dist = (root.Position - target.p).Magnitude
    
    local tween = TS:Create(root, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = target})
    
    -- Noclip pendant le TP
    local nc = game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    
    tween:Play()
    tween.Completed:Wait()
    nc:Disconnect()
    root.Velocity = Vector3.new(0,0,0)
end

-- ⚔️ FAST ATTACK GHOST
_G.Attack = function()
    local rem = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("validator") or RS:FindFirstChild("MainEvent")
    if rem then 
        if rem.Name == "validator" then rem:FireServer() else rem:FireServer("SelfDefense") end 
    end
end