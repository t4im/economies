core.register_craftitem("bank:plastic_card", {
	description = "Plastic card",
	inventory_image = "bank_plastic_card.png",
})

if economies.with_compressor and economies.with_plastic and technic then
	technic.register_compressor_recipe({
		input = {"homedecor:plastic_sheeting 6"},
		output = "bank:plastic_card"
	})
elseif economies.with_plastic then
	core.register_craft({
		type = "shapeless",
		output = "bank:plastic_card",
		recipe = {
			"homedecor:plastic_sheeting", "homedecor:plastic_sheeting", "homedecor:plastic_sheeting",
			"homedecor:plastic_sheeting", "homedecor:plastic_sheeting"
			}
	})
end

core.register_craftitem("bank:smart_card_chip", {
	description = "Smart card chip",
	inventory_image = "bank_smart_card_chip.png",
})

core.register_craftitem("bank:smart_card", {
	description = "Smart card",
	inventory_image = "bank_smart_card.png",
})

core.register_craft({
	type = "shapeless",
	output = "bank:smart_card",
	recipe = { "bank:smart_card_chip", "bank:plastic_card"}
})

core.register_craftitem("bank:debit_card", {
	description = "Debit card",
	inventory_image = "bank_credit_card.png",
	stack_max = 1,
})

core.register_craftitem("bank:credit_card", {
	description = "Credit card",
	inventory_image = "bank_credit_card.png",
	stack_max = 1,
})
