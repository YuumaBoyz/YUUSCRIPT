local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ CONFIGURATION INITIALE ]] --
_G.TweenSpeed = 300 -- Vitesse optimisée
_G.AutoFarmEnabled = false
_G.SniperEnabled = false
_G.FruitESP = false
_G.AntiAFK = true
_G.BypassGates = true -- Nouveau
_G.SafeMode = false    -- Nouveau (Arrêt si Admin/Hunter proche)
_G.SelectedWeapon = "Combat"

-- [[ FONCTION SERVER HOP ]] --
local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, s in pairs(Servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceId, s.id)
            break
        end
    end
end

-- [[ PROTECTION ANTI-AFK ]] --
if _G.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    game.Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- [[ CRÉATION DE LA FENÊTRE ]] --
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT 🚀 V3.0",
    SubTitle = "By YUUMA - Ultimate Blox Fruits",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520), -- Légèrement plus grand pour les nouvelles options
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- [[ ONGLETS ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Items = Window:AddTab({ Title = "Items & Fruits", Icon = "apple" }),
    Visuals = Window:AddTab({ Title = "Visuels", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Serveur & Misc", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
}

local Options = Fluent.Options

-- [[ 1. SECTION AUTOFARM ]] --
Tabs.Main:AddParagraph({
    Title = "Gestion du Farm Sea 1",
    Content = "Le farm utilise désormais le système de Bypass Gates."
})

-- SÉLECTEUR D'ARME AMÉLIORÉ
local WeaponDropdown = Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme à utiliser",
    Description = "L'arme sera équipée automatiquement avant chaque combat.",
    Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass", "Dual Katana", "Iron Mace", "Soul Cane", "Bisentor"},
    Default = "Combat",
    Callback = function(Value)
        _G.SelectedWeapon = Value
    end
})

local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm Global", Default = false })

FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        task.spawn(function()
            if _G.AutofarmPro then
                _G.AutofarmPro.Start() 
            else
                Fluent:Notify({Title = "⚠️ Erreur", Content = "Module Autofarm Pro (Sea 1) non détecté !"})
            end
        end)
    end
end)

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Vol",
    Description = "300 recommandé pour la Sea 1.",
    Default = 300,
    Min = 50,
    Max = 800,
    Rounding = 1,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

-- NOUVELLE SECTION PHYSIQUE
Tabs.Main:AddParagraph({ Title = "Options de Physique" })

Tabs.Main:AddToggle("BypassGates", {Title = "Bypass Gates (Traverser Portes)", Default = true}):OnChanged(function(v)
    _G.BypassGates = v
end)

Tabs.Main:AddToggle("SafeMode", {Title = "Safe Mode (Anti-Admin/Bounty)", Default = false}):OnChanged(function(v)
    _G.SafeMode = v
    if v then
        task.spawn(function()
            while _G.SafeMode do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= game.Players.LocalPlayer and p:GetRoleInGroup(2830838) ~= "Guest" then -- Détecte les staffs
                        _G.AutoFarmEnabled = false
                        Options.AutoFarm:SetValue(false)
                        Fluent:Notify({Title = "🚨 ALERT", Content = "Admin détecté ! Farm stoppé."})
                        break
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

-- [[ 2. SECTION SNIPER FRUIT ]] --
Tabs.Items:AddParagraph({
    Title = "Inventaire & Fruits",
    Content = "Le sniper récolte et stocke automatiquement."
})

local SniperToggle = Tabs.Items:AddToggle("FruitSniper", {Title = "Activer Fruit Sniper Pro", Default = false })

SniperToggle:OnChanged(function()
    _G.SniperEnabled = Options.FruitSniper.Value
    if _G.SniperEnabled then
        task.spawn(function()
            while _G.SniperEnabled do
                if _G.FruitSniper then
                    pcall(function() _G.FruitSniper.CheckAndCollect() end)
                end
                task.wait(1.5)
            end
        end)
    end
end)

-- [[ 3. SECTION VISUELS ]] --
local ESPToggle = Tabs.Visuals:AddToggle("FruitESP", {Title = "ESP Fruits", Default = false })

ESPToggle:OnChanged(function()
    _G.FruitESP = Options.FruitESP.Value
    task.spawn(function()
        while _G.FruitESP do
            if _G.Visuals then _G.Visuals.UpdateESP(true) end
            task.wait(3)
        end
        if _G.Visuals then _G.Visuals.UpdateESP(false) end
    end)
end)

Tabs.Visuals:AddToggle("FullBright", {Title = "Lumière Infinie", Default = false }):OnChanged(function(Value)
    if Value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
    else
        game:GetService("Lighting").Brightness = 1
    end
end)

-- [[ 4. SECTION SERVEUR & MISC ]] --
Tabs.Misc:AddButton({
    Title = "Server Hop (Rapide)",
    Description = "Idéal pour chercher des coffres ou fruits.",
    Callback = function()
        Window:Dialog({
            Title = "Changer de serveur ?",
            Content = "Voulez-vous chercher un nouveau serveur public ?",
            Buttons = {
                { Title = "Oui", Callback = function() ServerHop() end },
                { Title = "Annuler" }
            }
        })
    end
})

Tabs.Misc:AddToggle("AntiAFK_Toggle", {Title = "Protection Anti-AFK", Default = true}):OnChanged(function(v)
    _G.AntiAFK = v
end)

-- [[ 5. PARAMÈTRES SYSTÈME ]] --
Tabs.Settings:AddButton({
    Title = "Détruire l'Interface",
    Callback = function() Window:Destroy() end
})

-- [[ FINALISATION ]] --
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "YUUSCRIPT V3.0 CHARGÉ",
    Content = "Farming Sea 1 prêt avec " .. _G.SelectedWeapon .. " !",
    Duration = 5
})