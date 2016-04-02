table.select = function(t, callback, max_items)
	local result, current_items, max_items = {}, 0, max_items or 0
	if max_items < 0 then
		error("max_items must be greater or equals to 0!", 2)
	end
	for i, e in pairs(t) do
		if callback(e, i) then 
			current_items = current_items + 1
			result[i] = e
			if current_items == max_items and max_items > 0 then goto end_for end
		end
	end
	::end_for::
	return result
end
table.select_first = function(t, callback)
	return table.select(t, callback, 1)
end