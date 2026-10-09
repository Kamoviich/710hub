-- Obsidian/gold interface. Legacy color keys keep existing widgets compatible.
local COLORS = {
    Black = Color3.fromRGB(15, 17, 22), Black2 = Color3.fromRGB(19, 22, 29),
    Panel = Color3.fromRGB(22, 26, 35), Panel2 = Color3.fromRGB(27, 31, 41),
    Panel3 = Color3.fromRGB(35, 40, 52), Green = Color3.fromRGB(230, 189, 110),
    GreenBright = Color3.fromRGB(255, 225, 169), GreenDark = Color3.fromRGB(48, 43, 33),
    Yellow = Color3.fromRGB(239, 195, 116), YellowSoft = Color3.fromRGB(219, 209, 187),
    White = Color3.fromRGB(238, 241, 248), Muted = Color3.fromRGB(149, 157, 177),
    Off = Color3.fromRGB(78, 87, 106), Red = Color3.fromRGB(244, 107, 122),
    NeonDim = Color3.fromRGB(58, 65, 81), Cyan = Color3.fromRGB(230, 189, 110),
    Success = Color3.fromRGB(113, 220, 175), Border = Color3.fromRGB(54, 61, 77),
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
-- Small line illustrations drawn with native UI, without external image assets.
local function drawIcon(parent, category, size, color)
    local canvas = Instance.new("Frame")
    canvas.Name = "CategoryIcon"; canvas.Size = UDim2.fromOffset(size, size)
    canvas.BackgroundTransparency = 1; canvas.Parent = parent
    local function line(x1, y1, x2, y2)
        local dx, dy = x2-x1, y2-y1
        local part = Instance.new("Frame")
        part.AnchorPoint = Vector2.new(.5, .5)
        part.Position = UDim2.fromScale((x1+x2)/48, (y1+y2)/48)
        part.Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)*size/24, 1.5)
        part.Rotation = math.deg(math.atan2(dy, dx))
        part.BackgroundColor3 = color; part.BorderSizePixel = 0; part.Parent = canvas
        addCorner(part, 2)
    end
    local paths = {
        Farm = {{3,8,3,16},{6,5,6,19},{6,12,18,12},{18,5,18,19},{21,8,21,16}},
        Bosses = {{3,7,6,18},{6,18,18,18},{18,18,21,7},{21,7,16,11},{16,11,12,4},{12,4,8,11},{8,11,3,7}},
        Pets = {{4,9,8,5},{8,5,12,9},{12,9,16,5},{16,5,20,9},{20,9,20,17},{20,17,12,21},{12,21,4,17},{4,17,4,9}},
        Metas = {{4,19,19,4},{11,4,19,4},{19,4,19,12},{4,12,4,20},{4,20,12,20}},
        Perfis = {{5,4,19,4},{19,4,19,20},{19,20,5,20},{5,20,5,4},{9,9,15,9},{9,14,15,14}},
        ["PvP"] = {{5,3,17,19},{3,5,19,17},{4,16,8,20},{16,4,20,8}},
        ["Sessão"] = {{4,19,4,13},{9,19,9,8},{14,19,14,11},{19,19,19,4}},
        Ajustes = {{4,6,20,6},{4,12,20,12},{4,18,20,18},{8,3,8,9},{16,9,16,15},{10,15,10,21}},
    }
    local segments = paths[category] or {{4,19,4,13},{9,19,9,8},{14,19,14,11},{19,19,19,4}}
    for _, points in ipairs(segments) do line(table.unpack(points)) end
    return canvas
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
shadow.Name = "PanelShadow"
shadow.BackgroundColor3 = Color3.new(0, 0, 0); shadow.BackgroundTransparency = .5
shadow.BorderSizePixel = 0; shadow.Parent = gui; addCorner(shadow, 22)
local main = Instance.new("Frame")
main.Name = "Main"; main.BackgroundColor3 = Color3.new(1,1,1); main.BorderSizePixel = 0
main.Active = true; main.Parent = gui; addCorner(main, 18)
addStroke(main, COLORS.Border, 1, .18)
addGradient(main, Color3.fromRGB(22, 25, 33), COLORS.Black, 90)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -40, 0, 58); header.Position = UDim2.fromOffset(20, 16)
header.BackgroundTransparency = 1; header.Active = true; header.Parent = main
local minimize = Instance.new("TextButton")
minimize.Name = "Minimizar"; minimize.Size = UDim2.fromOffset(42, 40)
minimize.Position = UDim2.new(1, 0, 0, 7); minimize.AnchorPoint = Vector2.new(1, 0)
minimize.Text = "−"; minimize.TextSize = 26; minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = COLORS.Muted; minimize.BackgroundColor3 = COLORS.Panel2
minimize.BorderSizePixel = 0; minimize.Parent = header; addCorner(minimize, 10)
-- Shared image source for the header and reopen button.
local brandViews, brandAsset, brandLoading = {}, nil, false
local function attachBrandLogo(holder)
    local artwork = Instance.new("ImageLabel")
    artwork.Name = "710HubLogo"
    artwork.Size = UDim2.new(1, -4, 1, -4)
    artwork.Position = UDim2.fromOffset(2, 2)
    artwork.BackgroundTransparency = 1
    artwork.ScaleType = Enum.ScaleType.Fit
    -- Display the image while fetching: fully transparent images may not load.
    artwork.ImageTransparency = 0
    artwork.ImageRectOffset = Vector2.new(40, 170)
    artwork.ImageRectSize = Vector2.new(1170, 875)
    artwork.Parent = holder
    brandViews[#brandViews + 1] = {Holder = holder, Image = artwork}
    local function loaded()
        if artwork.IsLoaded and holder.Parent then
            holder.TextTransparency = 1
            holder.BackgroundColor3 = COLORS.Black2
            M.LogoStatus = "Logo neon carregada"
        end
    end
    artwork:GetPropertyChangedSignal("IsLoaded"):Connect(loaded)
    if brandAsset then artwork.Image = brandAsset; loaded(); return end
    if brandLoading then return end
    brandLoading = true
    M.LogoStatus = "Carregando logo neon..."
    task.defer(function()
        local asset = type(getcustomasset) == "function" and getcustomasset
            or (type(getsynasset) == "function" and getsynasset)
            or (type(ENV.getcustomasset) == "function" and ENV.getcustomasset)
        if not asset or type(writefile) ~= "function" then
            M.LogoStatus = "Imagem indisponivel: ambiente sem getcustomasset/writefile"
            M:log("Logo", M.LogoStatus)
            return
        end
        local path = "710hub_logo_neon_v2.png"
        local signature = string.char(137, 80, 78, 71, 13, 10, 26, 10)
        local function valid(bytes)
            return type(bytes) == "string" and #bytes == 899743 and bytes:sub(1, 8) == signature
        end
        local ok, err = pcall(function()
            local cached = false
            if type(readfile) == "function" then
                local readOK, bytes = pcall(readfile, path)
                cached = readOK and valid(bytes)
            end
            if not cached then
                local bytes
                for _, url in ipairs({
                    "https://710hub-keys.710hub-key-server.workers.dev/icon.png",
                    "https://raw.githubusercontent.com/Kamoviich/710hub/main/assets/710hub-neon-yellow.png",
                }) do
                    local fetched, data = pcall(function() return game:HttpGet(url, true) end)
                    if fetched and valid(data) then bytes = data; break end
                    if not SESSION.Alive then return end
                end
                assert(bytes, "Nao foi possivel baixar o PNG")
                if not SESSION.Alive then return end
                writefile(path, bytes)
            end
            if not SESSION.Alive then return end
            brandAsset = asset(path)
            assert(type(brandAsset) == "string" and #brandAsset > 0, "Endereco de imagem local invalido")
            for _, view in ipairs(brandViews) do
                if view.Image.Parent then view.Image.Image = brandAsset end
            end
            task.delay(15, function()
                if not SESSION.Alive then return end
                local anyLoaded = false
                for _, view in ipairs(brandViews) do
                    if view.Image.Parent and view.Image.IsLoaded then
                        view.Holder.TextTransparency = 1
                        anyLoaded = true
                    end
                end
                M.LogoStatus = anyLoaded and "Logo neon carregada" or "PNG baixado; o ambiente nao renderizou a imagem local"
                M:log("Logo", M.LogoStatus)
            end)
        end)
        if not ok then
            M.LogoStatus = "Falha na logo: " .. tostring(err)
            M:log("Logo", M.LogoStatus)
        end
    end)
end
do
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(56, 56); logo.Position = UDim2.fromOffset(0, 0)
    logo.Text = "710"; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 18
    logo.TextColor3 = COLORS.Green; logo.BackgroundColor3 = COLORS.Black2
    logo.BorderSizePixel = 0; logo.Parent = header; addCorner(logo, 12)
    addStroke(logo, COLORS.Green, 1, .3)
    attachBrandLogo(logo)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(68, 4); title.Size = UDim2.new(1, -122, 0, 29)
    title.BackgroundTransparency = 1; title.Text = "710 HUB"; title.TextSize = 26
    title.Font = Enum.Font.GothamBlack; title.TextColor3 = COLORS.White
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "BrandSubtitle"
    subtitle.Position = UDim2.fromOffset(69, 34); subtitle.Size = UDim2.new(1, -123, 0, 19)
    subtitle.BackgroundTransparency = 1; subtitle.Text = "MUSCLE LEGENDS  /  CONTROLE DE EVOLUÇÃO"; subtitle.TextSize = 10
    subtitle.Font = Enum.Font.GothamMedium; subtitle.TextColor3 = COLORS.Muted
    subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = header
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1); line.Position = UDim2.fromOffset(20, 78)
    line.BackgroundColor3 = Color3.new(1, 1, 1); line.BorderSizePixel = 0; line.Parent = main
    addGradient(line, COLORS.GreenDark, COLORS.Border, 0)
end
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Conteudo"; scroll.Position = UDim2.fromOffset(16, 169)
scroll.Size = UDim2.new(1, -32, 1, -229); scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.Green; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(); scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true; scroll.Parent = main
do
    local ornament = Instance.new("Frame")
    ornament.Name = "HeaderArt"; ornament.BackgroundTransparency = 1
    ornament.Size = UDim2.fromOffset(64, 40); ornament.Position = UDim2.new(1, -116, 0, 6)
    ornament.Parent = header
    local emblem = drawIcon(ornament, "Farm", 36, COLORS.NeonDim)
    emblem.Position = UDim2.fromOffset(13, 2); emblem.Rotation = -18
    for i = 1, 3 do
        local dash = Instance.new("Frame")
        dash.Size = UDim2.fromOffset(2, 3+i*3); dash.Position = UDim2.fromOffset(i*5, 25)
        dash.BackgroundColor3 = COLORS.NeonDim; dash.BackgroundTransparency = .5
        dash.BorderSizePixel = 0; dash.Rotation = 25; dash.Parent = ornament
    end
end
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 12); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
local searchQuery, currentSection = "", ""
local searchEntries = {}
local UI = {Category = "Farm", CurrentCategory = "Farm", Order = 0, Tabs = {}, Width = 980,
    ContentWidth = 730, LargeText = false, Stats = {}, TabBadges = {}, TabLabels = {}}
UI.Descriptions = {
    Farm = "Treino, equipamentos e ganho de força.", Bosses = "Encontros, defesa e recompensas.",
    PvP = "Jogadores, combate e filtros de karma.", Pets = "Sua coleção, cristais e evolução.",
    Metas = "Planejamento e progresso da conta.", Perfis = "Configurações para cada objetivo.",
    ["Sessão"] = "Rendimento, histórico e diagnóstico.", Ajustes = "Seu painel, atalhos e preferências.",
}
function UI:compact(value)
    value = tonumber(value) or 0
    for _, unit in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
        if math.abs(value) >= unit[1] then return string.format("%.2f%s", value/unit[1], unit[2]) end
    end
    return string.format("%.0f", value)
end
function UI:label(parent, text, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Text = text; label.TextSize = size
    label.TextColor3 = color or COLORS.White; label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left; label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = parent; return label
end
do
    UI.Metrics = Instance.new("Frame")
    UI.Metrics.Name = "ResumoDaConta"; UI.Metrics.BackgroundTransparency = 1; UI.Metrics.Parent = main
    for index, data in ipairs({{"REBIRTHS", "Progresso da sua conta"}, {"FORÇA / MIN", "Rendimento observado"}, {"RITMO DO FARM", "Solicitações de treino"}}) do
        local tile = Instance.new("Frame")
        tile.Name = "Metrica"..index; tile.BackgroundColor3 = COLORS.Panel; tile.BorderSizePixel = 0
        tile.Position = UDim2.new((index-1)/3, (index-1)*4, 0, 0)
        tile.Size = UDim2.new(1/3,-8,1,0); tile.Parent = UI.Metrics
        addCorner(tile,12); addStroke(tile,COLORS.Border,1,.45)
        local heading = UI:label(tile,data[1],10,COLORS.Muted)
        heading.Position = UDim2.fromOffset(14,10); heading.Size = UDim2.new(1,-28,0,14)
        local value = UI:label(tile,"—",25,index == 1 and COLORS.GreenBright or COLORS.White)
        value.Font = Enum.Font.GothamBold; value.Position = UDim2.fromOffset(14,27); value.Size = UDim2.new(1,-28,0,29)
        local hint = UI:label(tile,data[2],10,COLORS.Muted)
        hint.Position = UDim2.fromOffset(14,59); hint.Size = UDim2.new(1,-28,0,15)
        UI.Stats[index] = {Frame=tile,Heading=heading,Value=value,Hint=hint}
    end
    UI.PageTitle = UI:label(main,"Farm",24,COLORS.White)
    UI.PageTitle.Font = Enum.Font.GothamBold
    UI.PageHint = UI:label(main,UI.Descriptions.Farm,11,COLORS.Muted)
    UI.Sidebar = Instance.new("Frame")
    UI.Sidebar.Name = "SidebarSurface"; UI.Sidebar.BackgroundColor3 = COLORS.Black2
    UI.Sidebar.BorderSizePixel = 0; UI.Sidebar.Parent = main
    addCorner(UI.Sidebar,12); addStroke(UI.Sidebar,COLORS.Border,1,.6)
    UI.NavCaption = UI:label(main,"ESPAÇO DE TRABALHO",9,COLORS.Muted)
    UI.VersionBadge = UI:label(main,"710 HUB  •  ML",10,COLORS.Off)
    task.spawn(function()
        while SESSION.Alive do
            UI.Stats[1].Value.Text = UI:compact(currentRebirths())
            local rate = M:strengthRate()
            UI.Stats[2].Value.Text = rate and (UI:compact(rate).." / min") or "Coletando..."
            local interval,reps = M:farmPace()
            UI.Stats[3].Value.Text = string.format("%.0f rep/s",reps/math.max(.001,interval))
            UI.Stats[3].Hint.Text = S.FarmCustom and "Velocidade personalizada" or "Perfil de velocidade ativo"
            task.wait(1)
        end
    end)
end
UI.Groups = {
    ["PVP E KARMA"] = "PvP",
    ["RENDIMENTO E PLANEJAMENTO"] = "Metas", ["BONUS OFICIAIS"] = "Farm",
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
    local count, sections, totals = 0, {}, {}
    for _, entry in ipairs(searchEntries) do
        if not entry.Heading then
            if entry.Available ~= false then totals[entry.Category] = (totals[entry.Category] or 0) + 1 end
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
        if tab:FindFirstChild("SelectedLine") then tab.SelectedLine.Visible = selected end
        tween(tab, .14, {BackgroundColor3 = selected and COLORS.GreenDark or COLORS.Panel2,
            TextColor3 = selected and COLORS.GreenBright or COLORS.Muted})
        if self.TabBadges[category] then self.TabBadges[category].Text = tostring(totals[category] or 0) end
        if self.TabLabels[category] then
            tween(self.TabLabels[category],.14,{TextColor3=selected and COLORS.GreenBright or COLORS.Muted})
        end
    end
    self.PageTitle.Text = searchQuery ~= "" and "Resultados da busca" or self.Category
    self.PageHint.Text = searchQuery ~= "" and (count.." funções encontradas em todas as categorias")
        or (self.Descriptions[self.Category] or "")
    if self.Empty then self.Empty.Visible = count == 0 end
    if resetScroll then scroll.CanvasPosition = Vector2.new() end
end
function UI:resize()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
    self.Width = math.max(280, math.min(980, viewport.X - 28))
    local height = math.max(300, math.min(760, viewport.Y - 40))
    self.Compact = self.Width < 680
    self.Short = height < 560
    local left = self.Compact and 20 or 224
    self.ContentWidth = self.Width - left - 20
    main.Size = UDim2.fromOffset(self.Width, height)
    if header:FindFirstChild("HeaderArt") then header.HeaderArt.Visible = self.Width >= 500 end
    if header:FindFirstChild("BrandSubtitle") then
        header.BrandSubtitle.Text = self.Compact and "MUSCLE LEGENDS" or "MUSCLE LEGENDS  /  CONTROLE DE EVOLUÇÃO"
    end
    main.Position = UDim2.new(.5, -self.Width / 2, .5, -height / 2)
    shadow.Size = UDim2.fromOffset(self.Width + 12, height + 12)
    shadow.Position = UDim2.new(.5, -self.Width / 2 - 6, .5, -height / 2 + 3)
    self.Metrics.Position = UDim2.fromOffset(20,92)
    self.Metrics.Size = UDim2.new(1,-40,0,84)
    self.Metrics.Visible = not self.Short
    self.Sidebar.Visible = not self.Compact
    self.Sidebar.Position = UDim2.fromOffset(20,190); self.Sidebar.Size = UDim2.new(0,184,1,-264)
    self.NavCaption.Visible = not self.Compact
    self.NavCaption.Position = UDim2.fromOffset(34,205); self.NavCaption.Size = UDim2.fromOffset(160,16)
    self.VersionBadge.Visible = not self.Compact
    self.VersionBadge.Position = UDim2.new(0,34,1,-101); self.VersionBadge.Size = UDim2.fromOffset(156,16)
    self.PageTitle.Position = UDim2.fromOffset(left,self.Compact and 283 or 190)
    self.PageTitle.Size = UDim2.new(0,self.ContentWidth,0,30)
    self.PageHint.Position = UDim2.fromOffset(left,self.Compact and 313 or 220)
    self.PageHint.Size = UDim2.new(0,self.ContentWidth,0,18)
    scroll.Position = UDim2.fromOffset(left,self.Compact and 344 or 298)
    scroll.Size = UDim2.new(0,self.ContentWidth,1,self.Compact and -412 or -366)
    if self.Nav then
        self.Nav.Position = UDim2.fromOffset(self.Compact and 20 or 28,self.Compact and 190 or 234)
        self.Nav.Size = self.Compact and UDim2.new(1,-40,0,39) or UDim2.new(0,168,1,-349)
        self.Nav.ScrollingDirection = self.Compact and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
        self.Nav.AutomaticCanvasSize = self.Compact and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
        self.NavLayout.FillDirection = self.Compact and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        for category,tab in pairs(self.Tabs) do
            tab.Size = UDim2.fromOffset(self.Compact and 108 or 168,self.Compact and 36 or 42)
            if self.TabBadges[category] then self.TabBadges[category].Visible = not self.Compact end
            if self.TabLabels[category] then self.TabLabels[category].Size = UDim2.new(1,self.Compact and -42 or -72,0,16) end
        end
    end
    if self.Search then
        self.Search.Position = UDim2.fromOffset(left,self.Compact and 236 or 249)
        self.Search.Size = UDim2.new(0,self.ContentWidth-50,0,38)
    end
    if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,self.Compact and 236 or 249) end
    for _, stat in ipairs(self.Stats) do
        stat.Value.TextSize = self.Compact and 19 or 25
        stat.Heading.TextSize = self.Compact and 8 or 10
        stat.Hint.TextSize = self.Compact and 8 or 10
        stat.Heading.Position = UDim2.fromOffset(self.Compact and 9 or 14,10)
        stat.Value.Position = UDim2.fromOffset(self.Compact and 9 or 14,27)
        stat.Hint.Position = UDim2.fromOffset(self.Compact and 9 or 14,59)
    end
    self.PageTitle.Visible = not (self.Short and self.Compact)
    self.PageHint.Visible = not (self.Short and self.Compact)
    if self.Short then
        self.Sidebar.Position = UDim2.fromOffset(20,96); self.Sidebar.Size = UDim2.new(0,184,1,-170)
        self.NavCaption.Position = UDim2.fromOffset(34,108)
        self.PageTitle.Position = UDim2.fromOffset(left,94)
        self.PageHint.Position = UDim2.fromOffset(left,124)
        scroll.Position = UDim2.fromOffset(left,self.Compact and 184 or 202)
        scroll.Size = UDim2.new(0,self.ContentWidth,1,self.Compact and -252 or -270)
        if self.Nav then
            self.Nav.Position = UDim2.fromOffset(self.Compact and 20 or 28,self.Compact and 92 or 136)
            self.Nav.Size = self.Compact and UDim2.new(1,-40,0,36) or UDim2.new(0,168,1,-253)
        end
        if self.Search then self.Search.Position = UDim2.fromOffset(left,self.Compact and 136 or 154) end
        if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,self.Compact and 136 or 154) end
    end
    for _, entry in ipairs(searchEntries) do if entry.Resize then entry.Resize() end end
end
do
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Categorias"; nav.Position = UDim2.fromOffset(16, 122)
    nav.Size = UDim2.new(1, -32, 0, 39); nav.BackgroundTransparency = 1; nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 2; nav.ScrollBarImageColor3 = COLORS.Cyan
    nav.ScrollingDirection = Enum.ScrollingDirection.X; nav.AutomaticCanvasSize = Enum.AutomaticSize.X
    nav.CanvasSize = UDim2.new(); nav.Parent = main
    UI.Nav = nav
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = nav
    UI.NavLayout = layout
    for index, category in ipairs({"Farm", "Bosses", "PvP", "Pets", "Metas", "Perfis", "Sessão", "Ajustes"}) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.fromOffset(94, 36); tab.Text = ""; tab.Font = Enum.Font.GothamBold
        tab.TextSize = 12; tab.TextColor3 = COLORS.Muted; tab.BackgroundColor3 = COLORS.Panel2
        tab.BorderSizePixel = 0; tab.LayoutOrder = index; tab.Parent = nav; addCorner(tab, 9)
        local icon = drawIcon(tab, category, 17, COLORS.YellowSoft)
        icon.Position = UDim2.fromOffset(10, 12)
        local name = UI:label(tab,category,12,COLORS.Muted)
        name.Position = UDim2.new(0,36,.5,-8); name.Size = UDim2.new(1,-72,0,16)
        UI.TabLabels[category] = name
        local badge = UI:label(tab,"0",10,COLORS.Muted)
        badge.TextXAlignment = Enum.TextXAlignment.Right
        badge.Position = UDim2.new(1,-32,0,13); badge.Size = UDim2.fromOffset(23,16)
        UI.TabBadges[category] = badge
        local indicator = Instance.new("Frame")
        indicator.Name = "SelectedLine"; indicator.Size = UDim2.new(1, -24, 0, 2)
        indicator.Position = UDim2.new(0, 12, 1, -2); indicator.BorderSizePixel = 0
        indicator.BackgroundColor3 = COLORS.Green; indicator.Visible = false; indicator.Parent = tab; addCorner(indicator, 2)
        addStroke(tab, COLORS.NeonDim, 1, .85)
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
    bottom.Size = UDim2.new(1, -40, 0, 44); bottom.Position = UDim2.new(0, 20, 1, -60)
    bottom.BackgroundColor3 = COLORS.Panel; bottom.BorderSizePixel = 0; bottom.Parent = main; addCorner(bottom, 10)
    local pause = Instance.new("TextButton")
    pause.Size = UDim2.fromOffset(90, 32); pause.Position = UDim2.new(1, -198, 0, 5)
    pause.TextSize = 13; pause.Font = Enum.Font.GothamBold; pause.BackgroundColor3 = COLORS.GreenDark
    pause.TextColor3 = COLORS.Green; pause.BorderSizePixel = 0; pause.Parent = bottom; addCorner(pause, 8)
    pause.Activated:Connect(function() M:pause("Manual", not M.Reasons.Manual) end)
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.fromOffset(96, 32); stop.Position = UDim2.new(1, -102, 0, 5)
    stop.Text = "Parar tudo"; stop.TextSize = 13; stop.Font = Enum.Font.GothamBold
    stop.TextColor3 = COLORS.Red; stop.BackgroundColor3 = Color3.fromRGB(47, 27, 36)
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
            status.Text = M:canAct() and "●  Pronto para treinar" or "●  Sessão em pausa"
            status.TextColor3 = M:canAct() and COLORS.Success or COLORS.Yellow
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
    holder.Size = UDim2.new(1, -9, 0, 64); holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0; holder.Parent = scroll
    local entry = UI:addEntry(holder, currentSection, true)
    local badge = Instance.new("Frame")
    badge.Size = UDim2.fromOffset(32, 32); badge.Position = UDim2.fromOffset(0, 6)
    badge.BackgroundColor3 = COLORS.Panel2; badge.BorderSizePixel = 0; badge.Parent = holder
    addCorner(badge, 9); addStroke(badge, COLORS.Border, 1, .6)
    local symbol = drawIcon(badge, UI.CurrentCategory, 22, COLORS.Green)
    symbol.Position = UDim2.fromOffset(5, 5)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(44, 8); title.Size = UDim2.new(1, -4, 0, 24)
    title.BackgroundTransparency = 1; title.Text = name; title.TextSize = 12
    title.TextColor3 = COLORS.YellowSoft; title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextWrapped = true; title.Parent = holder
    local detail = Instance.new("TextLabel")
    detail.Position = UDim2.fromOffset(2, 36); detail.Size = UDim2.new(1, -4, 0, 32)
    detail.Text = desc or ""; detail.TextSize = 14; detail.TextColor3 = COLORS.Muted
    detail.Font = Enum.Font.Gotham; detail.BackgroundTransparency = 1; detail.TextWrapped = true
    detail.TextXAlignment = Enum.TextXAlignment.Left; detail.TextYAlignment = Enum.TextYAlignment.Top; detail.Parent = holder
    entry.Resize = function()
        local width = math.max(80, UI.ContentWidth - 58)
        title.TextSize = UI.LargeText and 15 or 12; detail.TextSize = UI.LargeText and 13 or 11
        local service = game:GetService("TextService")
        local th = service:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(detail.Text, detail.TextSize, detail.Font, Vector2.new(width, 10000)).Y + 4
        title.Size = UDim2.new(1, -48, 0, th); detail.Position = UDim2.fromOffset(44, th + 12)
        detail.Size = UDim2.new(1, -48, 0, dh); holder.Size = UDim2.new(1, -9, 0, th + dh + 20)
    end
    entry.Resize()
end
local availabilityRefs = {}
local function card(titleText, description, callback, accentColor, availableFn)
    local accentColorFinal = accentColor or COLORS.Green
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = COLORS.Panel2; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Text = ""; b.Parent = scroll; addCorner(b, 11)
    local entry = UI:addEntry(b, currentSection .. " " .. titleText .. " " .. (description or ""))
    local stroke = addStroke(b, COLORS.Border, 1, .5)
    addGradient(b, Color3.fromRGB(255,255,255), Color3.fromRGB(217,223,239), 90)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(2, 18); accent.Position = UDim2.fromOffset(0, 16)
    accent.BackgroundColor3 = accentColorFinal; accent.BorderSizePixel = 0; accent.Parent = b; addCorner(accent, 2)
    local t = Instance.new("TextLabel")
    t.Name = "Titre"; t.Position = UDim2.fromOffset(16, 13); t.BackgroundTransparency = 1
    t.Text = titleText; t.TextColor3 = COLORS.White; t.Font = Enum.Font.GothamBold; t.TextSize = 16
    t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top; t.Parent = b
    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1; d.Text = description or ""; d.TextColor3 = COLORS.Muted
    d.Font = Enum.Font.Gotham; d.TextSize = 14; d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left; d.TextYAlignment = Enum.TextYAlignment.Top; d.Parent = b
    local action = UI:label(b,callback and "→" or "INFO",callback and 18 or 8,COLORS.Muted)
    action.Name = "CardAction"; action.Position = UDim2.new(1,-47,0,14)
    action.Size = UDim2.fromOffset(32,20); action.TextXAlignment = Enum.TextXAlignment.Center
    entry.Resize = function()
        local isToggle = b:GetAttribute("IsToggle") == true
        local reserve = isToggle and 108 or 36
        action.Visible = not isToggle
        local width = math.max(80, UI.ContentWidth - 43 - reserve)
        t.TextSize = UI.LargeText and 16 or 14; d.TextSize = UI.LargeText and 13 or 11
        local service = game:GetService("TextService")
        local th = service:GetTextSize(t.Text, t.TextSize, t.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(width, 10000)).Y + 4
        t.Size = UDim2.new(1, -32 - reserve, 0, th)
        d.Position = UDim2.fromOffset(16, 18 + th); d.Size = UDim2.new(1, -32, 0, dh)
        -- Descriptions use the full width below the toggle for easier reading.
        if reserve > 0 then
            dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(math.max(80, UI.ContentWidth - 43), 10000)).Y + 4
            d.Size = UDim2.new(1, -32, 0, dh)
        end
        b.Size = UDim2.new(1, -9, 0, math.max(72, 32 + th + dh))
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
    b.MouseLeave:Connect(function() tween(b, .2, {BackgroundColor3 = COLORS.Panel2}); tween(stroke, .2, {Transparency = .5}) end)
    b.Activated:Connect(function()
        if not isAvailable() then setHubStatus(titleText .. " indisponível nesta sessão"); return end
        tween(stroke, .1, {Transparency = 0})
        task.delay(.2, function() if b.Parent then tween(stroke, .2, {Transparency = .5}) end end)
        if callback then task.spawn(callback, b, t, d) end
    end)
    return b, t, d, stroke, renderAvailability
end
