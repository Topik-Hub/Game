Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Topik-Hub/GUI/main/main"))()

-- Настройки окна с улучшенной темой
local Window = Library.CreateLib("TopikHub Premium v2.1", "RJTheme3") 


-- Главная вкладка
local MainTab = Window:NewTab("🏠 Главная")  


local MainSection = MainTab:NewSection("🌟 Премиум функции")

MainSection:NewButton("💰 Продать всё", "Автоматический сбор денег", function()
    -- Максимально простой скрипт для продажи всех предметов (1 раз)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local sellAllRemote = ReplicatedStorage.Source.Utility.Network.Remotes["Item: Sell All"]

    -- Функция продажи
    local function sellAll()
        if sellAllRemote.ClassName == "RemoteEvent" then
            sellAllRemote:FireServer()  -- Отправка без ожидания ответа
        else
            local result = sellAllRemote:InvokeServer()  -- Отправка с ожиданием ответа
        end
    end

    -- Запускаем продажу
    sellAll()
end)

MainSection:NewToggle("🍳 Авто-сбор еды", "Автоматически собирает готовую еду", function(state)
    if state then
        -- Запускаем авто-сбор
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        local SCAN_INTERVAL = 0.5
        local COLLECT_DISTANCE = 15
        
        -- Поиск удаленного события
        local CollectRemote = ReplicatedStorage:FindFirstChild("Source") and
                            ReplicatedStorage.Source:FindFirstChild("Utility") and
                            ReplicatedStorage.Source.Utility:FindFirstChild("Network") and
                            ReplicatedStorage.Source.Utility.Network:FindFirstChild("Remotes") and
                            ReplicatedStorage.Source.Utility.Network.Remotes:FindFirstChild("Plot: Collect")
        
        if not CollectRemote then
            warn("Не найдено удаленное событие для сбора!")
            return
        end
        
        -- Создаем соединение для авто-сбора
        local autoCollectConnection
        autoCollectConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if LocalPlayer and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local cookingFolder = workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild("Cooking")
                    if cookingFolder then
                        local playerFolder = cookingFolder:FindFirstChild(LocalPlayer.Name)
                        if playerFolder then
                            for _, foodItem in ipairs(playerFolder:GetChildren()) do
                                local promptPart = foodItem:FindFirstChild("ProximityPart")
                                if promptPart then
                                    local prompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt and prompt.Enabled then
                                        if (hrp.Position - promptPart.Position).Magnitude <= COLLECT_DISTANCE then
                                            CollectRemote:FireServer(foodItem.Name)
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        -- Сохраняем соединение для последующего отключения
        _G.AutoCollectConnection = autoCollectConnection
    else
        -- Выключаем авто-сбор
        if _G.AutoCollectConnection then
            _G.AutoCollectConnection:Disconnect()
            _G.AutoCollectConnection = nil
        end
    end
end)

MainSection:NewToggle("🔒 Анти-АФК", "Предотвращает отключение за бездействие", function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
end)

local FoodGUISection = MainTab:NewSection("🍽️ ГУИ Еды")

FoodGUISection:NewButton("📲 Открыть интерфейс еды", "Включает/выключает панель управления кухней", function()
    local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local StocksGui = PlayerGui:FindFirstChild("Stocks")
    
    if StocksGui then
        StocksGui.Enabled = not StocksGui.Enabled
    end
end)

  

-- Вкладка игрока
local PlayerTab = Window:NewTab("👤 Игрок") 
local PlayerSection = PlayerTab:NewSection("📊 Характеристики")

local wsSlider = PlayerSection:NewSlider("🚶 Скорость ходьбы", "Стандарт: 16 | Макс: 250", 250, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

local jpSlider = PlayerSection:NewSlider("🦘 Сила прыжка", "Стандарт: 50 | Макс: 200", 200, 50, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)


-- Настройки
local SettingsTab = Window:NewTab("⚙️ Настройки")
local SettingsSection = SettingsTab:NewSection("🔧 Параметры")

SettingsSection:NewKeybind("🔳 Переключить GUI [F]", "Показать/скрыть интерфейс", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)

SettingsSection:NewButton("🖥️ Оптимизация FPS", "Максимальная производительность", function()
    -- Улучшенный код оптимизации
    local settings = {
        Graphics = {
            QualityLevel = "Level01",
            MeshPartDetail = "Level01",
            ShadowQuality = 0,
            WaterQuality = 0
        },
        Lighting = {
            Brightness = 0,
            GlobalShadows = false,
            FogEnd = 9e9,
            OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        },
        Terrain = {
            WaterWaveSize = 0,
            WaterWaveSpeed = 0,
            WaterReflectance = 0,
            WaterTransparency = 1
        }
    }
    
    for service, props in pairs(settings) do
        for prop, value in pairs(props) do
            if game:GetService(service)[prop] ~= nil then
                game:GetService(service)[prop] = value
            end
        end
    end
    
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Оптимизация FPS",
        Text = "Графика была оптимизирована для лучшей производительности",
        Duration = 5
    })
end)

-- Кредиты
local CreditsTab = Window:NewTab("❤️ Благодарности")
local CreditsSection = CreditsTab:NewSection("👨‍💻 Разработчик")

CreditsSection:NewLabel("Версия: 2.1 Premium")
CreditsSection:NewLabel("Создано: Topik#4001")

CreditsSection:NewButton("📋 Копировать Discord", "Скопировать tag разработчика", function()
    local inviteCode = "mfAjWaz2j9" -- Ваш код приглашения
    local discordUrl = "https://discord.gg/"..inviteCode
    
    -- Проверяем доступные методы копирования
    if setclipboard then
        setclipboard(discordUrl)
        
        -- Показываем уведомление об успешном копировании
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ Успешно!",
            Text = "Ссылка на Discord скопирована: discord.gg/"..inviteCode,
            Duration = 5,
            Icon = "rbxassetid://11240648121" -- ID иконки Discord
        })
    else
        -- Альтернативный метод для старых эксплойтов
        local success = pcall(function()
            toclipboard(discordUrl) -- Пробуем старый метод
        end)
        
        if success then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Успешно!",
                Text = "Ссылка скопирована в буфер",
                Duration = 5
            })
        else
            -- Если копирование не удалось, предлагаем альтернативу
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚠️ Внимание",
                Text = "Скопируйте вручную: discord.gg/"..inviteCode,
                Duration = 8,
                Icon = "rbxassetid://11240647910"
            })
        end
    end
    
    -- Дополнительно пытаемся открыть Discord
    pcall(function()
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = game:GetService("HttpService"):JSONEncode({
                cmd = "INVITE_BROWSER",
                nonce = game:GetService("HttpService"):GenerateGUID(false),
                args = {code = inviteCode}
            })
        })
    end)
end)
