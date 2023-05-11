local DataService = require(game:GetService("ReplicatedStorage"):WaitForChild("DataService"))
local ServerScriptService = game:GetService("ServerScriptService")
if not DataService.Server_Initialized then return end

local Service = {}

DataService.Changed:Connect(function(Player : Player, Player_Data : {}, DataName : string)
    if not Player_Data[DataName] then return end

    local Leaderstats = Player:FindFirstChild("leaderstats")
    if not Leaderstats then return end

    local Data = Leaderstats:FindFirstChild(DataName)
    if not Data then return end

    Data.Value = Player_Data[DataName]
end)

function Service:InitPlayer(Player : Player, Player_Data : {}, DataToShow : { string }?)
    if not DataToShow or typeof(DataToShow) ~= 'table' or not DataToShow[1] or typeof(DataToShow[1]) ~= 'string' then return end
    
    local Leaderstats = Instance.new("Folder")
    Leaderstats.Name = "leaderstats"
    Leaderstats.Parent = Player

    for _, DataName : string in ipairs(DataToShow) do
        if not Player_Data[DataName] then continue end
        local Data = if typeof(Player_Data[DataName]) == "number" then Instance.new("IntValue") elseif typeof(Player_Data[DataName]) == "string" then Instance.new("StringValue") else continue end 
        Data.Name = DataName
        Data.Parent = Leaderstats
        Data.Value = Player_Data[DataName]
    end
end

return Service