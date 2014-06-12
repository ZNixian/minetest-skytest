minetest.register_node("skytest:auto_activator", {
	description = "Auto Activator",
	tiles = {"skytest_autoplacer.png", "skytest_autoplacer.png", "skytest_autoplacer.png", "skytest_autoplacer.png", "skytest_autoplacer_front.png", "skytest_autoplacer.png"},
	groups = {snappy = 2, oddly_breakable_by_hand = 3},
	buildtest = {
		pipe_groups = {
			type = "transp",
		},
		power = {
		},
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",	"invsize[8,9;]"..
									"list[context;main;0,0;8,4;]"..
									"list[current_player;main;0,5;8,4;]")
		local inv = meta:get_inventory()
		inv:set_size("main", 4*8)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
})
	
minetest.register_craft({
	output = "skytest:auto_activator",
	recipe = {
		{	"default:steel_ingot",	"default:stone",				"default:steel_ingot",		},
		{	"default:stone",		"mesecons:wire_00000000_off",	"default:stone",			},
		{	"default:steel_ingot",	"default:stone",				"default:steel_ingot",		},
	}
})
if buildtest~=nil then
buildtest.pumps.pumpible["skytest:auto_activator"] = {
	power = function(pos, speed)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local node = minetest.get_node(pos)
		for i=1, speed do
			for i=1, inv:get_size("main") do
				if not inv:get_stack("main", i):is_empty() then
					local stack = inv:get_stack("main", i)
					local dir = minetest.facedir_to_dir(node.param2)
					local def = minetest.registered_items[stack:get_name()]
					-----------------------------------------
					local pos_under, pos_above = vector.add(pos, dir), vector.add(pos, vector.add(dir, dir))
					
					local placer = {
						get_player_name = function() return "deployer" end,
						getpos = function() return pos end,
						get_player_control = function() return {jump=false,right=false,left=false,
									LMB=false,RMB=false,sneak=false,aux1=false,down=false,up=false} end,
						get_wield_index = function()
							return i % 8
						end,
						get_inventory = function()
							return inv
						end,
						get_look_dir = function()
							return dir
						end,
						get_look_yaw = function()
							return math.pi/2
						end
					}
					-----------------------------------------
					local orgstack = stack:to_string()
					if def==nil then return end
					if def.on_place~=nil then
						stack = def.on_place(stack, placer, {type="node", under=pos_under, above=pos_above})
						stack = stack or inv:get_stack("main", i)
						if type(stack)=="table" or type(stack)=="string" then stack = ItemStack(stack) end
					end
					if def.on_use~=nil and orgstack == stack:to_string() then
						stack = def.on_use(stack, placer, {type="node", under=pos_under, above=pos_above})
						stack = stack or inv:get_stack("main", i)
						if type(stack)=="table" or type(stack)=="string" then stack = ItemStack(stack) end
					end
					-- if orgstack == stack:to_string() then
						-- local newpos = vector.add(dir, pos)
						-- local newstack = stack:to_table()
						-- newstack.count = 1
						-- minetest.add_item(newpos, newstack)
						-- stack:take_item()
					-- end
					inv:set_stack("main", i, stack)
					return
				end
			end
		end
	end,
}
end
