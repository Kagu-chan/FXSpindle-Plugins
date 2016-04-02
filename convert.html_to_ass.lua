function convert.html_to_ass(html)
	local result, i = html:gsub("#(%x%x)(%x%x)(%x%x)", function(r, g, b)
		return convert.rgb_to_ass(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
	end)
	return result
end