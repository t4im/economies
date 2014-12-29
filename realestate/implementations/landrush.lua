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
