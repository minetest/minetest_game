minetest.register_craft({
	output = 'books:paper',
	recipe = {
		{'default:papyrus', 'default:papyrus', 'default:papyrus'},
	}
})

minetest.register_craft({
	output = 'books:book',
	recipe = {
		{'books:paper'},
		{'books:paper'},
		{'books:paper'},
	}
})

minetest.register_craft({
	output = 'books:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'books:book', 'books:book', 'books:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "books:bookshelf",
	burntime = 30,
})
