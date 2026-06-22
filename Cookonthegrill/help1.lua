--[[
  MeatShop AutoBuy — модуль для TopikHub GUI v2
  Покупает ВСЁ доступное количество за цикл
]]

return function(Window)
    local remote = game:GetService("ReplicatedStorage").Remotes.BuyMeat
    local content = game:GetService("Players").LocalPlayer.PlayerGui.MeatShop.Main.Content
    local WantList = {}
    local Running = false
    local Interval = 10
    local CurrentItems = {}
    local itemDropdown = nil

    local function ParsePrice(text)
        if not text then return 0 end
        local s = text:gsub("%$",""):gsub(",","")
        local n = tonumber(s)
        if n then return n end
        n = tonumber(s:sub(1,-3)) or tonumber(s:sub(1,-2)) or 0
        local suf = s:sub(-2)
        if suf=="Qa" then return n*1e15 end
        if suf=="Qi" then return n*1e18 end
        if suf=="Sx" then return n*1e24 end
        if suf=="Sp" then return n*1e27 end
        suf = s:sub(-1)
        return n * ({K=1e3,M=1e6,B=1e9,T=1e12})[suf] or 1
    end

    -- Сколько штук доступно для покупки
    local function GetStockCount(item)
        local label = item:GetChildren()[5]:FindFirstChild("StockLabel")
        if not label then return 0 end
        local t = label.Text
        if t == "Always In Stock" then return math.huge end
        if t == "Out of Stock" then return 0 end
        return tonumber(t:match("In Stock: (%d+)")) or 0
    end

    -- Вкладка
    local Tab = Window:NewTab("🛒 Автопокупка")
    local Ctrl = Tab:NewSection("⚙️ Управление")

    Ctrl:NewToggle("🤖 Вкл/Выкл", "", function(state)
        Running = state
        if state then
            task.spawn(function()
                while Running do
                    for _, page in ipairs(content:GetChildren()) do
                        if page:IsA("ScrollingFrame") then
                            for _, item in ipairs(page:GetChildren()) do
                                if item:IsA("Frame") then
                                    local lbl = item:GetChildren()[5]:FindFirstChild("NameLabel")
                                    local name = lbl and lbl.Text or ""
                                    if name ~= "" then
                                        for _, want in ipairs(WantList) do
                                            if want.name == name then
                                                local stock = GetStockCount(item)
                                                local toBuy = stock == math.huge and 9999 or stock
                                                local bought = 0
                                                for i = 1, toBuy do
                                                    remote:FireServer(name)
                                                    bought = bought + 1
                                                    task.wait(0.2)
                                                end
                                                if bought > 0 then
                                                    print("✅ " .. name .. " x" .. bought)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(Interval)
                end
            end)
        end
    end)

    Ctrl:NewSlider("⏱ Интервал (сек)", "", 30, 10, function(v) Interval = v end)

    itemDropdown = Ctrl:NewDropdown("📦 Предмет", "Выбери и добавь в список", {"сначала выбери раздел"}, function(sel)
        if sel == "сначала выбери раздел" then return end
        for _, v in ipairs(CurrentItems) do
            if v.name == sel then
                for _, w in ipairs(WantList) do
                    if w.name == sel then
                        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "⚠️", Text = "Уже в списке", Duration = 2})
                        return
                    end
                end
                table.insert(WantList, {name = sel, maxPrice = v.price * 2})
                local txt = ""
                for _, w in ipairs(WantList) do txt = txt .. w.name .. ", " end
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "✅ Добавлено", Text = txt, Duration = 3})
                return
            end
        end
    end)

    local pageShort = {"Common","Uncommon","Rare","Legendary","Mythic","Exotic","Unknown","Secret","Impossible"}
    local pageNames = {"CommonPage","UncommonPage","RarePage","LegendaryPage","MythicPage","ExoticPage","UnknownPage","SecretPage","ImpossiblePage"}

    Ctrl:NewDropdown("📁 Раздел", "Выбери раздел магазина", pageShort, function(sel)
        local idx = nil
        for i, v in ipairs(pageShort) do
            if v == sel then idx = i; break end
        end
        if not idx then return end
        local page = content:FindFirstChild(pageNames[idx])
        if not page then return end

        CurrentItems = {}
        local names = {}
        for _, item in ipairs(page:GetChildren()) do
            if item:IsA("Frame") then
                local lbl = item:GetChildren()[5]:FindFirstChild("NameLabel")
                local name = lbl and lbl.Text or ""
                if name ~= "" then
                    local priceBtn = item:GetChildren()[6]:FindFirstChild("MoneyBtn")
                    local price = priceBtn and ParsePrice(priceBtn.Text) or 0
                    table.insert(CurrentItems, {name = name, price = price})
                    table.insert(names, name)
                end
            end
        end
        if #names > 0 and itemDropdown and itemDropdown.Refresh then
            itemDropdown.Refresh(itemDropdown, names)
        end
    end)

    local List = Tab:NewSection("📋 Мои предметы")
    List:NewButton("🧹 Очистить список", "", function() WantList = {} end)
    List:NewButton("📜 Показать список", "", function()
        if #WantList == 0 then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "📋", Text = "Список пуст", Duration = 2})
            return
        end
        local msg = ""
        for i, w in ipairs(WantList) do msg = msg .. i .. ". " .. w.name .. "\n" end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "📋 ("..#WantList..")", Text = msg, Duration = 5})
    end)

    print("✅ MeatShop AutoBuy v2 — покупает всё количество!")
end
