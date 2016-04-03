-- Nice Joystick Tester, by tavuntu, GPL License and you know the rest.
function love.load()
	print(love.system.getOS())
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
		print(k,v)
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

	win={w=gr.getWidth(),h=gr.getHeight()}-- Window.
	--mo.setVisible(false)
	main_font = gr.newFont(math.floor(15))
	min_font = gr.newFont(math.floor(12))
	gr.setFont(main_font)
	joy_index = 1-- Index to see a joystick.
	current_joy = nil
	ass=math.floor(50)-- Axes square's size.
	asx,asy=10,100-- Coordenates for the first axis pair.
	gr.setLineStyle("rough")
	gr.setBackgroundColor(0,31,31)
	buttons={}-- All the available buttons.

	joysticks = {}
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

		drawGamepad(1280-600 + 10, 35)
		drawGamepadInput(900, 400)
	else
		gr.print("No joysticks were found :(",10,10)
		buttons={}
	end
end

function drawGamepad(x,y)
	gr.setColor(255,255,255)
	gr.draw(gamepadText.Gamepad, x, y)

	if current_joy:isGamepadDown("a") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.A, x + 440, y + 147, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("b") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.B, x + 484, y + 103, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("y") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Y, x + 440, y + 59, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("x") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.X, x + 396, y + 103, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("leftstick") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	local axis_x = current_joy:getGamepadAxis("leftx")
	local axis_y = current_joy:getGamepadAxis("lefty")

	gr.draw(gamepadText.Left_Stick, x + 81 + axis_x * 12, y + 77 + axis_y * 12)

	if current_joy:isGamepadDown("rightstick") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	local axis_x = current_joy:getGamepadAxis("rightx")
	local axis_y = current_joy:getGamepadAxis("righty")
	gr.draw(gamepadText.Right_Stick, x + 330 + axis_x * 12, y + 179 + axis_y * 12)

	gr.setColor(255,255,255)
	gr.draw(gamepadText.Dpad, x + 164, y + 177)
	love.graphics.setBlendMode("lighten","premultiplied")
	if current_joy:isGamepadDown("dpdown") then gr.draw(gamepadText.Dpad_Down, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpup") then gr.draw(gamepadText.Dpad_Up, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpleft") then gr.draw(gamepadText.Dpad_Left, x + 164, y + 177) end
	if current_joy:isGamepadDown("dpright") then gr.draw(gamepadText.Dpad_Right, x + 164, y + 177) end
	love.graphics.setBlendMode("alpha")

	if current_joy:isGamepadDown("back") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Back, x + 213, y + 111, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("start") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Start, x + 337, y + 111, 0, 0.5, 0.5)

	if current_joy:isGamepadDown("leftshoulder") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.LB, x + 78, y + -50)

	if current_joy:isGamepadDown("rightshoulder") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.RB, x + 423, y + -50)
end

function drawGamepadInput(x,y)


	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y, 150, 50)
	if current_joy:isGamepadDown("a") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.A, x + 10, y, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("a")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 16)

	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y + 50, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y + 50, 150, 50)
	if current_joy:isGamepadDown("b") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.B, x + 10, y + 50, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("b")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 50 + 16)

	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y + 100, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y + 100, 150, 50)
	if current_joy:isGamepadDown("x") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.X, x + 10, y + 100, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("x")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 100 + 16)

	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y + 150, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y + 150, 150, 50)
	if current_joy:isGamepadDown("y") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Y, x + 10, y + 150, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("y")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 150 + 16)

	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y + 200, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y + 200, 150, 50)
	if current_joy:isGamepadDown("back") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Back, x + 10, y + 200, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("back")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 200 + 16)

	gr.setColor(200,200,200)
	gr.rectangle("fill", x + 8, y + 250, 150, 50)
	gr.setColor(0,0,0)
	gr.rectangle("line", x + 8, y + 250, 150, 50)
	if current_joy:isGamepadDown("start") then
		gr.setColor(100,100,100)
	else
		gr.setColor(255,255,255)
	end
	gr.draw(gamepadText.Start, x + 10, y + 250, 0, 0.5, 0.5)
	local inputtype, inputindex, hatdirection = current_joy:getGamepadMapping("start")
	gr.setColor(50,50,50)
	gr.print(inputindex and ("Button_"..inputindex) or "None", x + 65, y + 250 + 16)
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
		if d=="d" or d=="ld" or d=="rd" then gr.draw(gamepadText.Dpad_Down, px, py, 0, 0.5) end
		if d=="u" or d=="lu" or d=="ru" then gr.draw(gamepadText.Dpad_Up, px, py, 0, 0.5) end
		if d=="l" or d=="ld" or d=="lu" then gr.draw(gamepadText.Dpad_Left, px, py, 0, 0.5) end
		if d=="r" or d=="rd" or d=="ru" then gr.draw(gamepadText.Dpad_Right, px, py, 0, 0.5) end
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
		love.event.quit()
		print(love.joystick.saveGamepadMappings())
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
end
