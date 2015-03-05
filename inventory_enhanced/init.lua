
-- TODO : add a recipes interface
-- TODO : add a right panel for external mods' buttons

inventory_enhanced = {}

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	on_put = function(inv, listname, index, stack, player)
	inv:set_list(listname, {})
	end
})
trash:set_size("main", 1)

--************************************

-- CREATIVE

--************************************


-- Create detached creative inventory when a new player joins
inventory_enhanced.init_creative_inventory = function(player)
	local name = player:get_player_name()
	inventory_enhanced[name] = {}
	inventory_enhanced[name].size = 0
	inventory_enhanced[name].filter = " "
	inventory_enhanced[name].n_recipe = 1
	inventory_enhanced[name].start_i = 1
	local recipes_inv = minetest.create_detached_inventory("creative_"..name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			-- nothing moves inside the recipe frame
			-- nothing moves to the creative main inv
			--move allowed from recipe to input
			if to_list == "recipe" or to_list == "main" 
				or (from_list == "recipe" and to_list ~= "recipe_input") 
				or (from_list == "recipe_input" and to_list ~="inventory_trash")
				or (from_list == "main" and to_list == "inventory_trash") then
				return 0
			else
				inv:set_list('recipe_input', {})
				return count
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			-- player can only put entire stack in trash to delete it
			if listname == "inventory_trash" then
				return inv:get_stack(listname, index):get_count()
			else 
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			-- player can only take stack from creative main inv
			if listname == "main" and creative_enhanced.player_gamemode_is_creative(player:get_player_name()) then
				return 1
			else 
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			-- if stack moved to recipe input, update the recipe frame
			-- restore the stack from where he was moved
			if to_list == "recipe_input" then
				local to_stack = inv:get_stack("recipe_input", 1)
				local from_stack = inv:get_stack(from_list, from_index)
				inventory_enhanced.set_recipes_inventory(player, to_stack)
				inv:set_stack(from_list, from_index, to_stack)
			-- if stack moved to trash, empty it
			elseif to_list == "inventory_trash" then
				inventory_enhanced.set_recipes_inventory(player, nil)
				inv:set_list(to_list, {})
			end
		end,
		on_put = function(inv, listname, index, stack, player)
			-- if stack is put in the trash, empty it
			if listname == "creative_trash" then
				inv:set_list(listname, {})
			end
		end,
		on_take = function(inv, listname, index, stack, player)
			-- stack can be taken from creative main inv
			if listname == "main" then
				inv:set_stack(listname, index, stack)
			end
		end,
	})
	recipes_inv:set_size("recipe", 9)
	recipes_inv:set_size("recipe_input", 1)
	recipes_inv:set_size("inventory_trash", 1)

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
			default.get_hotbar_bg(5,3.5)..
			"button[11.5,0.2;1.5,0.5;recipes;recipes]"
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
	inv:set_list("main", filtered_list)
	inventory_enhanced[name]["size"] = #filtered_list
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
		default.get_hotbar_bg(0,3.5)..
		"button[6.5,0.2;1.5,0.5;recipes;recipes]"
	)
end

--************************************

-- RECIPES

--************************************

inventory_enhanced.set_recipes_formspec = function(player, start_i, pagenum)
	local name = player:get_player_name()
	local filter = inventory_enhanced[name].filter
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((inventory_enhanced[name]["size"]-1) / (6*4) + 1)
	inventory_enhanced[name].recipes_formspec = "size[9,7.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[detached:creative_"..name..";recipe;6,0;3,3;]"..
		"list[detached:creative_"..name..";recipe_input;4,1;1,1;]"..
		"image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"image[6.1,4.1;0.8,0.8;trash.png]"..
		"button[4,2;1,1;alternative;alt]"..
		"list[detached:creative_"..name..";inventory_trash;6,4;1,1;]"..
		"list[detached:creative_"..name..";main;0.05,1;4,6;"..tostring(start_i).."]"..
		"label[1.7,7.1;"..tostring(pagenum).."/"..tostring(pagemax).."]"..
		"button[0,7;1.6,1;search_previous;<<]"..
		"button[2.5,7;1.6,1;search_next;>>]"..
		"button[2.55,0.2;0.8,0.5;search;?]"..
		"button[3.3,0.2;0.8,0.5;clear;X]"..
		"field[0.3,0.3;2.6,1;filter;;"..filter.."]"
end

inventory_enhanced.set_recipes_inventory = function(player, stack)
	local name = player:get_player_name()
	local inv = minetest.get_inventory({type="detached", name="creative_"..name})
	local n = inventory_enhanced[name].n_recipe
	local recipe_list = {}
	if stack then
		local recipes = minetest.get_all_craft_recipes(stack:get_name())
		print(dump(recipes))
		if recipes and recipes[n] then
			for i,v in ipairs(recipes[n].items) do
				recipe_list[i] = v or ""
			end
		else 
			inventory_enhanced[name].n_recipe = 1
		end
	end

	inv:set_list("recipe", recipe_list)
end


--************************************

-- register

--************************************

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	inventory_enhanced.init_creative_inventory(player)
	inventory_enhanced.set_recipes_formspec(player, 0, 1)
	-- Select the formspec according to player's gamemode
	if creative_enhanced.player_gamemode_is_creative(name) then
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
			inventory_enhanced.set_creative_formspec(player, 0, 1)
		elseif mode == 0 then
			inventory_enhanced.set_survival_formspec(player)
		end
	end)
end

-- Handle inventory formspec
minetest.register_on_player_receive_fields(function(player, formname, fields)
	print(dump(fields))
	if fields.quit return true end
	local name = player:get_player_name()
	if fields.filter == "" then
		fields.filter = " "
	end

	local find_i = function()
		local start_i = inventory_enhanced[name].start_i

		if fields.search_previous then
			start_i = start_i - 4*6
		end
		if fields.search_next then
			start_i = start_i + 4*6
		end

		if start_i < 0 then
			start_i = start_i + 4*6
		end
		if start_i >= inventory_enhanced[name]["size"] then
			start_i = start_i - 4*6
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
		inventory_enhanced.set_recipes_formspec(player, start_i, pagenum)
	end
	if fields.clear then
		inventory_enhanced[name].start_i = 0
		update_filter(name, " ")
		update_formspec(player, 0, 1) -- reset to page 1
	elseif fields.search then
		inventory_enhanced[name].start_i = 0
		update_filter(name, fields.filter)
		update_formspec(player, 0, 1) -- reset to page 1
	elseif fields.search_previous or fields.search_next then
		local start_i = find_i()
		update_formspec(player, start_i, start_i / (6*4) + 1)
	elseif fields.alternative then
		inventory_enhanced[name].n_recipe = inventory_enhanced[name].n_recipe + 1
	end
	-- formspecs and inventory are now updated
	-- proceed to show recipes if requested
	if fields.recipes or formname == "inventory_enhanced:recipes" then
		minetest.show_formspec(name, "inventory_enhanced:recipes", inventory_enhanced[name].recipes_formspec)
	end
	return true
end)

minetest.log("action","inventory_enhanced loaded")
