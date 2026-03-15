local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ CONFIGURATION INITIALE ]] --
_G.TweenSpeed = 100
_G.AutoFarmEnabled = false
_G.SniperEnabled = false
_G.FruitESP = false
_G.AntiAFK = true

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
    SubTitle = "By YUUMA",
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
    Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
}

local Options = Fluent.Options

-- [[ 1. SECTION AUTOFARM ]] --
Tabs.Main:AddParagraph({
    Title = "Gestion du Farm",
    Content = "Progression automatique et intelligente."
})

local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm Global", Default = false })

FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        task.spawn(function()
            local success, err = pcall(function()
                if _G.Autofarm then
                    -- Remplace les noms ci-dessous par les cibles de ton île actuelle
                    _G.Autofarm.Start("Bandit Quest Giver", "BanditQuest1", "Bandit")
                else
                    Fluent:Notify({Title = "Erreur", Content = "Module Autofarm non trouvé sur GitHub !"})
                end
            end)
            if not success then warn("Erreur Autofarm: " .. err) end
        end)
    end
end)

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Déplacement",
    Description = "Vitesse de sécurité : 100 - 150.",
    Default = 100,
    Min = 50,
    Max = 350,
    Rounding = 1,
    Callback = function(Value)
        _G.TweenSpeed = Value
    end
})

-- [[ 2. SECTION SNIPER FRUIT ]] --
Tabs.Items:AddParagraph({
    Title = "Détecteur de Fruits",
    Content = "Collecte automatique avec retour à la position."
})

local SniperToggle = Tabs.Items:AddToggle("FruitSniper", {Title = "Activer Fruit Sniper", Default = false })

SniperToggle:OnChanged(function()
    _G.SniperEnabled = Options.FruitSniper.Value
    if _G.SniperEnabled then
        task.spawn(function()
            while _G.SniperEnabled do
                if _G.FruitSniper then
                    _G.FruitSniper.CheckAndCollect()
                end
                task.wait(2)
            end
        end)
    end
end)

-- [[ 3. SECTION VISUELS ]] --
Tabs.Visuals:AddParagraph({
    Title = "Améliorations Visuelles",
    Content = "Optimise ta vision sur le terrain."
})

-- ESP FRUITS (Fusionné)
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

-- FULLBRIGHT
Tabs.Visuals:AddToggle("FullBright", {Title = "Lumière Infinie", Default = false }):OnChanged(function(Value)
    if Value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
    else
        game:GetService("Lighting").Brightness = 1
    end
end)

-- [[ 4. PARAMÈTRES & SYSTÈME ]] --
Tabs.Settings:AddButton({
    Title = "Détruire l'Interface",
    Description = "Ferme proprement le script.",
    Callback = function()
        Window:Destroy()
    end
})

Tabs.Settings:AddKeybind("MinimizeBind", {
    Title = "Masquer le menu",
    Mode = "Toggle",
    Default = "RightControl",
    Callback = function(Value)
        -- Géré automatiquement par Fluent
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
    Title = "YUUSCRIPT",
    Content = "Système opérationnel. Bonne triche !",
    Duration = 5
})