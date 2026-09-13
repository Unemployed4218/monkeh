local Services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	VirtualUser = game:GetService("VirtualUser"),
	Workspace = workspace,
	Lighting = game:GetService("Lighting"),
	UserInputService = game:GetService("UserInputService"),
	VirtualInputManager = game:GetService("VirtualInputManager"),
	RunService = game:GetService("RunService")
}

local PlayerData = {
	Player = Services.Players.LocalPlayer,
	DisplayName = Services.Players.LocalPlayer.DisplayName,
	Character = Services.Players.LocalPlayer.Character,
	Humanoid = nil,
	Camera = Services.Workspace.CurrentCamera,
	Backpack = Services.Players.LocalPlayer:WaitForChild("Backpack")
}

PlayerData.Humanoid = PlayerData.Character and PlayerData.Character:FindFirstChildOfClass("Humanoid")

local Remotes = {
	ChangeSpeedSize = Services.ReplicatedStorage.rEvents.changeSpeedSizeRemote,
	MuscleEvent = PlayerData.Player.muscleEvent
}

local Utils = {}

function Utils.formatNumber(n)
	if n >= 1e18 then return string.format("%.1fqi", n / 1e18)
	elseif n >= 1e15 then return string.format("%.1fqa", n / 1e15)
	elseif n >= 1e12 then return string.format("%.1ft", n / 1e12)
	elseif n >= 1e9 then return string.format("%.1fb", n / 1e9)
	elseif n >= 1e6 then return string.format("%.1fm", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fk", n / 1e3)
	else return tostring(n) end
end

function Utils.formatWithCommas(n)
	local formatted = tostring(math.floor(n))
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
		if k == 0 then break end
	end
	return formatted
end

function Utils.greeting()
	return "hai " .. PlayerData.DisplayName
end

local library = (function()
local Theme = {
	green = Color3.fromRGB(48, 209, 88),
	label = Color3.fromRGB(255, 255, 255),
	secondary = Color3.fromRGB(210, 210, 220),
	tertiary = Color3.fromRGB(160, 160, 170),
	grouped = Color3.fromRGB(22, 22, 24),
	sheet = Color3.fromRGB(8, 8, 10),
	trackOff = Color3.fromRGB(120, 120, 128),
	font = Enum.Font.GothamBold
}

local function destroyNamed(parent, name)
	if parent and parent.FindFirstChild then
		local existing = parent:FindFirstChild(name)
		if existing then
			pcall(function()
				existing:Destroy()
			end)
		end
	end
end

destroyNamed(game:GetService("CoreGui"), "imgui")
if game:GetService("Players").LocalPlayer then
	destroyNamed(game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"), "imgui")
end
if type(gethui) == "function" then
	local ok, gh = pcall(gethui)
	if ok and gh then
		destroyNamed(gh, "imgui")
	end
end

local cloneref = cloneref and cloneref or function(...)
	return ...
end
local CoreGui = cloneref(game:GetService("CoreGui"))
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = game:GetService("Players").LocalPlayer
local root = Instance.new("ScreenGui")
root.Name = "imgui"
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset = true
root.Parent = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")

local windowsFrame = Instance.new("Frame")
windowsFrame.Name = "Windows"
windowsFrame.BackgroundTransparency = 1
windowsFrame.Size = UDim2.fromScale(1, 1)
windowsFrame.ZIndex = 2
windowsFrame.Parent = root

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightShift and root and root.Enabled ~= nil then
		root.Enabled = not root.Enabled
	end
end)

local function tween(obj, props, t, style)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 28)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(255, 255, 255)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.78
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function pad(parent, l, t, r, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = parent
	return p
end

local function glass(frame)
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	corner(frame, 36)
	stroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.9)
	return frame
end

local function makeRow(parent, height)
	local row = Instance.new("Frame")
	row.Name = "GlassRow"
	row.BackgroundColor3 = Theme.grouped
	row.BackgroundTransparency = 0.48
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, height or 52)
	row.Parent = parent
	corner(row, math.floor((height or 52) / 2))
	return row
end

local function attachControls(parent)

	local controls = {}

	function controls:AddLabel(label_text)
		local row = makeRow(parent, 44)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(14, 0)
		label.Size = UDim2.new(1, -28, 1, 0)
		label.Font = Theme.font
		label.Text = tostring(label_text or "")
		label.TextColor3 = Theme.label
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.ZIndex = row.ZIndex + 1
		label.Parent = row
		return label
	end

	function controls:AddButton(button_text, callback)
		callback = typeof(callback) == "function" and callback or function() end
		local button = Instance.new("TextButton")
		button.AutoButtonColor = false
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundTransparency = 0.28
		button.Size = UDim2.new(1, 0, 0, 48)
		button.Font = Theme.font
		button.Text = tostring(button_text or "Button")
		button.TextColor3 = Theme.label
		button.TextSize = 16
		button.ZIndex = parent.ZIndex + 1
		button.Parent = parent
		corner(button, 24)
		button.MouseButton1Click:Connect(function()
			tween(button, { BackgroundTransparency = 0.08 }, 0.08)
			task.delay(0.08, function()
				tween(button, { BackgroundTransparency = 0.28 }, 0.18)
			end)
			pcall(callback)
		end)
		return button
	end

	function controls:AddSwitch(switch_text, callback)
		callback = typeof(callback) == "function" and callback or function() end
		local row = makeRow(parent, 54)
		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Position = UDim2.fromOffset(16, 0)
		titleLbl.Size = UDim2.new(1, -86, 1, 0)
		titleLbl.Font = Theme.font
		titleLbl.Text = tostring(switch_text or "Switch")
		titleLbl.TextColor3 = Theme.label
		titleLbl.TextSize = 16
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.ZIndex = row.ZIndex + 1
		titleLbl.Parent = row
		local track = Instance.new("TextButton")
		track.AutoButtonColor = false
		track.BackgroundColor3 = Theme.trackOff
		track.BackgroundTransparency = 0.25
		track.Position = UDim2.new(1, -67, 0.5, -16)
		track.Size = UDim2.fromOffset(51, 31)
		track.Text = ""
		track.ZIndex = row.ZIndex + 2
		track.Parent = row
		corner(track, 16)
		local knob = Instance.new("Frame")
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Position = UDim2.fromOffset(2, 2)
		knob.Size = UDim2.fromOffset(27, 27)
		knob.ZIndex = track.ZIndex + 1
		knob.Parent = track
		corner(knob, 14)
		stroke(knob, Color3.fromRGB(0, 0, 0), 1, 0.9)
		local toggled = false
		local function apply(state, fire)
			toggled = state and true or false
			tween(track, {
				BackgroundColor3 = toggled and Theme.green or Theme.trackOff,
				BackgroundTransparency = toggled and 0 or 0.25
			}, 0.18)
			tween(knob, { Position = UDim2.fromOffset(toggled and 22 or 2, 2) }, 0.18, Enum.EasingStyle.Back)
			if fire ~= false then
				pcall(callback, toggled)
			end
		end
		track.MouseButton1Click:Connect(function()
			apply(not toggled, true)
		end)
		local switch_data = {}
		function switch_data:Set(bool)
			apply(bool and true or false, true)
		end
		return switch_data, track
	end

	function controls:AddTextBox(textbox_text, callback, textbox_options)
		callback = typeof(callback) == "function" and callback or function() end
		textbox_options = typeof(textbox_options) == "table" and textbox_options or { clear = true }
		local row = makeRow(parent, 54)
		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Position = UDim2.fromOffset(16, 0)
		titleLbl.Size = UDim2.new(0.48, 0, 1, 0)
		titleLbl.Font = Theme.font
		titleLbl.Text = tostring(textbox_text or "Value")
		titleLbl.TextColor3 = Theme.label
		titleLbl.TextSize = 15
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		titleLbl.ZIndex = row.ZIndex + 1
		titleLbl.Parent = row
		local field = Instance.new("Frame")
		field.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		field.BackgroundTransparency = 0.86
		field.Position = UDim2.new(0.5, 0, 0.5, -16)
		field.Size = UDim2.new(0.5, -16, 0, 32)
		field.ZIndex = row.ZIndex + 1
		field.Parent = row
		corner(field, 16)
		local box = Instance.new("TextBox")
		box.BackgroundTransparency = 1
		box.ClearTextOnFocus = false
		box.Position = UDim2.fromOffset(10, 0)
		box.Size = UDim2.new(1, -20, 1, 0)
		box.Font = Theme.font
		box.PlaceholderText = "0"
		box.PlaceholderColor3 = Theme.tertiary
		box.Text = ""
		box.TextColor3 = Theme.label
		box.TextSize = 15
		box.TextXAlignment = Enum.TextXAlignment.Right
		box.ZIndex = field.ZIndex + 1
		box.Parent = field
		box.FocusLost:Connect(function()
			if #box.Text > 0 then
				pcall(callback, box.Text)
				if textbox_options.clear ~= false then
					box.Text = ""
				end
			end
		end)
		return box
	end

	function controls:AddDropdown(dropdown_name, callback)
		callback = typeof(callback) == "function" and callback or function() end
		dropdown_name = tostring(dropdown_name or "Dropdown")

		local wrap = Instance.new("Frame")
		wrap.Name = "Dropdown"
		wrap.BackgroundTransparency = 1
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.ZIndex = parent.ZIndex + 1
		wrap.Parent = parent

		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 6)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = wrap

		local header = makeRow(wrap, 54)
		header.LayoutOrder = 1

		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Position = UDim2.fromOffset(16, 0)
		titleLbl.Size = UDim2.new(0.46, 0, 1, 0)
		titleLbl.Font = Theme.font
		titleLbl.Text = dropdown_name
		titleLbl.TextColor3 = Theme.label
		titleLbl.TextSize = 15
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		titleLbl.ZIndex = header.ZIndex + 1
		titleLbl.Parent = header

		local valueBtn = Instance.new("TextButton")
		valueBtn.AutoButtonColor = false
		valueBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueBtn.BackgroundTransparency = 0.86
		valueBtn.Position = UDim2.new(0.48, 0, 0.5, -16)
		valueBtn.Size = UDim2.new(0.52, -16, 0, 32)
		valueBtn.Font = Theme.font
		valueBtn.Text = "Select"
		valueBtn.TextColor3 = Theme.secondary
		valueBtn.TextSize = 13
		valueBtn.TextTruncate = Enum.TextTruncate.AtEnd
		valueBtn.ZIndex = header.ZIndex + 2
		valueBtn.Parent = header
		corner(valueBtn, 16)

		local listFrame = Instance.new("ScrollingFrame")
		listFrame.Name = "Objects"
		listFrame.BackgroundColor3 = Theme.grouped
		listFrame.BackgroundTransparency = 0.2
		listFrame.BorderSizePixel = 0
		listFrame.Size = UDim2.new(1, 0, 0, 0)
		listFrame.Visible = false
		listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		listFrame.ScrollBarThickness = 3
		listFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		listFrame.ScrollBarImageTransparency = 0.45
		listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		listFrame.ZIndex = parent.ZIndex + 4
		listFrame.LayoutOrder = 2
		listFrame.Parent = wrap
		corner(listFrame, 18)
		pad(listFrame, 8, 8, 8, 8)

		local objectsLayout = Instance.new("UIListLayout")
		objectsLayout.Padding = UDim.new(0, 4)
		objectsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		objectsLayout.Parent = listFrame

		local open = false
		local items = {}

		local function itemCount()
			local n = 0
			for _ in pairs(items) do
				n += 1
			end
			return n
		end

		local function refreshListSize()
			local count = itemCount()
			local height = math.clamp(count * 38 + 16, 0, 190)
			listFrame.Size = UDim2.new(1, 0, 0, open and height or 0)
			listFrame.Visible = open and count > 0
		end

		valueBtn.MouseButton1Click:Connect(function()
			open = not open
			refreshListSize()
		end)

		local dropdown_data = {}

		function dropdown_data:Add(n)
			n = tostring(n or "Option")
			if items[n] then
				return items[n]
			end
			local object = Instance.new("TextButton")
			object.Name = n
			object.AutoButtonColor = false
			object.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			object.BackgroundTransparency = 0.88
			object.Size = UDim2.new(1, 0, 0, 34)
			object.Font = Theme.font
			object.Text = "  " .. n
			object.TextColor3 = Theme.label
			object.TextSize = 13
			object.TextXAlignment = Enum.TextXAlignment.Left
			object.TextTruncate = Enum.TextTruncate.AtEnd
			object.ZIndex = listFrame.ZIndex + 1
			object.Parent = listFrame
			corner(object, 12)
			object.MouseButton1Click:Connect(function()
				valueBtn.Text = n
				valueBtn.TextColor3 = Theme.label
				open = false
				refreshListSize()
				pcall(callback, n)
			end)
			items[n] = object
			object.Destroying:Connect(function()
				if items[n] == object then
					items[n] = nil
				end
				refreshListSize()
			end)
			refreshListSize()
			return object
		end

		function dropdown_data:Remove(n)
			n = tostring(n or "")
			local object = items[n]
			if object then
				items[n] = nil
				object:Destroy()
				if valueBtn.Text == n then
					valueBtn.Text = "Select"
					valueBtn.TextColor3 = Theme.secondary
				end
				refreshListSize()
			end
		end

		return dropdown_data, wrap
	end

	function controls:AddFolder(folder_name)
		folder_name = tostring(folder_name or "Folder")

		local wrap = Instance.new("Frame")
		wrap.Name = "Folder"
		wrap.BackgroundTransparency = 1
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.ZIndex = parent.ZIndex + 1
		wrap.Parent = parent

		local wrapLayout = Instance.new("UIListLayout")
		wrapLayout.Padding = UDim.new(0, 8)
		wrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
		wrapLayout.Parent = wrap

		local header = Instance.new("TextButton")
		header.AutoButtonColor = false
		header.BackgroundColor3 = Theme.grouped
		header.BackgroundTransparency = 0.32
		header.Size = UDim2.new(1, 0, 0, 48)
		header.Font = Theme.font
		header.Text = ""
		header.ZIndex = wrap.ZIndex + 1
		header.LayoutOrder = 1
		header.Parent = wrap
		corner(header, 24)

		local chevron = Instance.new("TextLabel")
		chevron.BackgroundTransparency = 1
		chevron.Position = UDim2.fromOffset(16, 0)
		chevron.Size = UDim2.fromOffset(22, 48)
		chevron.Font = Theme.font
		chevron.Text = "+"
		chevron.TextColor3 = Theme.secondary
		chevron.TextSize = 20
		chevron.ZIndex = header.ZIndex + 1
		chevron.Parent = header

		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Position = UDim2.fromOffset(42, 0)
		titleLbl.Size = UDim2.new(1, -56, 1, 0)
		titleLbl.Font = Theme.font
		titleLbl.Text = folder_name
		titleLbl.TextColor3 = Theme.label
		titleLbl.TextSize = 16
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.ZIndex = header.ZIndex + 1
		titleLbl.Parent = header

		local objects = Instance.new("Frame")
		objects.Name = "Objects"
		objects.BackgroundTransparency = 1
		objects.AutomaticSize = Enum.AutomaticSize.Y
		objects.Size = UDim2.new(1, 0, 0, 0)
		objects.Visible = false
		objects.ZIndex = wrap.ZIndex + 1
		objects.LayoutOrder = 2
		objects.Parent = wrap

		local objectsLayout = Instance.new("UIListLayout")
		objectsLayout.Padding = UDim.new(0, 8)
		objectsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		objectsLayout.Parent = objects

		local open = false
		header.MouseButton1Click:Connect(function()
			open = not open
			objects.Visible = open
			chevron.Text = open and "–" or "+"
		end)

		return attachControls(objects), wrap
	end

	return controls
end

local lib = {}

function lib:AddWindow(title, options)
	title = tostring(title or "Window")
	options = (typeof(options) == "table") and options or {}
	options.min_size = options.min_size or Vector2.new(400, 500)

	local Window = Instance.new("Frame")
	Window.Name = "Window"
	Window.Active = true
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.Position = UDim2.fromScale(0.5, 0.5)
	Window.Size = UDim2.fromOffset(options.min_size.X, options.min_size.Y)
	Window.ZIndex = 20
	Window.Parent = windowsFrame
	glass(Window)
	Window.BackgroundColor3 = Theme.sheet
	Window.Draggable = true

	local closePill = Instance.new("TextButton")
	closePill.Name = "Toggle"
	closePill.AutoButtonColor = false
	closePill.BackgroundColor3 = Theme.grouped
	closePill.BackgroundTransparency = 0.48
	closePill.Position = UDim2.new(1, -52, 0, 12)
	closePill.Size = UDim2.fromOffset(36, 36)
	closePill.Text = ""
	closePill.ZIndex = Window.ZIndex + 5
	closePill.Parent = Window
	corner(closePill, 18)

	local closeGlyph = Instance.new("TextLabel")
	closeGlyph.BackgroundTransparency = 1
	closeGlyph.Size = UDim2.fromScale(1, 1)
	closeGlyph.Font = Theme.font
	closeGlyph.Text = "–"
	closeGlyph.TextColor3 = Theme.label
	closeGlyph.TextSize = 22
	closeGlyph.ZIndex = closePill.ZIndex + 1
	closeGlyph.Parent = closePill

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Position = UDim2.fromOffset(0, 8)
	header.Size = UDim2.new(1, 0, 0, 40)
	header.ZIndex = Window.ZIndex + 2
	header.Parent = Window

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(18, 2)
	titleLabel.Size = UDim2.new(1, -76, 0, 36)
	titleLabel.Font = Theme.font
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.label
	titleLabel.TextSize = 22
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = header.ZIndex
	titleLabel.Parent = header

	local tabSelection = Instance.new("Frame")
	tabSelection.Name = "TabSelection"
	tabSelection.BackgroundColor3 = Theme.grouped
	tabSelection.BackgroundTransparency = 0.48
	tabSelection.Position = UDim2.fromOffset(16, 52)
	tabSelection.Size = UDim2.new(1, -32, 0, 40)
	tabSelection.Visible = false
	tabSelection.ZIndex = Window.ZIndex + 3
	tabSelection.Parent = Window
	corner(tabSelection, 22)

	local tabButtons = Instance.new("ScrollingFrame")
	tabButtons.Name = "TabButtons"
	tabButtons.BackgroundTransparency = 1
	tabButtons.BorderSizePixel = 0
	tabButtons.Size = UDim2.fromScale(1, 1)
	tabButtons.ScrollBarThickness = 0
	tabButtons.ScrollingDirection = Enum.ScrollingDirection.X
	tabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabButtons.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabButtons.ZIndex = tabSelection.ZIndex
	tabButtons.Parent = tabSelection
	pad(tabButtons, 4, 4, 4, 4)

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.Padding = UDim.new(0, 4)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabList.Parent = tabButtons

	local tabsFrame = Instance.new("Frame")
	tabsFrame.Name = "Tabs"
	tabsFrame.BackgroundTransparency = 1
	tabsFrame.Position = UDim2.fromOffset(0, 100)
	tabsFrame.Size = UDim2.new(1, 0, 1, -116)
	tabsFrame.ZIndex = Window.ZIndex + 2
	tabsFrame.Parent = Window

	local open = true
	local canopen = true
	local oldy = Window.AbsoluteSize.Y
	local oldTabVis = {}

	local resizeHandle = Instance.new("TextButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Active = true
	resizeHandle.AutoButtonColor = false
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.AnchorPoint = Vector2.new(1, 1)
	resizeHandle.Position = UDim2.new(1, -6, 1, -6)
	resizeHandle.Size = UDim2.fromOffset(28, 28)
	resizeHandle.Font = Theme.font
	resizeHandle.Text = "↘"
	resizeHandle.TextColor3 = Theme.tertiary
	resizeHandle.TextSize = 18
	resizeHandle.ZIndex = Window.ZIndex + 10
	resizeHandle.Parent = Window

	local resizing = false
	local resizeStart = Vector2.zero
	local resizeStartSize = Vector2.zero
	local resizeInputType = nil

	local function beginResize(input)
		if not open then
			return
		end
		resizing = true
		resizeInputType = input.UserInputType
		resizeStart = Vector2.new(input.Position.X, input.Position.Y)
		resizeStartSize = Window.AbsoluteSize
		if Window.AnchorPoint ~= Vector2.zero then
			local absoluteTopLeft = Window.AbsolutePosition
			local parentTopLeft = windowsFrame.AbsolutePosition
			Window.AnchorPoint = Vector2.zero
			Window.Position = UDim2.fromOffset(
				absoluteTopLeft.X - parentTopLeft.X,
				absoluteTopLeft.Y - parentTopLeft.Y
			)
		end
	end

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			beginResize(input)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if not resizing then
			return
		end
		local isMouseMove = resizeInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement
		local isTouchMove = resizeInputType == Enum.UserInputType.Touch
			and input.UserInputType == Enum.UserInputType.Touch
		if not isMouseMove and not isTouchMove then
			return
		end
		local current = Vector2.new(input.Position.X, input.Position.Y)
		local delta = current - resizeStart
		local newWidth = math.max(options.min_size.X, resizeStartSize.X + delta.X)
		local newHeight = math.max(options.min_size.Y, resizeStartSize.Y + delta.Y)
		Window.Size = UDim2.fromOffset(newWidth, newHeight)
		oldy = newHeight
	end)

	UIS.InputEnded:Connect(function(input)
		if not resizing then
			return
		end
		if (resizeInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1)
			or (resizeInputType == Enum.UserInputType.Touch
				and input.UserInputType == Enum.UserInputType.Touch) then
			resizing = false
			resizeInputType = nil
		end
	end)

	closePill.MouseButton1Click:Connect(function()
		if not canopen then
			return
		end
		canopen = false
		if open then
			oldTabVis = {}
			for _, v in ipairs(tabsFrame:GetChildren()) do
				oldTabVis[v] = v.Visible
				v.Visible = false
			end
			tabSelection.Visible = false
			header.Visible = false
			oldy = Window.AbsoluteSize.Y
			resizing = false
			resizeHandle.Visible = false
			tween(Window, { Size = UDim2.fromOffset(Window.AbsoluteSize.X, 56) }, 0.28)
			closeGlyph.Text = "+"
		else
			for i, v in pairs(oldTabVis) do
				i.Visible = v
			end
			tabSelection.Visible = true
			header.Visible = true
			resizeHandle.Visible = true
			tween(Window, { Size = UDim2.fromOffset(Window.AbsoluteSize.X, oldy) }, 0.28)
			closeGlyph.Text = "–"
		end
		open = not open
		task.wait(0.28)
		canopen = true
	end)

	local window_data = {}
	local firstTab = true

	function window_data:AddTab(tab_name)
		tab_name = tostring(tab_name or "Tab")
		tabSelection.Visible = true

		local new_button = Instance.new("TextButton")
		new_button.AutoButtonColor = false
		new_button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		new_button.BackgroundTransparency = 1
		new_button.Size = UDim2.fromOffset(math.max(86, #tab_name * 8 + 28), 32)
		new_button.Font = Theme.font
		new_button.Text = tab_name
		new_button.TextColor3 = Theme.secondary
		new_button.TextSize = 12
		new_button.ZIndex = tabButtons.ZIndex + 1
		new_button.Parent = tabButtons
		corner(new_button, 16)

		local new_tab = Instance.new("ScrollingFrame")
		new_tab.Name = "Tab"
		new_tab.BackgroundTransparency = 1
		new_tab.BorderSizePixel = 0
		new_tab.Size = UDim2.fromScale(1, 1)
		new_tab.Visible = false
		new_tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
		new_tab.CanvasSize = UDim2.new(0, 0, 0, 0)
		new_tab.ScrollBarThickness = 3
		new_tab.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		new_tab.ScrollBarImageTransparency = 0.55
		new_tab.ScrollingDirection = Enum.ScrollingDirection.Y
		new_tab.ZIndex = tabsFrame.ZIndex
		new_tab.Parent = tabsFrame
		pad(new_tab, 16, 4, 16, 18)

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = new_tab

		local function show()
			for _, v in ipairs(tabButtons:GetChildren()) do
				if v:IsA("TextButton") then
					v.BackgroundTransparency = 1
					v.TextColor3 = Theme.secondary
				end
			end
			for _, v in ipairs(tabsFrame:GetChildren()) do
				v.Visible = false
			end
			new_button.BackgroundTransparency = 0.35
			new_button.TextColor3 = Theme.label
			new_tab.Visible = true
		end

		new_button.MouseButton1Click:Connect(show)
		if firstTab then
			firstTab = false
			task.defer(show)
		end

		local tab_data = attachControls(new_tab)

		function tab_data:Show()
			show()
		end

		return tab_data, new_tab
	end

	return window_data, Window
end

return lib

end)()

local tmac = library:AddWindow("TMaC | Main - " .. Utils.greeting(), {
	min_size = Vector2.new(520, 560)
})

PlayerData.Player.Idled:Connect(function()
	Services.VirtualUser:CaptureController()
	Services.VirtualUser:ClickButton2(Vector2.new())
end)

local Tabs = {
	Main = tmac:AddTab("Main"),
	Killing = tmac:AddTab("Killing"),
	Specs = tmac:AddTab("Specs"),
	Pets = tmac:AddTab("Pets"),
	Farming = tmac:AddTab("Farming"),
	Inventory = tmac:AddTab("Inventory"),
	Teleport = tmac:AddTab("Teleports"),
	Stats = tmac:AddTab("Stats"),
	Info = tmac:AddTab("Info")
}

Tabs.Info:AddLabel("Made by Tree 🌳🌳")
Tabs.Info:AddLabel("Any issues? Ping @liltree694 on Discord")
Tabs.Info:AddLabel("—— Tabs ——")
Tabs.Info:AddLabel("Main: character, protection, movement, world")
Tabs.Info:AddLabel("Killing: auto kill, lists, kill aura")
Tabs.Info:AddLabel("Specs: inspect players and spectate")
Tabs.Info:AddLabel("Pets: equip, shop, evolve, trade")
Tabs.Info:AddLabel("Farming: rebirths, exercises, rocks, bosses")
Tabs.Info:AddLabel("Inventory: boosts, eggs, gifting, wheel")
Tabs.Info:AddLabel("Teleports / Stats: locations and session gains")

Tabs.Main:AddLabel("—— Character ——")

local Settings = {
	Size = {Value = 2, Enabled = false},
	Speed = {Value = 120, Enabled = false},
	FOV = {Value = 70, Enabled = false}
}

Tabs.Main:AddTextBox("Size:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		Settings.Size.Value = tonumber(text)
	end
end, {clear = false})

Tabs.Main:AddSwitch("Set Size", function(bool)
	Settings.Size.Enabled = bool
end)

task.spawn(function()
	while true do
		if Settings.Size.Enabled and PlayerData.Character and PlayerData.Humanoid then
			Remotes.ChangeSpeedSize:InvokeServer("changeSize", Settings.Size.Value)
		end
		task.wait(0.01)
	end
end)

Tabs.Main:AddTextBox("Speed:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		Settings.Speed.Value = tonumber(text)
	end
end, {clear = false})

Tabs.Main:AddSwitch("Set Speed", function(bool)
	Settings.Speed.Enabled = bool
end)

task.spawn(function()
	while true do
		if Settings.Speed.Enabled and PlayerData.Character and PlayerData.Humanoid then
			Remotes.ChangeSpeedSize:InvokeServer("changeSpeed", Settings.Speed.Value)
		end
		task.wait(0.01)
	end
end)

if PlayerData.Camera then
	Tabs.Main:AddTextBox("FOV:", function(text)
		text = string.gsub(text, "%s+", "")
		if tonumber(text) and tonumber(text) >= 1 and tonumber(text) <= 120 then
			Settings.FOV.Value = tonumber(text)
		end
	end, {clear = false})
	Tabs.Main:AddSwitch("Set FOV", function(bool)
		Settings.FOV.Enabled = bool
		PlayerData.Camera.FieldOfView = bool and Settings.FOV.Value or 70
	end)
	task.spawn(function()
		while true do
			if Settings.FOV.Enabled and PlayerData.Camera then
				PlayerData.Camera.FieldOfView = Settings.FOV.Value
			end
			task.wait(0.01)
		end
	end)
end

Tabs.Main:AddLabel("—— Protection ——")

local Protection = {
	AntiFling = {Enabled = false},
	PositionLock = {Enabled = false, Position = nil}
}

local function eAntiFling()
	if not Protection.AntiFling.Enabled or not PlayerData.Player.Character then return end
	if not PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if PlayerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and 
	   PlayerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		PlayerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(100000, 0, 100000)
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.P = 1250
	bv.Parent = PlayerData.Player.Character.HumanoidRootPart
end

local function dAntiFling()
	if not PlayerData.Player.Character or not PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if PlayerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and 
	   PlayerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		PlayerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
end

Tabs.Main:AddSwitch("Anti Fling", function(bool)
	Protection.AntiFling.Enabled = bool
	if bool then eAntiFling() else dAntiFling() end
end)

PlayerData.Player.CharacterAdded:Connect(function(newChar)
	newChar:WaitForChild("HumanoidRootPart", 5)
	if Protection.AntiFling.Enabled then eAntiFling() end
end)

local function lockPosition()
	eAntiFling()
	if not Protection.PositionLock.Enabled or not Protection.PositionLock.Position or not PlayerData.Player.Character then return end
	if not PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if PlayerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
		PlayerData.Player.Character.HumanoidRootPart.PositionLocker.Position = Protection.PositionLock.Position
	else
		dAntiFling()
		local bp = Instance.new("BodyPosition")
		bp.Name = "PositionLocker"
		bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bp.Position = Protection.PositionLock.Position
		bp.P = 100000
		bp.Parent = PlayerData.Player.Character.HumanoidRootPart
	end
end

local function unlockPosition()
	if PlayerData.Player.Character and PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then
		if PlayerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
			PlayerData.Player.Character.HumanoidRootPart.PositionLocker:Destroy()
		end
	end
	Protection.PositionLock.Position = nil
end

Tabs.Main:AddSwitch("Lock Position", function(bool)
	Protection.PositionLock.Enabled = bool
	if bool then
		if PlayerData.Player.Character and PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			Protection.PositionLock.Position = PlayerData.Player.Character.HumanoidRootPart.Position
		end
		lockPosition()
	else
		unlockPosition()
	end
end)

local VisibilitySettings = {
	HidePets = false,
	HidePopups = true,
	ShowPetsEvent = Services.ReplicatedStorage.rEvents:WaitForChild("showPetsEvent"),
	SavePlayerSizeEvent = Services.ReplicatedStorage.rEvents:WaitForChild("savePlayerSizeEvent")
}

Tabs.Pets:AddLabel("—— Visibility ——")
Tabs.Pets:AddSwitch("Hide Pets", function(state)
	VisibilitySettings.HidePets = state
	VisibilitySettings.ShowPetsEvent:FireServer(state and "hidePets" or "showPets")
end):Set(true)

PlayerData.Player.CharacterAdded:Connect(function(newChar)
	if Protection.PositionLock.Enabled and newChar:WaitForChild("HumanoidRootPart", 5) then
		Protection.PositionLock.Position = newChar.HumanoidRootPart.Position
		lockPosition()
	end
end)

task.spawn(function()
	while true do
		if Protection.PositionLock.Enabled then lockPosition() end
		task.wait(0.1)
	end
end)

local WaterParts = {
	Parts = {},
	PartSize = 2048,
	TotalDistance = 50000,
	StartPosition = Vector3.new(-2, -9.5, -2)
}

task.spawn(function()
	for x = 0, math.ceil(WaterParts.TotalDistance / WaterParts.PartSize) - 1 do
		for z = 0, math.ceil(WaterParts.TotalDistance / WaterParts.PartSize) - 1 do
			for i, offset in ipairs({
				{x * WaterParts.PartSize, z * WaterParts.PartSize, "Side_" .. x .. "_" .. z},
				{-x * WaterParts.PartSize, z * WaterParts.PartSize, "LeftRight_" .. x .. "_" .. z},
				{-x * WaterParts.PartSize, -z * WaterParts.PartSize, "UpLeft_" .. x .. "_" .. z},
				{x * WaterParts.PartSize, -z * WaterParts.PartSize, "UpRight_" .. x .. "_" .. z}
			}) do
				local part = Instance.new("Part")
				part.Size = Vector3.new(WaterParts.PartSize, 1, WaterParts.PartSize)
				part.Position = WaterParts.StartPosition + Vector3.new(offset[1], 0, offset[2])
				part.Anchored = true
				part.Transparency = 1
				part.CanCollide = true
				part.Name = "Part_" .. offset[3]
				part.Parent = Services.Workspace
				table.insert(WaterParts.Parts, part)
			end
		end
	end
end)

Tabs.Main:AddLabel("—— Movement ——")

local walkonwaterSwicth = Tabs.Main:AddSwitch("Walk on Water", function(bool)
	for _, part in ipairs(WaterParts.Parts) do
		if part and part.Parent then part.CanCollide = bool end
	end
end)

walkonwaterSwicth:Set(true)

Tabs.Main:AddSwitch("Infinite Jump", function(bool)
	_G.InfiniteJump = bool
	if bool then
		Services.UserInputService.JumpRequest:Connect(function()
			if _G.InfiniteJump then
				Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
			end
		end)
	end
end)

local FortuneWheelData = {
	Running = false,
	Generation = 0,
	Remote = Services.ReplicatedStorage.rEvents:WaitForChild("openFortuneWheelRemote"),
	Chances = Services.ReplicatedStorage
		:WaitForChild("shared")
		:WaitForChild("catalogs")
		:WaitForChild("fortuneWheelChances")
		:WaitForChild("Fortune Wheel")
}

local function spinFortuneWheel()
	pcall(function()
		FortuneWheelData.Remote:InvokeServer(
			"openFortuneWheel",
			FortuneWheelData.Chances
		)
	end)
end

Tabs.Inventory:AddLabel("—— Fortune Wheel ——")
Tabs.Inventory:AddSwitch("Spin Fortune Wheel", function(state)
	FortuneWheelData.Running = state
	FortuneWheelData.Generation += 1
	local generation = FortuneWheelData.Generation
	if not state then return end
	task.spawn(function()
		while FortuneWheelData.Running and FortuneWheelData.Generation == generation do
			spinFortuneWheel()
			task.wait(1)
		end
	end)
end)

Tabs.Main:AddLabel("—— World ——")
local timeDropdown = Tabs.Main:AddDropdown("Change Time", function(selection)
	Services.Lighting.ClockTime = selection == "Night" and 0 or 9
end)

timeDropdown:Add("Night")
timeDropdown:Add("Day")
Tabs.Specs:AddLabel("—— Player Stats ——")

local SpecsData = {
	PlayerToInspect = nil,
	EmojiMap = {
		["Time"] = utf8.char(0x1F55B), ["Stats"] = utf8.char(0x1F4CA), ["Strength"] = utf8.char(0x1F4AA),
		["Rebirths"] = utf8.char(0x1F504), ["Durability"] = utf8.char(0x1F6E1), ["Kills"] = utf8.char(0x1F480),
		["Agility"] = "⚡", ["Evil Karma"] = utf8.char(0x1F608), ["Good Karma"] = utf8.char(0x1F607),
		["Brawls"] = utf8.char(0x1F94A)
	},
	StatDefinitions = {
		{name = "Strength", statName = "Strength"}, {name = "Rebirths", statName = "Rebirths"},
		{name = "Durability", statName = "Durability"}, {name = "Agility", statName = "Agility"},
		{name = "Kills", statName = "Kills"}, {name = "Evil Karma", statName = "evilKarma"},
		{name = "Good Karma", statName = "goodKarma"}, {name = "Brawls", statName = "Brawls"}
	},
	StatLabels = {}
}

local specdropdown = Tabs.Specs:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(Services.Players:GetPlayers()) do
		if text == player.DisplayName .. " | " .. player.Name then
			SpecsData.PlayerToInspect = player
			break
		end
	end
end)

for _, player in ipairs(Services.Players:GetPlayers()) do
	specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end

Services.Players.PlayerAdded:Connect(function(player)
	specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

Services.Players.PlayerRemoving:Connect(function()
	specdropdown:Clear()
	for _, p in ipairs(Services.Players:GetPlayers()) do
		specdropdown:Add(p.DisplayName .. " | " .. p.Name)
	end
end)

local playerNameLabel = Tabs.Specs:AddLabel("👤 Name: N/A")
local playerUsernameLabel = Tabs.Specs:AddLabel("🎫 Username: N/A")

for _, info in ipairs(SpecsData.StatDefinitions) do
	SpecsData.StatLabels[info.name] = Tabs.Specs:AddLabel(SpecsData.EmojiMap[info.name] .. " " .. info.name .. ": N/A")
end

local function updateStatLabels(targetPlayer)
	if not targetPlayer then return end
	playerNameLabel.Text = "👤 Name: " .. targetPlayer.DisplayName
	playerUsernameLabel.Text = "🎫 Username: " .. targetPlayer.Name
	if not targetPlayer:FindFirstChild("leaderstats") then return end
	for _, info in ipairs(SpecsData.StatDefinitions) do
		local statObject = targetPlayer.leaderstats:FindFirstChild(info.statName) or targetPlayer:FindFirstChild(info.statName)
		if statObject then
			SpecsData.StatLabels[info.name].Text = string.format("%s %s: %s (%s)", SpecsData.EmojiMap[info.name] or "", info.name,
				Utils.formatNumber(statObject.Value), Utils.formatWithCommas(statObject.Value))
		else
			SpecsData.StatLabels[info.name].Text = SpecsData.EmojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
		end
	end
end

task.spawn(function()
	while true do
		if SpecsData.PlayerToInspect then updateStatLabels(SpecsData.PlayerToInspect) end
		task.wait(0.1)
	end
end)

Tabs.Specs:AddLabel("—— Combat Preview ——")

local AdvancedStats = {
	HealthLabel = Tabs.Specs:AddLabel("🛡️ Enemy Health: N/A"),
	EnemyDamageLabel = Tabs.Specs:AddLabel("💥 Enemy Damage: N/A"),
	PlayerHealthLabel = Tabs.Specs:AddLabel("🛡️ Your Health: N/A"),
	PlayerDamageLabel = Tabs.Specs:AddLabel("💥 Your Damage: N/A"),
	HitsToKillLabel = Tabs.Specs:AddLabel("👊 Hits to Kill: N/A")
}

local StatsCache = {
	health = 0,
	enemyDamage = 0,
	playerHealth = 0,
	playerDamage = 0,
	hitsToKill = "N/A"
}

local function calculatePlayerHealth(targetPlayer)
	if not targetPlayer then return 0 end
	local durabilityStat = targetPlayer:FindFirstChild("Durability") or 
		(targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
	if not durabilityStat then return 0 end
	local totalMultiplier = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Infernal Health") then
		totalMultiplier = totalMultiplier + 0.15 * (targetPlayer.ultimatesFolder["Infernal Health"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("mighty") and string.lower(petValue.Value.Name):match("monster") then
					totalMultiplier = totalMultiplier + 0.5
				end
				if string.lower(petValue.Value.Name):match("small") and string.lower(petValue.Value.Name):match("fry") then
					totalMultiplier = totalMultiplier + 0.25
				end
			end
		end
	end
	return durabilityStat.Value * totalMultiplier
end

local function calculatePlayerDamage(targetPlayer)
	if not targetPlayer then return 0 end
	if not targetPlayer:FindFirstChild("leaderstats") or not targetPlayer.leaderstats:FindFirstChild("Strength") then return 0 end
	local baseDamage = targetPlayer.leaderstats.Strength.Value * 0.066666666666666666666666666666666666666666666667
	local totalMultiplier = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Demon Damage") then
		totalMultiplier = totalMultiplier + 0.1 * (targetPlayer.ultimatesFolder["Demon Damage"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("wild") and string.lower(petValue.Value.Name):match("wizard") then
					totalMultiplier = totalMultiplier + 0.5
				end
				if string.lower(petValue.Value.Name):match("chaos") and string.lower(petValue.Value.Name):match("sorcerer") then
					totalMultiplier = totalMultiplier + 0.25
				end
			end
		end
	end
	return baseDamage * totalMultiplier
end

local function updateAdvancedStats(targetPlayer)
	if not targetPlayer then
		AdvancedStats.HealthLabel.Text = "🛡️ Enemy Health: N/A"
		AdvancedStats.EnemyDamageLabel.Text = "💥 Enemy Damage: N/A"
		AdvancedStats.PlayerHealthLabel.Text = "🛡️ Your Health: N/A"
		AdvancedStats.PlayerDamageLabel.Text = "💥 Your Damage: N/A"
		AdvancedStats.HitsToKillLabel.Text = "👊 Hits to Kill: N/A"
		return
	end
	StatsCache.health = calculatePlayerHealth(targetPlayer)
	StatsCache.enemyDamage = calculatePlayerDamage(targetPlayer)
	StatsCache.playerHealth = calculatePlayerHealth(PlayerData.Player)
	StatsCache.playerDamage = calculatePlayerDamage(PlayerData.Player)
	StatsCache.hitsToKill = StatsCache.playerDamage <= 0 and "∞" or (math.ceil(StatsCache.health / StatsCache.playerDamage) > 200 and "∞" or 
		(math.ceil(StatsCache.health / StatsCache.playerDamage) < 1 and "instant" or math.ceil(StatsCache.health / StatsCache.playerDamage)))
	AdvancedStats.HealthLabel.Text = string.format("🛡️ Enemy Health: %s (%s)", Utils.formatNumber(StatsCache.health), Utils.formatWithCommas(StatsCache.health))
	AdvancedStats.EnemyDamageLabel.Text = string.format("💥 Enemy Damage: %s (%s)", Utils.formatNumber(StatsCache.enemyDamage), Utils.formatWithCommas(StatsCache.enemyDamage))
	AdvancedStats.PlayerHealthLabel.Text = string.format("🛡️ Your Health: %s (%s)", Utils.formatNumber(StatsCache.playerHealth), Utils.formatWithCommas(StatsCache.playerHealth))
	AdvancedStats.PlayerDamageLabel.Text = string.format("💥 Your Damage: %s (%s)", Utils.formatNumber(StatsCache.playerDamage), Utils.formatWithCommas(StatsCache.playerDamage))
	AdvancedStats.HitsToKillLabel.Text = string.format("👊 Hits to Kill: %s", tostring(StatsCache.hitsToKill))
end

task.spawn(function()
	while true do
		updateAdvancedStats(SpecsData.PlayerToInspect)
		task.wait(0.1)
	end
end)

local function checkCharacter()
	if not Services.Players.LocalPlayer.Character then
		repeat task.wait() until Services.Players.LocalPlayer.Character
	end
	return Services.Players.LocalPlayer.Character
end

local function gettool()
	for _, v in pairs(Services.Players.LocalPlayer.Backpack:GetChildren()) do
		if v.Name == "Punch" and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			Services.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
		end
	end
	Services.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
	Services.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

local function isPlayerAlive(player)
	return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
		player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function isSpawnProtected(player)
	if not player or not player.Character then return false end
	if player.Character:FindFirstChildOfClass("ForceField")
		or player.Character:FindFirstChild("spawnProtectionHighlight") then
		return true
	end
	local protectedUntil = player.Character:GetAttribute("SpawnProtectedUntil")
	return typeof(protectedUntil) == "number" and Services.Workspace:GetServerTimeNow() < protectedUntil
end

local function getLocalCombatCharacter()
	local character = Services.Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or humanoid.Health <= 0 or not humanoidRootPart then return end
	return character, humanoid, humanoidRootPart
end

local function positionNearTarget(target, heightOffset)
	if not isPlayerAlive(target)
		or isSpawnProtected(target)
		or isSpawnProtected(Services.Players.LocalPlayer) then
		return false
	end
	local _, _, localRoot = getLocalCombatCharacter()
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not localRoot or not targetRoot then return false end
	localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, heightOffset, 0)
	localRoot.AssemblyLinearVelocity = Vector3.zero
	localRoot.AssemblyAngularVelocity = Vector3.zero
	return true
end

local function touchAndPunchTarget(target, heightOffset)
	if not positionNearTarget(target, heightOffset) then return false, false end
	Services.RunService.Heartbeat:Wait()
	if not positionNearTarget(target, heightOffset) then return false, false end
	local character = getLocalCombatCharacter()
	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not character or not targetRoot or not targetHumanoid or isSpawnProtected(target) then return false, false end
	local hand = character:FindFirstChild("LeftHand") or character:FindFirstChild("RightHand")
	if not hand then return false, false end
	local punchTool = character:FindFirstChild("Punch") or Services.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if punchTool and punchTool.Parent ~= character and humanoid then
		humanoid:EquipTool(punchTool)
	end
	local healthBefore = targetHumanoid.Health
	local attempted = pcall(function()
		firetouchinterest(targetRoot, hand, 0)
		firetouchinterest(targetRoot, hand, 1)
		Services.Players.LocalPlayer.muscleEvent:FireServer("punch", hand.Name == "LeftHand" and "leftHand" or "rightHand")
	end)
	if not attempted then return false, false end
	for _ = 1, 4 do
		Services.RunService.Heartbeat:Wait()
		if not isPlayerAlive(target) or targetHumanoid.Health < healthBefore then
			return true, true
		end
		if isSpawnProtected(target) then
			return false, false
		end
	end
	return false, true
end

local function restoreCombatPosition(savedCFrame)
	if not savedCFrame then
		return
	end
	local _, _, root = getLocalCombatCharacter()
	if not root then
		return
	end
	root.CFrame = savedCFrame
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function attackPlayerWithLimit(target, hitLimit, shouldContinue, heightOffset)
	local _, _, root = getLocalCombatCharacter()
	local savedCFrame = root and root.CFrame
	local hits = 0
	while hits < hitLimit and shouldContinue() and isPlayerAlive(target) and not isSpawnProtected(target) do
		local hitRegistered, attempted = touchAndPunchTarget(target, heightOffset)
		if not attempted then break end
		if hitRegistered then
			hits += 1
		else
			task.wait(0.05)
		end
	end
	restoreCombatPosition(savedCFrame)
	return hits
end

Tabs.Pets:AddLabel("—— Equip Pets ——")

local function equipBestStatPets(priority)
	for _, folder in pairs(Services.Players.LocalPlayer.petsFolder:GetChildren()) do
		if folder:IsA("Folder") then
			for _, pet in pairs(folder:GetChildren()) do
				Services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
			end
		end
	end
	task.wait(0.2)
	local petsByName = {}
	for _, petName in ipairs(priority) do petsByName[petName] = {} end
	for _, pet in pairs(Services.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
		if petsByName[pet.Name] then table.insert(petsByName[pet.Name], pet) end
	end
	local equippedCount = 0
	for _, petName in ipairs(priority) do
		for _, pet in ipairs(petsByName[petName]) do
			if equippedCount >= 9 then return end
			Services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
			equippedCount += 1
			task.wait(0.1)
		end
	end
end

Tabs.Pets:AddButton("Equip Best Damage", function()
	equipBestStatPets({"Wild Wizard", "Chaos Sorcerer", "Mighty Monster", "Small Fry"})
end)

Tabs.Pets:AddButton("Equip Best Health", function()
	equipBestStatPets({"Mighty Monster", "Small Fry", "Wild Wizard", "Chaos Sorcerer"})
end)

Tabs.Killing:AddLabel("—— Whitelist ——")

_G.whitelistedPlayers = _G.whitelistedPlayers or {}
_G.blacklistedPlayers = _G.blacklistedPlayers or {}

for _, connectionName in ipairs({
	"killAllConnection",
	"farmBadKarmaConnection",
	"farmGoodKarmaConnection",
	"blacklistKillConnection",
	"deathRingConnection"
}) do
	local connection = _G[connectionName]
	if connection then
		pcall(function() connection:Disconnect() end)
		_G[connectionName] = nil
	end
end

_G.killAll = false
_G.killBlacklistedOnly = false
_G.farmBadKarma = false
_G.farmGoodKarma = false
_G.deathRingEnabled = false
_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
_G.killListGeneration = (_G.killListGeneration or 0) + 1

local function isWhitelisted(player)
	for _, name in ipairs(_G.whitelistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

local function isBlacklisted(player)
	for _, name in ipairs(_G.blacklistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

local removeWhitelistDropdown
local whitelistLabel = Tabs.Killing:AddLabel("Whitelist: None")
local whitelistDropdown = Tabs.Killing:AddDropdown("Add to Whitelist", function(selectedText)
	local playerName = selectedText:match("| (.+)$")
	if playerName then
		playerName = playerName:gsub("^%s*(.-)%s*$", "%1")
		for _, name in ipairs(_G.whitelistedPlayers) do
			if name:lower() == playerName:lower() then return end
		end
		table.insert(_G.whitelistedPlayers, playerName)
		if removeWhitelistDropdown then removeWhitelistDropdown:Add(playerName) end
	end
end)

removeWhitelistDropdown = Tabs.Killing:AddDropdown("Remove from Whitelist", function(selectedName)
	for index = #_G.whitelistedPlayers, 1, -1 do
		if _G.whitelistedPlayers[index]:lower() == selectedName:lower() then
			table.remove(_G.whitelistedPlayers, index)
		end
	end
	removeWhitelistDropdown:Remove(selectedName)
end)

for _, playerName in ipairs(_G.whitelistedPlayers) do
	removeWhitelistDropdown:Add(playerName)
end

Tabs.Killing:AddButton("Clear Whitelist", function()
	_G.whitelistedPlayers = {}
	removeWhitelistDropdown:Clear()
end)

Tabs.Killing:AddSwitch("Whitelist Friends", function(bool)
	_G.whitelistFriends = bool
	if bool then
		for _, player in pairs(Services.Players:GetPlayers()) do
			if player ~= Services.Players.LocalPlayer and player:IsFriendsWith(Services.Players.LocalPlayer.UserId) then
				if not isWhitelisted(player) then 
					table.insert(_G.whitelistedPlayers, player.Name) 
				end
			end
		end
		_G.friendWhitelistConnection = Services.Players.PlayerAdded:Connect(function(player)
			if _G.whitelistFriends and player:IsFriendsWith(Services.Players.LocalPlayer.UserId) then
				if not isWhitelisted(player) then
					table.insert(_G.whitelistedPlayers, player.Name)
				end
			end
		end)
		_G.friendCheckLoop = task.spawn(function()
			while _G.whitelistFriends do
				task.wait(3)
				for _, player in pairs(Services.Players:GetPlayers()) do
					if player ~= Services.Players.LocalPlayer and player:IsFriendsWith(Services.Players.LocalPlayer.UserId) then
						if not isWhitelisted(player) then
							table.insert(_G.whitelistedPlayers, player.Name)
							print("Neuer Freund zur Whitelist hinzugefügt:", player.Name)
						end
					end
				end
			end
		end)
	else
		if _G.friendWhitelistConnection then
			_G.friendWhitelistConnection:Disconnect()
			_G.friendWhitelistConnection = nil
		end
		if _G.friendCheckLoop then
			task.cancel(_G.friendCheckLoop)
			_G.friendCheckLoop = nil
		end
	end
end)

Tabs.Killing:AddLabel("—— Auto Kill ——")

Tabs.Killing:AddSwitch("Kill Everyone", function(bool)
	_G.killAll = bool
	_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
	local generation = _G.killAllGeneration
	if not bool then return end
	task.spawn(function()
		while _G.killAll and _G.killAllGeneration == generation do
			local foundTarget = false
			for _, player in ipairs(Services.Players:GetPlayers()) do
				if not _G.killAll or _G.killAllGeneration ~= generation then break end
				if player ~= Services.Players.LocalPlayer
					and not isWhitelisted(player)
					and isPlayerAlive(player)
					and not isSpawnProtected(player) then
					foundTarget = true
					attackPlayerWithLimit(player, 4, function()
						return _G.killAll and _G.killAllGeneration == generation and not isWhitelisted(player)
					end, 3.5)
				end
			end
			if foundTarget then
				Services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end)
end)

Tabs.Killing:AddLabel("—— Karma Killing ——")

local KarmaKillData = {FarmEvil = false, FarmGood = false, Generation = 0}

local function matchesKarmaMode(player)
	local goodKarma = player:FindFirstChild("goodKarma")
	local evilKarma = player:FindFirstChild("evilKarma")
	if not goodKarma or not evilKarma then return false end
	local goodValue = goodKarma.Value or 0
	local evilValue = evilKarma.Value or 0
	if goodValue + evilValue < 5 then return false end
	return (KarmaKillData.FarmEvil and goodValue > evilValue)
		or (KarmaKillData.FarmGood and evilValue > goodValue)
end

local function restartKarmaWorker()
	KarmaKillData.Generation += 1
	local generation = KarmaKillData.Generation
	if not KarmaKillData.FarmEvil and not KarmaKillData.FarmGood then return end
	task.spawn(function()
		while (KarmaKillData.FarmEvil or KarmaKillData.FarmGood) and KarmaKillData.Generation == generation do
			local foundTarget = false
			for _, player in ipairs(Services.Players:GetPlayers()) do
				if KarmaKillData.Generation ~= generation then break end
				if player ~= Services.Players.LocalPlayer
					and not isWhitelisted(player)
					and isPlayerAlive(player)
					and not isSpawnProtected(player)
					and matchesKarmaMode(player) then
					foundTarget = true
					attackPlayerWithLimit(player, 4, function()
						return KarmaKillData.Generation == generation
							and not isWhitelisted(player)
							and matchesKarmaMode(player)
					end, 3.5)
				end
			end
			if foundTarget then
				Services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end)
end

Tabs.Killing:AddSwitch("Farm Evil Karma", function(state)
	KarmaKillData.FarmEvil = state
	restartKarmaWorker()
end)

Tabs.Killing:AddSwitch("Farm Good Karma", function(state)
	KarmaKillData.FarmGood = state
	restartKarmaWorker()
end)

Tabs.Killing:AddLabel("—— Clanlist ——")

local Clanlist = {
	Tags = {},
	DropdownItems = {},
	Excluded = {},
	Running = false,
	Generation = 0
}

local function parseClanlistTags(text)
	text = string.lower(tostring(text or "")):gsub(",", " ")
	local tags, seen = {}, {}
	for token in string.gmatch(text, "%S+") do
		if token ~= "" and not seen[token] then
			seen[token] = true
			table.insert(tags, token)
		end
	end
	return tags
end

local function displayContainsTag(player, tag)
	local displayName = string.lower(player.DisplayName or "")
	tag = string.lower((tag or ""):gsub("%s+", ""))
	if tag == "" or displayName == "" then
		return false
	end

	local escaped = tag:gsub("(%W)", "%%%1")
	if tag:match("^%d+$") then
		return string.find(displayName, "%f[%d]" .. escaped .. "%f[%D]") ~= nil
	end
	return string.find(displayName, escaped, 1, true) ~= nil
end

local function shouldClanlistKill(player)
	if not player or player == Services.Players.LocalPlayer or #Clanlist.Tags == 0 then
		return false
	end
	if isWhitelisted(player) then
		return false
	end
	for _, name in ipairs(Clanlist.Excluded) do
		if name:lower() == player.Name:lower() then
			return false
		end
	end
	for _, tag in ipairs(Clanlist.Tags) do
		if displayContainsTag(player, tag) then
			return true
		end
	end
	return false
end

local clanlistLabel = Tabs.Killing:AddLabel("Clanlist: None")
local function refreshClanlistLabel()
	clanlistLabel.Text = #Clanlist.Tags == 0 and "Clanlist: None" or ("Clanlist: " .. table.concat(Clanlist.Tags, ", "))
	clanlistLabel.Size = UDim2.new(0, math.max(240, clanlistLabel.TextBounds.X + 25), 0, 20)
end

refreshClanlistLabel()

local function clanlistHasTag(tag)
	for _, current in ipairs(Clanlist.Tags) do
		if current == tag then
			return true
		end
	end
	return false
end

local removeClanlistDropdown
local function addClanlistTagToDropdown(tag)
	if Clanlist.DropdownItems[tag] then
		return
	end
	Clanlist.DropdownItems[tag] = removeClanlistDropdown:Add(tag)
end

local function removeClanlistTag(tag)
	tag = string.lower(tostring(tag or ""))
	for index = #Clanlist.Tags, 1, -1 do
		if Clanlist.Tags[index] == tag then
			table.remove(Clanlist.Tags, index)
		end
	end
	local item = Clanlist.DropdownItems[tag]
	if item then
		item:Destroy()
		Clanlist.DropdownItems[tag] = nil
	end
	refreshClanlistLabel()
end

local function clearClanlist()
	Clanlist.Tags = {}
	for tag, item in pairs(Clanlist.DropdownItems) do
		if item then
			item:Destroy()
		end
		Clanlist.DropdownItems[tag] = nil
	end
	refreshClanlistLabel()
end

Tabs.Killing:AddTextBox("Add to Clanlist", function(text)
	for _, tag in ipairs(parseClanlistTags(text)) do
		if not clanlistHasTag(tag) then
			table.insert(Clanlist.Tags, tag)
			addClanlistTagToDropdown(tag)
		end
	end
	refreshClanlistLabel()
end, {clear = true})

removeClanlistDropdown = Tabs.Killing:AddDropdown("Remove from Clanlist", function(selectedTag)
	removeClanlistTag(selectedTag)
end)

Tabs.Killing:AddButton("Clear Clanlist", function()
	clearClanlist()
end)

Tabs.Killing:AddSwitch("Kill Clanlist", function(state)
	Clanlist.Running = state
	Clanlist.Generation += 1
	local generation = Clanlist.Generation
	if not state then
		return
	end
	task.spawn(function()
		while Clanlist.Running and Clanlist.Generation == generation do
			local foundTarget = false
			for _, player in ipairs(Services.Players:GetPlayers()) do
				if shouldClanlistKill(player) and isPlayerAlive(player) and not isSpawnProtected(player) then
					foundTarget = true
					attackPlayerWithLimit(player, 4, function()
						return Clanlist.Running
							and Clanlist.Generation == generation
							and shouldClanlistKill(player)
							and isPlayerAlive(player)
							and not isSpawnProtected(player)
					end, 3.5)
				end
			end
			if foundTarget then
				Services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end)
end)

Tabs.Killing:AddLabel("—— Killlist ——")

local removeKilllistDropdown
local blacklistLabel = Tabs.Killing:AddLabel("Killlist: None")

local blacklistDropdown = Tabs.Killing:AddDropdown("Add to Killlist", function(selectedText)
	local playerName = selectedText:match("| (.+)$")
	if playerName then
		playerName = playerName:gsub("^%s*(.-)%s*$", "%1")
		if not isBlacklisted({Name = playerName}) then
			table.insert(_G.blacklistedPlayers, playerName)
			if removeKilllistDropdown then removeKilllistDropdown:Add(playerName) end
		end
	end
end)

removeKilllistDropdown = Tabs.Killing:AddDropdown("Remove from Killlist", function(selectedName)
	for index = #_G.blacklistedPlayers, 1, -1 do
		if _G.blacklistedPlayers[index]:lower() == selectedName:lower() then
			table.remove(_G.blacklistedPlayers, index)
		end
	end
	removeKilllistDropdown:Remove(selectedName)
end)

for _, playerName in ipairs(_G.blacklistedPlayers) do
	removeKilllistDropdown:Add(playerName)
end

Tabs.Killing:AddButton("Clear Killlist", function()
	_G.blacklistedPlayers = {}
	removeKilllistDropdown:Clear()
end)

for _, player in ipairs(Services.Players:GetPlayers()) do
	if player ~= Services.Players.LocalPlayer then
		whitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		blacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end

Services.Players.PlayerAdded:Connect(function(player)
	if player ~= Services.Players.LocalPlayer then
		whitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		blacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

local targetKillAntiGravityName = "TMaCTargetKillAntiGravity"
local targetKillHeightOffset = 10

local targetKillGravityState = {
	Active = false,
	OriginalGravity = nil,
	Connection = nil
}

local function setTargetKillAntiGravity(enabled)
	local character = Services.Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if enabled then
		if not targetKillGravityState.Active then
			targetKillGravityState.Active = true
			targetKillGravityState.OriginalGravity = Services.Workspace.Gravity
			Services.Workspace.Gravity = 0
			targetKillGravityState.Connection = Services.RunService.Heartbeat:Connect(function()
				Services.Workspace.Gravity = 0
				local currentCharacter = Services.Players.LocalPlayer.Character
				local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
				if currentRoot then
					local velocity = currentRoot.AssemblyLinearVelocity
					currentRoot.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
				end
			end)
		end
		if root then
			local oldAntiGravity = root:FindFirstChild(targetKillAntiGravityName)
			if oldAntiGravity then oldAntiGravity:Destroy() end
			local velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
			root.AssemblyAngularVelocity = Vector3.zero
		end
	else
		if targetKillGravityState.Connection then
			targetKillGravityState.Connection:Disconnect()
			targetKillGravityState.Connection = nil
		end
		if targetKillGravityState.Active then
			Services.Workspace.Gravity = targetKillGravityState.OriginalGravity or 196.2
		end
		targetKillGravityState.Active = false
		targetKillGravityState.OriginalGravity = nil
	end
end

Tabs.Killing:AddSwitch("Kill List", function(bool)
	_G.killBlacklistedOnly = bool
	_G.killListGeneration = (_G.killListGeneration or 0) + 1
	local generation = _G.killListGeneration
	if not bool then
		setTargetKillAntiGravity(false)
		return
	end
	task.spawn(function()
		while _G.killBlacklistedOnly and _G.killListGeneration == generation do
			local target = nil
			for _, player in ipairs(Services.Players:GetPlayers()) do
				if not _G.killBlacklistedOnly or _G.killListGeneration ~= generation then break end
				if player ~= Services.Players.LocalPlayer
					and isBlacklisted(player)
					and isPlayerAlive(player)
					and not isSpawnProtected(player) then
					target = player
					break
				end
			end
			if target then
				local _, _, root = getLocalCombatCharacter()
				local savedCFrame = root and root.CFrame
				setTargetKillAntiGravity(true)
				pcall(function()
					while _G.killBlacklistedOnly
						and _G.killListGeneration == generation
						and target.Parent == Services.Players
						and isBlacklisted(target)
						and isPlayerAlive(target)
						and not isSpawnProtected(target) do
						local _, attempted = touchAndPunchTarget(target, targetKillHeightOffset)
						if not attempted then task.wait(0.1) end
					end
				end)
				setTargetKillAntiGravity(false)
				restoreCombatPosition(savedCFrame)
				Services.RunService.Heartbeat:Wait()
			else
				setTargetKillAntiGravity(false)
				task.wait(0.1)
			end
		end
		setTargetKillAntiGravity(false)
	end)
end)

local SpectateData = {
	SelectedPlayer = nil,
	SelectedPlayerUserId = nil,
	Spectating = false,
	CurrentTargetConnection = nil,
	LocalPlayerRespawnConnection = nil,
	CameraMonitorLoop = nil,
	HealthBar = nil,
	HealthConnection = nil
}

local function removeSpectateHealthBar()
	if SpectateData.HealthBar then
		SpectateData.HealthBar:Destroy()
		SpectateData.HealthBar = nil
	end
	if SpectateData.HealthConnection then
		SpectateData.HealthConnection:Disconnect()
		SpectateData.HealthConnection = nil
	end
end

local function attachSpectateHealthBar(character)
	removeSpectateHealthBar()
	if not character then
		return
	end
	local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 3)
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
	if not head or not humanoid then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TMaCSpectateHP"
	billboard.Size = UDim2.new(6, 0, 1.2, 0)
	billboard.StudsOffset = Vector3.new(0, 7.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 200
	billboard.Parent = head
	local background = Instance.new("Frame")
	background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	background.BackgroundTransparency = 0.3
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BorderSizePixel = 0
	background.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = background
	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
	bar.Size = UDim2.new(1, 0, 1, 0)
	bar.BorderSizePixel = 0
	bar.Parent = background
	local gradient = Instance.new("UIGradient")
	gradient.Parent = bar
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Transparency = 0.7
	stroke.Parent = bar
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextStrokeTransparency = 0.5
	label.Parent = background
	local function applyHealthColor(ratio)
		local top, bottom
		if ratio > 0.75 then
			top = Color3.fromRGB(80, 255, 80)
			bottom = Color3.fromRGB(20, 90, 20)
		elseif ratio > 0.50 then
			top = Color3.fromRGB(255, 220, 50)
			bottom = Color3.fromRGB(120, 90, 10)
		elseif ratio > 0.25 then
			top = Color3.fromRGB(255, 160, 40)
			bottom = Color3.fromRGB(120, 60, 10)
		else
			top = Color3.fromRGB(255, 70, 70)
			bottom = Color3.fromRGB(90, 15, 15)
		end
		bar.BackgroundColor3 = top
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, top),
			ColorSequenceKeypoint.new(1, bottom)
		})
	end
	local function refresh()
		local player = SpectateData.SelectedPlayer
		local health = player and calculatePlayerHealth(player) or 0
		local maxHealth = math.max(humanoid.MaxHealth, 1)
		local ratio = humanoid.Health / maxHealth
		if ratio ~= ratio then
			ratio = 0
		end
		ratio = math.clamp(ratio, 0, 1)
		bar.Size = UDim2.new(ratio, 0, 1, 0)
		applyHealthColor(ratio)
		label.Text = Utils.formatNumber(health)
	end
	SpectateData.HealthBar = billboard
	SpectateData.HealthConnection = humanoid.HealthChanged:Connect(refresh)
	refresh()
end

getgenv().SpectateState = getgenv().SpectateState or {
	SavedUserId = nil,
	IsSpectating = false
}

local function stopSpectating()
	removeSpectateHealthBar()
	if SpectateData.CurrentTargetConnection then
		SpectateData.CurrentTargetConnection:Disconnect()
		SpectateData.CurrentTargetConnection = nil
	end
	if SpectateData.CameraMonitorLoop then
		SpectateData.CameraMonitorLoop = false
	end
	local localPlayer = Services.Players.LocalPlayer
	if localPlayer.Character then
		local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			PlayerData.Camera.CameraSubject = humanoid
			PlayerData.Camera.CameraType = Enum.CameraType.Custom
		end
	end
	if PlayerData.Humanoid then
		PlayerData.Camera.CameraSubject = PlayerData.Humanoid
	end
end

local function startCameraMonitor()
	if SpectateData.CameraMonitorLoop then
		SpectateData.CameraMonitorLoop = false
		task.wait(0.3)
	end
	SpectateData.CameraMonitorLoop = true
	task.spawn(function()
		while SpectateData.CameraMonitorLoop do
			task.wait(0.2)
			if SpectateData.Spectating and SpectateData.SelectedPlayer then
				local targetChar = SpectateData.SelectedPlayer.Character
				if targetChar then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid then
						if PlayerData.Camera.CameraSubject ~= targetHumanoid then
							PlayerData.Camera.CameraSubject = targetHumanoid
						end
						if SpectateData.HealthBar and SpectateData.HealthBar.Parent then
							local label = SpectateData.HealthBar:FindFirstChildWhichIsA("TextLabel", true)
							if label then
								label.Text = Utils.formatNumber(calculatePlayerHealth(SpectateData.SelectedPlayer))
							end
						elseif targetChar then
							attachSpectateHealthBar(targetChar)
						end
					end
				end
			else
				break
			end
		end
	end)
end

local function updateSpectateTarget(player)
	if not player then
		if SpectateData.SelectedPlayerUserId then
			for _, p in ipairs(Services.Players:GetPlayers()) do
				if p.UserId == SpectateData.SelectedPlayerUserId then
					player = p
					SpectateData.SelectedPlayer = player
					break
				end
			end
		end
		if not player and getgenv().SpectateState.SavedUserId then
			for _, p in ipairs(Services.Players:GetPlayers()) do
				if p.UserId == getgenv().SpectateState.SavedUserId then
					player = p
					SpectateData.SelectedPlayer = player
					SpectateData.SelectedPlayerUserId = p.UserId
					break
				end
			end
		end
		if not player then
			stopSpectating()
			return
		end
	end
	SpectateData.SelectedPlayerUserId = player.UserId
	SpectateData.SelectedPlayer = player
	if SpectateData.CurrentTargetConnection then
		SpectateData.CurrentTargetConnection:Disconnect()
		SpectateData.CurrentTargetConnection = nil
	end
	local function setCamera(char)
		if not SpectateData.Spectating or SpectateData.SelectedPlayerUserId ~= player.UserId then
			return
		end
		local humanoid = char:WaitForChild("Humanoid", 3)
		if humanoid and SpectateData.Spectating and SpectateData.SelectedPlayerUserId == player.UserId then
			PlayerData.Camera.CameraSubject = humanoid
			attachSpectateHealthBar(char)
		end
	end
	if player.Character then
		setCamera(player.Character)
	end
	SpectateData.CurrentTargetConnection = player.CharacterAdded:Connect(function(newChar)
		if SpectateData.Spectating and SpectateData.SelectedPlayerUserId == player.UserId then
			setCamera(newChar)
		end
	end)
end

local function updatePlayerList()
	return Services.Players:GetPlayers()
end

Tabs.Specs:AddLabel("—— Spectate ——")

local specsdropdown = Tabs.Specs:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(updatePlayerList()) do
		local optionText = player.DisplayName .. " | " .. player.Name
		if text == optionText then
			SpectateData.SelectedPlayer = player
			SpectateData.SelectedPlayerUserId = player.UserId
			getgenv().SpectateState.SavedUserId = player.UserId
			if SpectateData.Spectating then
				updateSpectateTarget(player)
			end
			break
		end
	end
end)

Tabs.Specs:AddSwitch("Spectate", function(bool)
	SpectateData.Spectating = bool
	getgenv().SpectateState.IsSpectating = bool
	if SpectateData.Spectating then
		if SpectateData.SelectedPlayerUserId then
			getgenv().SpectateState.SavedUserId = SpectateData.SelectedPlayerUserId
		end
		updateSpectateTarget()
		startCameraMonitor()
	else
		stopSpectating()
		task.wait(0.1)
		local localPlayer = Services.Players.LocalPlayer
		if localPlayer.Character then
			local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				PlayerData.Camera.CameraSubject = humanoid
			end
		end
		getgenv().SpectateState.IsSpectating = false
	end
end)

for _, player in ipairs(updatePlayerList()) do
	specsdropdown:Add(player.DisplayName .. " | " .. player.Name)
end

Services.Players.PlayerAdded:Connect(function(player)
	specsdropdown:Add(player.DisplayName .. " | " .. player.Name)
	if getgenv().SpectateState.IsSpectating and getgenv().SpectateState.SavedUserId == player.UserId then
		SpectateData.Spectating = true
		SpectateData.SelectedPlayer = player
		SpectateData.SelectedPlayerUserId = player.UserId
		updateSpectateTarget(player)
	end
end)

Services.Players.PlayerRemoving:Connect(function(player)
	if player.UserId == SpectateData.SelectedPlayerUserId then
		if SpectateData.Spectating then
			stopSpectating()
			SpectateData.SelectedPlayer = nil
			SpectateData.CurrentTargetConnection = nil
			local localPlayer = Services.Players.LocalPlayer
			if localPlayer.Character and PlayerData.Humanoid then
				PlayerData.Camera.CameraSubject = PlayerData.Humanoid
			end
		end
	end
end)

if SpectateData.LocalPlayerRespawnConnection then
	SpectateData.LocalPlayerRespawnConnection:Disconnect()
end

SpectateData.LocalPlayerRespawnConnection = Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid", 3)
	if humanoid then
		PlayerData.Humanoid = humanoid
	end
	task.wait(0.5)
	if getgenv().SpectateState.IsSpectating then
		SpectateData.Spectating = true
		updateSpectateTarget()
		startCameraMonitor()
	else
		if PlayerData.Humanoid then
			PlayerData.Camera.CameraSubject = PlayerData.Humanoid
		end
	end
end)

Tabs.Killing:AddLabel("—— Kill Aura ——")

local KillAura = {
	RingPart = nil,
	RingColor = Color3.fromRGB(255, 0, 0),
	RingTransparency = 0.6,
	CenterCFrame = nil,
	Frozen = false,
	Generation = 0,
	Rainbow = true,
	RainbowSpeed = 0.18,
	SelectedGradient = nil
}
_G.showDeathRing = false
_G.deathRingRange = 20

local staleKillAuraRing = Services.Workspace:FindFirstChild("TMaCKillAuraRing")
if staleKillAuraRing then staleKillAuraRing:Destroy() end

Tabs.Killing:AddTextBox("Range (1-140):", function(text)
	if tonumber(text) then
		_G.deathRingRange = math.clamp(tonumber(text), 1, 140)
		if KillAura.RingPart then
			KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
		end
	end
end, {clear = false})

local RingColors = {
	{Name = "Rainbow", Hue = nil, Range = 1},
	{Name = "Red", Hue = 0, Range = 0.08},
	{Name = "Orange", Hue = 0.08, Range = 0.07},
	{Name = "Yellow", Hue = 0.14, Range = 0.06},
	{Name = "Green", Hue = 0.33, Range = 0.08},
	{Name = "Cyan", Hue = 0.5, Range = 0.07},
	{Name = "Blue", Hue = 0.64, Range = 0.07},
	{Name = "Purple", Hue = 0.78, Range = 0.07},
	{Name = "Pink", Hue = 0.9, Range = 0.07}
}

KillAura.SelectedGradient = RingColors[2]

local function getGradientColor()
	local preset = KillAura.SelectedGradient or RingColors[1]
	local speed = KillAura.RainbowSpeed or 0.35
	if preset.Hue == nil then
		return Color3.fromHSV((tick() * speed) % 1, 1, 1)
	end
	local wave = (math.sin(tick() * speed * math.pi * 2) + 1) * 0.5
	local hue = (preset.Hue + (wave - 0.5) * preset.Range) % 1
	return Color3.fromHSV(hue, 1, 1)
end

local ringColorDropdown = Tabs.Killing:AddDropdown("Ring Color", function(selection)
	for _, colorData in ipairs(RingColors) do
		if colorData.Name == selection then
			KillAura.SelectedGradient = colorData
			KillAura.Rainbow = true
			local color = getGradientColor()
			KillAura.RingColor = color
			if KillAura.RingPart then
				KillAura.RingPart.Color = color
			end
			break
		end
	end
end)

for _, colorData in ipairs(RingColors) do
	ringColorDropdown:Add(colorData.Name)
end

local function destroyKillAuraRing()
	if KillAura.RingPart then
		KillAura.RingPart:Destroy()
		KillAura.RingPart = nil
	end
end

local function createKillAuraRing()
	destroyKillAuraRing()
	local oldRing = Services.Workspace:FindFirstChild("TMaCKillAuraRing")
	if oldRing then oldRing:Destroy() end
	KillAura.RingPart = Instance.new("Part")
	KillAura.RingPart.Name = "TMaCKillAuraRing"
	KillAura.RingPart.Shape = Enum.PartType.Cylinder
	KillAura.RingPart.Material = Enum.Material.Neon
	KillAura.RingPart.Color = KillAura.RingColor
	KillAura.RingPart.Transparency = KillAura.RingTransparency
	KillAura.RingPart.Anchored = true
	KillAura.RingPart.CanCollide = false
	KillAura.RingPart.CanTouch = false
	KillAura.RingPart.CanQuery = false
	KillAura.RingPart.CastShadow = false
	KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
	if KillAura.CenterCFrame then
		KillAura.RingPart.CFrame = KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
	KillAura.RingPart.Parent = Services.Workspace
end

local showRingSwitch

showRingSwitch = Tabs.Killing:AddSwitch("Show Ring", function(bool)
	if bool and not _G.deathRingEnabled then
		_G.showDeathRing = false
		showRingSwitch:Set(false)
		return
	end
	_G.showDeathRing = bool
	if bool then
		createKillAuraRing()
	else
		destroyKillAuraRing()
	end
end)

if _G.deathRingConnection then
	_G.deathRingConnection:Disconnect()
	_G.deathRingConnection = nil
end

local function updateKillAuraRing()
	if KillAura.RingPart and KillAura.CenterCFrame then
		KillAura.RingPart.CFrame = KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
end

task.spawn(function()
	while true do
		if KillAura.RingPart then
			local color = getGradientColor()
			KillAura.RingColor = color
			KillAura.RingPart.Color = color
		end
		Services.RunService.RenderStepped:Wait()
	end
end)

Tabs.Killing:AddSwitch("Toggle Ring", function(bool)
	_G.deathRingEnabled = bool
	KillAura.Generation += 1
	local generation = KillAura.Generation
	if not bool then
		if showRingSwitch and _G.showDeathRing then showRingSwitch:Set(false) end
		return
	end
	local _, _, initialRoot = getLocalCombatCharacter()
	if initialRoot then KillAura.CenterCFrame = initialRoot.CFrame end
	task.spawn(function()
		while _G.deathRingEnabled and KillAura.Generation == generation do
			local _, _, localRoot = getLocalCombatCharacter()
			if localRoot and not KillAura.Frozen then
				KillAura.CenterCFrame = localRoot.CFrame
			end
			updateKillAuraRing()
			Services.RunService.RenderStepped:Wait()
		end
	end)
	task.spawn(function()
		while _G.deathRingEnabled and KillAura.Generation == generation do
			if KillAura.Frozen or not KillAura.CenterCFrame then
				task.wait(0.05)
				continue
			end
			local centerCFrame = KillAura.CenterCFrame
			local attackedPlayer = false
			for _, player in ipairs(Services.Players:GetPlayers()) do
				if not _G.deathRingEnabled or KillAura.Generation ~= generation then break end
				local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if player ~= Services.Players.LocalPlayer
					and not isWhitelisted(player)
					and isPlayerAlive(player)
					and not isSpawnProtected(player)
					and targetRoot
					and (centerCFrame.Position - targetRoot.Position).Magnitude <= _G.deathRingRange then
					attackedPlayer = true
					KillAura.Frozen = true
					KillAura.CenterCFrame = centerCFrame
					updateKillAuraRing()
					attackPlayerWithLimit(player, 4, function()
						local currentTargetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						return _G.deathRingEnabled
							and KillAura.Generation == generation
							and not isWhitelisted(player)
							and currentTargetRoot
							and (centerCFrame.Position - currentTargetRoot.Position).Magnitude <= _G.deathRingRange
					end, 3.5)
					for _ = 1, 4 do
						local _, _, currentLocalRoot = getLocalCombatCharacter()
						if currentLocalRoot then
							currentLocalRoot.CFrame = centerCFrame
							currentLocalRoot.AssemblyLinearVelocity = Vector3.zero
							currentLocalRoot.AssemblyAngularVelocity = Vector3.zero
						end
						KillAura.CenterCFrame = centerCFrame
						updateKillAuraRing()
						Services.RunService.Heartbeat:Wait()
					end
					KillAura.Frozen = false
				end
			end
			if not attackedPlayer then task.wait(0.05) end
		end
		KillAura.Frozen = false
	end)
end)

task.spawn(function()
	while true do
		whitelistLabel.Text = #_G.whitelistedPlayers == 0 and "Whitelist: None" or "Whitelist: " .. table.concat(_G.whitelistedPlayers, ", ")
		blacklistLabel.Text = #_G.blacklistedPlayers == 0 and "Killlist: None" or "Killlist: " .. table.concat(_G.blacklistedPlayers, ", ")
		task.wait(0.01)
	end
end)

Tabs.Farming:AddLabel("—— Rebirths ——")

local RebirthData = {
	Label = Tabs.Farming:AddLabel("Rebirths: 0"),
	TargetLabel = Tabs.Farming:AddLabel("Target: None"),
	Rebirths = PlayerData.Player.leaderstats:WaitForChild("Rebirths"),
	TargetRebirths = 0,
	IsAutoRebirthing = false
}

Tabs.Farming:AddTextBox("Set Rebirth Target (Required):", function(text)
	if tonumber(text) and tonumber(text) >= 0 then RebirthData.TargetRebirths = tonumber(text) end
end)

RebirthData.Switch = Tabs.Farming:AddSwitch("Auto Rebirth", function(enabled)
	if enabled and RebirthData.TargetRebirths > 0 and RebirthData.Rebirths.Value < RebirthData.TargetRebirths then
		RebirthData.IsAutoRebirthing = true
		task.spawn(function()
			while RebirthData.IsAutoRebirthing and RebirthData.Rebirths.Value < RebirthData.TargetRebirths do
				Services.ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
				task.wait(0.05)
			end
			RebirthData.IsAutoRebirthing = false
			RebirthData.Switch:Set(false)
		end)
	else
		RebirthData.IsAutoRebirthing = false
	end
end)

task.spawn(function()
	while true do
		RebirthData.Label.Text = "Rebirths: " .. Utils.formatWithCommas(RebirthData.Rebirths.Value)
		RebirthData.TargetLabel.Text = "Target Rebirths: " .. Utils.formatWithCommas(RebirthData.TargetRebirths)
		task.wait(0.01)
	end
end)

local SizeData = {Active = false}

Tabs.Farming:AddLabel("—— Size ——")

Tabs.Farming:AddSwitch("Auto Size 1", function(bool) SizeData.Active = bool end):Set(false)

task.spawn(function()
	while true do
		if SizeData.Active and PlayerData.Character and PlayerData.Humanoid then
			Remotes.ChangeSpeedSize:InvokeServer("changeSize", 1)
		end
		task.wait(0.01)
	end
end)

local KingData = {TargetPosition = CFrame.new(-8665.4, 17.21, -5792.9), TeleportActive = false}

Tabs.Farming:AddLabel("—— Muscle King ——")

Tabs.Farming:AddSwitch("Auto King", function(enabled)
	KingData.TeleportActive = enabled
end)

task.spawn(function()
	while true do
		if KingData.TeleportActive then
			if not PlayerData.Character or not PlayerData.Character:FindFirstChildOfClass("Humanoid") then
				PlayerData.Player.CharacterAdded:Wait()
				PlayerData.Character = PlayerData.Player.Character
				task.wait(2)
			end
			if not PlayerData.Humanoid or PlayerData.Humanoid.Health <= 0 then
				repeat
					task.wait(0.5)
					PlayerData.Character = PlayerData.Player.Character
					PlayerData.Humanoid = PlayerData.Character and PlayerData.Character:FindFirstChildOfClass("Humanoid")
				until PlayerData.Character and PlayerData.Humanoid and PlayerData.Humanoid.Health > 0
				task.wait(1)
			end
			if PlayerData.Character and PlayerData.Character:FindFirstChild("HumanoidRootPart") then
				if (PlayerData.Character.HumanoidRootPart.Position - KingData.TargetPosition.Position).magnitude > 5 then
					pcall(function() 
						PlayerData.Character.HumanoidRootPart.CFrame = KingData.TargetPosition 
					end)
				end
			end
		end
		task.wait(0.05)
	end
end)

local bossEnabled = false
local bossThread = nil
local punchRespawnConn = nil
local chestEnabled = false
local chestThread = nil
Tabs.Farming:AddLabel("—— Boss Farm ——")
local bossFolder = Tabs.Farming:AddFolder("Boss Farm")

bossFolder:AddSwitch("Auto Fight Boss", function(value)
	bossEnabled = value
	if bossThread then task.cancel(bossThread) bossThread = nil end
	if punchRespawnConn then
		punchRespawnConn:Disconnect()
		punchRespawnConn = nil
	end
	if not bossEnabled then return end
	local function equipPunch(character)
		character = character or PlayerData.Player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not humanoid then return end
		local punchTool = character:FindFirstChild("Punch") or PlayerData.Player.Backpack:WaitForChild("Punch", 5)
		if punchTool and punchTool.Parent ~= character then
			humanoid:EquipTool(punchTool)
		end
	end
	punchRespawnConn = PlayerData.Player.CharacterAdded:Connect(function(newChar)
		if not bossEnabled then return end
		task.spawn(function()
			equipPunch(newChar)
		end)
	end)
	bossThread = task.spawn(function()
		local muscleEvent = PlayerData.Player:WaitForChild("muscleEvent")
		equipPunch()
		while bossEnabled do
			local arena = Services.Workspace:FindFirstChild("Events") and Services.Workspace.Events:FindFirstChild("BossArena")
			local boss = nil
			local hitbox = nil
			if arena then
				for i = 1, 5 do
					local folder = arena:FindFirstChild("Boss" .. i)
					if folder then
						local bossPart = folder:FindFirstChild("Boss")
						if bossPart and bossPart:IsA("BasePart") then
							local hp = bossPart:GetAttribute("Health")
							if typeof(hp) ~= "number" or hp > 0 then
								local hb = folder:FindFirstChild("BossDamageHitbox", true)
								if hb and hb:IsA("BasePart") then
									boss = bossPart
									hitbox = hb
									break
								end
							end
						end
					end
				end
			end
			local character = PlayerData.Player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character and humanoid and not character:FindFirstChild("Punch") then
				local punchTool = PlayerData.Player.Backpack:FindFirstChild("Punch")
				if punchTool then
					humanoid:EquipTool(punchTool)
				end
			end
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if boss and hitbox and root then
				local behindPos = boss.Position - boss.CFrame.LookVector * (boss.Size.Z / 2 + 3)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = CFrame.new(behindPos, boss.Position)
				local leftHand = character:FindFirstChild("LeftHand")
				local rightHand = character:FindFirstChild("RightHand")
				if leftHand then
					pcall(function() muscleEvent:FireServer("punch", "leftHand") end)
					pcall(function() firetouchinterest(leftHand, hitbox, 0) firetouchinterest(leftHand, hitbox, 1) end)
				end
				if rightHand then
					pcall(function() muscleEvent:FireServer("punch", "rightHand") end)
					pcall(function() firetouchinterest(rightHand, hitbox, 0) firetouchinterest(rightHand, hitbox, 1) end)
				end
				task.wait(0.03)
			else
				task.wait(0.2)
			end
		end
		bossThread = nil
	end)
end)

bossFolder:AddSwitch("Auto Boss Chest", function(value)
	chestEnabled = value
	if chestThread then task.cancel(chestThread) chestThread = nil end
	if not chestEnabled then return end
	chestThread = task.spawn(function()
		while chestEnabled do
			local chest = Services.Workspace:FindFirstChild("BossChest")
			if chest then
				local root = chest:FindFirstChild("Root")
				local prompt = root and root:FindFirstChild("bossChestPrompt")
				if prompt then pcall(function() fireproximityprompt(prompt) end) end
			end
			task.wait(0.08)
		end
		chestThread = nil
	end)
end)

Tabs.Farming:AddLabel("—— Exercises ——")
Tabs.Farming:AddLabel("Recommended while auto rebirthing")

local ExerciseData = {
	SelectedTool = nil,
	AutoFarm = false
}

local toolDropdown = Tabs.Farming:AddDropdown("Select Exercise", function(selection)
	ExerciseData.SelectedTool = selection
end)
for _, tool in ipairs({"Weight", "Pushups", "Situps", "Handstands"}) do 
	toolDropdown:Add(tool)
end

local machinesFolder = Services.Workspace:WaitForChild("machinesFolder")
local squatsByName = {}
local squatMachineNames = {}
local liftMachineNames = {}

local MachineExerciseData = {
	Squat = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}},
	Lift = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}}
}

for _, machine in ipairs(machinesFolder:GetChildren()) do
	local lowerName = string.lower(machine.Name)
	if string.find(lowerName, "squat", 1, true) and lowerName ~= "squat rack" then
		squatsByName[machine.Name] = squatsByName[machine.Name] or {}
		table.insert(squatsByName[machine.Name], machine)
	elseif string.find(lowerName, "lift", 1, true) and lowerName ~= "deadlift" then
		MachineExerciseData.Lift.Choices[machine.Name] = machine
		table.insert(liftMachineNames, machine.Name)
	end
end

for machineName, matchingSquats in pairs(squatsByName) do
	MachineExerciseData.Squat.Choices[machineName] = matchingSquats[1]
	table.insert(squatMachineNames, machineName)
end

table.sort(squatMachineNames)
table.sort(liftMachineNames)

local function getMachineInteractPart(machine)
	for _, descendant in ipairs(machine:GetDescendants()) do
		if descendant:IsA("BasePart") and string.lower(descendant.Name) == "interactseat" then
			return descendant
		end
	end
end

local function enterExerciseMachine(machine)
	if not machine or not machine.Parent then return false end
	local character = PlayerData.Player.Character or PlayerData.Player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	local interactPart = getMachineInteractPart(machine)
	if not humanoidRootPart or not interactPart then return false end
	humanoidRootPart.CFrame = interactPart.CFrame * CFrame.new(0, 3, 0)
	humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	task.wait(0.4)
	Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(0.1)
	Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	task.wait(0.4)
	return true
end

local toolExerciseSwitch
local squatExerciseSwitch
local liftExerciseSwitch

toolExerciseSwitch = Tabs.Farming:AddSwitch("Start exercising", function(enabled)
	ExerciseData.AutoFarm = enabled
	if enabled then
		if squatExerciseSwitch and MachineExerciseData.Squat.Running then squatExerciseSwitch:Set(false) end
		if liftExerciseSwitch and MachineExerciseData.Lift.Running then liftExerciseSwitch:Set(false) end
		task.spawn(function()
			while ExerciseData.AutoFarm do
				if PlayerData.Character ~= PlayerData.Player.Character then
					PlayerData.Character = PlayerData.Player.Character
					PlayerData.Humanoid = PlayerData.Character and PlayerData.Character:FindFirstChildOfClass("Humanoid")
				end
				if not PlayerData.Character or not PlayerData.Character:FindFirstChildOfClass("Humanoid") then
					PlayerData.Player.CharacterAdded:Wait()
					PlayerData.Character = PlayerData.Player.Character
					PlayerData.Humanoid = PlayerData.Character and PlayerData.Character:FindFirstChildOfClass("Humanoid")
					task.wait(2)
				end
				if not PlayerData.Humanoid or PlayerData.Humanoid.Health <= 0 then
					repeat
						task.wait(0.5)
						PlayerData.Character = PlayerData.Player.Character
						PlayerData.Humanoid = PlayerData.Character and PlayerData.Character:FindFirstChildOfClass("Humanoid")
					until PlayerData.Character and PlayerData.Humanoid and PlayerData.Humanoid.Health > 0
					task.wait(1)
				end
				if PlayerData.Character and ExerciseData.SelectedTool then
					local toolName = ExerciseData.SelectedTool
					if not PlayerData.Character:FindFirstChild(toolName) then
						local toolInBackpack = PlayerData.Player.Backpack:FindFirstChild(toolName)
						if toolInBackpack then
							PlayerData.Humanoid:EquipTool(toolInBackpack)
							task.wait(0.2)
						end
					end
					if PlayerData.Character:FindFirstChild(toolName) then
						pcall(function()
							PlayerData.Player.muscleEvent:FireServer("rep")
						end)
					end
					if toolName == "Handstands" and tick() % 6 < 0.1 then
						pcall(function()
							Services.VirtualUser:CaptureController()
							Services.VirtualUser:ClickButton1(Vector2.new(500, 500))
						end)
					end
				end
				task.wait()
			end
		end)
	else
		if ExerciseData.SelectedTool and PlayerData.Player.Character then
			local equippedTool = PlayerData.Player.Character:FindFirstChild(ExerciseData.SelectedTool)
			if equippedTool then
				equippedTool.Parent = PlayerData.Player.Backpack
			end
		end
	end
end)

local function addMachineDropdown(label, machineData, machineNames)
	local dropdown = Tabs.Farming:AddDropdown(label, function(selection)
		machineData.SelectedMachine = machineData.Choices[selection]
		machineData.ActiveMachine = nil
		machineData.SeatPart = nil
		machineData.ReenterAt = 0
	end)
	for _, machineName in ipairs(machineNames) do
		dropdown:Add(machineName)
	end
end

local function startMachineExercise(machineData)
	machineData.Generation += 1
	local generation = machineData.Generation
	local lastCharacter = PlayerData.Player.Character
	task.spawn(function()
		while machineData.Running and machineData.Generation == generation do
			local character = PlayerData.Player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character ~= lastCharacter then
				lastCharacter = character
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = os.clock() + 3.5
			end
			if not character or not humanoid or humanoid.Health <= 0 then
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 3.5)
				task.wait(0.1)
				continue
			end
			local humanoidState = humanoid:GetState()
			local jumpedOff = machineData.ActiveMachine and (
				humanoidState == Enum.HumanoidStateType.Jumping
				or humanoidState == Enum.HumanoidStateType.Freefall
				or (machineData.SeatPart and humanoid.SeatPart ~= machineData.SeatPart)
			)
			if jumpedOff then
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = os.clock() + 3.5
			end
			if machineData.SelectedMachine and not machineData.ActiveMachine and os.clock() >= machineData.ReenterAt then
				if enterExerciseMachine(machineData.SelectedMachine) then
					machineData.ActiveMachine = machineData.SelectedMachine
					machineData.SeatPart = humanoid.SeatPart
				end
			end
			if machineData.ActiveMachine then
				pcall(function()
					PlayerData.Player.muscleEvent:FireServer("rep")
				end)
			end
			task.wait()
		end
	end)
end

local function setMachineExerciseState(machineData, otherMachineData, state)
	machineData.Running = state
	machineData.Generation += 1
	machineData.ActiveMachine = nil
	machineData.SeatPart = nil
	machineData.ReenterAt = 0
	if not state then return end
	if toolExerciseSwitch and ExerciseData.AutoFarm then toolExerciseSwitch:Set(false) end
	if otherMachineData.Running then
		if machineData == MachineExerciseData.Squat and liftExerciseSwitch then
			liftExerciseSwitch:Set(false)
		elseif machineData == MachineExerciseData.Lift and squatExerciseSwitch then
			squatExerciseSwitch:Set(false)
		end
	end
	startMachineExercise(machineData)
end

addMachineDropdown("Select Squat", MachineExerciseData.Squat, squatMachineNames)
squatExerciseSwitch = Tabs.Farming:AddSwitch("Auto Squat", function(state)
	setMachineExerciseState(MachineExerciseData.Squat, MachineExerciseData.Lift, state)
end)

addMachineDropdown("Select Lift", MachineExerciseData.Lift, liftMachineNames)
liftExerciseSwitch = Tabs.Farming:AddSwitch("Auto Lift", function(state)
	setMachineExerciseState(MachineExerciseData.Lift, MachineExerciseData.Squat, state)
end)

Tabs.Farming:AddLabel("—— Rocks ——")

local RockData = {
	Data = {["Tiny Rock - 0 Dura"] = 0, ["Large Rock - 100 Dura"] = 100, ["Punching Rock - 10 Dura"] = 10,
		["Golden Rock - 5k Dura"] = 5000, ["Frost Rock - 150k Dura"] = 150000, ["Mythical Rock - 400k Dura"] = 400000,
		["Eternal Rock - 750k Dura"] = 750000, ["Legend Rock - 1m Dura"] = 1000000, ["Muscle King Rock - 5m Dura"] = 5000000,
		["Jungle Rock - 10m Dura"] = 10000000, ["Industrial Rock - 25m Dura"] = 25000000,},
	SelectedRock = nil
}

local rockDropdown = Tabs.Farming:AddDropdown("Select Rock", function(selection) RockData.SelectedRock = selection end)
for rockName in pairs(RockData.Data) do rockDropdown:Add(rockName) end

Tabs.Farming:AddSwitch("Auto Rock", function(enabled)
	getgenv().RockFarmRunning = enabled
	if enabled and RockData.SelectedRock then
		task.spawn(function()
			while getgenv().RockFarmRunning do
				task.wait(0.12)
				if PlayerData.Player.Durability.Value >= RockData.Data[RockData.SelectedRock] then
					for _, v in pairs(Services.Workspace.machinesFolder:GetDescendants()) do
						if v.Name == "neededDurability" and v.Value == RockData.Data[RockData.SelectedRock] and 
						   PlayerData.Player.Character:FindFirstChild("LeftHand") and v.Parent:FindFirstChild("Rock") then
							firetouchinterest(v.Parent.Rock, PlayerData.Player.Character.RightHand, 0)
							firetouchinterest(v.Parent.Rock, PlayerData.Player.Character.RightHand, 1)
							firetouchinterest(v.Parent.Rock, PlayerData.Player.Character.LeftHand, 0)
							firetouchinterest(v.Parent.Rock, PlayerData.Player.Character.LeftHand, 1)
							gettool()
						end
					end
				end
			end
		end)
	end
end)

Tabs.Farming:AddLabel("—— Combo Farms ——")

local farmingConfigs = {
	{name = "Pushup + Industrial Rock", tool = "Pushups", rock = "Industrial Rock"},
	{name = "Pushup + Jungle Rock", tool = "Pushups", rock = "Ancient Jungle Rock"},
	{name = "Pushup + Muscle King Rock", tool = "Pushups", rock = "Muscle King Mountain"},
	{name = "Pushup + Legends Rock", tool = "Pushups", rock = "Rock Of Legends"}
}

for _, config in ipairs(farmingConfigs) do
	local isActive = false
	Tabs.Farming:AddSwitch(config.name, function(state)
		isActive = state
		if isActive then
			if PlayerData.Player.Backpack:FindFirstChild(config.tool) and not PlayerData.Player.Character:FindFirstChild(config.tool) then
				PlayerData.Player.Character.Humanoid:EquipTool(PlayerData.Player.Backpack[config.tool])
			end
			task.spawn(function()
				while isActive do
					PlayerData.Player.muscleEvent:FireServer("rep")
					if Services.Workspace.machinesFolder:FindFirstChild(config.rock) and PlayerData.Player.Character:FindFirstChild("LeftHand") then
						firetouchinterest(Services.Workspace.machinesFolder[config.rock].Rock, PlayerData.Player.Character.LeftHand, 0)
						firetouchinterest(Services.Workspace.machinesFolder[config.rock].Rock, PlayerData.Player.Character.LeftHand, 1)
					end
					if PlayerData.Player.Backpack:FindFirstChild("Punch") then
						PlayerData.Humanoid:EquipTool(PlayerData.Player.Backpack.Punch)
						PlayerData.Player.muscleEvent:FireServer("punch", "rightHand")
						PlayerData.Player.muscleEvent:FireServer("punch", "leftHand")
					end
					Services.RunService.RenderStepped:Wait()
					if PlayerData.Player.Backpack:FindFirstChild(config.tool) then
						PlayerData.Player.Character.Humanoid:EquipTool(PlayerData.Player.Backpack[config.tool])
					end
				end
			end)
		else
			if PlayerData.Player.Character:FindFirstChild(config.tool) then
				PlayerData.Player.Character[config.tool].Parent = PlayerData.Player.Backpack
			end
		end
	end)
end

Tabs.Inventory:AddLabel("—— Consumables ——")

local EggEaterData = {Running = false}

task.spawn(function()
	while true do
		if EggEaterData.Running then
			local tool = PlayerData.Player.Character:FindFirstChild("Protein Egg") or PlayerData.Player.Backpack:FindFirstChild("Protein Egg")
			if tool then PlayerData.Player.muscleEvent:FireServer("proteinEgg", tool) end
			task.wait(0.25)
		else
			task.wait(1)
		end
	end
end)

Tabs.Inventory:AddSwitch("Eat All Eggs", function(state) EggEaterData.Running = state end):Set(false)

local BoostData = {
	ItemList = {"Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar"},
	Running = false
}

task.spawn(function()
	while true do
		if BoostData.Running then
			for _, itemName in ipairs(BoostData.ItemList) do
				local tool = PlayerData.Player.Character:FindFirstChild(itemName) or PlayerData.Player.Backpack:FindFirstChild(itemName)
				if tool then
					local parts = {}
					for word in itemName:gmatch("%S+") do table.insert(parts, word:lower()) end
					for i = 2, #parts do parts[i] = parts[i]:sub(1, 1):upper() .. parts[i]:sub(2) end
					for i = 1, 10 do PlayerData.Player.muscleEvent:FireServer(table.concat(parts), tool) end
				end
			end
		end
		task.wait(0.1)
	end
end)

Tabs.Inventory:AddSwitch("Eat all Boosts (expect lag)", function(state) BoostData.Running = state end)
Tabs.Pets:AddLabel("—— Pet Shop ——")
Tabs.Pets:AddLabel("Needs gems and inventory space")
local PetShopRuntime = Services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("runtime")
local PetShopFolder = PetShopRuntime:WaitForChild("cPetShopFolder")
local PetShopRemote = Services.ReplicatedStorage.rEvents:WaitForChild("cPetShopRemote")

local PetShopData = {
	SelectedPet = nil,
	PetList = {}
}

local AuraData = {
	SelectedAura = nil,
	AuraList = {}
}

for _, item in ipairs(PetShopFolder:GetChildren()) do
	if item:GetAttribute("IsPowerUp") == true then
		table.insert(AuraData.AuraList, item.Name)
	else
		table.insert(PetShopData.PetList, item.Name)
	end
end

table.sort(PetShopData.PetList)
table.sort(AuraData.AuraList)
local petDropdown = Tabs.Pets:AddDropdown("Choose Pet", function(text) PetShopData.SelectedPet = text end)
for _, petName in ipairs(PetShopData.PetList) do petDropdown:Add(petName) end

Tabs.Pets:AddSwitch("Buy Pet", function(bool)
	_G.AutoHatchPet = bool
	if bool then
		task.spawn(function()
			while _G.AutoHatchPet do
				local selectedPet = PetShopData.SelectedPet and PetShopFolder:FindFirstChild(PetShopData.SelectedPet)
				if selectedPet then
					pcall(function()
						PetShopRemote:InvokeServer(selectedPet)
					end)
				end
				task.wait(0.1)
			end
		end)
	end
end)

Tabs.Pets:AddLabel("—— Auras ——")
local auraDropdown = Tabs.Pets:AddDropdown("Select Aura", function(text) AuraData.SelectedAura = text end)
for _, auraName in ipairs(AuraData.AuraList) do auraDropdown:Add(auraName) end

Tabs.Pets:AddSwitch("Buy Aura", function(bool)
	_G.AutoHatchAura = bool
	if bool then
		task.spawn(function()
			while _G.AutoHatchAura do
				local selectedAura = AuraData.SelectedAura and PetShopFolder:FindFirstChild(AuraData.SelectedAura)
				if selectedAura then
					pcall(function()
						PetShopRemote:InvokeServer(selectedAura)
					end)
				end
				task.wait(0.1)
			end
		end)
	end
end)

Tabs.Pets:AddLabel("—— Auto Evolve ——")
local petDropdown3 = Tabs.Pets:AddDropdown("Choose Pet", function(text) PetShopData.SelectedPet = text end)
for _, petName in ipairs(PetShopData.PetList) do petDropdown3:Add(petName) end
local running = false

Tabs.Pets:AddSwitch("Auto Evolve", function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            if PetShopData.SelectedPet then
                game.ReplicatedStorage.rEvents.petEvolveEvent:FireServer(
                    "evolvePet",
                    PetShopData.SelectedPet
                )
            end
            task.wait(0.5)
        end
    end)
end)

Tabs.Pets:AddLabel("—— Auto Trade ——")
local TradeData = {SelectedPlayer = nil}

local playerDropdown4 = Tabs.Pets:AddDropdown("Choose Player", function(name)
    local username = name:match(" | (.+)") or name
    TradeData.SelectedPlayer = Services.Players:FindFirstChild(username)
end)

for _, player in ipairs(Services.Players:GetPlayers()) do
    if player ~= Services.Players.LocalPlayer then
        playerDropdown4:Add(player.DisplayName .. " | " .. player.Name)
    end
end

Services.Players.PlayerAdded:Connect(function(player)
    if player ~= Services.Players.LocalPlayer then
        playerDropdown4:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

Services.Players.PlayerRemoving:Connect(function(player)
    playerDropdown4:Remove(player.DisplayName .. " | " .. player.Name)
    if TradeData.SelectedPlayer == player then TradeData.SelectedPlayer = nil end
end)

local petDropdown2 = Tabs.Pets:AddDropdown("Choose Pet", function(text) PetShopData.SelectedPet = text end)
for _, petName in ipairs(PetShopData.PetList) do petDropdown2:Add(petName) end
local running = false

Tabs.Pets:AddSwitch("Auto Trade", function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            if TradeData.SelectedPlayer and PetShopData.SelectedPet then
                local tradingEvent = game.ReplicatedStorage.rEvents.tradingEvent
                local unique = game.Players.LocalPlayer.petsFolder.Unique
                tradingEvent:FireServer(
                    "sendTradeRequest",
                    TradeData.SelectedPlayer
                )
                task.wait(0.5)
                local offered = 0
                for _, pet in ipairs(unique:GetChildren()) do
                    if not running then break end
                    if pet.Name == PetShopData.SelectedPet then
                        tradingEvent:FireServer("offerItem", pet)
                        offered += 1
                        task.wait(0.01)
                        if offered >= 6 then
                            break
                        end
                    end
                end
                task.wait(0.05)
                if running then
                    tradingEvent:FireServer("acceptTrade")
                end
            end
            task.wait(2)
        end
    end)
end)

Tabs.Inventory:AddLabel("—— Egg Gifter ——")
local EggGifterData = {ProteinEggLabel = Tabs.Inventory:AddLabel("Protein Eggs: 0"), SelectedPlayer = nil, EggCount = 0}

local playerDropdown = Tabs.Inventory:AddDropdown("Choose Player", function(name)
    local username = name:match(" | (.+)") or name
    EggGifterData.SelectedPlayer = Services.Players:FindFirstChild(username)
end)

for _, player in ipairs(Services.Players:GetPlayers()) do
    if player ~= Services.Players.LocalPlayer then
        playerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

Services.Players.PlayerAdded:Connect(function(player)
    if player ~= Services.Players.LocalPlayer then
        playerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

Services.Players.PlayerRemoving:Connect(function(player)
    playerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
    if EggGifterData.SelectedPlayer == player then EggGifterData.SelectedPlayer = nil end
end)

local eggAmountTextBox = Tabs.Inventory:AddTextBox("Amount:", function(text)
	local amount = tonumber(text)
	if amount then
		EggGifterData.EggCount = math.max(0, math.floor(amount))
	end
end, {clear = false})

Tabs.Inventory:AddButton("Start Gifting", function()
	local amount = tonumber(eggAmountTextBox.Text) or EggGifterData.EggCount
	amount = amount and math.max(0, math.floor(amount)) or 0
	EggGifterData.EggCount = amount
	if not EggGifterData.SelectedPlayer or amount == 0 then return end
	task.spawn(function()
		for _ = 1, amount do
			local egg = Services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Protein Egg")
			if not egg then break end
			pcall(function()
				Services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", EggGifterData.SelectedPlayer, egg)
			end)
			task.wait(0.1)
		end
	end)
end)

Tabs.Inventory:AddLabel("—— Shake Gifter ——")
local ShakeGifterData = {TropicalShakeLabel = Tabs.Inventory:AddLabel("Tropical Shakes: 0"), SelectedPlayer = nil, ShakeCount = 0}

local playerDropdown3 = Tabs.Inventory:AddDropdown("Choose Player", function(name)
	local usernameone = name:match(" | (.+)") or name
	ShakeGifterData.SelectedPlayer = Services.Players:FindFirstChild(usernameone)
end)

for _, player in ipairs(Services.Players:GetPlayers()) do
	if player ~= Services.Players.LocalPlayer then
		playerDropdown3:Add(player.DisplayName .. " | " .. player.Name)
	end
end

Services.Players.PlayerAdded:Connect(function(player)
	if player ~= Services.Players.LocalPlayer then
		playerDropdown3:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

Services.Players.PlayerRemoving:Connect(function(player)
	playerDropdown3:Remove(player.DisplayName .. " | " .. player.Name)
	if ShakeGifterData.SelectedPlayer == player then ShakeGifterData.SelectedPlayer = nil end
end)

local shakeAmountTextBox = Tabs.Inventory:AddTextBox("Amount:", function(text)
	local amount = tonumber(text)
	if amount then
		ShakeGifterData.ShakeCount = math.max(0, math.floor(amount))
	end
end, {clear = false})

Tabs.Inventory:AddButton("Start Gifting", function()
	local amount = tonumber(shakeAmountTextBox.Text) or ShakeGifterData.ShakeCount
	amount = amount and math.max(0, math.floor(amount)) or 0
	ShakeGifterData.ShakeCount = amount
	if not ShakeGifterData.SelectedPlayer or amount == 0 then return end
	task.spawn(function()
		for _ = 1, amount do
			local shake = Services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Tropical Shake")
			if not shake then break end
			pcall(function()
				Services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", ShakeGifterData.SelectedPlayer, shake)
			end)
			task.wait(0.1)
		end
	end)
end)

task.spawn(function()
	while true do
		local proteinEggCount = 0
		local tropicalShakeCount = 0
		if PlayerData.Backpack then
			for _, item in ipairs(PlayerData.Backpack:GetChildren()) do
				if item.Name == "Protein Egg" then proteinEggCount = proteinEggCount + 1
				elseif item.Name == "Tropical Shake" then tropicalShakeCount = tropicalShakeCount + 1 end
			end
		end
		EggGifterData.ProteinEggLabel.Text = "Protein Eggs: " .. proteinEggCount
		ShakeGifterData.TropicalShakeLabel.Text = "Tropical Shakes: " .. tropicalShakeCount
		task.wait(7.5)
	end
end)

Tabs.Inventory:AddLabel("Gifted boosts can conflict with auto eat. Sit on a machine to reduce lag.")
Tabs.Teleport:AddLabel("—— Islands ——")

local teleportLocations = {
	{name = "Tree Island", pos = CFrame.new(-37.1, 9.2, 1919)},
	{name = "Main Island", pos = CFrame.new(16.07, 9.08, 133.8)},
	{name = "Beach", pos = CFrame.new(-8, 9, -169.2)}
}

for _, loc in ipairs(teleportLocations) do
	Tabs.Teleport:AddButton(loc.name, function()
		if PlayerData.Player.Character and PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			PlayerData.Player.Character.HumanoidRootPart.CFrame = loc.pos
		end
	end)
end

Tabs.Teleport:AddLabel("—— Gyms ——")

local gymLocations = {
	{name = "Industrial gym", pos = CFrame.new(-5254.681641, 58.342850, 4931.850586)},
	{name = "Jungle Gym", pos = CFrame.new(-8543, 6.8, 2400)},
	{name = "Muscle King Gym", pos = CFrame.new(-8665.4, 17.21, -5792.9)},
	{name = "Legends Gym", pos = CFrame.new(4516, 991.5, -3856)},
	{name = "Infernal Gym", pos = CFrame.new(-6759, 7.36, -1284)},
	{name = "Mythical Gym", pos = CFrame.new(2250, 7.37, 1073.2)},
	{name = "Frost Gym", pos = CFrame.new(-2623, 7.36, -409)}
}

for _, gym in ipairs(gymLocations) do
	Tabs.Teleport:AddButton(gym.name, function()
		if PlayerData.Player.Character and PlayerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			PlayerData.Player.Character.HumanoidRootPart.CFrame = gym.pos
		end
	end)
end

Tabs.Stats:AddLabel("—— Session Time ——")

local StatsData = {
	StopwatchLabel = Tabs.Stats:AddLabel("0d 0h 0m 0s"),
	StartTime = tick(),
	Leaderstats = PlayerData.Player:WaitForChild("leaderstats"),
	Stats = {},
	InitialValues = {},
	StatLabels = {}
}

Tabs.Stats:AddLabel("—— Session Gains ——")

task.spawn(function()
	while true do
		local elapsedTime = tick() - StatsData.StartTime
		local days = math.floor(elapsedTime / (24 * 3600))
		local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
		local minutes = math.floor((elapsedTime % 3600) / 60)
		local seconds = math.floor(elapsedTime % 60)
		StatsData.StopwatchLabel.Text = string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
		task.wait(0.1)
	end
end)

StatsData.Stats = {
	{name = SpecsData.EmojiMap["Strength"] .. " Strength", stat = StatsData.Leaderstats:WaitForChild("Strength")},
	{name = SpecsData.EmojiMap["Rebirths"] .. " Rebirths", stat = StatsData.Leaderstats:WaitForChild("Rebirths")},
	{name = SpecsData.EmojiMap["Durability"] .. " Durability", stat = PlayerData.Player:WaitForChild("Durability")},
	{name = SpecsData.EmojiMap["Kills"] .. " Kills", stat = StatsData.Leaderstats:WaitForChild("Kills")},
	{name = SpecsData.EmojiMap["Agility"] .. " Agility", stat = PlayerData.Player:WaitForChild("Agility")},
	{name = SpecsData.EmojiMap["Evil Karma"] .. " Evil Karma", stat = PlayerData.Player:WaitForChild("evilKarma")},
	{name = SpecsData.EmojiMap["Good Karma"] .. " Good Karma", stat = PlayerData.Player:WaitForChild("goodKarma")},
	{name = SpecsData.EmojiMap["Brawls"] .. " Brawls", stat = StatsData.Leaderstats:WaitForChild("Brawls")}
}

for _, info in ipairs(StatsData.Stats) do
	StatsData.InitialValues[info.name] = info.stat.Value
	StatsData.StatLabels[info.name] = Tabs.Stats:AddLabel("")
end


local function enableTabScrolling()
	local gui
	pcall(function()
		gui = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if not gui then
		local lp = game:GetService("Players").LocalPlayer
		gui = lp and lp:FindFirstChild("PlayerGui")
	end
	local imgui = gui and (gui:FindFirstChild("imgui") or gui:FindFirstChild("Imgui"))
	if not imgui then
		return
	end
	local windows = imgui:FindFirstChild("Windows")
	if not windows then
		return
	end
	for _, window in ipairs(windows:GetChildren()) do
		local tabsFolder = window:FindFirstChild("Tabs")
		if tabsFolder then
			for _, tab in ipairs(tabsFolder:GetChildren()) do
				if tab:IsA("ScrollingFrame") then
					tab.ScrollingEnabled = true
					tab.ScrollBarThickness = math.max(tab.ScrollBarThickness, 6)
					tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
					local layout = tab:FindFirstChildOfClass("UIListLayout")
					if layout then
						tab.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
					end
				elseif tab:IsA("GuiObject") and not tab:FindFirstChild("TMaCScroll") then
					local scroll = Instance.new("ScrollingFrame")
					scroll.Name = "TMaCScroll"
					scroll.BackgroundTransparency = 1
					scroll.BorderSizePixel = 0
					scroll.Size = UDim2.new(1, 0, 1, 0)
					scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
					scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
					scroll.ScrollBarThickness = 6
					scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 80, 80)
					scroll.ScrollingDirection = Enum.ScrollingDirection.Y
					scroll.ZIndex = tab.ZIndex
					local pad = Instance.new("UIPadding")
					pad.PaddingRight = UDim.new(0, 10)
					pad.PaddingBottom = UDim.new(0, 8)
					pad.Parent = scroll
					for _, child in ipairs(tab:GetChildren()) do
						child.Parent = scroll
					end
					scroll.Parent = tab
					local layout = scroll:FindFirstChildOfClass("UIListLayout")
					if layout then
						local function refresh()
							scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
						end
						layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)
						scroll.ChildAdded:Connect(function()
							task.defer(refresh)
						end)
						task.defer(refresh)
					end
				end
			end
		end
	end
end

task.defer(enableTabScrolling)
task.delay(0.5, enableTabScrolling)

enableTabScrolling()

while true do
	for _, info in ipairs(StatsData.Stats) do
		local currentValue = info.stat.Value
		local gained = currentValue - StatsData.InitialValues[info.name]
		StatsData.StatLabels[info.name].Text = string.format("%s: %s (%s) | Gained: %s (%s)", info.name,
			Utils.formatNumber(currentValue), Utils.formatWithCommas(currentValue),
			Utils.formatNumber(gained), Utils.formatWithCommas(gained))
	end
	wait(0.1)
end