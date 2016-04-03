-- Nice Joystick Tester, by tavuntu, GPL License and you know the rest.
function love.load()
	print(love.system.getOS())
	gr=love.graphics
	kb=love.keyboard
	mo=love.mouse
	js=love.joystick

	love.joystick.loadGamepadMappings("gamecontrollerdb.map")

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
	main_font=gr.newFont(math.floor(15))
	gr.setFont(main_font)
	joy_index=1-- Index to see a joystick.
	current_joy=nil
	ass=math.floor(50)-- Axes square's size.
	asx,asy=10,100-- Coordenates for the first axis pair.
	gr.setLineStyle("rough")
	gr.setBackgroundColor(0,31,31)
	buttons={}-- All the available buttons.
end
function love.update(dt)

end
function love.draw()
	gr.setColor(255,255,255)
	gr.setLineWidth(1)
	local joysticks = js.getJoysticks()
	if #joysticks>0 then
		current_joy=joysticks[joy_index]
		gr.print(joysticks[joy_index]:getName()..", GUID:"..joysticks[joy_index]:getGUID(),10,10)
		local axis_count=current_joy:getAxisCount()
		-- Show axes info:
		gr.print("Axes:",asx,asy-main_font:getHeight()*1.1)
		gr.setColor(0,255,0)
		gr.setColor(0,255,0)
		local next_distance=0
		for i=1,axis_count/2 do
			local x=asx+next_distance
			gr.rectangle("line",x,asy,ass,ass)
			next_distance=ass*1.1
		end
		gr.setColor(255,255,255)
		next_distance=0
		for i=1,axis_count,2 do
			-- Axis:
			local x_axis=math.floor(asx+next_distance+ass/2-current_joy:getAxis(i)*-1*ass/2-2)
			local y_axis=math.floor(asy+ass/2-current_joy:getAxis(i+1)*-1*ass/2-2)
			gr.setColor(0,127,0)
			-- Vertical line:
			gr.line(x_axis+2,asy+2,x_axis+2,asy+ass-3)
			-- Horizontal:
			gr.line(asx+next_distance+2,y_axis+2,asx+next_distance+ass-3,y_axis+2)
			gr.setColor(255,255,255)
			gr.rectangle("fill",x_axis,y_axis,3,3)
			next_distance=ass*1.1
		end
		if axis_count==0 then
			gr.print("No axes :(",asx,asy)
		end
		-- Show buttons info:
		gr.setLineWidth(3)
		gr.print("Buttons: ",asx,asy+ass*1.2)
		local button_count=current_joy:getButtonCount()
		next_distance=ass/2

		for i=1,button_count do
			--print(current_joy:getID())
			table.insert(buttons,false)
			gr.setColor(0,0,0)
			if current_joy:isDown(i) then
				buttons[i]=true-- Mark the button as "ok".
				gr.setColor(255,255,255)
			end
			gr.circle("line",next_distance,asy+ass*1.7,ass/4)
			if buttons[i] then gr.setColor(0,255,0) end
			gr.setColor(255,255,255)
			gr.print(i-1,next_distance-main_font:getWidth(""..i-1)/2,asy+ass*1.7-main_font:getHeight()/2)
			next_distance=next_distance+ass*.55
		end

		for k,v in ipairs(gamepadKey) do
			--print(current_joy:getID())
			table.insert(buttons,false)
			gr.setColor(0,0,0)
			if current_joy:isGamepadDown(v) then
				buttons[v]=true-- Mark the button as "ok".
				gr.setColor(255,255,255)
			end
			gr.circle("line", 25, 225 + (k-1) * 30, ass/4)
			gr.setColor(255,255,255)
			if buttons[v] then gr.setColor(0,255,0) end
			gr.print(
				v,
				25 +20,
				225 + (k-1) * 30 - 8
			)
			gr.setColor(255,255,255)
			next_distance=next_distance+ass*.55
		end

		buttons = {}

		if button_count==0 then
			gr.print("No buttons :(")
		end

		gr.setColor(255,255,255)
		next_distance=0
		for k,v in ipairs(gamepadAxis) do
			local axis = current_joy:getGamepadAxis(v)
			gr.setColor(255,255,255)
			love.graphics.print(v..": "..math.floor(axis*100),350 +  15, 250 + (k-1) * 45 + 12)
			gr.setColor(0,255,0)
			love.graphics.rectangle("fill", 350 + 150 + 100, 250 + (k-1) * 45, axis*100, 40)
			gr.setColor(0,0,0)
			love.graphics.rectangle("line", 350 + 150, 250 + (k-1) * 45, 200, 40)
			-- -- Axis:
			-- gr.setColor(0,127,0)
			-- -- Vertical line:
			-- gr.line(x_axis+2,asy+2,x_axis+2,asy+ass-3)
			-- -- Horizontal:
			-- gr.line(asx+next_distance+2,y_axis+2,asx+next_distance+ass-3,y_axis+2)
			-- gr.setColor(255,255,255)
			-- gr.rectangle("fill",x_axis,y_axis,3,3)
			next_distance=ass*1.1
		end
	else
		gr.print("No joysticks were found :(",10,10)
		buttons={}
	end
	drawGamepad(1280-600 + 10, 35)
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

function love.keypressed(key)
	if key=="escape" then
		love.event.quit()
	end
end
