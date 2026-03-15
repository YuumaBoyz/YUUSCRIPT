-- [[ MODULE : FAST ATTACK & AUTO-CLICKER ]] --
local FastAttack = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

_G.FastAttackSpeed = 0.1 -- Plus c'est bas, plus c'est rapide (0.1 est safe)

function FastAttack.Attack()
    local char = Player.Character
    local weapon = char and char:FindFirstChildOfClass("Tool")
    
    if char and weapon then
        Remote:InvokeServer("Attack")
    end
end

function FastAttack.Start()
    _G.AutoAttackEnabled = true
    
    task.spawn(function()
        while _G.AutoAttackEnabled do
            if _G.AutoFarmEnabled then -- On n'attaque que si le farm tourne
                pcall(FastAttack.Attack)
            end
            task.wait(_G.FastAttackSpeed)
        end
    end)
end

function FastAttack.Stop()
    _G.AutoAttackEnabled = false
end

_G.FastAttack = FastAttack
return FastAttack