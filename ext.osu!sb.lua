local Spindle = _G.Spindle or {}
local type, error, pairs, ipairs, unpack, setmetatable = _G.type, _G.error, _G.pairs, _G.ipairs, _G.unpack, _G.setmetatable
local outFile, pTime
local events, obj = 0, 0
local eventChain = {}

function string.split(s, sep)
	local sep, fields = sep or ":", {}
	local pattern = ("([^%s]+)"):format(sep)
	s:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

_G.objects = {}

_G.Layers = {
	bg = "Background"
}

_G.Positions = {
	c = "Centre",
	l = "CentreLeft",
	r = "CentreRight"
}

_G.SBLayers = {
	"Background and Video events",
	"Storyboard Layer 0 (Background)",
	"Storyboard Layer 1 (Fail)",
	"Storyboard Layer 2 (Pass)",
	"Storyboard Layer 3 (Foreground)",
	"Storyboard Sound Samples"
}

Spindle.oop = {
	generateClass = function(name, properties, functions, constructor, ...)
		local meta = {}
		order = {...}
		Spindle.oop.addMetaFunctions(meta, order)
		Spindle.oop.addType(meta, name)
		Spindle.oop.addProperties(meta, constructor)
		Spindle.oop.addProperties(meta, properties)
		Spindle.oop.addFunctions(meta, functions)
		Spindle.oop.createConstructor(meta, constructor, properties, order)
		_G[name] = meta
	end,
	addMetaFunctions = function(meta, order)
		meta.__index = meta
		meta.__newindex = function(object, key, value)
			if type(object[key]) == "function" and object["_" .. key] then
				object[key](object, value)
			else
				error("Not allowed to set or overwrite property definitions!", 2)
			end
		end
		meta.__metatable = function() error("Get Metatable is not allowed!", 2) end
		meta.__tostring = function(self)
			return table.tostring(self:totable())
		end
		function meta:totable()
			local result = {}
			for _k, _v in pairs(self) do
				result[_k:sub(2)] = _v
			end
			return result
		end
		function meta.fromtable(_t)
			local args = {}
			for _i, _n in ipairs(order) do
				args[_i] = _t[_n]
			end
			return meta.new(unpack(args))
		end
	end,
	addType = function(meta, name)
		function meta:type()
			return name:lower()
		end
	end,
	addProperties = function(meta, properties)
		for name, _value in pairs(properties) do
			local key = "_" .. name
			meta[name] = function(self, value)
				if value ~= nil then
					self[key] = value
				end
				return self[key]
			end
		end
	end,
	addFunctions = function(meta, functions)
		for name, func in pairs(functions) do
			meta[name] = func
		end
	end,
	createConstructor = function(meta, constructor, properties, order)
		meta.new = function(...)
			local assertArray, inp, cons = {}, {...}, {}
			for i, key in ipairs(order) do
				cons["_" .. key] = inp[i]
			end
			for key, value in pairs(properties) do
				cons["_" .. key] = (type(value) == "table" and value.type) and value.type or value
			end
			return setmetatable(cons, meta)
		end
	end,
	getPropertyTypeRelations = function(properties)
		rel = {}
		for name, value in pairs(properties) do
			rel[name] = type(value)
		end
		return rel
	end,
}

_G.rawtype = type
_G.type = function(obj)
	return obj and rawtype(obj) == "table" and obj.type and rawtype(obj.type) == "function" and obj:type() or rawtype(obj)
end

function enableSBMode(targetFile)
	print("ENABLE STORYBOARD MODE")
	pTime = os.clock()

	outFile = io.tmpfile()
	outFile:write("[Events]\n")

	local f_base = command_line_args.working_dir .. "/" .. command_line_args.filebase
	local fName = targetFile

	_G._exit = function()
		print("Translate Sprites and Events...")
		for i, e in ipairs(_G.SBLayers) do
			outFile:write("//" .. e, "\n")
			local cObjects = table.select(objects, function(co)
				return co:sbLayer() == i
			end)

			for si, sprite in pairs(cObjects) do
				local l = ("Sprite,%s,%s,\"%s%s\",%d,%d"):format(
					sprite:layer(), 
					sprite:position(), 
					sprite:fileMount(), 
					sprite:file(), 
					sprite:x(), 
					sprite:y()
				)
				outFile:write(l, "\n")

				local currentEvents = table.reset_indexes(table.select(eventChain, function(e)
					return e:hash() == sprite:randomKey()
				end))
				table.sort(currentEvents, function(a, b)
					return a:from() < b:from() or (a:from() == b:from() and a:to() < b:to())
				end)

				for ei, event in ipairs(currentEvents) do
					local el = (" %s"):format(event)
					outFile:write(el, "\n")

					events = events + 1
				end
			end
		end

		if outFile then
			local oFile = io.open(fName, "w")
			if oFile then
				outFile:seek("set")
				for line in outFile:lines() do
					oFile:write(line, "\n")
				end
				outFile:close()
				oFile:close()
				print(("Produced objects: %d\nProduced events: %d\nProcess duration (in seconds): %.3f"):format(
					obj, 
					events, 
					os.clock() - pTime
				))
			else
				error("couldn't create output file: " .. fName, 1)
			end
		end
	end

	io.write_line = function(line)
		if _G.type(line) ~= "sprite" then error("Only Storyboard-Sprites accepted", 2) end
		obj = obj + 1
		_G.objects[obj] = line
	end
end

local defaultMount = "SB/"

Spindle.oop.generateClass("Event", {}, {
	round = function(self)
		local args = self["_args"]
		table.map(args, function(e, i)
			if type(e) == "number" then e = math.round(e, 5) end
			return e
		end)
		self["_args"] = args
	end
}, {
	type = "F",
	easing = 0,
	from = 0,
	to = 0,
	args = {},
	hash = ""
}, "type", "easing", "from", "to", "args", "hash")

Event.__tostring = function(self)
	self:round()
	local d_to_r = function(d)
		return math.round((d / 180) * math.pi, 5)
	end
	local result = ("%s,%d,%d,%s,"):format(self:type(), self:easing(), self:from(), (self:from()==self:to() and "" or math.round(self:to(),0)))
	if self:type() == "F" then
		return result .. self:args().f .. "," .. self:args().t
	elseif self:type() == "S" then
		return result .. (self:args().f == self:args().t and self:args().t or ("%s,%s"):format(self:args().f, self:args().t))
	elseif self:type() == "V" then
		return result .. (self:args().fx == self:args().tx and self:args().fy == self:args().ty and ("%s,%s"):format(self:args().fx, self:args().fy) or ("%s,%s,%s,%s"):format(self:args().fx, self:args().fy, self:args().tx, self:args().ty))
	elseif self:type() == "R" then
		return result .. (self:args().f == self:args().t and d_to_r(self:args().f) or ("%s,%s"):format(d_to_r(self:args().f), d_to_r(self:args().t)))
	elseif self:type() == "M" then
		return result .. (self:args().fx == self:args().tx and self:args().fy == self:args().ty and ("%s,%s"):format(self:args().fx, self:args().fy) or ("%s,%s,%s,%s"):format(self:args().fx, self:args().fy, self:args().tx, self:args().ty))
	elseif self:type() == "MX" then
		return result .. (self:args().fx == self:args().tx and self:args().tx or ("%s,%s"):format(self:args().fx, self:args().tx))
	elseif self:type() == "MY" then
		return result .. (self:args().fy == self:args().ty and self:args().ty or ("%s,%s"):format(self:args().fy, self:args().ty))
	elseif self:type() == "C" then
		return result .. ("%s,%s,%s,%s,%s,%s"):format(self:args().fr, self:args().fg, self:args().fb, self:args().tr, self:args().tg, self:args().tb)
	end
end

function Event:create(type, easing, from, to, args, hash)
	local e = Event.new(type, easing, from, to, args, hash)
	eventChain[#eventChain + 1] = e
end

Spindle.oop.generateClass("Sprite", {
	layer = _G.Layers.bg,
	position = _G.Positions.c,
	fileMount = defaultMount,
	firstStart = 0,
	x = 320,
	y = 240,
	lastX = 320,
	lastY = 240,
	lastScale = 1,
	lastScaleX = 1,
	lastScaleY = 1,
	lastFade = 0,
	lastRotate = 0,
	lastR = 255,
	lastG = 255,
	lastB = 255,
	randomKey = "",
	sbLayer = 2,
	blur = 0,
	gray = 0
}, {
	hash = function(self)
		local l = 32
        if l < 1 then return nil end
        local s = ""
        for i = 1, l do
            n = math.random(32, 126)
            if n == 96 then n = math.random(32, 95) end
                s = s .. string.char(n)
        end
    	self:randomKey(s)
	end,
	init = function(self)
		local s = self:firstStart()
		self:fileMount(defaultMount)
		self:hash()
		if self:x() ~= 320 or self:y() ~= 240 then 
			self:lastX(self:x())
			self:lastY(self:y())
			self:move(0, s, s, self:x(), self:y()) 
		end
		if self:lastR() ~= 255 or self:lastG() ~= 255 or self:lastB() ~= 255 then self:color(0, s, s, self:lastR(), self:lastG(), self:lastB()) end
		if self:lastScale() ~= 1 then self:scale(0, s, s, self:lastScale()) elseif self:lastScaleX() ~= 1 or self:lastScaleY() ~= 1 then self:vScale(0, s, s, self:lastScaleX(), self:lastScaleY()) end
		if self:lastRotate() ~= 0 then self:rotate(0, s, s, self:lastRotate()) end
		if self:blur() == 1 then self:toBlur() end
		if self:gray() == 1 then self:toGray() end
	end,
	toBlur = function(self)
		local f = string.split(self:file(), ".")
		f[#f-1] = f[#f-1] .. "_blur"
		self:file(table.concat(f, "."))
	end,
	toGray = function(self)
		local f = string.split(self:file(), ".")
		f[#f-1] = f[#f-1] .. "_gray"
		self:file(table.concat(f, "."))
	end,
	fade = function(self, easing, from, to, target)
		Event:create("F", easing, from, to, {f = self:lastFade(), t = target}, self:randomKey())
		self:lastFade(target)
	end,
	rotate = function(self, easing, from, to, target)
		Event:create("R", easing, from, to, {f = self:lastRotate(), t = target}, self:randomKey())
		self:lastRotate(target)
	end,
	scale = function(self, easing, from, to, target)
		Event:create("S", easing, from, to, {f = self:lastScale(), t = target}, self:randomKey())
		self:lastScaleX(target)
		self:lastScaleY(target)
		self:lastScale(target)
	end,
	vScale = function(self, easing, from, to, tx, ty)
		Event:create("V", easing, from, to, {fx = self:lastScaleX(), fy = self:lastScaleY(), tx = tx, ty = ty}, self:randomKey())
		self:lastScaleX(tx)
		self:lastScaleY(ty)
	end,
	move = function(self, easing, from, to, x, y)
		if x == self:lastX() then
			Event:create("MY", easing, from, to, {fy = self:lastY(), ty = y}, self:randomKey())
		elseif y == self:lastY() then
			Event:create("MX", easing, from, to, {fx = self:lastX(), tx = x}, self:randomKey())
		else
			Event:create("M", easing, from, to, {fx = self:lastX(), fy = self:lastY(), tx = x, ty = y}, self:randomKey())
		end
		self:lastX(x)
		self:lastY(y)
	end,
	color = function(self, easing, from, to, r, g, b)
		Event:create("C", easing, from, to, {fr = self:lastR(), fg = self:lastG(), fb = self:lastB(), tr = r, tg = g, tb = b}, self:randomKey())
		self:lastR(r)
		self:lastG(g)
		self:lastB(b)
	end
}, {
	file = ""
}, "file")

function Sprite:background(file)
	local s = Sprite.new(file)
	s:fileMount("")
	io.write_line(s)
end

function Sprite:defaultMount(dir)
	defaultMount = dir
end

function notnil(e)
	return type(e) ~= "nil"
end

_G.sprites = {}
_G.spritesOrder = {}

function sprite(file, init, fade, start, x, y, scaleX, scaleY, rotate, r, g, b, blur, gray)
	local s = Sprite.new(file)
	s:hash()

	key = s:randomKey()

	if notnil(fade) then s:lastFade(fade) end
	if notnil(start) then s:firstStart(start) end
	if notnil(x) then s:x(x) end
	if notnil(y) then s:y(y) end
	if notnil(scaleX) or notnil(scaleY) then
		if scaleX == scaleY and type(scaleX) == "number" then
			s:lastScale(scaleX)
		else
			if notnil(scaleX) then s:lastScaleX(type(scaleX) == "table" and scaleX[1] or scaleX) end
			if notnil(scaleY) then s:lastScaleY(type(scaleY) == "table" and scaleY[1] or scaleY) end
		end
	end

	if notnil(rotate) then s:lastRotate(rotate) end
	if notnil(r) then s:lastR(r) end
	if notnil(g) then s:lastG(g) end
	if notnil(b) then s:lastB(b) end
	if notnil(blur) then s:blur(blur) end
	if notnil(gray) then s:gray(gray) end

	if init then s:init() end

	sprites[key] = s
	spritesOrder[#spritesOrder + 1] = key
	return last()
end

function last()
	return sprites[spritesOrder[#spritesOrder]]
end

function write()
	for i, k in ipairs(spritesOrder) do
		io.write_line(sprites[k])
	end
end

function bton(s)
	local bytes, n = {s:byte(1,-1)}, 0
	for i = 0, #s-1 do
		n = n + bytes[1+i] * 256^i
	end
	return n
end

function getFile(text)
	return bton(text) .. ".png"
end

_G.spectrum = {}

function arrToLua(arr, name, file)
	local oFile = io.open(file, "w")

	oFile:write(name, " = {\n")

	local function count(a)
		local i = 0
		for _, e in pairs(a) do i = i + 1 end
		return i
	end

	local function execute(a, tabs, last)
		if type(a) == "table" then
			oFile:write(("\t"):rep(tabs), "{\n")

			local c = count(a)
			local i = 1
			for _, e in pairs(a) do
				if type(e) == "table" then
					execute(e, tabs + 1, i == c)
				else
					execute(("%s = %s"):format(_, e), tabs + 1, i == c)
				end
				i = i + 1
			end

			oFile:write(("\t"):rep(tabs), last and "}\n" or "},\n")
		else
			oFile:write(("\t"):rep(tabs), a, last and "\n" or ",\n")
		end
	end

	local c = count(arr)
	local i = 1
	for _, e in pairs(arr) do
		if type(e) == "table" then
			execute(e, 1, i == c)
		else
			execute(("%s = %s"):format(_, e), 1, i == c)
		end
		i = i + 1
	end

	oFile:write("}")
	
	oFile:close()
end

function parseSpectrumFile(filename, overwrite, create, argPath)
	print("Start parsing spectrum file - overwrite is set to " .. (overwrite and "TRUE" or "FALSE"))

	local result
	if not overwrite then 
		result = {pcall(function()
			dofile(arg[4] .. "\\spectrum.lua")
		end)}

		if result[1] then 
			print("Loaded from cache - End parsing spectrum file")
			return
		end
	end

	local ifile = io.open(
		argPath and arg[4] .. "\\" .. filename or filename,
		"r"
	)
	local content = ifile:read("*a")
	ifile:close()

	local sLines = {}
	for p in content:gmatch("(.-)\n") do
		sLines[#sLines+1] = p:gsub("\n", "")
	end

	local i = 0
	local ii = 1

	for li, line in ipairs(sLines) do
		if line:find("Sprite") then
			i = i + 1
			ii = 1
			spectrum[i] = {}
		else
			local c = text.split(line, ",")
			if c[1] == " V" then
				local cur = {}
				cur.lStart = tonumber(c[3])
				cur.lEnd = tonumber(c[4])
				cur.x = tonumber(c[7])
				cur.y = tonumber(c[8])

				ii = ii + 1
				spectrum[i][ii] = cur
			end
		end
	end

	print("End parsing spectrum file - Start writing to file...")
	if create then arrToLua(spectrum, "spectrum", arg[4] .. "\\spectrum.lua") end
end

function createSpectrum(startTime, endTime, callback)
	local decArr = spectrum[1]
	local startI = false
	local startE = false
	
	for i, t in pairs(decArr) do		
		if not startI then
			if t.lStart >= startTime then startI = i end
		elseif not startE then
			if t.lEnd >= endTime then
				startE = i
				goto continue_specCreate
			end
		end
	end
	::continue_specCreate::

	for i, c in ipairs(spectrum) do
		local res = {callback(i, #spectrum)}
		local from, to = unpack(res)

		for n = startI, startE do
			local cs = c[n]
			if cs.lStart < from then goto continue_specInner end
			if cs.lEnd > to then goto continue_specInner end

			for _i = 3, #res do
				local current = res[_i]
				current[3]:vScale(0, cs.lStart, cs.lEnd, current[1] == true and cs.y or current[1], current[2] == true and cs.y or current[2])
			end

			::continue_specInner::
		end
	end
end