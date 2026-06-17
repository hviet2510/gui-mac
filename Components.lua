-- Components.lua
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Components = {}

local THEME_FALLBACK = {
	Accent = Color3.fromRGB(10, 132, 255),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(220, 220, 220),
	Card = Color3.fromRGB(52, 52, 54),
	Control = Color3.fromRGB(62, 62, 65),
	Control2 = Color3.fromRGB(58, 58, 60),
	Stroke = Color3.fromRGB(60, 60, 63),
	Track = Color3.fromRGB(90, 90, 93),
	Selected = Color3.fromRGB(58, 58, 60),
}

local function getTheme(Section)
	local theme = Section and Section.Window and Section.Window.Theme
	return theme or THEME_FALLBACK
end

local function Create(className, props, parent)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	obj.Parent = parent
	return obj
end

local function Corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(255, 255, 255)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.85
	s.Parent = parent
	return s
end

local function clamp(v, min, max)
	if v < min then return min end
	if v > max then return max end
	return v
end

function Components.BindSection(Section)
	local theme = getTheme(Section)
	local holder = Section.Instance

	function Section:Button(Options)
		Options = Options or {}

		local button = Create("TextButton", {
			Name = "Button",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.Control,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = Options.Title or "Button",
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = theme.Text,
		}, holder)

		Corner(button, 10)
		Stroke(button, theme.Stroke, 1, 0.85)

		local base = button.BackgroundColor3
		local hover = Color3.fromRGB(
			math.min(base.R * 255 + 6, 255),
			math.min(base.G * 255 + 6, 255),
			math.min(base.B * 255 + 6, 255)
		)

		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = hover,
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = base,
			}):Play()
		end)

		button.MouseButton1Click:Connect(function()
			if Options.Callback then
				Options.Callback()
			end
		end)

		return button
	end

	function Section:Toggle(Options)
		Options = Options or {}

		local state = Options.Default and true or false

		local wrap = Create("Frame", {
			Name = "Toggle",
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = theme.Control2,
			BorderSizePixel = 0,
		}, holder)

		Corner(wrap, 10)
		Stroke(wrap, theme.Stroke, 1, 0.9)

		local label = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -70, 1, 0),
			Text = Options.Title or "Toggle",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.Text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
		}, wrap)

		local sw = Create("Frame", {
			Name = "Switch",
			Size = UDim2.fromOffset(44, 22),
			Position = UDim2.new(1, -56, 0.5, -11),
			BackgroundColor3 = state and theme.Accent or theme.Track,
			BorderSizePixel = 0,
		}, wrap)

		Corner(sw, 999)

		local knob = Create("Frame", {
			Name = "Knob",
			Size = UDim2.fromOffset(18, 18),
			Position = state and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}, sw)

		Corner(knob, 999)

		local function Set(v)
			state = v and true or false

			TweenService:Create(sw, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = state and theme.Accent or theme.Track,
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = state and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2),
			}):Play()

			if Options.Callback then
				Options.Callback(state)
			end
		end

		wrap.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Set(not state)
			end
		end)

		return {
			Instance = wrap,
			Set = Set,
			Get = function()
				return state
			end,
		}
	end

	function Section:Slider(Options)
		Options = Options or {}

		local min = tonumber(Options.Min) or 0
		local max = tonumber(Options.Max) or 100
		local value = tonumber(Options.Default) or min
		value = clamp(value, min, max)

		local dragging = false

		local wrap = Create("Frame", {
			Name = "Slider",
			Size = UDim2.new(1, 0, 0, 54),
			BackgroundColor3 = theme.Control2,
			BorderSizePixel = 0,
		}, holder)

		Corner(wrap, 10)
		Stroke(wrap, theme.Stroke, 1, 0.9)

		local label = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -64, 0, 24),
			Text = Options.Title or "Slider",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.Text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
		}, wrap)

		local valueLabel = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -52, 0, 0),
			Size = UDim2.fromOffset(40, 24),
			Text = tostring(value),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = theme.SubText,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
		}, wrap)

		local bar = Create("Frame", {
			Name = "Bar",
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 6),
			BackgroundColor3 = theme.Track,
			BorderSizePixel = 0,
		}, wrap)

		Corner(bar, 999)

		local fill = Create("Frame", {
			Name = "Fill",
			Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
		}, bar)

		Corner(fill, 999)

		local function Set(v, fire)
			v = clamp(tonumber(v) or min, min, max)
			value = v

			local alpha = (value - min) / math.max(max - min, 1)
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			valueLabel.Text = tostring(math.floor((value * 100 + 0.5)) / 100):gsub("%.00$", "")

			if Options.Callback and fire then
				Options.Callback(value)
			end
		end

		local function updateFromX(x)
			local absPos = bar.AbsolutePosition.X
			local absSize = bar.AbsoluteSize.X
			local alpha = clamp((x - absPos) / math.max(absSize, 1), 0, 1)
			local v = min + ((max - min) * alpha)
			Set(v, true)
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateFromX(input.Position.X)
			end
		end)

		wrap.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateFromX(input.Position.X)
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				updateFromX(input.Position.X)
			end
		end)

		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		return {
			Instance = wrap,
			Set = Set,
			Get = function()
				return value
			end,
		}
	end

	function Section:Textbox(Options)
		Options = Options or {}

		local box = Create("TextBox", {
			Name = "Textbox",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.Control,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = Options.Placeholder or Options.Title or "Enter text",
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = theme.Text,
			PlaceholderColor3 = theme.SubText,
		}, holder)

		Corner(box, 10)
		Stroke(box, theme.Stroke, 1, 0.85)

		if Options.Default then
			box.Text = tostring(Options.Default)
		end

		box.FocusLost:Connect(function(enterPressed)
			if enterPressed and Options.Callback then
				Options.Callback(box.Text)
			end
		end)

		return {
			Instance = box,
			Set = function(_, v)
				box.Text = tostring(v or "")
			end,
			Get = function()
				return box.Text
			end,
		}
	end

	function Section:Dropdown(Options)
		Options = Options or {}

		local values = Options.Values or {}
		local selected = Options.Default

		local wrap = Create("Frame", {
			Name = "Dropdown",
			Size = UDim2.new(1, 0, 0, 36),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, holder)

		local button = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.Control,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
		}, wrap)

		Corner(button, 10)
		Stroke(button, theme.Stroke, 1, 0.85)

		local title = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Text = Options.Title or "Dropdown",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.Text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
		}, button)

		local chevron = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -28, 0, 0),
			Size = UDim2.fromOffset(16, 36),
			Text = "⌄",
			TextColor3 = theme.SubText,
			Font = Enum.Font.GothamMedium,
			TextSize = 16,
		}, button)

		local selectedLabel = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -170, 0, 0),
			Size = UDim2.fromOffset(130, 36),
			Text = selected and tostring(selected) or "Select",
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = theme.SubText,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
		}, button)

		local list = Create("Frame", {
			Name = "List",
			Position = UDim2.fromOffset(0, 40),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
		}, wrap)

		local listPad = Create("UIPadding", {
			PaddingTop = UDim.new(0, 2),
		}, list)

		local listLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, list)

		local expanded = false

		local function setSelected(v, fire)
			selected = v
			selectedLabel.Text = tostring(v or "Select")
			if Options.Callback and fire then
				Options.Callback(v)
			end
		end

		local function setExpanded(v)
			expanded = v and true or false
			list.Visible = expanded
			chevron.Text = expanded and "⌃" or "⌄"
		end

		for _, v in ipairs(values) do
			local opt = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = theme.Control2,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = tostring(v),
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextColor3 = theme.Text,
			}, list)

			Corner(opt, 10)
			Stroke(opt, theme.Stroke, 1, 0.9)

			opt.MouseButton1Click:Connect(function()
				setSelected(v, true)
				setExpanded(false)
			end)
		end

		button.MouseButton1Click:Connect(function()
			setExpanded(not expanded)
		end)

		if selected ~= nil then
			setSelected(selected, false)
		end

		return {
			Instance = wrap,
			Set = function(_, v)
				setSelected(v, true)
			end,
			Get = function()
				return selected
			end,
			Expand = function()
				setExpanded(true)
			end,
			Collapse = function()
				setExpanded(false)
			end,
		}
	end
end

return Components
