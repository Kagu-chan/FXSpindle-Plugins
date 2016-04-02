table.map = function(t, callback)
	local result = {}
	for i, e in pairs(t) do
		t[i] = callback(e, i)
	end
end