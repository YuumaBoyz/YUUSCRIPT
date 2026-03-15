local TweenService = game:GetService("TweenService")
local TweenModule = {}

_G.TweenSpeed = _G.TweenSpeed or 100
local currentTween = nil -- Stocke le mouvement en cours

function TweenModule.MoveTo(targetCFrame, speedOverride)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Arrêter le mouvement précédent s'il existe
    if currentTween then currentTween:Cancel() end
    
    -- Calcul de la vitesse
    local currentSpeed = speedOverride or _G.TweenSpeed
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / currentSpeed
    
    -- [[ SÉCURITÉ : NOCLIP ]] --
    -- Active le passage à travers les murs pendant le trajet
    local noclipLoop
    noclipLoop = game:GetService("RunService").Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- Configuration du Tween
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(rootPart, info, {CFrame = targetCFrame})
    
    -- [[ STABILISATION ]] --
    -- On force la vélocité à zéro pour éviter les "glissades" à l'arrivée
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    
    currentTween:Play()
    
    -- [[ NETTOYAGE APRÈS ARRIVÉE ]] --
    currentTween.Completed:Connect(function()
        if noclipLoop then noclipLoop:Disconnect() end
        -- Redonner la collision après l'arrivée
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)
    
    return currentTween
end

-- Stop complet et propre
function TweenModule.Stop()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

return TweenModule