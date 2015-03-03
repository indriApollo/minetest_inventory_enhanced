
-- reduce size of armor inventory from 6 to 5
minetest.register_on_joinplayer(function(player)
local armor_inv = minetest.get_inventory({type="detached", name = player:get_player_name().."_armor"})
armor_inv:set_size("armor", 5)
end)

-- disable the standard armor formspec
armor.update_inventory = function(self, player) return end
armor.formspec = nil

-- integrate into creative inventory_enhanced
inventory_enhanced.set_creative_formspec = function(player, start_i, pagenum)
	local name = player:get_player_name()
	local filter = inventory_enhanced[name]["filter"]
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((inventory_enhanced[name]["size"]-1) / (6*4) + 1)
	player:set_inventory_formspec(
			"size[14,7.5]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"list[current_player;main;6,3.5;8,1;]"..
			"list[current_player;main;6,4.75;8,3;8]"..
			"list[current_player;craft;9,0;3,3;]"..
			"list[current_player;craftpreview;13,1;1,1;]"..
			"image[12,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"list[detached:creative_"..name..";main;0.05,1;4,6;"..tostring(start_i).."]"..
			"label[1.65,7.2;"..tostring(pagenum).."/"..tostring(pagemax).."]"..
			"button[0,7;1.6,1;search_previous;<<]"..
			"button[2.5,7;1.6,1;search_next;>>]"..
			"image[6.1,2.1;0.8,0.8;trash.png]"..
			"list[detached:creative_trash;main;6,2;1,1;]"..
			"button[2.55,0.2;0.8,0.5;search;?]"..
			"button[3.3,0.2;0.8,0.5;clear;X]"..
			"field[0.3,0.3;2.6,1;filter;;"..filter.."]"..
			default.get_hotbar_bg(6,3.5)..

			-- armor formspec
			"list[detached:"..name.."_armor;armor;4.5,0;1,5;]"..
			"image[7.1,0;2,3.5;"..armor.textures[name].preview.."]"
	)
end

-- integrate into survival inventory_enhanced

minetest.log("action","3d_armor_plugin loaded")
