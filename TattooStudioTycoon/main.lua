local player = game.Players.LocalPlayer -- Игрок, к которому телепортируем
local character = player.Character or player.CharacterAdded:Wait() -- Персонаж
local humanoidRootPart = character:WaitForChild("HumanoidRootPart") -- Основа персонажа

-- Список объектов, которые нужно телепортировать
local objectsToTeleport = {
    workspace.CrateFolder:GetChildren()[4],
    workspace.CrateFolder:GetChildren()[3],
    workspace.CrateFolder:GetChildren()[6],
    workspace.CrateFolder:GetChildren()[5],
    workspace.CrateFolder:GetChildren()[8],
    workspace.CrateFolder:GetChildren()[7],
    workspace.CrateFolder:GetChildren()[9],
    workspace.CrateFolder:GetChildren()[10],
    workspace.CrateFolder:GetChildren()[11],
    workspace.CrateFolder:GetChildren()[12],
    workspace.CrateFolder:GetChildren()[13],
    workspace.CrateFolder:GetChildren()[14],
    workspace.CrateFolder:GetChildren()[15],
    workspace.CrateFolder:GetChildren()[16],
    workspace.CrateFolder:GetChildren()[17],
    workspace.CrateFolder:GetChildren()[18],
    workspace.CrateFolder:GetChildren()[19],
    workspace.CrateFolder:GetChildren()[20],
    workspace.CrateFolder:GetChildren()[21],
    workspace.CrateFolder:GetChildren()[22],
    workspace.CrateFolder:GetChildren()[28],
    workspace.CrateFolder:GetChildren()[24],
    workspace.CrateFolder:GetChildren()[26],
    workspace.CrateFolder:GetChildren()[25],
    workspace.CrateFolder:GetChildren()[27],
    workspace.CrateFolder:GetChildren()[29],
    workspace.CrateFolder:GetChildren()[30],
    workspace.CrateFolder:GetChildren()[31],
    workspace.CrateFolder:GetChildren()[32],
    workspace.CrateFolder:GetChildren()[33],
    workspace.CrateFolder:GetChildren()[34],
    workspace.CrateFolder.CrateTemplate, -- Отдельный объект (не по индексу)
    workspace.CrateFolder:GetChildren()[23],
    workspace.CrateFolder:GetChildren()[2],
    workspace.CrateFolder:GetChildren()[41],
    workspace.CrateFolder:GetChildren()[40],
    workspace.CrateFolder:GetChildren()[39],
    workspace.CrateFolder:GetChildren()[38],
    workspace.CrateFolder:GetChildren()[37],
    workspace.CrateFolder:GetChildren()[36],
    workspace.CrateFolder:GetChildren()[35],
}

-- Телепортируем каждый объект
for _, obj in ipairs(objectsToTeleport) do
    if obj and obj:IsA("BasePart") then -- Если это часть (Part, MeshPart и т. д.)
        obj.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5, 0) -- Над игроком
        obj.Anchored = true -- Фиксируем, чтобы не падало
    elseif obj and (obj:IsA("Model") or obj:IsA("Folder")) then -- Если это модель или папка
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                child.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                child.Anchored = true
            end
        end
    end
end
