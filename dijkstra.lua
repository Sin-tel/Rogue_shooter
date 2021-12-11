teamD = {}
teamF = {}

Dijkstra = {}

function Dijkstra:new() 
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new:reset()

	return new
end

function Dijkstra:reset()
	for x=0,Map.w do
        self[x]={}
        for y=0,Map.h do
            self[x][y]=math.huge
        end
    end
end


function Dijkstra:calculate(g)
    

    self:reset()

    local passes=1
    local wq={} 
    local pq={}

    if(g:passable()) then
        self[g.x][g.y]=0
        table.insert(wq, {g.x, g.y})
    end

    while true do
       --while #wq>0 do
       for k,t in ipairs(wq) do
            --local t=table.remove(wq)
            local x = t[1]
            local y = t[2]
            for _,d in pairs({{0,1},{0,-1},{1,0},{-1,0}}) do
                local xx=x+d[1]
                local yy=y+d[2]
                local newCost = self[x][y] + moveCost[xx][yy]
                if (not solid[xx][yy]) and self[xx][yy]>newCost then
                    self[xx][yy]=newCost
                    if(newCost<20) then
                        table.insert(pq,{xx,yy})
                    end
                end
            end
        end
        if #pq<1 then break end
        --passes=passes+1
        wq = {}
        --
        wq, pq = pq, wq
    end

    

end

function Dijkstra:calculateMG(goals)

    self:reset()

    local passes=1
    local wq={} 
    local pq={}

    local start = love.timer.getTime()

    for _,v in pairs(goals) do
        if(not solid[v.x][v.y] ) then
            self[v.x][v.y]=0
            table.insert(wq, {v.x, v.y})
        end 
    end
    
    while true do
       --while #wq>0 do
       for k,t in ipairs(wq) do
            --local t=table.remove(wq)
            local x = t[1]
            local y = t[2]
            for _,d in pairs({{0,1},{0,-1},{1,0},{-1,0}}) do
                local xx=x+d[1]
                local yy=y+d[2]
                local newCost = self[x][y] + moveCost[xx][yy]
                if (not solid[xx][yy]) and self[xx][yy]>newCost then
                    self[xx][yy]=newCost
                    if(newCost<20) then
                        table.insert(pq,{xx,yy})
                    end
                end
            end
        end
        if #pq<1 then break end
        wq = {}
      -- passes=passes+1
        wq, pq = pq, wq
    end
end

function Dijkstra:calculateFlee(map,dist)
    local dist = dist or 16

    self:reset()

    local passes=1
    local wq={} 
    local pq={}

    for x=0,Map.w do
        for y=0,Map.h do
            if(not solid[x][y] and map[x][y] >= dist) then
                self[x][y]=0
                if(map[x][y] == dist) then
                    table.insert(wq, {x, y})
                end
            end
        end
    end

    while true do
         --while #wq>0 do
       for k,t in ipairs(wq) do
            --local t=table.remove(wq)
            local x = t[1]
            local y = t[2]
            for _,d in pairs({{0,1},{0,-1},{1,0},{-1,0}}) do
                local xx=x+d[1]
                local yy=y+d[2]
                local newCost = self[x][y] + moveCost[xx][yy]
                if (not solid[xx][yy]) and self[xx][yy]>newCost then
                    self[xx][yy]=newCost
                    --if(newCost<20) then
                        table.insert(pq,{xx,yy})
                    --end
                end
            end
        end
        if #pq<1 then break end
        wq = {}
       -- passes=passes+1
        wq, pq = pq, wq
    end
end