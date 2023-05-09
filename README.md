# ProfileSync

**ProfileSync** is a powerful and user-friendly Profile Managing module designed to streamline the setup and replication of Player Data in your Roblox games. By leveraging the reliability of [ProfileService](https://github.com/MadStudioRoblox/ProfileService), ProfileSync ensures that your game can handle high volumes of data with ease.

ProfileSync offers seamless synchronization between Server and Client data, allowing for real-time updates without the need for remote functions. This ensures that your game's players always have access to the latest data, while you can focus on creating an engaging and immersive experience. Unlock the full potential of data management in your Roblox projects with ProfileSync!

## Getting Started

Get started by getting the module in one of these places: 
- **[Github](https://github.com/nSpected/ArklightRBLX/releases/tag/Release)**
- **[Roblox Library](https://www.roblox.com/library/13385972417/DataService-v1-0-0)**

### What you'll need

- **[Knit](https://github.com/Sleitnick/Knit) v1.5.1 or above**, if you choose to go with the Knit version.
- Some scripting knowledge, as this is only a small module that aims to make it a bit more practical to set and get data from both client and server, but it does not do anything by itself.

### Setting up

- Drag and drop and **.rbxm** file inside your place, or take it from the Roblox Library (Toolbox).
- Ungroup the version you're going to use in ```ReplicatedStorage```.
  - If you are using **Knit**, you may already have a folder for your Services and Controllers, so you can just move ```DataController``` and ```DataService``` to their respective folder.

For people who are using **Knit**, you are ready to go as the module will initialize by default when Knit starts.

### No Knit - Extra
You need to require the module manually in both client and server, you can do it by:
- Inside a script in ```ServerScriptService``` require the **DataService** module, and run the init function:

```lua
local DataService = require(Path.To.DataService) -- Change this to the DataService module.
DataService:Init()
```

- Now inside a LocalScript in ```StarterPlayerScripts```, require the **DataController** module, and run the init function:

```lua	
local DataController = require(Path.To.DataController) -- Change this to the DataController module.
DataController:Init()
```

- **You're all set now!**

## Usage Example - KNIT

- Since you probably want to use the actual benefits of this module, here's an example of how you can use it:

- SERVER:
```lua
  -- SERVICES --
  local RS = game:GetService("ReplicatedStorage")
  local Players = game:GetService("Players")

  -- FRAMEWORKS --
  local Knit = require(RS.Packages.Knit)

  -- SERVICES --
  local Services = Knit.AddServices(RS.Services)

  -- STARTING KNIT --
  Knit.Start():andThen(function()
    print("[SERVER] Knit Started.")
    
    local DataService = Knit.GetService("DataService")
    
    task.spawn(function()
      while task.wait(1) do
        DataService:Add(Players:GetPlayers()[1], "Coins", 100)
      end	
    end)	
  end):catch(warn)
```

- CLIENT:
```lua
  -- SERVICES --
  local RS = game:GetService("ReplicatedStorage")

  -- FRAMEWORKS --
  local Knit = require(RS.Packages.Knit)

  -- CONTROLLERS --
  local Controllers = Knit.AddControllers(RS.Controllers)

  -- STARTING KNIT --
  Knit.Start():await()

  -- DATA CONTROLLER --
  local DataController = Knit.GetController("DataController")

  -- TEST --
  while task.wait(1) do
    print(DataController:GetData(game.Players.LocalPlayer, "Coins"))
  end
```

## Usage Example - NO KNIT

- And here's an example of how you can use it without Knit:

- SERVER:
```lua
  -- SERVICES --
  local RS = game:GetService("ReplicatedStorage")
  local Players = game:GetService("Players")

  -- MODULES --
  local DataService = require(RS.DataService) -- Change to your path.
  DataService:Init()

  -- TEST --
  task.spawn(function()
    while task.wait(1) do
      if DataService.Initialized == false then return end -- If the Service has not been initialized yet, we don't do anything.
      DataService:Add(Players:GetPlayers()[1], "Coins", 100) -- This will increase the player's coins by 100 every 1 second once his data has been loaded.
    end   
  end)
```

- CLIENT:
```lua
  -- SERVICES --
  local RS = game:GetService("ReplicatedStorage")

  -- CONTROLLERS --
  local DataController = require(RS:WaitForChild("DataController"))
  DataController:Init() -- Initialize the Client.

  -- TEST --
  while task.wait(1) do
    print(DataController:GetData(game.Players.LocalPlayer, "Coins")) -- This may not return right away as the data can take a while to load
  end
```
