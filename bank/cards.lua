minetest.register_craftitem("bank:plastic_card", {
	description = "Plastic card",
	inventory_image = "bank_plastic_card.png",
})

minetest.register_craftitem("bank:smart_card_chip", {
	description = "Smart card chip",
	inventory_image = "bank_smart_card_chip.png",
})

minetest.register_craftitem("bank:smart_card", {
	description = "Smart card",
	inventory_image = "bank_smart_card.png",
})

minetest.register_craft({
	type = "shapeless",
	output = 'bank:smart_card',
	recipe = {
		{'bank:smart_card_chip', 'bank:plastic_card'},
	}
})

minetest.register_craftitem("bank:debit_card", {
	description = "Debit card",
	inventory_image = "bank_credit_card.png",
	stack_max = 1,
})

minetest.register_craftitem("bank:credit_card", {
	description = "Credit card",
	inventory_image = "bank_credit_card.png",
	stack_max = 1,
})
