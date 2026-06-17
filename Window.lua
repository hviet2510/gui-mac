-- Window.lua
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Components = require(script.Parent.Components)

local Window = {}
Window.__index = Window

local DEFAULT_THEME = {
	Background = Color3.fromRGB(28, 28, 30),
	Sidebar = Color3.fromRGB(36, 36, 38),
	Content = Color3.fromRGB(44, 44, 46),
	Card = Color3.fromRGB(52, 52, 54),
	Accent = Color3.fromRGB(10, 132, 255),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(220, 220, 220),
	Stroke = Color3.fromRGB(60, 60, 63),
	Selected = Color3.fromRGB(58, 58, 60),
}

local function create(className, props, parent)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	obj.Parent = parent
	return obj
end

local function corner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 12),
	}, parent)
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	}, parent)
end

local function listLayout(parent, paddingY)
	return create("UIListLayout", {
		Padding = UDim.new(0, paddingY or 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, parent)
end

function Window.new(options)
	options = options or {}
	local theme = options.Theme or DEFAULT_THEME

	local self = setmetatable({}, Window)
	self.Theme = theme
	self.Tabs = {}
	self.ActiveTab = nil

	local gui = create("ScreenGui", {
		Name = "MacUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, CoreGui)

	local mainSize = options.Size
	if not mainSize then
		if UIS.TouchEnabled then
			mainSize = UDim2.fromScale(0.95, 0.8)
		else
			mainSize = UDim2.fromOffset(760, 480)
		end
	end

	local main = create("Frame", {
		Name = "Main",
		Size = mainSize,
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
	}, gui)
	corner(main, 18)

	create("UIStroke", {
		Thickness = 1,
		Transparency = 0.7,
		Color = theme.Stroke,
	}, main)

	local topBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
	}, main)

	local function dot(color, x)
		local f = create("Frame", {
			Size = UDim2.fromOffset(12, 12),
			Position = UDim2.fromOffset(x, 13),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, topBar)
		corner(f, 999)
		return f
	end

	dot(Color3.fromRGB(255, 95, 87), 14)
	dot(Color3.fromRGB(255, 189, 46), 34)
	dot(Color3.fromRGB(40, 200, 64), 54)

	create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "MacUI",
		TextColor3 = theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, topBar)

	create("Frame", {
		Name = "Separator",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 38),
		BackgroundColor3 = theme.Stroke,
		BorderSizePixel = 0,
	}, main)

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 180, 1, -39),
		Position = UDim2.fromOffset(0, 39),
		BackgroundColor3 = theme.Sidebar,
		BorderSizePixel = 0,
	}, main)
	padding(sidebar, 8, 8, 12, 8)
	listLayout(sidebar, 6)

	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -180, 1, -39),
		Position = UDim2.fromOffset(180, 39),
		BackgroundColor3 = theme.Content,
		BorderSizePixel = 0,
	}, main)

	local card = create("Frame", {
		Name = "Card",
		Size = UDim2.new(1, -30, 1, -30),
		Position = UDim2.fromOffset(15, 15),
		BackgroundColor3 = theme.Card,
		BorderSizePixel = 0,
	}, content)
	corner(card, 14)

	create("UIStroke", {
		Thickness = 1,
		Transparency = 0.8,
		Color = theme.Stroke,
	}, card)

	local pages = create("Frame", {
		Name = "Pages",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, card)

	local drag = false
	local dragStart
	local startPos

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if not drag then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	self.Gui = gui
	self.Main = main
	self.TopBar = topBar
	self.Sidebar = sidebar
	self.Content = content
	self.Card = card
	self.Pages = pages

	function self:CreateTab(name, icon)
		local window = self
		local tab = {}
		tab.Window = window
		tab.Name = name
		tab.Icon = icon
		tab.Sections = {}

		local button = create("TextButton", {
			Name = name .. "_Tab",
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, window.Sidebar)
		corner(button, 10)

		local stroke = create("UIStroke", {
			Thickness = 1,
			Transparency = 1,
			Color = Color3.new(1, 1, 1),
		}, button)

		padding(button, 12, 0, 0, 0)

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = window.Theme.SubText,
			Text = (icon and (icon .. "  ") or "") .. name,
		}, button)

		local page = create("ScrollingFrame", {
			Name = name .. "_Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ScrollBarThickness = 2,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		}, window.Pages)

		padding(page, 14, 14, 14, 14)
		listLayout(page, 10)

		function tab:SetSelected(state)
			if state then
				button.BackgroundTransparency = 0
				button.BackgroundColor3 = window.Theme.Selected
				stroke.Transparency = 0.75
				label.TextColor3 = window.Theme.Text
			else
				button.BackgroundTransparency = 1
				stroke.Transparency = 1
				label.TextColor3 = window.Theme.SubText
			end
		end

		function tab:Select()
			for _, other in ipairs(window.Tabs) do
				other.Page.Visible = false
				other:SetSelected(false)
			end
			page.Visible = true
			tab:SetSelected(true)
			window.ActiveTab = tab
		end

		function tab:CreateSection(sectionTitle)
			local section = {}
			section.Window = window
			section.Tab = tab
			section.Name = sectionTitle
			section.Components = {}

			local holder = create("Frame", {
				Name = sectionTitle .. "_Section",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = window.Theme.Card,
				BorderSizePixel = 0,
			}, page)
			corner(holder, 12)

			create("UIStroke", {
				Thickness = 1,
				Transparency = 0.85,
				Color = window.Theme.Stroke,
			}, holder)

			padding(holder, 12, 12, 12, 12)
			listLayout(holder, 8)

			create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 22),
				Font = Enum.Font.GothamSemibold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = window.Theme.Text,
				Text = sectionTitle,
			}, holder)

			section.Instance = holder
            section.Container = holder

            Components.BindSection(section)

          return section
		end

		button.MouseButton1Click:Connect(function()
			tab:Select()
		end)

		tab.Button = button
		tab.Page = page

		table.insert(window.Tabs, tab)

		if #window.Tabs == 1 then
			tab:Select()
		end

		return tab
	end

	function self:Destroy()
		if self.Gui then
			self.Gui:Destroy()
		end
	end

	return self
end

Window.CreateWindow = Window.new

return Window
