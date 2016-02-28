axis={}
axis.__index=axis
-- size = size in pixels of the square.
function axis:new(size,...)
	local args={...}
	local a={}
	a.size=size
	return setmetatable(a,axis)
end
function axis:draw(gr)
	gr.setLineWidth(1)
	gr.setLineStyle("rough")
	gr.setColor(255,0,0)
	gr.draw("line",)
end