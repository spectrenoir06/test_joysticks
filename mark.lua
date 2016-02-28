mark={}
mark.__index=mark
-- x,y=coordenates, type="ok" or "bad":
function mark:new(x,y,type)
	local args={...}
	local t={}
	t.x=x
	t.y=y
	t.type=type
	t.rad=5
	return setmetatable(t,mark)
end
function mark:draw(gr)
	if self.type=="ok" then
		gr.setColor(0,200,0)
		gr.circle("fill",self.x,self.y,self.rad)
	elseif self.type=="bad"

	end
end
