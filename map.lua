Map = {}

Map.w = 100
Map.h = 100

Map.sw = 40
Map.sh = 30

function Map:new(fill,screen) 
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new.default = fill
	
	if(screen) then
		for x=0,self.sw do
			new[x] = {}
			for y=0,self.sh do
				new[x][y] = fill
			end
		end
	else
		for x=0,self.w do
			new[x] = {}
			for y=0,self.h do
				new[x][y] = fill
			end
		end
	end

	return new
end