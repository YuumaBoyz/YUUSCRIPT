local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initialisation de la fenêtre
local Window = Fluent:CreateWindow({
    Title = "Blox Fruit Discret Edition",
    SubTitle = "par AI Assistant",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

-- Création des Onglets
local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Items = Window:AddTab({ Title = "Items & Fruits", Icon = "apple" }),
    Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
}

--- 1. SECTION AUTOFARM ---
local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false })

FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = FarmToggle.Value
    if _G.AutoFarmEnabled then
        -- On lance la boucle dans un thread séparé pour ne pas freeze l'UI
        task.spawn(function()
            local Autofarm = require(game.ReplicatedStorage.Scripts.Autofarm)
            Autofarm.Start("Bandit Quest Giver", "BanditQuest1", "Bandit")
        end)
    end
end)

--- 2. SECTION SNIPER FRUIT ---
local SniperToggle = Tabs.Items:AddToggle("FruitSniper", {Title = "Fruit Sniper Auto-TP", Default = false })

SniperToggle:OnChanged(function()
    _G.SniperEnabled = SniperToggle.Value
    task.spawn(function()
        while _G.SniperEnabled do
            local Sniper = require(game.ReplicatedStorage.Scripts.FruitSniper)
            Sniper.CheckForFruits()
            task.wait(2) -- Vérification toutes les 2 secondes
        end
    end)
end)

--- 3. SECTION CONFIGURATION ---
Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Déplacement",
    Description = "Ajuste la vitesse du Tween (Discrétion)",
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

-- Finalisation
Window:SelectTab(1)
Fluent:Notify({
    Title = "Script Chargé",
    Content = "Bonne progression autonome !",
    Duration = 5
})