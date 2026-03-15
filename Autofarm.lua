local AutofarmPro = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

-- Sécurité pour les quêtes (Fix : image_6e3b9e.jpg)
local function GetActiveQuest()
    local main = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("Main")
    if not main then return false end
    
    local questFrame = main:FindFirstChild("Quest")
    if questFrame and questFrame.Visible then
        local container = questFrame:FindFirstChild("Container")
        if container then
            -- On cherche intelligemment l'objet texte pour éviter le crash "Member of Frame"
            local title = container:FindFirstChild("QuestTitle")
            if title then
                if title:IsA("TextLabel") then return title.Text ~= "" end
                -- Si QuestTitle est une Frame, on cherche le label à l'intérieur
                local realText = title:FindFirstChildWhichIsA("TextLabel")
                return realText and realText.Text ~= ""
            end
        end
    end
    return false
end

local function GetClosestMob(targetName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, dist = nil, math.huge
    for _, v in pairs(enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local r = v:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (Player.Character.HumanoidRootPart.Position - r.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

function AutofarmPro.Start()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local target = _G.QuestsData[1]
                for _, data in ipairs(_G.QuestsData) do
                    if Player.Data.Level.Value >= data.Level then target = data end
                end

                if not GetActiveQuest() then
                    char.HumanoidRootPart.CFrame = target.Pos
                    task.wait(0.5)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    local mob = GetClosestMob(target.Mob)
                    if mob then
                        local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon) or char:FindFirstChild(_G.SelectedWeapon)
                        if tool then char.Humanoid:EquipTool(tool) end
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        char.HumanoidRootPart.CFrame = target.Pos * CFrame.new(0, 50, 0)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

return AutofarmPro