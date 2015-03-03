
-- Other mods should check the player's gamemode by fetching
-- gamemode.players[name]
-- This is faster than reading the save file every time since
-- the gamemode bool is already loaded in memory
-- if nil, the player is probably not or no more connected

gamemode = {}
-- contains the gamemode of the player
gamemode.players = {}
-- contains the functions wich are called on gamemode change
gamemode.functions = {}

minetest.register_privilege("gamemode", {
	description = "Player can change his gamemode",
})

minetest.register_on_joinplayer(function(player)
	-- Check if player is saved in gamemodes.txt
	-- Else we create a survival entry for the new player
	local name = player:get_player_name()
	local save_file = Settings(minetest.get_worldpath().."/gamemodes.txt")
	local mode = tonumber(save_file:get(name))
	if  mode == 1 then
		gamemode.players[name] = 1
	elseif mode == 0 then
		gamemode.players[name] = 0
	else --create entry
		if minetest.setting_getbool("creative_mode") then
			gamemode.players[name] = 1
			save_file:set(name, 1)
		else
			gamemode.players[name] = 0
			save_file:set(name, 0)
		end
		save_file:write()
	end
end)

minetest.register_on_leaveplayer(function(player)
	-- we clear player's entry in table to save (little) space
	gamemode.players[player:get_player_name()] = nil
end)

local chatcommand = {
	params = "<gamemode>",
	description = "Set your game mode : survival 0 / creative 1",
	privs = {gamemode = true},
	func = function(name,param)
		if param == "" then
			return true, "Set your game mode : survival 0 / creative 1"
		elseif tonumber(param) == 0 or param == "survival" then
			if gamemode.players[name] == 0 then
				return true, "*Already in survival"
			end
			gamemode.set_mode(name, 0)
		elseif tonumber(param) == 1 or param == "creative" then
			if gamemode.players[name] == 1 then
				return true, "*Already in creative"
			end
			gamemode.set_mode(name, 1)
		else 
			return true, "*Valid gamemodes are 0 survival, 1 creative"
		end
		return true
	end,
}

minetest.register_chatcommand("gamemode", chatcommand)
-- shortcommand for the lazy :P
minetest.register_chatcommand("gm", chatcommand)

gamemode.set_mode = function(name, mode)
	local save_file = Settings(minetest.get_worldpath().."/gamemodes.txt")
	gamemode.players[name] = mode
	save_file:set(name, mode)
	save_file:write() -- save changes
	gamemode.on_change(name, mode) -- call the registered functions
	if mode == 0 then -- survival
		minetest.chat_send_player(name, "Your gamemode is now 'survival'")
		minetest.log("action","gamemode of "..name.." changed to survival")
	elseif mode == 1 then -- creative
		minetest.chat_send_player(name, "Your gamemode is now 'creative'")
		minetest.log("action","gamemode of "..name.." changed to creative")
	end
end

gamemode.register_on_change = function(func)
	table.insert(gamemode.functions, func)
end

gamemode.on_change = function(name, mode)
	-- this function is called each time the player changes his gamemode
	-- functions which are registered in gamemode.functions are now called
	for i,v in ipairs(gamemode.functions) do
		gamemode.functions[i](name, mode)
	end
end

minetest.log("action","Gamemodes loaded")