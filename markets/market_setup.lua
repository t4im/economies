markets = markets or {}
markets.setup = markets.setup or {}

function markets.setup.metadata(meta)
	meta:get_inventory():set_size("item_type", 1)
end

markets.setup.item = smartfs.create("markets:setup_item", function(state)
	local param = state.param or {}
	assert(param.pos, "setup form called without supplied node position")

	local form = {
		padding = 0.5,
		width = 8,
		height = 4.5 + 4,
	}
	local field = {}
	field.padding = 0.3
	field.height = 0.7
	field.width = form.width - 2

	state:size(form.width, form.height)
	state:label(0, 0, "title", "Setup")
	state:button(form.width - 0.7, 0, 0.7, 0.7, "close", "X", true)

	state:field(field.padding, 1.3, field.width, field.height, "name", "Name")
	state:field(field.padding, 2.3, field.width, field.height, "description", "Description")

	state:inventory(0, 3, 1, 1, "item_type"):usePosition(param.pos)
	state:field(1.5 * field.padding + 1, 3.5, (field.width - 1 - field.padding)/2, field.height, "unit", "Unit")
	state:field(2 * field.padding + 1 + (field.width - 1 - field.padding)/2, 3.5, (field.width - 1 - field.padding)/2, field.height, "price", "Price")

	state:button(6, form.height - 5.3, 2, field.height, "save", "Save", true)

	state:inventory(0, form.height - 4, 8, 4, "main")
end)
