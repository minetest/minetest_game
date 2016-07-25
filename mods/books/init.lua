books = {}

dofile(minetest.get_modpath("books") .. "/craftitems.lua")
dofile(minetest.get_modpath("books") .. "/nodes.lua")
dofile(minetest.get_modpath("books") .. "/crafting.lua")

minetest.register_alias("paper", "books:paper")
minetest.register_alias("book", "books:book")
minetest.register_alias("bookshelf", "books:bookshelf")
minetest.register_alias("default:paper", "books:paper")
minetest.register_alias("default:default:book", "books:book")
minetest.register_alias("default:bookshelf", "books:bookshelf")
