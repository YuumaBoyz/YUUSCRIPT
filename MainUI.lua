--[[ 👑 INTERFACE FLUENT V12 ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "👑 YUUSCRIPT [PREMIUM]",
    SubTitle = "Executive Edition",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460),
    Acrylic = false, Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
}

-- 🔘 AUTO FARM TOGGLE
Tabs.Main:AddToggle("AFarm", {Title = "🚀 Démarrer Auto-Farm", Default = false}):OnChanged(function(v)
    _G.Settings.AutoFarm = v
end)

-- 📏 DISTANCE SLIDER
Tabs.Main:AddSlider("FDist", {
    Title = "📏 Distance de Farm",
    Default = 10, Min = 5, Max = 30, Rounding = 0,
    Callback = function(v) _G.Settings.Distance = v end
})

Fluent:Notify({Title = "YUUSCRIPT V12", Content = "Système modulaire chargé !", Duration = 5})