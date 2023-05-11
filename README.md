# 🌟 Introduction

![profile-sync-banner](https://github.com/nSpected/ProfileSync/blob/c5e65a3384372a0f51b931a47bb4cd4214766e9e/img/ps-banner.png)

**ProfileSync** is a powerful and user-friendly Profile Managing module designed to streamline the setup and replication of Player Data in your Roblox games. By leveraging the reliability of [ProfileService](https://github.com/MadStudioRoblox/ProfileService), ProfileSync ensures that your game can handle high volumes of data with ease.

ProfileSync offers seamless synchronization between Server and Client data, allowing for real-time updates without the need for remote functions. This ensures that your game's players always have access to the latest data, while you can focus on creating an engaging and immersive experience. Unlock the full potential of data management in your Roblox projects with ProfileSync!

## 🚀 Getting Started

Get started by getting the module from one of these sources: 
- **[Github](https://github.com/nSpected/ProfileSync/releases)**
- **[Roblox Library](https://www.roblox.com/library/13397074576/ProfileSync-v1-0-1)**

### 📦 What you'll need

- **[Knit](https://github.com/Sleitnick/Knit) v1.5.1 or above**, if you choose to go with the Knit version.
- Some scripting knowledge, as this is only a small module that aims to make it a bit more practical to set and get data from both client and server, but it does not do anything by itself.

## 🛠️ Setting up

- Drag and drop the ```.rbxm``` file into your place, or find it in the Roblox Library (Toolbox) and add it to your game.
- Ungroup the version you're going to use, placing it in the ```ReplicatedStorage```.
  - If you are using the ```Knit``` framework, you may already have designated folders for your Services and Controllers. In this case, move the ```DataController``` and ```DataService``` modules to their respective folders.

:::tip You're All Set!
For those using Knit, you're all set! :white_check_mark: The module will initialize automatically when Knit starts :rocket:, and you're ready to take advantage of **ProfileSync** in your Roblox project :joystick:.
:::

## :wrench: No Knit - Required Extra Steps 
:::caution
This is only for those who are not using Knit!
:::

You need to require the module manually in both client and server, you can do it by:
- Inside a script in ```ServerScriptService``` require the **DataService** module, and run the ```:Init()``` function:

```lua
local DataService = require(Path.To.DataService) -- Change this to the DataService module.
DataService:Init()
```

- Now, inside a LocalScript in ```StarterPlayerScripts```, require the **DataController** module, and run the ```:Init()``` function:

```lua	
local DataController = require(Path.To.DataController) -- Change this to the DataController module.
DataController:Init()
```

- :tada: **You're all set now!**

## 💡 Usage Example - KNIT

- Since you probably want to use the actual benefits of this module, here's an example of how you can use it:

### 🌐 SERVER:
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

### 🖥️ CLIENT:
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
  DataController.Changed:Connect(function(Player_Data : {}, DataName : string)
	  print(game.Players.LocalPlayer, "'s [", DataName, "] has been changed to: ", Player_Data[DataName])
  end)
```

## 💡 Usage Example - NO KNIT

- And here's an example of how you can use it without Knit:

### 🌐 SERVER:
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

### 🖥️ CLIENT:
```lua
  -- SERVICES --
  local RS = game:GetService("ReplicatedStorage")

  -- CONTROLLERS --
  local DataController = require(RS:WaitForChild("DataController"))
  DataController:Init() -- Initialize the Client.

  -- TEST --
  DataController.Changed:Connect(function(Player_Data : {}, DataName : string)
	  print(game.Players.LocalPlayer, "'s [", DataName, "] has been changed to: ", Player_Data[DataName])
  end)
```

