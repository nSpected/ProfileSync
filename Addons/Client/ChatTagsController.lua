-- SERVICES --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- KNIT --
local Knit = require(ReplicatedStorage.Packages.Knit) -- Change this to your knit path, or remove if not using Knit.

-- CONTROLLERS --
local DataController = Knit.GetController("DataController") -- NO KNIT: require(ReplicatedStorage:WaitForChild("DataController"))

local Controller = {}

export type Tags_Data = {
    Tags : { string }, -- List of tags that will be available
    Tag_Colors : { [ string ] : Color3 }, -- Color for each tag listed in the Tags table
    Tag_Requirements : { [ string ] : { [ string ] : string | number } }, -- Requirements for each tag listed in the Tags table, if it's group rank then it will be a number, if it's a gamepass then it will be a string
    Tag_Priority : { [ string ] : number }, -- Priority for each tag listed in the Tags table, the higher the number the higher the priority
    Group_ID : number?, -- Group ID
}

function Controller.Init(Data : Tags_Data)
	
	if not Data then
		Data = {
			Tags = {
				"VIP", 
				"Owner", 
				"Developer"
			},
			
			Tag_Colors = { 
				["VIP"] = Color3.fromRGB(255, 212, 42), 
				["Owner"] = Color3.fromRGB(255, 87, 87), 
				["Developer"] = Color3.fromRGB(165, 92, 195)
			},
			
			Tag_Requirements = { 
				["VIP"] = "VIP", 
				["Owner"] = 255,
				["Developer"] = 6
			},
			
			Tag_Priority = { -- HIGHER OVERWITES LOWER
				["VIP"] = 1,
				["Developer"] = 2,
				["Owner"] = 255,
			},
			
			Group_ID = 0
		}
	end
	
	ChatService.OnIncomingMessage = function(Message : TextChatMessage)
		local Props : TextChatMessageProperties = Instance.new("TextChatMessageProperties")

		local highestPriority = -1
		local selectedTag = nil
		local selectedColor = nil
		
		if Message.TextSource then
			for _, v in ipairs(Players:GetPlayers()) do
				if v.UserId ~= Message.TextSource.UserId then continue end

				local Player_Passes = DataController:GetData(v, "Passes")
				if not Player_Passes then
					Player_Passes = {}
				end

				local groupId = Data.Group_ID or 0
				local Player_GroupRank = v:GetRankInGroup(groupId)

				for tag, requirement in pairs(Data.Tag_Requirements) do
					local priority = Data.Tag_Priority[tag]

					if type(requirement) == "number" then
						if Player_GroupRank and Player_GroupRank >= requirement and priority > highestPriority then
							highestPriority = priority
							selectedTag = tag
							selectedColor = Data.Tag_Colors[tag]
						end
					elseif type(requirement) == "string" then
						if table.find(Player_Passes, requirement) and priority > highestPriority then
							highestPriority = priority
							selectedTag = tag
							selectedColor = Data.Tag_Colors[tag]
						end
					end
				end
				
				if selectedTag and selectedColor then
					selectedTag = "[" .. selectedTag .. "] "
					Props.PrefixText = "<font color='#" .. selectedColor:ToHex() .. "'>" .. selectedTag .. "</font>" .. Message.PrefixText
				end
			end
		end
		
		return Props
	end
end


return Controller