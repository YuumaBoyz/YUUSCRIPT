-- [[ MODULE : FAST ATTACK & AUTO-CLICKER ]] --
local FastAttack = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ CONFIGURATION ]] --
_G.FastAttackSpeed = 0.05 -- Baissé à 0.05 pour une vitesse maximale (insane)
_G.AutoAttackEnabled = false

-- [[ FONCTION : ÉQUIPER L'ARME AUTOMATIQUEMENT ]] --
local function EquipWeapon()
    local selected = _G.SelectedWeapon or "Combat"
    local char = Player.Character
    if not char then return end
    
    -- Si l'arme n'est pas déjà dans la main
    if not char:FindFirstChild(selected) then
        local tool = Player.Backpack:FindFirstChild(selected)
        if tool then
            char.Humanoid:EquipTool(tool)
        end
    end
end

-- [[ FONCTION D'ATTAQUE OPTIMISÉE ]] --
function FastAttack.Attack()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- 1. On s'assure que l'arme est bien équipée
    EquipWeapon()
    
    local weapon = char:FindFirstChildOfClass("Tool")
    if weapon then
        -- 2. On envoie l'attaque au serveur (Méthode Blox Fruits)
        Remote:InvokeServer("Attack")
        
        -- 3. Animation de clic visuel (pour éviter les bugs de hitbox)
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
    end
end

-- [[ BOUCLE DE DÉBIT MASSIF ]] --
function FastAttack.Start()
    if _G.AutoAttackEnabled then return end -- Évite les doubles boucles
    _G.AutoAttackEnabled = true
    
    Log("⚔️", "***Fast Attack V3 activé (Vitesse: " .. _G.FastAttackSpeed .. ")***")

    task.spawn(function()
        while _G.AutoAttackEnabled do
            if _G.AutoFarmEnabled then
                -- On utilise un pcall pour éviter que le script ne crash si le perso meurt
                local success, err = pcall(function()
                    FastAttack.Attack()
                end)
                
                -- Anti-Lag : Si le serveur peine, on ralentit très légèrement
                task.wait(_G.FastAttackSpeed)
            else
                task.wait(0.5) -- Pause si l'autofarm est arrêté
            end
        end
    end)
end

function FastAttack.Stop()
    _G.AutoAttackEnabled = false
    Log("🛑", "***Fast Attack désactivé.***")
end

-- [[ COMPATIBILITÉ ]] --
_G.FastAttack = FastAttack
return FastAttack