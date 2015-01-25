local previousTransfer = realestate.transfer
realestate.transfer = function(pos, node, puncher)
	local name = puncher:get_player_name()
	local chunk = landrush.get_chunk(pos)
	landrush.claims[chunk] = {owner=name, shared={}, claimtype='landclaim'}
	landrush.save_claims()
	if previousTransfer then
		return previousTransfer(pos, node, puncher)
	end
	return true
end

-- deprecate the old landrush sale block gracefully
minetest.register_node("realestate:deprecated_landrush_sale_block", {
	tiles= { "default_wood.png^[crack:1:16" },
	groups = { dig_immediate=3, not_in_creative_inventory=1 },
	drop = "default:wood 5",
})
minetest.register_alias("landrush:sale_block", "realestate:deprecated_landrush_sale_block")

