function shape.curve(pct, _s, _p1, _p2, _e)
	local shap = ("m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f c"):format(_s[1], _s[2], _p1[1], _p1[2], _p2[1], _p2[2], _e[1], _e[2])
	local sp = shape.split(shap, 1)
	local tab = shape.to_table(sp)
	return math.bezier(pct, tab)
end