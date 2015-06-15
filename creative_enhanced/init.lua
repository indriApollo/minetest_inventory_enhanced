
creative_enhanced = {}


-- returns true if game is creative or if player is in creative gamemode
creative_enhanced.player_gamemode_is_creative = function(name)
	-- if world is creative, return true ofc
	if minetest.setting_getbool("creative_mode") then
		return true
	-- if player's gamemode value is set in table, check it
	-- else assume he is in survival
	elseif gamemode and gamemode.players then
		if gamemode.players[name] == 1 then
			return true
		end
	end
	return false
end

if minetest.setting_getbool("creative_mode") then
	local digtime = 0.5
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x=1,y=1,z=2.5},
		range = 10,
		tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level = 3,
			groupcaps = {
				crumbly = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				cracky = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				snappy = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				choppy = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				oddly_breakable_by_hand = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
			},
			damage_groups = {fleshy = 10},
		}
	})
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		if creative_enhanced.player_gamemode_is_creative(placer:get_player_name()) then
			return true -- nothing is taken from inventory
		else 
			return false -- pass over to mods
		end
end)

minetest.log("action","creative_enhanced loaded")
