table.reset_indexes = function(t)
	local r = {}
	for i, e in pairs(t) do
		r[#r+1] = e
	end
	return r
end