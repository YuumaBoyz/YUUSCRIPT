--[[
    💎 YUUSCRIPT : ULTIMATE STATE-MACHINE AUTOFARM (V2.1 - ANTI-BUG)
]]

local AutofarmPro = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [ Données de Quêtes inchangées ] --
local QuestsData = {
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 30, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 40, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 55, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Bobby", QuestID = 3, Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(896, 6, 4390)},
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 120, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4942, 21, 4381)},
    {Level = 150, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Vice Admiral", QuestID = 2, Pos = CFrame.new(-4942, 21, 4381)},
    {Level = 150, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-4842, 718, -2620)},
    {Level = 175, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Dark Master", QuestID = 2, Pos = CFrame.new(-4842, 718, -2620)},
}

local function Log(emoji, msg) print(emoji .. " [YUUSCRIPT] : " .. msg) end

local function CheckHealth()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    return hum and (hum.Health / hum.MaxHealth) >= 0.25
end

local function GetActiveQuest()
    local pGui = Player:FindFirstChild("PlayerGui")
    local questGui = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("Quest")
    if questGui and questGui.Visible then
        -- On vérifie que la quête a bien un titre (sinon elle est buggée)
        local title = questGui:FindFirstChild("Container") and questGui.Container:FindFirstChild("QuestTitle")
        return title and title.Text ~= ""
    end
    return false
end

function AutofarmPro.GetTargetData()
    local currentLevel = Player.Data.Level.Value
    local target = QuestsData[1]
    for _, data in ipairs(QuestsData) do
        if currentLevel >= data.Level then target = data end
    end
    return target
end

local function EquipWeapon()
    local weaponName = _G.SelectedWeapon or "Melee"
    local char = Player.Character
    if char and not char:FindFirstChild(weaponName) then
        local tool = Player.Backpack:FindFirstChild(weaponName)
        if tool then
            char.Humanoid:EquipTool(tool)
            task.wait(0.2) -- Indispensable pour JJSploit
        end
    end
end

local function GetClosestMob(targetName, spawnPos)
    local closestMob, shortestDistance = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local mRoot = mob:FindFirstChild("HumanoidRootPart")
            if mRoot then
                local distance = (mRoot.Position - spawnPos.Position).Magnitude
                if distance < 1000 and distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    Log("🚀", "Démarrage du Turbo-Farm...")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local targetData = AutofarmPro.GetTargetData()

                if not GetActiveQuest() then
                    -- Reset mouvement et prise de quête
                    if _G.TweenModule then _G.TweenModule.Stop() end
                    _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed).Completed:Wait()
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                    task.wait(0.5)
                elseif not CheckHealth() then
                    root.CFrame = root.CFrame * CFrame.new(0, 150, 0)
                    task.wait(2)
                else
                    EquipWeapon()
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)

                    if mob then
                        local mRoot = mob.HumanoidRootPart
                        root.Velocity = Vector3.new(0, 0, 0)
                        -- On descend un peu (20 studs au lieu de 25) pour être sûr de toucher
                        root.CFrame = mRoot.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- ATTAQUE
                        if _G.FastAttack then
                            _G.FastAttack.Attack()
                        else
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                        end
                    else
                        -- Si pas de mob, on attend pile sur le spawn
                        _G.TweenModule.MoveTo(targetData.Pos, _G.TweenSpeed)
                    end
                end
            end)
            task.wait()
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    VirtualUser:Button1Up(Vector2.new(0,0))
    Log("🛑", "Système arrêté.")
end

return AutofarmPro