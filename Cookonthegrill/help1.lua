--[[
  MeatShop AutoBuy — модуль для TopikHub GUI
  Загружается с GitHub, добавляет вкладку 🛒 Автопокупка

  Зависимости:
    - Библиотека TopikHub (Window:NewTab, NewDropdown, NewToggle, NewSlider, NewButton)
    - Игра с MeatShop в PlayerGui
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
                                                local stock = item:GetChildren()[5]:FindFirstChild("StockLabel")
                                                local stxt = stock and stock.Text or ""
                                                if stxt=="Always In Stock" or (stxt:find("In Stock") and tonumber(stxt:match("%d+") or 0)>0) then
                                                    remote:FireServer(name)
                                                    task.wait(0.3)
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

    -- Dropdown предметов (создаём раньше, чтоб раздел мог его обновить)
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

    -- Dropdown разделов
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

    -- Список
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

    print("✅ MeatShop AutoBuy загружен!")
end
