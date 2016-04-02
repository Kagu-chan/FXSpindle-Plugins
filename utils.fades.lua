utils.get_fades = function(l, facIn, facOut, maxIn, maxOut)
	return math.trim(math.trim(l.infade * facIn, 0, maxIn), 0, l.start_time), math.trim(l.outfade * facOut, 0, maxOut)
end

utils.set_fades = function(l, facIn, facOut, maxIn, maxOut)
	local infade, outfade = utils.get_fades(l, facIn, facOut, maxIn, maxOut)
	l.start_time = l.start_time - infade
	l.end_time = l.end_time + outfade
	
	return infade, outfade
end