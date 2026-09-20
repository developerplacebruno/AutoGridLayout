--!strict
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui

local activeConnections: { [UIGridLayout]: { RBXScriptConnection } } = {}

local function clearConnections(gridLayout: UIGridLayout)
	local connections = activeConnections[gridLayout]
	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
		activeConnections[gridLayout] = nil
	end
end

local function getAttribute(gridLayout: UIGridLayout, name: string, default: number): number
	local value = gridLayout:GetAttribute(name)
	if type(value) == "number" then
		return value
	end

	return default
end

local function updateGridLayout(gridLayout: UIGridLayout)
	local container = gridLayout.Parent
	if not container or not container:IsA("GuiObject") then
		return
	end

	local aspectRation = getAttribute(gridLayout, "AspectRatio", 1)
	local columns = getAttribute(gridLayout, "Columns", 7)
	local paddingScale = getAttribute(gridLayout, "Padding", 0.01)
	local rows = getAttribute(gridLayout, "Rows", 0)

	local absoluteSize = container.AbsoluteSize

	local paddingOffset = paddingScale * absoluteSize.X

	local totalPaddingX = paddingOffset * (columns - 1)
	local cellWidth = math.max((absoluteSize.X - totalPaddingX) / columns, 0)

	local cellHeight: number

	if rows > 0 then
		local totalPaddingY = paddingOffset * (rows - 1)
		cellHeight = math.max((absoluteSize.Y - totalPaddingY) / rows, 0)
	else
		cellHeight = cellWidth / aspectRation
	end

	gridLayout.CellPadding = UDim2.fromOffset(paddingOffset, paddingOffset)
	gridLayout.CellSize = UDim2.fromOffset(cellWidth, cellHeight)
end

local function setupGridLayout(gridLayout: UIGridLayout)
	clearConnections(gridLayout)

	local container = gridLayout.Parent
	if not container or not container:IsA("GuiObject") then
		return
	end

	local function update()
		updateGridLayout(gridLayout)
	end

	update()

	local connections = {
		container:GetPropertyChangedSignal("AbsoluteSize"):Connect(update),
		gridLayout:GetAttributeChangedSignal("AspectRatio"):Connect(update),
		gridLayout:GetAttributeChangedSignal("Columns"):Connect(update),
		gridLayout:GetAttributeChangedSignal("Padding"):Connect(update),
		gridLayout:GetAttributeChangedSignal("Rows"):Connect(update),
	}

	activeConnections[gridLayout] = connections

	gridLayout.AncestryChanged:Connect(function(_, parent)
		if not parent then
			clearConnections(gridLayout)
		end
	end)
end

for _, descendant in playerGui:GetDescendants() do
	if descendant:IsA("UIGridLayout") then
		setupGridLayout(descendant)
	end
end

playerGui.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("UIGridLayout") then
		setupGridLayout(descendant)
	end
end)
