local TweenService = game:GetService("TweenService")
local TweenModule = {}

-- Paramètre de vitesse par défaut (modifiable via l'UI Fluent plus tard)
_G.TweenSpeed = _G.TweenSpeed or 100

function TweenModule.MoveTo(targetCFrame, speedOverride)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Utilise la vitesse globale ou une vitesse spécifique si fournie
    local currentSpeed = speedOverride or _G.TweenSpeed
    
    -- Calcul de la distance pour une vitesse constante
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / currentSpeed
    
    -- Configuration du mouvement (Linéaire pour éviter les saccades)
    local info = TweenInfo.new(
        duration, 
        Enum.EasingStyle.Linear, 
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(rootPart, info, {CFrame = targetCFrame})
    
    -- Exécution du mouvement
    tween:Play()
    
    -- On retourne le tween pour pouvoir utiliser .Completed:Wait() dans les autres scripts
    return tween
end

-- Fonction pour stopper instantanément tout mouvement en cours
function TweenModule.Stop()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local stopTween = TweenService:Create(rootPart, TweenInfo.new(0), {CFrame = rootPart.CFrame})
        stopTween:Play()
    end
end

return TweenModule