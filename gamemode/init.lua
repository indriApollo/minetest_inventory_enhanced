
-- Other mods should check the player's gamemode by fetching
-- gamemode.players[name]
-- This is faster than reading the save file every time since
-- the gamemode bool is already loaded in memory
-- if nil, the player has probably left the world and his entry was cleared

gamemode = {}
gamemode.players = {}

minetest.register_privilege("gamemode", {
	description = "Player can change his gamemode",
})

minetest.register_on_joinplayer(function(player)
	-- Check if player is in creative gamemode
	-- Else we create a survival entry for the player
	local name = player:get_player_name()
	local save_file = Settings(minetest.get_worldpath().."/gamemodes.txt")
	if save_file:get(name) == 1 then
		gamemode.players[name] = 1
	elseif save_file:get(name) == 0 then
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

minetest.register_chatcommand("gamemode", {
	params = "<gamemode>",
	description = "Set your game mode : survival 0 / creative 1",
	privs = {gamemode = true},
	func = function(name,param)
		if param == "" then
			return true, "Set your game mode : survival 0 / creative 1"
		elseif tonumber(param) == 0 or param == "survival" then
			gamemode.set_mode(name, 0)
		elseif tonumber(param) == 1 or param == "creative" then
			gamemode.set_mode(name, 1)
		else 
			return true, "*Valid gamemodes are 0 survival, 1 creative"
		end
		return true
	end,
})

-- shortcommand for the lazy :P
minetest.register_chatcommand("gm", {
	params = "<gamemode>",
	description = "Set your game mode : survival 0 / creative 1",
	privs = {gamemode = true},
	func = function(name,param)
		if param == "" then
			return true, "Set your game mode : survival 0 / creative 1"
		elseif tonumber(param) == 0 or param == "survival" then
			gamemode.set_mode(name, 0)
		elseif tonumber(param) == 1 or param == "creative" then
			gamemode.set_mode(name, 1)
		else 
			return true, "*Valid gamemodes are 0 survival, 1 creative"
		end
		return true
	end,
})

gamemode.set_mode = function(name, mode)
	local save_file = Settings(minetest.get_worldpath().."/gamemodes.txt")
	if mode == 0 then -- survival
		gamemode.players[name] = 0
		save_file:set(name,0)
		minetest.chat_send_player(name, "Your gamemode is now 'survival'")
	elseif mode == 1 then -- creative
		gamemode.players[name] = 1
		save_file:set(name, 1)
		minetest.chat_send_player(name, "Your gamemode is now 'creative'")
	end
	save_file:write() -- save changes
end

gamemode.load_modes = function()
	local save_file = Settings(minetest.get_worldpath().."/gamemodes.txt")
	for name,mode in pairs(save_file:to_table()) do
		gamemode.players[name] = mode
	end
end

gamemode.load_modes()
minetest.log("action","Gamemodes loaded")