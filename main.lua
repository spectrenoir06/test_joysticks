function love.load()
	gr=love.graphics
	kb=love.keyboard
	mo=love.mouse
	js=love.joystick

	-- love.joystick.loadGamepadMappings("gamecontrollerdb.map")

	gamepadText = {}

	local tab = love.filesystem.getDirectoryItems("media/")

	for k, v in ipairs(tab) do
		v = v:gsub(".png$","")
		v = v:gsub("360_","")
		gamepadText[v] = gr.newImage("media/360_"..v..".png")
	end

	gamepadKey = {
		"a",
		"b",
		"x",
		"y",
		"back",
		"guide",
		"start",
		"leftstick",
		"rightstick",
		"leftshoulder",
		"rightshoulder",
		"dpup",
		"dpdown",
		"dpleft",
		"dpright"
	}

	gamepadAxis = {
		"leftx",
		"lefty",
		"rightx",
		"righty",
		"triggerleft",
		"triggerright"
	}


	hatDir = {
		"c",
		"d",
		"l",
		"ld",
		"lu",
		"r",
		"rd",
		"ru",
		"u"
	}

	hatDirRev = {
		d = 4,
		l = 8,
		r = 2,
		u = 1
	}


	win={w=gr.getWidth(),h=gr.getHeight()}-- Window.
	--mo.setVisible(false)
	main_font = gr.newFont(math.floor(15))
	min_font = gr.newFont(math.floor(12))
	gr.setFont(main_font)

	current_joy = nil

	gr.setLineStyle("rough")
	gr.setBackgroundColor(0,31,31)

	joysticks = {}
end

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function keymapExtract(line)
	local t = split(line, ",")
	local guid = t[1]
	local name = t[2]
	-- for k, v in ipairs(t) do print(k,v) end
	local data = {}
	for i=3, #t-1 do
		local key, value = string.match(t[i], '(.*):(.*)')
		-- print(i, key, value)
		data[key] = value
	end
	return guid, name, data
end


function keymapToTab(sguid)
	local str = love.joystick.saveGamepadMappings()

	if sguid then
		for line in (str..'\n'):gmatch('(.-)\r?\n') do
			local guid, name, data = keymapExtract(line)
			-- print(sguid, guid, line)
			if sguid == guid then
				return guid, name, data
			end
		end
		return nil
	else
		local ret = {}
		for line in (str..'\n'):gmatch('(.-)\r?\n') do
			local guid, name, data = keymapExtract(line)
			table.insert(ret, {guid = guid, name = name, data = data})
		end
		return ret
	end
end

function keymapClear(guid, name)
	love.joystick.loadGamepadMappings(guid..","..name..",")
end

function keymapSetKey(guid, name, key, type, value, hatdir)
	local guid, name, data = keymapToTab(guid or current_joy:getGUID())
	if not guid then
		guid = current_joy:getGUID()
		name = current_joy:getName()
		print("keymapSetKey",guid,name,key,type,value)
	end

	data = data or {}

	print("keymapSetKey",guid,name,key,type,value)

	-- print(data[key])

	if key == "triggerleft" then key = "lefttrigger" end
	if key == "triggerright" then key = "righttrigger" end

	if type == "button" then
		data[key] = "b"..value
	elseif type == "hat" then
		data[key] = "h"..value.."."..hatdir
	elseif type == 'axis' then
		data[key] = "a"..value
	else
		data[key] = nil
	end

	print(data[key])
	print(tabToKeymap(guid, name, data))

	love.joystick.loadGamepadMappings(tabToKeymap(guid, name, data))
end

function tabToKeymap(guid, name, data)
	str = guid..","..name..","
	for k, v in pairs(data) do
		str = str..k..":"..v..","
	end
	return str
end

function isButton(key)
	for k,v in ipairs(gamepadKey) do
		if v == key then
			return true
		end
	end
	return false
end

function love.joystickadded(joy)
	joysticks[joy] = joy
	if not current_joy then current_joy = joy end
end

function love.joystickremoved(joy)
	joysticks[joy] = nil
	if current_joy == joy then
		current_joy = nil
		for k,v in pairs(joysticks) do
			current_joy = v
		end
	end
end


function love.update(dt)
	if modif then
		modif_time = modif_time + dt
		if modif_time > 5 then
			modif_time = 0
			modif = false
		end
	end
end


function love.draw()
	gr.setColor(255,255,255)
	gr.setLineWidth(1)

	drawJoyList(10, 10)

	if current_joy then
		drawInfo(10,130)
		drawAxis(10, 130 + 60)
		drawButton(10, 380 + 60)
		drawHat(10, 530 + 60)

		drawGamepad(500 + 20, 10)
		drawGamepadInput(520, 400)
	end

	if modif then
		drawPopup(0,0)
	end
end

function drawPopup()
	gr.setColor(0,0,0,230)
	gr.rectangle("fill",0,0,win.w,win.h)
	gr.setColor(255,255,255,255)
	local x = win.w / 2 - 600/2
	local y = win.h / 2 - 150/2
	gr.setColor(200,200,200)
	gr.rectangle("fill", x, y, 600, 150)

	gr.setColor(0,0,0,255)
	gr.rectangle("line", x, y, 600, 150)
	gr.setColor(50,50,50)
	if modif_type == "button" then
		love.graphics.print("Press the button          of your gamepad.", x + 20, y + 20)
		gr.setColor(255,255,255)
		drawIcone(x + 142, y + 4, modif)
	elseif modif_type == "axis" then
		love.graphics.print("Press the axis          of your gamepad.", x + 20, y + 20)
		gr.setColor(255,255,255)
		drawIcone(x + 125, y + 4, modif)
	end
	gr.setColor(50,50,50)
	love.graphics.print(modif_type, x + 20, y + 40)
	love.graphics.print("for cancel press ESC or wait "..math.ceil(5 - modif_time).." seconds", x + 20, y + 60)
end

function drawIcone(x,y, name)
	if gamepadText[name] then
		if name == 'guide' then
			love.graphics.draw(gamepadText[name], x, y, nil, 0.78, 0.78)
		else
			love.graphics.draw(gamepadText[name], x, y, nil , 0.5, 0.5)
		end
	end
end

function drawGamepad(x,y)

	gr.setColor(255,255,255)
	gr.rectangle("line", x, y, 750, 390)

	x = x - 20
	y = y - 20

	gr.draw(gamepadText.Gamepad, x, y)

	if current_joy:isGamepadDown("a") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.a, x + 440, y + 147, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("b") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.b, x + 484, y + 103, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("y") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.y, x + 440, y + 59, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("x") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.x, x + 396, y + 103, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("leftstick") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	local axis_x = current_joy:getGamepadAxis("leftx")
	local axis_y = current_joy:getGamepadAxis("lefty")

	gr.draw(gamepadText.leftstick, x + 81 + axis_x * 12, y + 77 + axis_y * 12)

	if current_joy:isGamepadDown("rightstick") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	local axis_x = current_joy:getGamepadAxis("rightx")
	local axis_y = current_joy:getGamepadAxis("righty")
	gr.draw(gamepadText.rightstick, x + 330 + axis_x * 12, y + 179 + axis_y * 12)

	gr.setColor(255,255,255)
	gr.draw(gamepadText.Dpad, x + 164, y + 177)
	love.graphics.setBlendMode("lighten","premultiplied")
	if current_joy:isGamepadDown("dpdown") then gr.draw(gamepadText.dpdown, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpup") then gr.draw(gamepadText.dpup, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpleft") then gr.draw(gamepadText.dpleft, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpright") then gr.draw(gamepadText.dpright, x + 164, y + 177) end
	love.graphics.setBlendMode("alpha")

	if current_joy:isGamepadDown("back") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.back, x + 213, y + 111, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("start") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.start, x + 337, y + 111, 0, 0.5, 0.5)


	if current_joy:isGamepadDown("guide") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.guide, x + 270, y + 101)

	if current_joy:isGamepadDown("leftshoulder") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.leftshoulder, x + 545 + 22, y - 5)

	if current_joy:isGamepadDown("rightshoulder") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.rightshoulder, x + 645 + 22, y - 5)

	gr.setColor(255,255,255)

	local axis_l = current_joy:getGamepadAxis("triggerleft")
	local axis_r = current_joy:getGamepadAxis("triggerright")

	gr.setColor(255 - math.abs(axis_l*200), 255 - math.abs(axis_l*200), 255 - math.abs(axis_l*200))
	gr.draw(gamepadText.triggerleft, x + 22 + 550, y + 70)

	gr.setColor(axis_l * 255, 255 - math.abs(axis_l*255), -(axis_l * 255))
	gr.rectangle("fill", x + 22 + 600, y + 170 - 75 * axis_l + 75, 30, 75 * axis_l)

	gr.setColor(255,255,255)
	gr.rectangle("line", x + 22 + 600, y + 170, 30, 75)

	local val = math.floor(axis_l * 100).."%"
	gr.print(val, x + 22 + 635 - main_font:getWidth(val), y + 250)

	gr.setColor(255 - math.abs(axis_r*200), 255 - math.abs(axis_r*200), 255 - math.abs(axis_r*200))
	gr.draw(gamepadText.triggerright, x + 22 + 650, y + 70)

	gr.setColor(axis_r * 255, 255 - math.abs(axis_r*255), -(axis_r * 255))
	gr.rectangle("fill", x + 22 + 670, y + 170 - 75 * axis_r + 75, 30, 75 * axis_r)

	gr.setColor(255,255,255)
	gr.rectangle("line", x + 22 + 670, y + 170, 30, 75)

	local val = math.floor(axis_r * 100).."%"
	gr.print(val, x + 22 + 700 - main_font:getWidth(val), y + 250)

	if current_joy:isVibrationSupported() then
		gr.setColor(230,230,230)
		gr.rectangle("fill", x + 600, y + 270, 145, 50)
		gr.setColor(0,0,0)
		gr.rectangle("line", x + 600, y + 270, 145, 50)
		love.graphics.print( "Test Vibration 1", x + 610, y + 270 + 15)

		gr.setColor(230,230,230)
		gr.rectangle("fill", x + 600, y + 270 + 60, 145, 50)
		gr.setColor(0,0,0)
		gr.rectangle("line", x + 600, y + 270 + 60, 145, 50)
		love.graphics.print( "Test Vibration 2", x + 610, y + 270 + 60 + 15)
	end
end

function drawGamepadInput(x,y)

	gr.rectangle("line", x, y, 582, 302)

	drawnSingleInput(x+1, y+1, gamepadText.a, "a", 0.5)
	drawnSingleInput(x+1, y + 1 + 50, gamepadText.b, "b", 0.5)
	drawnSingleInput(x+1, y + 1 + 100, gamepadText.x, "x", 0.5)
	drawnSingleInput(x+1, y + 1 + 150, gamepadText.y, "y", 0.5)
	drawnSingleInput(x+1, y + 1 + 200, gamepadText.start, "start", 0.5)
	drawnSingleInput(x+1, y + 1 + 250, gamepadText.back, "back", 0.5)

	drawnSingleInput(x+ 1 + 145, y + 1, gamepadText.guide, "guide", 0.78)
	drawnSingleInput(x+ 1 + 145, y + 1 + 50, gamepadText.leftstick, "leftstick", 0.5)
	drawnSingleInput(x+ 1 + 145, y + 1 + 100, gamepadText.rightstick, "rightstick", 0.5)

	drawnSingleInput(x+ 1 + 145, y + 1 + 150, gamepadText.leftshoulder, "leftshoulder", 0.5)
	drawnSingleInput(x+ 1 + 145, y + 1 + 200, gamepadText.rightshoulder, "rightshoulder", 0.5)


	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 0, gamepadText.leftx, "leftx", 0.5)
	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 50, gamepadText.lefty, "lefty", 0.5)

	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 100, gamepadText.rightx, "rightx", 0.5)
	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 150, gamepadText.righty, "righty", 0.5)

	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 200, gamepadText.triggerleft, "triggerleft", 0.5, 0.5, true)
	drawnSingleInput(x+ 1 + 145 * 2, y + 1 + 250, gamepadText.triggerright, "triggerright", 0.5, 0.5, true)

	drawnSingleInput(x+ 1 + 145 * 3, y + 1 + 50 * 0, gamepadText.dpup, "dpup", 0.5)
	drawnSingleInput(x+ 1 + 145 * 3, y + 1 + 50 * 1, gamepadText.dpdown, "dpdown", 0.5)
	drawnSingleInput(x+ 1 + 145 * 3, y + 1 + 50 * 2, gamepadText.dpleft, "dpleft", 0.5)
	drawnSingleInput(x+ 1 + 145 * 3, y + 1 + 50 * 3, gamepadText.dpright, "dpright", 0.5)
end

function drawnSingleInput(x, y, img, input, rx, ry, color)
	gr.setColor(200,200,200)
	gr.rectangle("fill", x, y, 145, 50)

	gr.setColor(0,0,0)
	gr.rectangle("line", x, y, 145, 50)

	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping(input)
	gr.setColor(50,50,50)
	if inputtype == "button" then
		gr.print(inputindex and ("Button_"..inputindex-1), x + 55, y + 16)
		if current_joy:isDown(inputindex) then
			gr.setColor(100,100,100)
		else
			gr.setColor(255,255,255)
		end
	elseif inputtype == "axis" then
		local axis_val = current_joy:getGamepadAxis(input)
		gr.setColor(50,50,50)
		gr.print(inputindex and ("Axis_"..inputindex-1), x + 55, y + 16)

		if input == 'triggerleft' or input == 'triggerright' then
			gr.setColor(axis_val * 255, 255 - math.abs(axis_val*255), -(axis_val * 255))
			gr.rectangle("fill", x + 120, y + 5 - (axis_val * 40) + 40, 20, 40 * axis_val)
		else
			gr.setColor(axis_val * 255, 255 - math.abs(axis_val*255), -(axis_val * 255))
			gr.rectangle("fill", x + 120, y + 5 - axis_val * 20 + 20, 20, 20 * axis_val)
		end


		gr.setColor(255,255,255)
		gr.rectangle("line", x + 120, y + 5, 20, 40)
		if color then
			gr.setColor(255 - math.abs(axis_val*200), 255 - math.abs(axis_val*200), 255 - math.abs(axis_val*200))
		else
			gr.setColor(255,255,255)
		end
	elseif inputtype == "hat" then
		gr.setColor(50,50,50)
		gr.print(inputindex and ("Hat_"..(inputindex-1).."_"..hatdirection), x + 55, y + 16)
		if current_joy:getHat(inputindex) == hatdirection then
			gr.setColor(100,100,100)
		else
			gr.setColor(255,255,255)
		end
	else
		gr.setColor(50,50,50)
		gr.print("None", x + 55, y + 16)
		gr.setColor(255,255,255)
	end
	gr.draw(img, x, y, 0, rx, ry)
end

function drawAxis(x, y)

	gr.rectangle("line",x,y, 500, 250)

	local axis_count=current_joy:getAxisCount()
	if axis_count == 0 then
		gr.print("Axis: No axes", x, y)
	else
		gr.print("Axis: "..axis_count, x, y)

		for i=1, axis_count do

			local px = x + math.floor((i-1)/10) * 100 + 15
			local py = i * 20 + y - math.floor((i-1)/10) * 200 + 10

			gr.setColor(255,255,255)
			gr.print((i-1)..":", px - main_font:getWidth(""..(i-1)..":"), py)

			gr.setColor((current_joy:getAxis(i)*255), 255 - math.abs(current_joy:getAxis(i)*255), -(current_joy:getAxis(i)*255))
			gr.rectangle("fill", px + 35, py, (current_joy:getAxis(i)*25), 18)

			gr.setColor(255,255,255)
			local val = math.floor(current_joy:getAxis(i) * 100).."%"
			love.graphics.setFont(min_font)
			gr.print(val, px + 59 - min_font:getWidth(val), py + 1)
			love.graphics.setFont(main_font)
			gr.rectangle("line", px + 10, py, 50, 18)
		end
	end
end

function drawButton(x, y)
	gr.setLineWidth(1)

	gr.rectangle("line",x,y, 284, 150)

	local button_count = current_joy:getButtonCount()

	if button_count == 0 then
		gr.print("Button: No button", x, y)
	else
		gr.print("Button: "..button_count, x, y)
	end

	for i=1,button_count do
		local isDown = current_joy:isDown(i)

		local px = x + (i-1) * 28 - math.floor((i-1)/10) * 280 + 14
		local py = y + math.floor((i-1)/10) * 28 + 12 + 25

		if isDown then
			gr.setColor(255,0,0)
		else
			gr.setColor(100,100,100)
		end
		gr.circle("fill", px, py + 4, 12)

		gr.setColor(255,255,255)

		gr.circle("line", px, py + 4, 12)
		gr.print(i-1, px - main_font:getWidth(""..i-1)/2, py - 5)
	end
end

function drawHat(x, y)
	gr.setLineWidth(1)
	gr.rectangle("line",x,y, 500, 120)


	local hat_count = current_joy:getHatCount()

	if hat_count == 0 then
		gr.print("Hat: No Hat", x, y)
	else
		gr.print("Hat: "..hat_count, x, y)
	end

	for i=1, hat_count do
		local d = current_joy:getHat(i)

		local px = x + (i-1) * 50 - math.floor((i-1)/10) * 50 * 10
		local py = y + math.floor((i-1)/10) * 50 + 20

		gr.draw(gamepadText.Dpad, px, py, 0, 0.5)
		gr.setBlendMode("lighten","premultiplied")
		if d=="d" or d=="ld" or d=="rd" then gr.draw(gamepadText.dpdown, px, py, 0, 0.5) end
		if d=="u" or d=="lu" or d=="ru" then gr.draw(gamepadText.dpup, px, py, 0, 0.5) end
		if d=="l" or d=="ld" or d=="lu" then gr.draw(gamepadText.dpleft, px, py, 0, 0.5) end
		if d=="r" or d=="rd" or d=="ru" then gr.draw(gamepadText.dpright, px, py, 0, 0.5) end
		gr.setBlendMode("alpha")
		local lx, ly = gamepadText.Dpad:getWidth()/2, gamepadText.Dpad:getHeight()/2
		gr.print(i-1, px + lx/2 - main_font:getWidth(""..i-1)/2, py + ly/2 - main_font:getHeight(""..i-1)/2)

	end
end

function drawInfo(x, y)
	gr.rectangle("line",x,y, 500, 60)
	gr.print("Name: "..current_joy:getName(), x, y)
	gr.print("GUID: "..current_joy:getGUID(), x, y + 20)
	gr.print("Vibration Supported: "..(current_joy:isVibrationSupported() and "Yes" or "False"), x, y + 40)
end

function drawJoyList(x, y)
	gr.rectangle("line", x, y, 500, 120)

	local i = 0
	for k, v in pairs(joysticks) do
		if (v == current_joy) then
			gr.setColor(255,255,255)
			gr.print(">", x + 5, y + (15 * i) + 25)
		else

		end
		gr.print(v:getName(), x + 15 + 10, y + (15 * i) + 25)
		-- gr.print(v:getGUID(), x + 350, y + (15 * i) + 25)
		i = i + 1
	end

	if i > 0 then
		gr.print("Gamepad: "..i, x, y)
	else
		gr.print("Gamepad: None", x, y)
	end
end

function love.keypressed(key)
	if key=="escape" then
		if modif then
			modif = false
		else
			print(love.joystick.saveGamepadMappings())
			love.event.quit()
		end
	end
	if key == "up" then
		local tab = {}
		local id = 0
		local i = 1
		for k,v in pairs(joysticks) do
			table.insert(tab, v)
			if v == current_joy then id = i end
			i = i + 1
		end
		if tab[id - 1] then current_joy = tab[id - 1] end
	end
	if key == "down" then
		local tab = {}
		local id = 0
		local i = 1
		for k,v in pairs(joysticks) do
			table.insert(tab, v)
			if v == current_joy then id = i end
			i = i + 1
		end
		if tab[id + 1] then current_joy = tab[id + 1] end
	end

	-- if key == "r" then
	-- 	modif = 'a'
	-- 	modif_type = 'button'
	-- 	-- love.joystick.loadGamepadMappings("test")
	-- 	local guid, name, tab = keymapToTab(current_joy:getGUID())
	-- 	-- keymapSetKey(guid, name, "leftx", "button", 1, nil)
	-- 	-- keymapSetKey(guid, name, "dpup", "hat", 0, 1)
	-- 	-- keymapSetKey(guid, name, "leftx", "axis", 0, nil)
	-- 	save = saveAxis(current_joy)
	--
	-- 	print(love.joystick.saveGamepadMappings())
	-- end

	if key == "r" then
		current_joy:setVibration( 0, 1, 1)
	end

	if key == "t" then
		current_joy:setVibration( 1, 0, 1 )
	end

	if key == 'i' then
		print(love.joystick.saveGamepadMappings())
	end

end


function saveAxis(joy)
	t = {}
	for i=1, joy:getAxisCount() do
		t[i] = joy:getAxis(i)
	end
	return t
end

function findModifAxis(joy, save)
	local abs = math.abs
	for i=1, joy:getAxisCount() do
		-- print(abs(save[i] - joy:getAxis(i)))
		if abs(save[i] - joy:getAxis(i)) > 0.30 then
			return i
		end
	end
	return nil
end

function love.joystickpressed( joystick, button )
	if modif and joystick == current_joy then
		local guid, name, tab = keymapToTab(current_joy:getGUID())
		keymapSetKey(guid, name, modif, "button", button-1, nil)
		modif = false
	end
end

function love.joystickaxis( joystick, axis, value )
	if modif and modif_type == 'axis' and joystick == current_joy then
		local guid, name, tab = keymapToTab(current_joy:getGUID())
		local a = findModifAxis(current_joy, save)
		if a then
			keymapSetKey(guid, name, modif, "axis", a-1, nil)
			modif = false
		end
	end
end

function love.joystickhat( joystick, hat, direction )
	if modif and joystick == current_joy then
		local guid, name, tab = keymapToTab(current_joy:getGUID())
		keymapSetKey(guid, name, modif, "hat", hat-1, hatDirRev[direction])
		modif = false
	end
end

function love.mousepressed(x, y, button, isTouch)

	local px, py = 520, 400

	print(x,y)

	if not modif then
		mouseSingleInput(x, y, px+1, py + 1, "a")
		mouseSingleInput(x, y, px+1, py + 1 + 50, "b")
		mouseSingleInput(x, y, px+1, py + 1 + 100, "x")
		mouseSingleInput(x, y, px+1, py + 1 + 150, "y")
		mouseSingleInput(x, y, px+1, py + 1 + 200, "start")
		mouseSingleInput(x, y, px+1, py + 1 + 250, "back")

		mouseSingleInput(x, y, px+ 1 + 145, py + 1, "guide")
		mouseSingleInput(x, y, px+ 1 + 145, py + 1 + 50, "leftstick")
		mouseSingleInput(x, y, px+ 1 + 145, py + 1 + 100, "rightstick")

		mouseSingleInput(x, y, px+ 1 + 145, py + 1 + 150, "leftshoulder")
		mouseSingleInput(x, y, px+ 1 + 145, py + 1 + 200, "rightshoulder")


		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 0, "leftx")
		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 50, "lefty")

		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 100, "rightx")
		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 150, "righty")

		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 200, "triggerleft")
		mouseSingleInput(x, y, px+ 1 + 145 * 2, py + 1 + 250, "triggerright")

		mouseSingleInput(x, y, px+ 1 + 145 * 3, py + 1 + 50 * 0, "dpup")
		mouseSingleInput(x, y, px+ 1 + 145 * 3, py + 1 + 50 * 1, "dpdown")
		mouseSingleInput(x, y, px+ 1 + 145 * 3, py + 1 + 50 * 2, "dpleft")
		mouseSingleInput(x, y, px+ 1 + 145 * 3, py + 1 + 50 * 3, "dpright")
	end

	if current_joy:isVibrationSupported() then
		if x >= (500 + 600) and x <= (500 + 600 + 145) and y >= (-10 + 270) and y <= (-10 + 270 + 50) then
			current_joy:setVibration(1,0,1)
		end
		if x >= (500 + 600) and x <= (500 + 600 + 145) and y >= (-10 + 270 + 60) and y <= (-10 + 270 + 60 + 50) then
			current_joy:setVibration(0,1,1)
		end
	end
end

function mouseSingleInput(mouseX, mouseY, x, y, key)
	if	mouseX >= x
		and mouseX <= x + 145
		and mouseY >= y
		and mouseY <= y + 50
	then
		print(key)
		modif = key
		modif_time = 0
		if isButton(key) then
			modif_type = "button"
		else
			modif_type = "axis"
			save = saveAxis(current_joy)
		end
	end
end
