local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ CONFIGURATION INITIALE ]] --
_G.TweenSpeed = 100
_G.AutoFarmEnabled = false
_G.SniperEnabled = false
_G.FruitESP = false
_G.AntiAFK = true
_G.SelectedWeapon = "Combat" -- Valeur par défaut logicielle

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
    Title = "YUUSCRIPT 🚀",
    SubTitle = "By YUUMA - Blox Fruits Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
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
    Title = "Gestion du Farm",
    Content = "Progression automatique et intelligente."
})

-- SÉLECTEUR D'ARME (Placé avant le bouton Start pour la logique)
Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme à utiliser",
    Description = "Sélectionne l'arme à équiper automatiquement.",
    Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass", "Dual Katana", "Iron Mace"},
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
            if _G.Autofarm then
                _G.Autofarm.Start() 
            else
                Fluent:Notify({Title = "Erreur", Content = "Module Autofarm non chargé !"})
            end
        end)
    end
end)

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Déplacement",
    Description = "Ajuste la vitesse du Tween (80-150 recommandé).",
    Default = 100,
    Min = 50,
    Max = 800,
    Rounding = 1,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

-- [[ 2. SECTION SNIPER FRUIT ]] --
Tabs.Items:AddParagraph({
    Title = "Détecteur de Fruits",
    Content = "Collecte automatique avec pause temporaire du farm."
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
Tabs.Visuals:AddParagraph({
    Title = "Améliorations Visuelles",
    Content = "ESP et éclairage."
})

local ESPToggle = Tabs.Visuals:AddToggle("FruitESP", {Title = "ESP Fruits (Murs/Distance)", Default = false })

ESPToggle:OnChanged(function()
    _G.FruitESP = Options.FruitESP.Value
    task.spawn(function()
        while _G.FruitESP do
            if _G.Visuals then
                _G.Visuals.UpdateESP(true)
            end
            task.wait(3)
        end
        if not _G.FruitESP and _G.Visuals then
            _G.Visuals.UpdateESP(false)
        end
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
Tabs.Misc:AddParagraph({
    Title = "Gestion du Serveur",
    Content = "Hop entre les serveurs pour trouver des fruits."
})

Tabs.Misc:AddButton({
    Title = "Server Hop (Rapide)",
    Description = "Rejoint un nouveau serveur public.",
    Callback = function()
        Window:Dialog({
            Title = "Changer de serveur ?",
            Content = "Voulez-vous chercher un nouveau serveur ?",
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
    Description = "Ferme proprement le script.",
    Callback = function()
        Window:Destroy()
    end
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
    Title = "YUUSCRIPT CHARGÉ",
    Content = "Prêt pour le farm avec l'arme sélectionnée !",
    Duration = 5
})