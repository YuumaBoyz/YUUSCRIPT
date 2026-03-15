local Visuals = {}
local folderName = "FruitESP_Folder"

-- Nettoyage au cas où le script est relancé
if workspace:FindFirstChild(folderName) then
    workspace[folderName]:Destroy()
end

local espFolder = Instance.new("Folder", workspace)
espFolder.Name = folderName

function Visuals.CreateESP(part, text)
    if part:FindFirstChild("FruitESP") then return end
    
    local bgui = Instance.new("BillboardGui", part)
    bgui.Name = "FruitESP"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local nametag = Instance.new("TextLabel", bgui)
    nametag.Text = "🍎 " .. text
    nametag.Size = UDim2.new(1, 0, 1, 0)
    nametag.BackgroundTransparency = 1
    nametag.TextColor3 = Color3.fromRGB(255, 50, 50) -- Rouge vif
    nametag.TextSchema = Enum.Font.GothamBold
    nametag.TextSize = 14
    nametag.TextStrokeTransparency = 0
end

function Visuals.UpdateESP(enabled)
    espFolder:ClearAllChildren()
    if not enabled then return end
    
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
            if item:FindFirstChild("Handle") then
                Visuals.CreateESP(item.Handle, item.Name)
            end
        end
    end
end

return Visuals