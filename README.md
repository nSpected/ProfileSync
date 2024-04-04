# About it 📝
ProfileSync is a simple project that I made for managing data and its replication in my games, it provides an easy-to-use syntax and allows you to easily access player data on both client and server with the same syntax.
It currently relies on a personal wrapper of Warp for its replication network, so it should be quite performant in that context (I hope), while maintaining a similar syntax to the default Roblox events.
Also, since some of you might want to handle replication yourselves, or not have it at all, you can disable it completely by just having its Filter List to be empty while the Filter Type is set to "Whitelist".

# Why use ProfileSync? ✅
- It's simple, fast, and does the job.
- I maintain it since I use it.

# Why NOT use ProfileSync? ❌ 
- It has not been properly tested in production.
- It's in early development.

# Setup 🛠️
- Get the model from the Creator Store: Roblox Creator Store.
- Or get it from its GitHub releases: pending...
- Drop the "ProfileSync" folder inside ServerScriptService.
- Setup the data structure inside `ProfileSync > Utilities > Settings`.
- You're ready to go! 🚀

# Example Usages

## Gettings a player's data:
Can be used on both client and server, though client is limited to the data that he is allowed to read.

### Not using promise:
```lua
local playerProfile = DataController:GetProfile(player, 20, false) -- Yields
if not playerProfile then return end --// Profile could not be loaded
```

### Using promise:
```lua
DataController:GetProfile(player, 20, true):andThen(function(playerProfile)
    if not playerProfile then return end --// Profile could not be loaded
    --// Yay, profile loaded!!
end):catch(warn)
```

## Editing a player's data:

### Setting a player's coins to 100:
```lua
local newCoins = DataService:Set(player, "Coins", 100)
print(newCoins) --// It will print 100.
```

For more information regarding ProfileSync, take a look into its documentation page: 
https://docs.inkrnl.com/roblox/projects/profilesync.