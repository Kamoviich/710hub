-- Black/yellow neon theme. Legacy color keys keep existing widgets compatible.
local COLORS = {
    Black = Color3.fromRGB(5, 5, 5), Black2 = Color3.fromRGB(12, 12, 12),
    Panel = Color3.fromRGB(17, 17, 15), Panel2 = Color3.fromRGB(23, 23, 20),
    Panel3 = Color3.fromRGB(37, 36, 21), Green = Color3.fromRGB(255, 238, 0),
    GreenBright = Color3.fromRGB(255, 250, 115), GreenDark = Color3.fromRGB(61, 54, 5),
    Yellow = Color3.fromRGB(255, 238, 0), YellowSoft = Color3.fromRGB(255, 248, 155),
    White = Color3.fromRGB(250, 249, 239), Muted = Color3.fromRGB(205, 204, 190),
    Off = Color3.fromRGB(125, 124, 112), Red = Color3.fromRGB(255, 184, 42),
    NeonDim = Color3.fromRGB(116, 103, 10), Cyan = Color3.fromRGB(255, 211, 0),
}
local function addCorner(obj, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 10); item.Parent = obj; return item
end
local function addStroke(obj, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color; item.Thickness = thickness or 1
    item.Transparency = transparency or 0; item.Parent = obj; return item
end
local function addGradient(obj, first, second, rotation)
    local item = Instance.new("UIGradient")
    item.Color = ColorSequence.new(first, second); item.Rotation = rotation or 0
    item.Parent = obj; return item
end
local function tween(obj, duration, goal)
    TweenService:Create(obj, TweenInfo.new(duration or .16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end
local guiParent = assert(LP:WaitForChild("PlayerGui", 10), "PlayerGui indisponivel")
local oldGui = guiParent:FindFirstChild("710Hub_MuscleLegends")
if oldGui then oldGui:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_MuscleLegends"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = guiParent
local baseCleanup = SESSION.Cleanup
SESSION.Cleanup = function()
    pcall(baseCleanup)
    if gui then gui:Destroy() end
end
local shadow = Instance.new("Frame")
shadow.BackgroundColor3 = Color3.new(0, 0, 0); shadow.BackgroundTransparency = .35
shadow.BorderSizePixel = 0; shadow.Parent = gui; addCorner(shadow, 22)
local main = Instance.new("Frame")
main.Name = "Main"; main.BackgroundColor3 = COLORS.Black; main.BorderSizePixel = 0
main.Active = true; main.Parent = gui; addCorner(main, 18)
addStroke(main, COLORS.Cyan, 1.5, .3)
addGradient(main, COLORS.Black, Color3.fromRGB(17, 16, 7), 70)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -32, 0, 58); header.Position = UDim2.fromOffset(16, 8)
header.BackgroundTransparency = 1; header.Active = true; header.Parent = main
local minimize = Instance.new("TextButton")
minimize.Name = "Minimizar"; minimize.Size = UDim2.fromOffset(42, 40)
minimize.Position = UDim2.new(1, 0, 0, 7); minimize.AnchorPoint = Vector2.new(1, 0)
minimize.Text = "−"; minimize.TextSize = 26; minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = COLORS.Cyan; minimize.BackgroundColor3 = COLORS.Panel2
minimize.BorderSizePixel = 0; minimize.Parent = header; addCorner(minimize, 10)
do
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(48, 44); logo.Position = UDim2.fromOffset(0, 6)
    logo.Text = "710"; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 18
    logo.TextColor3 = COLORS.Green; logo.BackgroundColor3 = COLORS.GreenDark
    logo.BorderSizePixel = 0; logo.Parent = header; addCorner(logo, 12)
    addStroke(logo, COLORS.Green, 1, .3)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(60, 4); title.Size = UDim2.new(1, -114, 0, 29)
    title.BackgroundTransparency = 1; title.Text = "710Hub"; title.TextSize = 25
    title.Font = Enum.Font.GothamBlack; title.TextColor3 = COLORS.White
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(61, 34); subtitle.Size = UDim2.new(1, -115, 0, 19)
    subtitle.BackgroundTransparency = 1; subtitle.Text = "MUSCLE LEGENDS"; subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamMedium; subtitle.TextColor3 = COLORS.Cyan
    subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = header
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -32, 0, 2); line.Position = UDim2.fromOffset(16, 65)
    line.BackgroundColor3 = Color3.new(1, 1, 1); line.BorderSizePixel = 0; line.Parent = main
    local gradient = addGradient(line, COLORS.Green, COLORS.Cyan, 0)
    local animation = TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(.6, 0)})
    animation:Play()
    gui.Destroying:Connect(function() animation:Cancel() end)
end
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Conteudo"; scroll.Position = UDim2.fromOffset(16, 169)
scroll.Size = UDim2.new(1, -32, 1, -229); scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = COLORS.Green; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(); scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true; scroll.Parent = main
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
local searchQuery, currentSection = "", ""
local searchEntries = {}
local UI = {Category = "Farm", CurrentCategory = "Farm", Order = 0, Tabs = {}, Width = 650, LargeText = false}
UI.Groups = {
    ["FARM"] = "Farm", ["MÁQUINAS"] = "Farm", ["AGILIDADE"] = "Farm", ["FARM INTELIGENTE"] = "Farm",
    ["BOSSES"] = "Bosses", ["PROTECAO E BOSSES"] = "Bosses", ["PETS E CRISTAIS"] = "Pets",
    ["METAS"] = "Metas", ["PROGRESSAO"] = "Metas", ["METAS E COMPARACAO"] = "Metas",
    ["PERFIS RÁPIDOS"] = "Perfis", ["CONTROLE E PERFIS"] = "Perfis",
    ["SESSÃO"] = "Sessão", ["DIAGNÓSTICO"] = "Sessão", ["HISTORICO E COMPATIBILIDADE"] = "Sessão",
    ["UTILIDADES"] = "Ajustes", ["TELEPORTES"] = "Ajustes",
}
function UI:normalize(text)
    text = string.lower(text)
    for accented, plain in pairs({["á"]="a",["à"]="a",["ã"]="a",["â"]="a",["é"]="e",["ê"]="e",["í"]="i",["ó"]="o",["ô"]="o",["õ"]="o",["ú"]="u",["ç"]="c",["Á"]="a",["Ã"]="a",["É"]="e",["Í"]="i",["Ó"]="o",["Ú"]="u",["Ç"]="c",["Õ"]="o"}) do
        text = string.gsub(text, accented, plain)
    end
    return text
end
function UI:addEntry(object, text, heading)
    self.Order += 1; object.LayoutOrder = self.Order
    local entry = {Object = object, Text = self:normalize(text), Category = self.CurrentCategory,
        Section = currentSection, Heading = heading == true, Available = true}
    searchEntries[#searchEntries + 1] = entry
    return entry
end
function UI:matches(entry)
    if searchQuery ~= "" then return string.find(entry.Text, searchQuery, 1, true) ~= nil end
    return entry.Category == self.Category
end
function UI:refresh(resetScroll, animate)
    local count, sections = 0, {}
    for _, entry in ipairs(searchEntries) do
        if not entry.Heading then
            local visible = entry.Available ~= false and self:matches(entry)
            entry.Object.Visible = visible
            if visible then count += 1; sections[entry.Section] = true end
            if visible and animate then
                entry.Object.BackgroundTransparency = .45
                tween(entry.Object, .2, {BackgroundTransparency = 0})
            end
        end
    end
    for _, entry in ipairs(searchEntries) do
        if entry.Heading then entry.Object.Visible = sections[entry.Section] == true end
    end
    for category, tab in pairs(self.Tabs) do
        local selected = searchQuery == "" and category == self.Category
        tween(tab, .14, {BackgroundColor3 = selected and COLORS.GreenDark or COLORS.Panel2,
            TextColor3 = selected and COLORS.GreenBright or COLORS.Muted})
    end
    if self.Empty then self.Empty.Visible = count == 0 end
    if resetScroll then scroll.CanvasPosition = Vector2.new() end
end
function UI:resize()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
    self.Width = math.max(280, math.min(740, viewport.X - 28))
    local height = math.max(280, math.min(690, viewport.Y - 60))
    main.Size = UDim2.fromOffset(self.Width, height)
    main.Position = UDim2.new(.5, -self.Width / 2, .5, -height / 2)
    shadow.Size = UDim2.fromOffset(self.Width + 10, height + 10)
    shadow.Position = UDim2.new(.5, -self.Width / 2 - 5, .5, -height / 2 + 1)
    for _, entry in ipairs(searchEntries) do if entry.Resize then entry.Resize() end end
end
do
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Categorias"; nav.Position = UDim2.fromOffset(16, 122)
    nav.Size = UDim2.new(1, -32, 0, 39); nav.BackgroundTransparency = 1; nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 2; nav.ScrollBarImageColor3 = COLORS.Cyan
    nav.ScrollingDirection = Enum.ScrollingDirection.X; nav.AutomaticCanvasSize = Enum.AutomaticSize.X
    nav.CanvasSize = UDim2.new(); nav.Parent = main
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = nav
    for index, category in ipairs({"Farm", "Bosses", "Pets", "Metas", "Perfis", "Sessão", "Ajustes"}) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.fromOffset(87, 34); tab.Text = category; tab.Font = Enum.Font.GothamBold
        tab.TextSize = 14; tab.TextColor3 = COLORS.Muted; tab.BackgroundColor3 = COLORS.Panel2
        tab.BorderSizePixel = 0; tab.LayoutOrder = index; tab.Parent = nav; addCorner(tab, 9)
        UI.Tabs[category] = tab
        tab.Activated:Connect(function()
            UI.Category = category
            if UI.Search then UI.Search.Text = "" end
            searchQuery = ""
            UI:refresh(true, true)
        end)
    end
    local empty = Instance.new("TextLabel")
    empty.Size = UDim2.new(1, -16, 0, 90); empty.Text = "Nenhuma função encontrada.\nTente outra busca ou categoria."
    empty.TextSize = 16; empty.TextColor3 = COLORS.Muted; empty.TextWrapped = true
    empty.BackgroundTransparency = 1; empty.Visible = false; empty.Parent = scroll; UI.Empty = empty
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, -32, 0, 42); bottom.Position = UDim2.new(0, 16, 1, -50)
    bottom.BackgroundColor3 = COLORS.Panel; bottom.BorderSizePixel = 0; bottom.Parent = main; addCorner(bottom, 10)
    local pause = Instance.new("TextButton")
    pause.Size = UDim2.fromOffset(90, 32); pause.Position = UDim2.new(1, -198, 0, 5)
    pause.TextSize = 13; pause.Font = Enum.Font.GothamBold; pause.BackgroundColor3 = COLORS.GreenDark
    pause.TextColor3 = COLORS.Green; pause.BorderSizePixel = 0; pause.Parent = bottom; addCorner(pause, 8)
    pause.Activated:Connect(function() M:pause("Manual", not M.Reasons.Manual) end)
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.fromOffset(96, 32); stop.Position = UDim2.new(1, -102, 0, 5)
    stop.Text = "Parar tudo"; stop.TextSize = 13; stop.Font = Enum.Font.GothamBold
    stop.TextColor3 = COLORS.Red; stop.BackgroundColor3 = Color3.fromRGB(49, 35, 8)
    stop.BorderSizePixel = 0; stop.Parent = bottom; addCorner(stop, 8)
    stop.Activated:Connect(stopAllAutomations)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -214, 1, 0); status.Position = UDim2.fromOffset(10, 0)
    status.BackgroundTransparency = 1; status.TextColor3 = COLORS.Green; status.TextSize = 13
    status.Font = Enum.Font.GothamMedium; status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd; status.Parent = bottom
    task.spawn(function()
        while SESSION.Alive do
            pause.Text = M.Reasons.Manual and "Retomar" or "Pausar"
            status.Text = M:canAct() and "● Pronto" or "● Em pausa"
            status.TextColor3 = M:canAct() and COLORS.Green or COLORS.Yellow
            task.wait(.5)
        end
    end)
    local dragging, origin, position, touch = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; origin = input.Position; position = main.Position; touch = input
        end
    end)
    trackConnection(UIS.InputEnded:Connect(function(input)
        if input == touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    trackConnection(UIS.InputChanged:Connect(function(input)
        if not dragging or not (input.UserInputType == Enum.UserInputType.MouseMovement or input == touch) then return end
        local delta = input.Position - origin
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
        local x = position.X.Scale * viewport.X + position.X.Offset + delta.X
        local y = position.Y.Scale * viewport.Y + position.Y.Offset + delta.Y
        main.Position = UDim2.fromOffset(math.clamp(x, 0, math.max(0, viewport.X - main.Size.X.Offset)),
            math.clamp(y, 0, math.max(0, viewport.Y - main.Size.Y.Offset - 40)))
        shadow.Position = main.Position + UDim2.fromOffset(-5, 1)
    end))
    local cameraConnection
    local function watchViewport()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then
            cameraConnection = trackConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() UI:resize() end))
        end
        UI:resize()
    end
    trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport))
    watchViewport()
end
local function section(name, desc)
    currentSection = name .. " " .. (desc or "")
    UI.CurrentCategory = UI.Groups[name] or "Ajustes"
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -9, 0, 70); holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0; holder.Parent = scroll
    local entry = UI:addEntry(holder, currentSection, true)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(2, 8); title.Size = UDim2.new(1, -4, 0, 24)
    title.BackgroundTransparency = 1; title.Text = name; title.TextSize = 17
    title.TextColor3 = COLORS.Green; title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextWrapped = true; title.Parent = holder
    local detail = Instance.new("TextLabel")
    detail.Position = UDim2.fromOffset(2, 36); detail.Size = UDim2.new(1, -4, 0, 32)
    detail.Text = desc or ""; detail.TextSize = 14; detail.TextColor3 = COLORS.Muted
    detail.Font = Enum.Font.Gotham; detail.BackgroundTransparency = 1; detail.TextWrapped = true
    detail.TextXAlignment = Enum.TextXAlignment.Left; detail.TextYAlignment = Enum.TextYAlignment.Top; detail.Parent = holder
    entry.Resize = function()
        local width = math.max(100, UI.Width - 48)
        title.TextSize = UI.LargeText and 19 or 17; detail.TextSize = UI.LargeText and 16 or 14
        local service = game:GetService("TextService")
        local th = service:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(detail.Text, detail.TextSize, detail.Font, Vector2.new(width, 10000)).Y + 4
        title.Size = UDim2.new(1, -4, 0, th); detail.Position = UDim2.fromOffset(2, th + 12)
        detail.Size = UDim2.new(1, -4, 0, dh); holder.Size = UDim2.new(1, -9, 0, th + dh + 20)
    end
    entry.Resize()
end
local availabilityRefs = {}
local function card(titleText, description, callback, accentColor, availableFn)
    local accentColorFinal = accentColor or COLORS.Green
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = COLORS.Panel2; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Text = ""; b.Parent = scroll; addCorner(b, 12)
    local entry = UI:addEntry(b, currentSection .. " " .. titleText .. " " .. (description or ""))
    local stroke = addStroke(b, accentColorFinal, 1, .7)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(3, 24); accent.Position = UDim2.fromOffset(0, 16)
    accent.BackgroundColor3 = accentColorFinal; accent.BorderSizePixel = 0; accent.Parent = b; addCorner(accent, 2)
    local t = Instance.new("TextLabel")
    t.Name = "Titre"; t.Position = UDim2.fromOffset(16, 13); t.BackgroundTransparency = 1
    t.Text = titleText; t.TextColor3 = COLORS.White; t.Font = Enum.Font.GothamBold; t.TextSize = 16
    t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top; t.Parent = b
    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1; d.Text = description or ""; d.TextColor3 = COLORS.Muted
    d.Font = Enum.Font.Gotham; d.TextSize = 14; d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left; d.TextYAlignment = Enum.TextYAlignment.Top; d.Parent = b
    entry.Resize = function()
        local reserve = b:GetAttribute("IsToggle") and 108 or 0
        local width = math.max(100, UI.Width - 75 - reserve)
        t.TextSize = UI.LargeText and 18 or 16; d.TextSize = UI.LargeText and 16 or 14
        local service = game:GetService("TextService")
        local th = service:GetTextSize(t.Text, t.TextSize, t.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(width, 10000)).Y + 4
        t.Size = UDim2.new(1, -32 - reserve, 0, th)
        d.Position = UDim2.fromOffset(16, 18 + th); d.Size = UDim2.new(1, -32, 0, dh)
        -- Descriptions use the full width below the toggle for easier reading.
        if reserve > 0 then
            dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(math.max(100, UI.Width - 75), 10000)).Y + 4
            d.Size = UDim2.new(1, -32, 0, dh)
        end
        b.Size = UDim2.new(1, -9, 0, math.max(78, 32 + th + dh))
    end
    entry.Resize()
    t:GetPropertyChangedSignal("Text"):Connect(entry.Resize)
    d:GetPropertyChangedSignal("Text"):Connect(entry.Resize)
    b:GetAttributeChangedSignal("IsToggle"):Connect(entry.Resize)
    local function isAvailable()
        if not availableFn then return true end
        local ok, available = pcall(availableFn); return ok and available == true
    end
    local function renderAvailability()
        entry.Available = isAvailable(); b.Visible = entry.Available and UI:matches(entry)
    end
    if availableFn then availabilityRefs[#availabilityRefs + 1] = renderAvailability end
    b.MouseEnter:Connect(function() tween(b, .16, {BackgroundColor3 = COLORS.Panel3}); tween(stroke, .16, {Transparency = .15}) end)
    b.MouseLeave:Connect(function() tween(b, .2, {BackgroundColor3 = COLORS.Panel2}); tween(stroke, .2, {Transparency = .7}) end)
    b.Activated:Connect(function()
        if not isAvailable() then setHubStatus(titleText .. " indisponível nesta sessão"); return end
        tween(stroke, .1, {Transparency = 0})
        task.delay(.2, function() if b.Parent then tween(stroke, .2, {Transparency = .7}) end end)
        if callback then task.spawn(callback, b, t, d) end
    end)
    return b, t, d, stroke, renderAvailability
end
