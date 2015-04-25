
inventory_enhanced = {}

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	on_put = function(inv, listname, index, stack, player)
	inv:set_list(listname, {})
	end
})
trash:set_size("main", 1)

if creative_inventory then --disable default creative inventory
	creative_inventory.set_creative_formspec = function(a,b,c) return end
end

--************************************

-- CREATIVE

--************************************


-- Create detached creative inventory when a new player joins
inventory_enhanced.init_creative_inventory = function(player)
	local name = player:get_player_name()
	inventory_enhanced[name] = {}
	inventory_enhanced[name].size = 0
	inventory_enhanced[name].filter = " "
	inventory_enhanced[name].start_i = 1
	local creative_inv = minetest.create_detached_inventory("creative_"..name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if creative_enhanced.player_gamemode_is_creative then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if creative_enhanced.player_gamemode_is_creative then
				return -1
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		end,
		on_put = function(inv, listname, index, stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
		end,
	})

	-- create the creative inventory for the first time with a blank filter
	inventory_enhanced.filter_creative_inventory(name, " ")
	
end

-- set the creative inventory formspec
inventory_enhanced.set_creative_formspec = function(player, start_i, pagenum)
	local name = player:get_player_name()
	local filter = inventory_enhanced[name]["filter"]
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((inventory_enhanced[name]["size"]-1) / (6*4) + 1)
	player:set_inventory_formspec(
			"size[13,7.5]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"list[current_player;main;5,3.5;8,1;]"..
			"list[current_player;main;5,4.75;8,3;8]"..
			"list[current_player;craft;8,0;3,3;]"..
			"list[current_player;craftpreview;12,1;1,1;]"..
			"image[11,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"list[detached:creative_"..name..";main;0.05,1;4,6;"..tostring(start_i).."]"..
			"label[1.7,7.1;"..tostring(pagenum).."/"..tostring(pagemax).."]"..
			"button[0,7;1.6,1;search_previous;<<]"..
			"button[2.5,7;1.6,1;search_next;>>]"..
			"image[5.1,2.1;0.8,0.8;trash.png]"..
			"list[detached:trash;main;5,2;1,1;]"..
			"button[2.55,0.2;0.8,0.5;search;?]"..
			"button[3.3,0.2;0.8,0.5;clear;X]"..
			"field[0.3,0.3;2.6,1;filter;;"..filter.."]"..
			default.get_hotbar_bg(5,3.5)
	)
end

-- update the creative inventory whith searched content
inventory_enhanced.filter_creative_inventory = function(name, filter)
	filter = string.lower(filter)
	local inv = minetest.get_inventory({type="detached", name="creative_"..name})
	local filtered_list = {}

	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_inventory_enhanced or def.groups.not_in_inventory_enhanced == 0)
				and def.description and def.description ~= ""
				and def.name ~= "air" and def.name ~= "ignore" and def.name ~= "unknown" then

			if filter == " " then -- blank filter, display everything
				table.insert(filtered_list, name)
			elseif string.find(string.lower(def.description), filter,1,true)
				or string.find(string.lower(def.name), filter,1,true) then -- filter
				table.insert(filtered_list, name)
			end
		end
	end
	table.sort(filtered_list)
	inventory_enhanced[name]["size"] = #filtered_list
	inv:set_size("main", #filtered_list)
	inv:set_list("main", filtered_list)
end


--************************************

-- SURVIVAL

--************************************


inventory_enhanced.set_survival_formspec = function(player)
	player:set_inventory_formspec(
		"size[8,7.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_player;main;0,3.5;8,1;]"..
		"list[current_player;main;0,4.75;8,3;8]"..
		"list[current_player;craft;3,0;3,3;]"..
		"list[current_player;craftpreview;7,1;1,1;]"..
		"image[6,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"image[0.1,2.1;0.8,0.8;trash.png]"..
		"list[detached:trash;main;0,2;1,1;]"..
		default.get_hotbar_bg(0,3.5)
	)
end

--************************************

-- register

--************************************

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Select the formspec according to player's gamemode
	if creative_enhanced.player_gamemode_is_creative(name) then
		inventory_enhanced.init_creative_inventory(player)
		inventory_enhanced.set_creative_formspec(player, 0, 1)
	else 
		inventory_enhanced.set_survival_formspec(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	-- Free the context when player leaves
	local name = player:get_player_name()
	if inventory_enhanced[name] then
		inventory_enhanced[name] = nil
	end
end)

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

-- Handle inventory formspec
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if fields.filter == "" then
		fields.filter = " "
	end

	local find_i = function()
		local start_i = inventory_enhanced[name].start_i

		if fields.search_previous then
			start_i = start_i - 24
		end
		if fields.search_next then
			start_i = start_i + 24
		end

		if start_i < 0 then
			start_i = start_i + 24
		end
		if start_i >= inventory_enhanced[name]["size"] then
			start_i = start_i - 24
		end
			
		if start_i < 0 or start_i >= inventory_enhanced[name]["size"] then
			start_i = 0
		end
		inventory_enhanced[name].start_i = start_i
		return start_i
	end

	-- Generate the new lists
	local update_filter = function(name, filter)
		inventory_enhanced.filter_creative_inventory(name, filter) -- update creative inventory
		inventory_enhanced[name].filter = filter-- update the context accordingly
	end

	local update_formspec = function(player, start_i, pagenum)
		if creative_enhanced.player_gamemode_is_creative(name) then
			inventory_enhanced.set_creative_formspec(player, start_i, pagenum)
		else
			inventory_enhanced.set_survival_formspec(player)
		end
	end
	if fields.clear then
		inventory_enhanced[name].start_i = 0
		update_filter(name, " ")
		update_formspec(player, 0, 1) -- reset to page 1
	elseif fields.search and fields.filter ~= inventory_enhanced[name].filter then
		inventory_enhanced[name].start_i = 0
		update_filter(name, fields.filter)
		update_formspec(player, 0, 1) -- reset to page 1
	elseif fields.search_previous or fields.search_next then
		local start_i = find_i()
		update_formspec(player, start_i, start_i / 24 + 1)
	end
end)

minetest.log("action","inventory_enhanced loaded")
