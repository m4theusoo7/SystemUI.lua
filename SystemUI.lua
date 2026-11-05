--[[
    Cokka Hub UI Replacement
    - API compatível com o Cokka Hub original
    - Tema escuro + roxo/ciano (estilo Cokka)
    - Funciona no Delta (Instance.new only)
    - Sem dependência de servidor externo
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ============ TEMA ============
local THEME = {
    BG        = Color3.fromRGB(18, 18, 22),
    BG2       = Color3.fromRGB(26, 26, 32),
    BG3       = Color3.fromRGB(34, 34, 42),
    ACCENT    = Color3.fromRGB(138, 43, 226),   -- roxo Cokka
    ACCENT2   = Color3.fromRGB(0, 200, 255),    -- ciano
    TEXT      = Color3.fromRGB(230, 230, 240),
    TEXT_DIM  = Color3.fromRGB(150, 150, 165),
    STROKE    = Color3.fromRGB(60, 60, 75),
    GREEN     = Color3.fromRGB(80, 220, 120),
    RED       = Color3.fromRGB(230, 80, 80),
}

-- ============ HELPERS ============
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, parent)
end

local function stroke(parent, color, thick)
    return new("UIStroke", {
        Color = color or THEME.STROKE,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(parent, p)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p), PaddingRight = UDim.new(0, p),
    }, parent)
end

local function gradient(parent, c1, c2, rot)
    return new("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 90,
    }, parent)
end

local guiName = "CokkaHubUI_" .. tostring(math.random(1, 1e9))
local rootGui = new("ScreenGui", {
    Name = guiName,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, (gethui and gethui()) or game:GetService("CoreGui"))

-- ============ CLASSES ============
local UI = {}
UI.__index = UI

-- --- WINDOW ---
function UI:Window(title, keybind)
    local win = {}
    local self_ = self

    local main = new("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 560, 0, 400),
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundColor3 = THEME.BG,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
    }, rootGui)
    corner(main, 10)
    stroke(main, THEME.STROKE, 1)

    -- Header
    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = THEME.BG2,
        BorderSizePixel = 0,
    }, main)
    corner(header, 10)
    gradient(header, THEME.ACCENT, THEME.ACCENT2, 0)

    new("TextLabel", {
        Text = "  " .. title,
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = THEME.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
    }, header)

    local closeBtn = new("TextButton", {
        Text = "X",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -36, 0, 5),
        BackgroundColor3 = THEME.RED,
        TextColor3 = THEME.TEXT,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
    }, header)
    corner(closeBtn, 6)

    -- Tab bar (esquerda)
    local tabBar = new("Frame", {
        Size = UDim2.new(0, 140, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = THEME.BG2,
        BorderSizePixel = 0,
    }, main)

    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabBar)
    padding(tabBar, 6)

    -- Content area
    local content = new("Frame", {
        Size = UDim2.new(1, -140, 1, -40),
        Position = UDim2.new(0, 140, 0, 40),
        BackgroundColor3 = THEME.BG,
        BorderSizePixel = 0,
    }, main)

    local currentTab = nil
    local tabs = {}

    -- Botão de fechar
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    -- Keybind toggle
    if keybind then
        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == keybind then
                main.Visible = not main.Visible
            end
        end)
    end

    -- API: Tab
    function win:Tab(name)
        local btn = new("TextButton", {
            Text = name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = THEME.BG3,
            TextColor3 = THEME.TEXT_DIM,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        }, tabBar)
        corner(btn, 6)

        local page = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = THEME.ACCENT,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
        }, content)

        new("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        padding(page, 10)

        local tabObj = {}

        local function activate()
            if currentTab then currentTab.Visible = false end
            page.Visible = true
            currentTab = page
            for _, b in pairs(tabs) do
                b.btn.BackgroundColor3 = THEME.BG3
                b.btn.TextColor3 = THEME.TEXT_DIM
            end
            btn.BackgroundColor3 = THEME.ACCENT
            btn.TextColor3 = THEME.TEXT
        end

        btn.MouseButton1Click:Connect(activate)
        table.insert(tabs, { btn = btn, page = page })

        if #tabs == 1 then activate() end

        -- === Elementos da aba ===

        function tabObj:Toggle(text, state, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = THEME.BG3,
                BorderSizePixel = 0,
            }, page)
            corner(row, 6)

            new("TextLabel", {
                Text = text,
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = THEME.TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13,
            }, row)

            local knobBg = new("Frame", {
                Size = UDim2.new(0, 36, 0, 18),
                Position = UDim2.new(1, -46, 0.5, -9),
                BackgroundColor3 = state and THEME.ACCENT or THEME.BG2,
                BorderSizePixel = 0,
            }, row)
            corner(knobBg, 9)

            local knob = new("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = THEME.TEXT,
                BorderSizePixel = 0,
            }, knobBg)
            corner(knob, 7)

            local click = new("TextButton", {
                Text = "",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, row)

            local current = state and true or false
            if callback then pcall(callback, current) end

            click.MouseButton1Click:Connect(function()
                current = not current
                if current then
                    TweenService:Create(knobBg, TweenInfo.new(0.15), { BackgroundColor3 = THEME.ACCENT }):Play()
                    TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(1, -16, 0.5, -7) }):Play()
                else
                    TweenService:Create(knobBg, TweenInfo.new(0.15), { BackgroundColor3 = THEME.BG2 }):Play()
                    TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0.5, -7) }):Play()
                end
                if callback then pcall(callback, current) end
            end)

            return { Set = function(_, v) current = v end }
        end

        function tabObj:Slider(text, min, max, default, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = THEME.BG3,
                BorderSizePixel = 0,
            }, page)
            corner(row, 6)

            new("TextLabel", {
                Text = text,
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 10, 0, 4),
                BackgroundTransparency = 1,
                TextColor3 = THEME.TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13,
            }, row)

            local valLabel = new("TextLabel", {
                Text = tostring(default),
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -60, 0, 4),
                BackgroundTransparency = 1,
                TextColor3 = THEME.ACCENT2,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
            }, row)

            local barBg = new("Frame", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 1, -14),
                BackgroundColor3 = THEME.BG2,
                BorderSizePixel = 0,
            }, row)
            corner(barBg, 3)

            local pct = (default - min) / (max - min)
            local fill = new("Frame", {
                Size = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = THEME.ACCENT,
                BorderSizePixel = 0,
            }, barBg)
            corner(fill, 3)
            gradient(fill, THEME.ACCENT, THEME.ACCENT2, 0)

            local click = new("TextButton", {
                Text = "",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, barBg)

            local dragging = false
            local function setFromX(x)
                local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * rel + 0.5)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valLabel.Text = tostring(val)
                if callback then pcall(callback, val) end
            end

            click.MouseButton1Down:Connect(function()
                dragging = true
                setFromX(UIS:GetMouseLocation().X)
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    setFromX(input.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            if callback then pcall(callback, default) end
            return { Set = function(_, v) valLabel.Text = tostring(v) end }
        end

        function tabObj:Dropdown(text, list, default, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = THEME.BG3,
                BorderSizePixel = 0,
                ClipsDescendants = false,
            }, page)
            corner(row, 6)

            new("TextLabel", {
                Text = text,
                Size = UDim2.new(1, -110, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = THEME.TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13,
            }, row)

            local selected = default or (list[1] or "")
            local selLabel = new("TextButton", {
                Text = selected .. " ▼",
                Size = UDim2.new(0, 100, 0, 24),
                Position = UDim2.new(1, -108, 0.5, -12),
                BackgroundColor3 = THEME.BG2,
                TextColor3 = THEME.ACCENT2,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0,
            }, row)
            corner(selLabel, 4)

            local dropdown = new("ScrollingFrame", {
                Size = UDim2.new(0, 100, 0, 0),
                Position = UDim2.new(1, -108, 1, 2),
                BackgroundColor3 = THEME.BG2,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                Visible = false,
                ZIndex = 10,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
            }, row)
            corner(dropdown, 4)
            stroke(dropdown, THEME.STROKE, 1)
            new("UIListLayout", { Padding = UDim.new(0, 2) }, dropdown)
            padding(dropdown, 3)

            local function rebuild()
                for _, c in ipairs(dropdown:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, item in ipairs(list) do
                    local opt = new("TextButton", {
                        Text = item,
                        Size = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = THEME.BG3,
                        TextColor3 = THEME.TEXT,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        BorderSizePixel = 0,
                        ZIndex = 11,
                    }, dropdown)
                    corner(opt, 3)
                    opt.MouseButton1Click:Connect(function()
                        selected = item
                        selLabel.Text = selected .. " ▼"
                        dropdown.Visible = false
                        if callback then pcall(callback, selected) end
                    end)
                end
                dropdown.Size = UDim2.new(0, 100, 0, math.min(#list * 24 + 6, 150))
            end
            rebuild()

            selLabel.MouseButton1Click:Connect(function()
                dropdown.Visible = not dropdown.Visible
            end)

            if callback then pcall(callback, selected) end
            return {
                Add = function(_, item) table.insert(list, item); rebuild() end,
                Set = function(_, item) selected = item; selLabel.Text = item .. " ▼" end,
            }
        end

        function tabObj:Button(text, callback)
            local btn = new("TextButton", {
                Text = text,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = THEME.BG3,
                TextColor3 = THEME.TEXT,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, page)
            corner(btn, 6)
            stroke(btn, THEME.STROKE, 1)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = THEME.ACCENT }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = THEME.BG3 }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
            end)
        end

        function tabObj:Label(text)
            local lbl = new("TextLabel", {
                Text = text,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = THEME.BG2,
                TextColor3 = THEME.ACCENT2,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                BorderSizePixel = 0,
            }, page)
            corner(lbl, 4)
            return {
                Set = function(_, t) lbl.Text = t end,
            }
        end

        function tabObj:Label1(text)
            return tabObj:Label(text)
        end

        function tabObj:Line()
            new("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = THEME.STROKE,
                BorderSizePixel = 0,
            }, page)
        end

        function tabObj:Textbox(text, placeholder, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = THEME.BG3,
                BorderSizePixel = 0,
            }, page)
            corner(row, 6)

            new("TextLabel", {
                Text = text,
                Size = UDim2.new(0, 120, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = THEME.TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 12,
            }, row)

            local box = new("TextBox", {
                Text = "",
                PlaceholderText = placeholder or "",
                Size = UDim2.new(1, -140, 0, 22),
                Position = UDim2.new(0, 130, 0.5, -11),
                BackgroundColor3 = THEME.BG2,
                TextColor3 = THEME.TEXT,
                PlaceholderColor3 = THEME.TEXT_DIM,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
            }, row)
            corner(box, 4)
            stroke(box, THEME.STROKE, 1)

            box.FocusLost:Connect(function()
                if callback then pcall(callback, box.Text) end
            end)
        end

        return tabObj
    end

    return win
end

-- ============ FACTORY ============
local factory = {}
factory.__index = factory
function factory:Window(...) return UI:Window(...) end

return setmetatable({}, factory)
