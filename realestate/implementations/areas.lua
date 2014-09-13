local previousTransfer = economies.realestate.transfer
economies.realestate.transfer = function(pos, node, puncher)
	local name = puncher:get_player_name()
	local areaList = areas:getAreasAtPos(pos)
	
	if #areaList > 1 then
		return false
	end

	for id, _ in pairs(areaList) do
		areas.areas[id].owner = name
		areas:save()
	end

	if previousTransfer then
		return previousTransfer(pos, node, puncher)
	end
	return true
end
