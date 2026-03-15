local TweenService = game:GetService("TweenService")
local TweenModule = {}

_G.TweenSpeed = _G.TweenSpeed or 100
local currentTween = nil 

function TweenModule.MoveTo(targetCFrame, speedOverride)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Si l'autofarm est coupé (par le sniper), on annule le mouvement en cours
    if not _G.AutoFarmEnabled and not speedOverride then
        if currentTween then currentTween:Cancel() end
        return nil
    end

    if currentTween then currentTween:Cancel() end
    
    local currentSpeed = speedOverride or _G.TweenSpeed
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / currentSpeed
    
    -- NOCLIP
    local noclipLoop
    noclipLoop = game:GetService("RunService").Stepped:Connect(function()
        if character and _G.AutoFarmEnabled then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        else
            noclipLoop:Disconnect()
        end
    end)

    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(rootPart, info, {CFrame = targetCFrame})
    
    rootPart.Velocity = Vector3.new(0, 0, 0)
    currentTween:Play()
    
    currentTween.Completed:Connect(function()
        if noclipLoop then noclipLoop:Disconnect() end
    end)
    
    return currentTween
end

function TweenModule.Stop()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

return TweenModule