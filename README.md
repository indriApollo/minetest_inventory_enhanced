# minetest_inventory_enhanced

Note: creative_enhanced and inventory_enhanced are interdepedendent. gamemode is optional

**creative_enhanced**

This component is needed by inventory enhanced to handle creative gameplay

**inventory enhanced**

A reworked version of the default minetest inventory.
- Adds a searching field to the creative inventory
- Adds a trash
- Toggles dynamically when gamemode is used

Depends on default, creative_enhanced and (optionnaly) gamemode

**gamemode**

This component adds the ability to dynamically change your gamemode.
Commands are:

```
/gamemode 0 --> survival
/gamemode 1 --> creative

/gm -->shortcommand
```

Note : gamemode's creative keeps the damage settings from minetest.conf (not a god mode)

Gamemode also comes with an API :

```
 -- register a function which gets executed when the gamemode of a player is changed
 gamemode.register_on_change = function(func)
```
 
Example with inventory_enhanced :

```
-- register an inventory change if gamemode is enabled
if gamemode then
	gamemode.register_on_change(function(name, mode)
		local player = minetest.get_player_by_name(name)
		if mode == 1 then
			inventory_enhanced.init_creative_inventory(player)
			inventory_enhanced.set_creative_formspec(player, 0, 1)
		elseif mode == 0 then
			inventory_enhanced.set_survival_formspec(player)
		end
	end)
end
```

**Licence :**

GNU lgpl 2.1

**Credit: **
Based on the default mod 'creative' by Perttu Ahola (celeron55) <celeron55@gmail.com>
