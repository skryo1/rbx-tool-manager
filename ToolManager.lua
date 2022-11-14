--[[

	ToolManager
		Sekuriyo @ 14/11/2022
		
		- Allows you to easily equip tools on NPC's both on the server and the client.
		
		- Gives full control over which tools are equipped using :GetTools()
		
		- Uses an OOP structure allowing you to individually manage each character's tools using this module.
		
		
	Documentation
		Sekuriyo @ 14/11/2022
		
			-- To be called with the specified character you wish to use, returns a ToolManager object.
		CONSTRUCTOR >> ToolManager.new( character ) >> RETURNS: table
			
			-- Call using the returned ToolManager object from the constructor.
			-- Equips the tool, this will not clone the tool so ensure you do that yourself.
		FUNCTION >> ToolManager:EquipTool( tool ) >> RETURNS: nil
		
			-- Call using the returned ToolManager object from the constructor.
			-- Returns all tools currently equipped by the character
		FUNCTION >> ToolManager:GetTools() >> RETURNS: dictionary
		
]]


local RunService = game:GetService("RunService")

local ToolManager = {}
ToolManager.__index = ToolManager


local function addTool( character: Model, tool: Tool, equippedTools: {} )
	assert(tool.Handle, "Specified tool does not have a handle set")
	
	local rightHand = character:FindFirstChild("RightHand")
	local gripAttachment = rightHand:FindFirstChild("RightGripAttachment")
	
	local motor6D = Instance.new("Motor6D")
	motor6D.Name = "RightGrip"
	motor6D.C0 = gripAttachment.CFrame
	motor6D.C1 = tool.Grip
	motor6D.Part0 = rightHand
	motor6D.Part1 = tool.Handle
	motor6D.Parent = rightHand
	tool.Parent = character
	table.insert(equippedTools, motor6D)
	table.insert(equippedTools, tool)
end

function ToolManager.new( character: Model ) : {}
	local self = {}
	setmetatable(self, ToolManager)
	
	self.character = character :: Model
	self.serverCheck = RunService:IsServer() :: boolean
	
	self.equippedTools = {} :: {}
	
	return self
end


function ToolManager:EquipTool( tool: Tool ) : nil
	assert(tool:IsA("Tool"), "Incorrect object type provided to ToolManager:EquipTool")
	self.equippedTools[tool] = {}
	addTool(self.character, tool, self.equippedTools[tool])
end


function ToolManager:UnequipTool( tool: Tool ) : nil
	assert(tool:IsA("Tool"), "Incorrect object type provided to ToolManager:EquipTool")
	
	local toolReference = self.equippedTools[tool] :: {}
	if toolReference then
		for _, item : Motor6D? in ipairs (toolReference) do
			item:Destroy()
		end
	end
	self.equippedTools[tool] = nil
end


function ToolManager:UnequipTools() : nil
	local tools = self:GetTools()
	for toolObj : Tool, toolRef : {} in pairs (tools) do
		for _ : number, toolObj : Motor6D? in ipairs (toolRef) do
			toolObj:Destroy()
		end
	end
end


function ToolManager:GetTools() : {}
	return self.equippedTools
end


return ToolManager