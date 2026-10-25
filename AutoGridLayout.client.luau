--!strict
local CollectionService = game:GetService("CollectionService")
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui

const TAG_NAME = "AutoGridLayout"

local AutoGridLayout = {}

local function getAttribute(uiGridLayout: UIGridLayout, name: string, default: number)
	local value = uiGridLayout:GetAttribute(name)
	return type(value) == "number" and value or default
end

local function setupGridLayout(uiGridLayout: UIGridLayout)
	local container = uiGridLayout.Parent
	if not container then
		return
	end

	local aspectRation = getAttribute(uiGridLayout, "AspectRation", 1)
	local columns = getAttribute(uiGridLayout, "Columns", 7)
	local padding = getAttribute(uiGridLayout, "Padding", 0.01)

	uiGridLayout.CellSize = UDim2.fromScale((1 - (columns + 1) * padding) / columns, 0)

	-- Add UIAspectRation to children

	local function setupChild(child: Instance)
		local uiAspectRatio = Instance.new("UIAspectRatioConstraint", child)
		uiAspectRatio.AspectRatio = aspectRation
		uiAspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
	end

	for _, child in container:GetChildren() do
		setupChild(child)
	end

	container.ChildAdded:Connect(function(child)
		setupChild(child)
	end)
end

function AutoGridLayout:init()
	for _, object in pairs(CollectionService:GetTagged(TAG_NAME)) do
		setupGridLayout(object)
	end

	CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(function(object)
		setupGridLayout(object)
	end)
end

return AutoGridLayout
