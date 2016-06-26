unused_args = false
allow_defined_top = true

read_globals = {
	"DIR_DELIM",
	"minetest", "core",
	"dump",
	"vector", "nodeupdate",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "ItemStack",
}

-- Overwrites minetest.handle_node_drops
files["mods/creative/init.lua"].globals = { "minetest" }

-- Don't report on legacy definitions of globals.
files["mods/default/legacy.lua"].global = false
