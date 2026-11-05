-- Garante que não duplique a UI se executar mais de uma vez
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("DeltaFloatingUI") then
    CoreGui.DeltaFloatingUI:Destroy()
end

-- Criação do ScreenGui principal na CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFloatingUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botão Flutuante (Floating Button)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = IntegerFontSize or 18
ToggleButton.Active = true
ToggleButton.Draggable = true -- Permite arrastar o botão flutuante pela tela

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0) -- Deixa o botão totalmente redondo
UICornerBtn.Parent = ToggleButton

local UIStrokeBtn = Instance.new("UIStroke")
UIStrokeBtn.Color = Color3.fromRGB(80, 80, 100)
UIStrokeBtn.Thickness = 2
UIStrokeBtn.Parent = ToggleButton

-- Janela Principal
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Parent = ScreenGui
MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainWindow.Position = UDim2.new(0.5, -150, 0.5, -100)
MainWindow.Size = UDim2.new(0, 300, 0, 200)
MainWindow.Visible = começaFechado or false -- Inicia fechada
MainWindow.Active = true
MainWindow.Draggable = true -- Permite arrastar a janela principal

local UICornerWindow = Instance.new("UICorner")
UICornerWindow.CornerRadius = UDim.new(0, 8)
UICornerWindow.Parent = MainWindow

local UIStrokeWindow = Instance.new("UIStroke")
UIStrokeWindow.Color = Color3.fromRGB(60, 60, 80)
UIStrokeWindow.Thickness = 2
UIStrokeWindow.Parent = MainWindow

-- Barra Superior da Janela (Título)
local TopBar = Instance.new("TextLabel")
TopBar.Name = "TopBar"
TopBar.Parent = MainWindow
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.Font = Enum.Font.GothamBold
TopBar.Text = "  Painel Delta"
TopBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TopBar.TextSize = 14
TopBar.TextXAlignment = Enum.TextXAlignment.Left

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 8)
UICornerTop.Parent = TopBar

-- Botão de Fechar dentro da Janela (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = CloseButton

-- Função para Abrir e Fechar a Janela
local function ToggleUI()
    MainWindow.Visible = not MainWindow.Visible
end

ToggleButton.MouseButton1Click:Connect(ToggleUI)
CloseButton.MouseButton1Click:Connect(ToggleUI)

print("Interface flutuante carregada com sucesso!")
