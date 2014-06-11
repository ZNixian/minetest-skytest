dofile(minetest.get_modpath("skytest").."/auto activator.lua")
local itestActive = false
if minetest.get_modpath("itest")~=nil then
	itestActive = true
end
for name, data in pairs({
	wood = {
		mat = "group:wood",
		hammer = {wear = 3000},
		sieve = {wear = 1500},
	},
	stone = {
		mat = "group:stone",
		hammer = {wear = 1500},
		sieve = {wear = 750},
	},
	steel = {
		mat = "default:steel_ingot",
		hammer = {wear = 750},
		sieve = {wear = 375},
	},
	diamond = {
		mat = "default:diamond",
		hammer = {wear = 375},
		sieve = {wear = 187},
	},
	mese = {
		mat = "default:mese_crystal",
		hammer = {wear = 0},
		sieve = {wear = 0},
	},
}) do
	minetest.register_tool("skytest:"..name.."_hammer", {
		description = name.." Hammer",
		inventory_image = "skytest_hammer_"..name..".png",
		on_use = function(itemstack, user, pointed_thing)
			local pos = pointed_thing.under
			local nn = minetest.get_node(pos).name
			local n = nil
			if minetest.get_item_group(nn, "stone") ~= 0 then
				n = "default:gravel"
			elseif nn == "default:gravel" then
				n = "default:sand"
			end
			if n==nil then return end
			itemstack:add_wear(data.hammer.wear)
			minetest.set_node(pos, {name=n})
			nodeupdate(pos)
			return itemstack
		end,
	})
	
	minetest.register_craft({
		output = "skytest:"..name.."_hammer",
		recipe = {
			{data.mat,		data.mat,			data.mat	},
			{data.mat,		"default:stick",	data.mat	},
			{"",			"default:stick",	""			},
		}
	})

	minetest.register_tool("skytest:"..name.."_sieve", {
		description = name.." Sieve",
		inventory_image = "skytest_sieve_"..name..".png",
		on_use = function(itemstack, user, pointed_thing)
			local pos = pointed_thing.under
			local nn = minetest.get_node(pos).name
			local inv = user:get_inventory()
			if nn == "default:gravel" then
				local c = math.random(100)
				if c <= 15 then
					inv:add_item("main", {name="default:coal_lump"})
				elseif c <= 30 then
					if itestActive then
						inv:add_item("main", {name="itest:copper_dust"})
					end
				elseif c <= 45 then
					if itestActive then
						inv:add_item("main", {name="itest:tin_dust"})
					end
				elseif c <= 46 then
					inv:add_item("main", {name="default:diamond"})
				elseif c <= 47 then
					inv:add_item("main", {name="default:mese_crystal"})
				end
			elseif nn == "default:sand" then
				local c = math.random(100)
				if c <= 20 then
					if itestActive then
						inv:add_item("main", {name="itest:iron_dust"})
					end
				elseif c <= 30 then
					if itestActive then
						inv:add_item("main", {name="itest:gold_dust"})
					end
				end
			else
				return
			end
			itemstack:add_wear(data.sieve.wear)
			minetest.remove_node(pos)
			nodeupdate(pos)
			return itemstack
		end,
	})
	
	minetest.register_craft({
		output = "skytest:"..name.."_sieve",
		recipe = {
			{	"default:stick",		"default:stick",	"default:stick"		},
			{	data.mat,				"",					data.mat			},
			{	data.mat,				data.mat,			data.mat			},
		}
	})
end