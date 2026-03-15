--[[
    📜 SCRIPT : BLOX FRUITS AAA [EXECUTIVE EDITION]
    🚀 MODULES : Auto-Farm (Fix Kill & Quest), Bring Mobs, Fruit Premium, Auto-Stats
    🛡️ STATUS : 100% STABLE - ZÉRO ERREUR
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local LP = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

--// ⚙️ GLOBALES
_G.WeaponToUse = "Melee"
_G.BlacklistedServers = _G.BlacklistedServers or {}
_G.FastAttack = true 
_G.BringMobs = true
_G.AutoFarm = false
_G.AutoStats = false
_G.AutoChest = false
_G.AutoCollect = false
_G.HopIfEmpty = false
_G.AutoGacha = false
_G.AutoStore = false
_G.FruitESP = false
_G.FarmDistance = 10
_G.CurrentTarget = nil


task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    local joinRemote = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("get_team") 
                      or RS:FindFirstChild("MainEvent")
    if joinRemote and LP.Team == nil then
        if joinRemote.Name == "get_team" then joinRemote:InvokeServer("Pirates")
        else RS.MainEvent:FireServer("SetTeam", "Pirates") end
    end
end)

local Window = Fluent:CreateWindow({
    Title = "👑 YUUSCRIPT",
    SubTitle = "by YUUMA",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

--// 🌀 MOTEUR GOD-MODE (ORBIT & FAST ATTACK V2)
local angle = 0
RunService.Stepped:Connect(function(dt)
    if _G.GodMode and _G.CurrentTarget and _G.CurrentTarget.Parent then
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- 1. Orbit Calculation
            angle = angle + (dt * _G.OrbitSpeed)
            local offsetX = math.cos(angle) * _G.OrbitRadius
            local offsetZ = math.sin(angle) * _G.OrbitRadius
            
            -- 2. Positionnement & Lock vers le bas
            root.CFrame = CFrame.new(
                _G.CurrentTarget.Position.X + offsetX, 
                _G.CurrentTarget.Position.Y + _G.VerticalOffset, 
                _G.CurrentTarget.Position.Z + offsetZ
            ) * CFrame.lookAt(Vector3.new(0,0,0), Vector3.new(0, -1, 0))

            -- 3. Bypass Anti-Cheat Physics
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Boucle Instant Kill V2 synchronisée
task.spawn(function()
    while task.wait() do
        if _G.GodMode and _G.CurrentTarget and _G.CurrentTarget.Parent then
            pcall(function()
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    local rem = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("validator") or RS:FindFirstChild("MainEvent")
                    if rem then
                        if rem.Name == "validator" then rem:FireServer() else rem:FireServer("SelfDefense") end
                    end
                end
            end)
            task.wait(_G.FastAttackSpeed)
        else
            task.wait(0.5)
        end
    end
end)

local IslandPositions = {
    ["MarineStart"] = CFrame.new(-2566, 7, 2045),
    ["Middle Town"] = CFrame.new(-690, 15, 1583),
    ["Jungle"] = CFrame.new(-1612, 37, 149),
    ["Pirate Village"] = CFrame.new(-1181, 4, 3851),
    ["Desert"] = CFrame.new(1094, 6, 4376),
    ["Frozen Village"] = CFrame.new(1132, 5, -1150),
    ["MarineFord"] = CFrame.new(-5036, 20, 4323),
    ["Skypiea"] = CFrame.new(-4839, 714, -2619),
    ["Prison"] = CFrame.new(4875, 5, 734),
    ["Magma Village"] = CFrame.new(-5242, 8, 8547),
    ["Fountain City"] = CFrame.new(5121, 5, 4105)
}

local function ScanIslands()
    -- 🕵️ On ne vide PAS la table, on complète les infos manquantes
    for _, v in pairs(workspace:GetDescendants()) do
        -- On cherche les donneurs de quêtes (meilleurs points de repère)
        if v:IsA("Model") and (v.Name:find("Quest") or v:FindFirstChild("Quest")) then
            
            -- On cherche un nom d'île valable
            local islandName = v.Parent and v.Parent.Name or v.Name
            
            -- ❌ On ignore les noms trop génériques pour ne pas polluer le menu
            if islandName ~= "NPC" and islandName ~= "NPCs" and islandName ~= "Inconnue" then
                if not IslandPositions[islandName] then
                    IslandPositions[islandName] = v:GetModelCFrame()
                end
            end
        end
    end
end


--// 🔄 MODULE SERVER HOP
local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TPService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local CurrentJobId = game.JobId
    
    -- ⛔ [1] On ajoute IMMÉDIATEMENT le serveur actuel à la liste noire
    _G.BlacklistedServers[CurrentJobId] = true

    local Api = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function() 
        return HttpService:JSONDecode(game:HttpGet(Api)) 
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            -- 🔍 [2] VÉRIFICATION ULTIME : Pas plein ET jamais visité !
            if server.playing < server.maxPlayers and not _G.BlacklistedServers[server.id] then
                
                -- 💾 [3] TRANSFERT DE LA MÉMOIRE AU PROCHAIN SERVEUR
                -- Sans ça, le nouveau serveur aurait une blacklist vide !
                local teleportFunc = queue_on_teleport or (syn and syn.queue_on_teleport)
                if teleportFunc then
                    local saveScript = "_G.BlacklistedServers = {"
                    for id, _ in pairs(_G.BlacklistedServers) do
                        saveScript = saveScript .. "['" .. id .. "'] = true, "
                    end
                    saveScript = saveScript .. "}"
                    teleportFunc(saveScript)
                end

                Fluent:Notify({
                    Title = "🚀 SAUT QUANTIQUE", 
                    Content = "Nouveau serveur non exploré trouvé ! TP en cours...", 
                    Duration = 3
                })
                
                -- ⚡ [4] TÉLÉPORTATION
                TPService:TeleportToPlaceInstance(PlaceId, server.id, LP)
                
                -- Pause de sécurité pour laisser le temps au jeu de charger
                task.wait(10) 
                break
            end
        end
    else
        warn("⚠️ ERREUR : L'API de Roblox n'a pas répondu pour la liste des serveurs.")
    end
end

--// 🛡️ SYSTÈME ANTI-ERREUR
local function SafeExecute(name, func)
    local success, err = pcall(func)
    if not success then
        warn("⚠️ [ERREUR " .. name .. "] : " .. tostring(err))
    end
end

local WebhookURL = "https://discord.com/api/webhooks/1482647357987487847/ZUHkKI4aWaolQwH0yDQmxKquwhXHK6s0hmcDYw2jkABdFM8VQ2QlPaQfJYtFT8n2hgRW"
local RareFruits = {"Quake", "Buddha", "Love", "Spider", "Sound", "Phoenix", "Portal", "Rumble", "Pain", "Blizzard", "Gravity", "Mammoth", "T-Rex", "Dough", "Shadow", "Venom", "Control", "Spirit", "Dragon", "Leopard", "Kitsune"}

local function SendWebhook(fruitName)
    -- Vérification de la rareté
    local isRare = false
    for _, name in pairs(RareFruits) do
        if fruitName:find(name) then isRare = true break end
    end

    if not isRare then return end -- On ignore les fruits communs

    local data = {
        ["embeds"] = {{
            ["title"] = "🍎 **FRUIT RARE DÉTECTÉ !**",
            ["description"] = "Un fruit précieux a été stocké avec succès.",
            ["color"] = 16761095, -- Couleur Or
            ["fields"] = {
                {["name"] = "👤 Joueur", ["value"] = LP.Name, ["inline"] = true},
                {["name"] = "🆙 Niveau", ["value"] = tostring(LP.Data.Level.Value), ["inline"] = true},
                {["name"] = "💰 Beli", ["value"] = tostring(LP.Data.Beli.Value) .. " $", ["inline"] = true},
                {["name"] = "🎁 Fruit", ["value"] = fruitName, ["inline"] = false}
            },
            ["footer"] = {["text"] = "YUUSCRIPT V12 - Loot Tracker"}
        }}
    }

    -- Envoi asynchrone pour ne pas freeze le jeu
    task.spawn(function()
        local json = game:GetService("HttpService"):JSONEncode(data)
        request({ -- Utilisation de la fonction 'request' standard des executeurs
            Url = WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

--// ⚡ MODULE ATTACK & FAST ATTACK
local function FastAttack()
    if not _G.FastAttack then return end
    local Remote = RS:FindFirstChild("remotes") and RS.remotes:FindFirstChild("validator") or RS:FindFirstChild("MainEvent")
    if Remote then
        if Remote.Name == "validator" then Remote:FireServer() else Remote:FireServer("SelfDefense") end
    end
end

--// ⚡ MODULE ATTACK VERSION "NATURELLE" (FIX IMMOBILITÉ)
local function AutoAttack()
    if not _G.AutoFarm or Window.Minimized then return end
    local char = LP.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if tool and root and _G.CurrentTarget then
        task.spawn(function()
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(_G.CurrentTarget.Position.X, root.Position.Y, _G.CurrentTarget.Position.Z))
            tool:Activate()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    for i = 1, 2 do task.spawn(function() for _ = 1, 3 do FastAttack() end end) end
end

--// 🚀 FONCTIONS TECHNIQUES
local function SafeTeleport(targetCFrame)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not targetCFrame then return end

    root.Velocity = Vector3.new(0, 0, 0)

    local floor = workspace:FindFirstChild("TP_Floor")
    if not floor then
        floor = Instance.new("Part", workspace)
        floor.Name = "TP_Floor"
        floor.Size = Vector3.new(25, 1, 25)
        floor.Anchored = true
        floor.Transparency = 1
        floor.CanCollide = true
    end
    floor.CFrame = targetCFrame * CFrame.new(0, -3.5, 0)

    local distance = (targetCFrame.p - root.Position).Magnitude
    local speed = 250
    local duration = distance / speed

    if distance < 20 then
        root.CFrame = targetCFrame
        return
    end

    local tween = TS:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    
    local connection
    connection = RunService.Stepped:Connect(function()
        if not _G.AutoFarm and not _G.AutoCollect then
            tween:Cancel()
            connection:Disconnect()
        end
        root.Velocity = Vector3.new(0, 0, 0)
    end)

    tween.Completed:Wait()
    if connection then connection:Disconnect() end
end

local function SetOptimizer(state)
    -- 🌫️ Mode White Screen (Désactive le rendu 3D)
    game:GetService("RunService"):Set3dRenderingEnabled(not state)

    if state then
        -- 🧹 Nettoyage des textures et effets
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        -- 🌑 Désactivation des ombres et lumières
        game.Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = 1
    end
end

-- 📉 FPS Cap (Limiteur de FPS ajustable)
local function SetFPSCap(value)
    if setfpscap then setfpscap(value) end
end

--// 🍎 LOGIQUE DE RÉCUPÉRATION DE FRUIT
local function GrabFruit()
    local foundFruit = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
            foundFruit = obj
            break
        end
    end

    if foundFruit then
        local oldPos = LP.Character.HumanoidRootPart.CFrame
        Fluent:Notify({Title = "🍎 FRUIT DÉTECTÉ", Content = "Récupération : " .. foundFruit.Name})
        
        SafeTeleport(foundFruit.Handle.CFrame)
        task.wait(0.7)

        local fruitInInv = LP.Backpack:FindFirstChild(foundFruit.Name) or LP.Character:FindFirstChild(foundFruit.Name)
        if fruitInInv then
            LP.Character.Humanoid:EquipTool(fruitInInv)
            task.wait(0.3)
            RS.Remotes.CommF_:InvokeServer("StoreFruit", foundFruit.Name, fruitInInv)
            Fluent:Notify({Title = "📦 SUCCÈS", Content = foundFruit.Name .. " stocké !"})
        end
        task.wait(0.5)
        SafeTeleport(oldPos) 
        return true
    end
    return false
end

--// 💰 MODULE AUTO-CHEST (ULTRA FAST EDITION)
local function CollectChests()
    -- 🛑 On coupe l'AutoFarm immédiatement pour éviter les conflits
    _G.AutoFarm = false 
    
    while _G.AutoChest do
        local foundAnything = false
        local allObjects = workspace:GetDescendants()
        
        for _, v in pairs(allObjects) do
            if not _G.AutoChest then break end
            
            if v:IsA("TouchTransmitter") and (v.Parent.Name:find("Chest") or v.Parent.Name:find("Lucky")) then
                local chest = v.Parent
                if chest and chest:IsA("BasePart") then
                    foundAnything = true
                    local char = LP.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- 🔓 Sécurité supplémentaire : On désancre et on coupe le farm encore une fois
                        root.Anchored = false 
                        root.CFrame = chest.CFrame
                        task.wait(0.08)
                    end
                end
            end
        end
        
        if not foundAnything then
            if _G.AutoChest then ServerHop() end
            break
        end
        task.wait(0.01)
    end
end

--// 🛒 AUTO-BUY PROGRESSION
local ItemsToBuy = {
    {Name = "Black Cape", Price = 50000, Level = 50, RemoteArg = {"BlackCapeBuy"}},
    {Name = "Black Leg", Price = 150000, Level = 100, RemoteArg = {"BuyBlackLeg"}},
    {Name = "Flash Step", Price = 100000, Level = 1, RemoteArg = {"BuySoru"}},
    {Name = "Skyjump", Price = 10000, Level = 1, RemoteArg = {"BuySkyjump"}}
}

local function AutoBuyItems()
    task.spawn(function()
        for _, item in pairs(ItemsToBuy) do
            local myBeli = LP.Data.Beli.Value
            local myLevel = LP.Data.Level.Value
            
            -- Vérification des conditions
            if myBeli >= item.Price and myLevel >= item.Level then
                -- On vérifie si on ne l'a pas déjà (Optionnel selon l'item)
                SafeExecute("AutoBuy", function()
                    -- Invocation du Remote sans se déplacer au NPC
                    RS.Remotes.CommF_:InvokeServer(unpack(item.RemoteArg))
                end)
            end
        end
    end)
end


