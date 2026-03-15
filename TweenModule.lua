local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local TweenModule = {}

-- [[ CONFIGURATION ]] --
_G.TweenSpeed = _G.TweenSpeed or 300 
local currentTween = nil 

-- [[ FONCTION BYPASS : FORCE LE PASSAGE ]] --
local function BypassObstacles(character)
    for _, obj in pairs(workspace:GetDescendants()) do
        -- On cible les portes, les barrières et les murs de quête
        if obj:IsA("BasePart") and (obj.Name:find("Gate") or obj.Name:find("Door") or obj.Name:find("Border")) then
            local dist = (character.HumanoidRootPart.Position - obj.Position).Magnitude
            if dist < 50 then -- Si on est proche d'une porte
                obj.CanCollide = false
                obj.CanTouch = false
            end
        end
    end
end

function TweenModule.Stop()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

function TweenModule.MoveTo(targetCFrame, speedOverride)
    local player = Players.LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end

    TweenModule.Stop()

    local currentSpeed = speedOverride or _G.TweenSpeed
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / currentSpeed

    -- Sécurité distance courte
    if distance < 5 then
        rootPart.CFrame = targetCFrame
        return {Completed = {Wait = function() end}}
    end

    -- 🛡️ NOCLIP & BYPASS GATES
    local bypassConnection
    bypassConnection = RunService.Stepped:Connect(function()
        if character and _G.AutoFarmEnabled then
            -- 1. NoClip Global
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            -- 2. Bypass des portes du monde
            BypassObstacles(character)
        else
            bypassConnection:Disconnect()
        end
    end)

    -- 🔧 TWEEN
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(rootPart, info, {CFrame = targetCFrame})
    
    -- Reset physique
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    
    currentTween:Play()

    currentTween.Completed:Connect(function()
        if bypassConnection then bypassConnection:Disconnect() end
        rootPart.Velocity = Vector3.new(0, 0, 0)
    end)

    return currentTween
end

_G.TweenModule = TweenModule
return TweenModule