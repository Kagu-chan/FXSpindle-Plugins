table.minmax = function(tab)
	local min, max = 0, 0
	for i, e in ipairs(tab) do
		if e < min then min = e end
		if e > max then max = e end
	end
	return min, max
end

table.min = function(tab)
	return ({table.minmax(tab)})[1]
end

table.max = function(tab)
	return ({table.minmax(tab)})[2]
end