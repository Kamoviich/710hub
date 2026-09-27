-- 710Hub: public loader. Contains no owner credential, key list or menu source.
local SERVER_URL = "https://710hub-keys.710hub-key-server.workers.dev"
local env = (getgenv and getgenv()) or _G
local previousHub = env.__710HubSession
if previousHub then
    previousHub.Alive = false
    if previousHub.Cleanup then pcall(previousHub.Cleanup) end
end
local old = env.__710HubKeySession
if old then
    old.Alive = false
    if old.Hub and old.Hub.Cleanup then pcall(old.Hub.Cleanup) end
end
local control = {Alive = true}
env.__710HubKeySession = control
local players = game:GetService("Players")
local deadline = os.clock() + 30
while not players.LocalPlayer and os.clock() < deadline do task.wait(.1) end
local player = assert(players.LocalPlayer, "710Hub: jogador indisponivel")
local parent = assert(player:WaitForChild("PlayerGui", 15), "710Hub: PlayerGui indisponivel")
local previous = parent:FindFirstChild("710Hub_Key")
if previous then previous:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_Key"; gui.ResetOnSpawn = false; gui.DisplayOrder = 200; gui.Parent = parent
local frame = Instance.new("Frame")
frame.Size = UDim2.new(.88, 0, 0, 310); frame.Position = UDim2.new(.5, 0, .5, 0)
frame.AnchorPoint = Vector2.new(.5, .5); frame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
frame.BorderSizePixel = 0; frame.Parent = gui
local constraint = Instance.new("UISizeConstraint"); constraint.MaxSize = Vector2.new(500, 310); constraint.Parent = frame
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 16); corner.Parent = frame
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(255, 238, 0); stroke.Thickness = 2; stroke.Parent = frame
local function label(text, y, height, size, color)
    local item = Instance.new("TextLabel")
    item.Position = UDim2.fromOffset(22, y); item.Size = UDim2.new(1, -44, 0, height)
    item.BackgroundTransparency = 1; item.Text = text; item.TextSize = size; item.TextWrapped = true
    item.Font = Enum.Font.Gotham; item.TextColor3 = color; item.Parent = frame; return item
end
label("710Hub", 20, 35, 28, Color3.fromRGB(255, 238, 0)).Font = Enum.Font.GothamBlack
label("Acesso autorizado", 58, 25, 17, Color3.new(1, 1, 1))
label("Insira a key fornecida pelo proprietario.", 87, 42, 15, Color3.fromRGB(210, 210, 195))
local input = Instance.new("TextBox")
input.Position = UDim2.fromOffset(22, 137); input.Size = UDim2.new(1, -44, 0, 43)
input.BackgroundColor3 = Color3.fromRGB(28, 28, 24); input.BorderSizePixel = 0
input.TextColor3 = Color3.new(1, 1, 1); input.Text = ""; input.PlaceholderText = "710-..."
input.TextSize = 15; input.ClearTextOnFocus = false; input.Parent = frame
local button = Instance.new("TextButton")
button.Position = UDim2.fromOffset(22, 190); button.Size = UDim2.new(1, -44, 0, 42)
button.BackgroundColor3 = Color3.fromRGB(255, 238, 0); button.TextColor3 = Color3.new(0, 0, 0)
button.Font = Enum.Font.GothamBold; button.TextSize = 17; button.Text = "Liberar menu"
button.BorderSizePixel = 0; button.Parent = frame
local status = label("A key e validada online. Nao compartilhe seu acesso.", 244, 53, 14, Color3.fromRGB(210, 210, 195))
local httpRequest = request or http_request or (syn and syn.request)
local busy = false
local function http(path, method, token, data)
    assert(type(httpRequest) == "function", "Este ambiente nao oferece requisicoes HTTP com cabecalhos.")
    assert(SERVER_URL:match("^https://") and not SERVER_URL:find("__SERVER_URL__", 1, true), "Servidor de keys ainda nao configurado.")
    local headers = { ["Content-Type"] = "application/json" }
    if token then headers.Authorization = "Bearer " .. token end
    local result, failure, completed = nil, nil, false
    task.spawn(function()
        local ok, response = pcall(httpRequest, {
            Url = SERVER_URL .. path, Method = method, Headers = headers,
            Body = data and game:GetService("HttpService"):JSONEncode(data) or nil,
        })
        if ok then result = response else failure = "Falha de rede. Tente novamente." end
        completed = true
    end)
    local limit = os.clock() + 20
    while not completed and control.Alive and os.clock() < limit do task.wait(.1) end
    assert(control.Alive, "Carregamento cancelado.")
    assert(completed, "O servidor demorou para responder.")
    assert(not failure, failure)
    assert(type(result) == "table" and type(result.Body) == "string", "Resposta HTTP invalida.")
    local code = tonumber(result.StatusCode or result.Status)
    if not code or code < 200 or code >= 300 then
        local ok, parsed = pcall(function() return game:GetService("HttpService"):JSONDecode(result.Body) end)
        error(ok and parsed.error or "Nao foi possivel validar o acesso.", 0)
    end
    return result.Body
end
local function lock(reason)
    if not control.Alive then return end
    control.Alive = false
    if control.Hub and control.Hub == env.__710HubSession then
        control.Hub.Alive = false
        if control.Hub.Cleanup then pcall(control.Hub.Cleanup) end
    end
    if gui.Parent then
        gui.Enabled = true; status.Text = reason .. " Execute o carregador novamente."
        input.Text = ""; button.Text = "Acesso encerrado"; button.Active = false
    end
end
button.Activated:Connect(function()
    if busy or not control.Alive then return end
    busy = true; button.Text = "Validando..."; status.Text = "Conectando ao servidor..."
    local key = input.Text:match("^%s*(.-)%s*$")
    local ok, failure = pcall(function()
        assert(#key == 68 and key:match("^710%-%x+$"), "Confira a key recebida.")
        local activation = game:GetService("HttpService"):JSONDecode(http("/api/activate", "POST", nil, {key = key}))
        input.Text = ""; key = nil
        assert(type(activation.token) == "string", "Resposta de autorizacao invalida.")
        local source = http("/api/script", "GET", activation.token)
        local chunk, compileError = loadstring(source, "=710Hub autorizado")
        assert(chunk, compileError)
        chunk()
        assert(control.Alive, "Carregamento substituido.")
        control.Hub = env.__710HubSession
        assert(control.Hub and control.Hub.Alive, "O menu nao iniciou. Consulte o aviso do 710Hub.")
        gui.Enabled = false
        task.spawn(function()
            while control.Alive do
                task.wait(60)
                if not control.Alive then break end
                if not control.Hub.Alive then control.Alive = false; gui:Destroy(); break end
                local valid = pcall(function() http("/api/session", "GET", activation.token) end)
                if not valid then lock("Nao foi possivel renovar a autorizacao."); break end
            end
        end)
    end)
    busy = false
    if not ok and control.Alive then status.Text = tostring(failure); button.Text = "Tentar novamente" end
end)
