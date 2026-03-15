-- [[ 👁️ YUUSCRIPT V3.0 - VISUALS ENGINE (ESP EDITION) ]] --

local Visuals = {}
local folderName = "FruitESP_Folder"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- **NETTOYAGE INITIAL** 🧹
if workspace:FindFirstChild(folderName) then
    workspace[folderName]:Destroy()
end

local espFolder = Instance.new("Folder", workspace)
espFolder.Name = folderName

-- [[ 🛠️ FONCTION DE CRÉATION DE L'ESP ]] --
function Visuals.CreateESP(part, text)
    -- On vérifie si l'ESP existe déjà pour ne pas dupliquer
    if part:FindFirstChild("FruitESP") then return end
    
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "FruitESP"
    bgui.Parent = part
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local nametag = Instance.new("TextLabel")
    nametag.Parent = bgui
    nametag.Text = "🍎 **" .. text:upper() .. "** 🍎" -- Texte en gras et majuscule
    nametag.Size = UDim2.new(1, 0, 1, 0)
    nametag.BackgroundTransparency = 1
    nametag.TextColor3 = Color3.fromRGB(255, 50, 50) -- **ROUGE VIF**
    nametag.Font = Enum.Font.GothamBold
    nametag.TextSize = 16
    nametag.TextStrokeTransparency = 0 -- Contour noir pour la lisibilité
    nametag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
end

-- [[ 🔄 BOUCLE DE MISE À JOUR AUTOMATIQUE ]] --
-- **Cette partie tourne en arrière-plan pour détecter les nouveaux fruits**
task.spawn(function()
    while task.wait(2) do -- Vérifie toutes les 2 secondes pour économiser les ressources
        if _G.FruitESP_Enabled then
            for _, item in pairs(workspace:GetChildren()) do
                -- Détection : soit c'est un outil (Tool), soit il a "Fruit" dans le nom
                if (item:IsA("Tool") or item.Name:find("Fruit")) and not item:IsA("Terrain") then
                    local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part") or item:FindFirstChildOfClass("MeshPart")
                    
                    if handle then
                        Visuals.CreateESP(handle, item.Name)
                    end
                end
            end
        else
            -- Si désactivé, on nettoie les labels existants
            for _, item in pairs(workspace:GetChildren()) do
                local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part")
                if handle and handle:FindFirstChild("FruitESP") then
                    handle.FruitESP:Destroy()
                end
            end
        end
    end
end)

-- [[ 🚀 FONCTION DE CONTRÔLE VIA L'UI ]] --
function Visuals.UpdateESP(enabled)
    _G.FruitESP_Enabled = enabled
    if not enabled then
        print("❌ ESP Désactivé")
    else
        print("✅ ESP Activé")
    end
end

return Visuals