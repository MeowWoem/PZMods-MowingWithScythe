--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "BuildingObjects/ISBuildingObject";

ISRakeLeavesCursor = ISBuildingObject:derive("ISRakeLeavesCursor");

local ghc = getCore():getGoodHighlitedColor();
local bhc = getCore():getBadHighlitedColor();


function ISRakeLeavesCursor:create(x, y, z, north, sprite)
	local playerObj = self.character;
	local sq = getSquare(x, y, z);
	ISInventoryPaneContextMenu.equipWeapon(self.rake, true, true, playerObj:getPlayerNum());
	self:walkTo(x, y, z);
	ISTimedActionQueue.add(ISRakeLeaves:new(playerObj, self.rake, sq, self.radius));
end

function ISRakeLeavesCursor:walkTo(x, y, z)
	local playerObj = self.character;
	x,y,z = self:getTopLeftOfSquares(x, y, z);
	local squares = self:getSquares(x, y, z);
	if self.character:getJoypadBind() == -1 then
		local closestSq = self:getClosestSquare(squares);
		if playerObj:getCurrentSquare() == closestSq then
			return true;
		end
		local adjacent = AdjacentFreeTileFinder.Find(closestSq, self.character);
		if not adjacent then return false; end
		ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent));
	end
	return true
end


function ISRakeLeavesCursor:isValid(square)
	local x,y,z = self:getTopLeftOfSquares(square:getX(), square:getY(), square:getZ());
	return self:isValidArea(x, y, z);
end

function ISRakeLeavesCursor:isValidArea(x, y, z, renderMode)
	renderMode = renderMode or false;
	local squares = self:getSquares(x, y, z);
	local hasLeaves = false;
	local isCouldSee = false;
	for _,sq in ipairs(squares) do
		if sq:isCouldSee(self.character:getPlayerNum()) then
			isCouldSee = true;
		end
		for i=sq:getObjects():size(),1,-1 do
			local o = sq:getObjects():get(i-1);
			if ISRakeLeaves.isLeaves(o) then
				hasLeaves = true;
				if(renderMode) then
					o:setHighlighted(true);
					o:setHighlightColor(ghc:getR(), ghc:getG(), ghc:getB(), 1.0);
				end
			end
		end
	end
	return hasLeaves and isCouldSee;
end

function ISRakeLeavesCursor:isRunningAction()
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.character);
    return actionQueue and actionQueue.queue and actionQueue.queue[1];
end

function ISRakeLeavesCursor:getTopLeftOfSquares(x, y, z)
	if self.character:getJoypadBind() ~= -1 then
		local cx,cy = math.floor(self.character:getX()), math.floor(self.character:getY());
		if self.character:isOnFire() then
			return cx,cy,z;
		end
		local dir = self.character:getDir();
		if     dir == IsoDirections.N  then   x,y = cx,   cy-2;
		elseif dir == IsoDirections.NE then   x,y = cx+1, cy-2;
		elseif dir == IsoDirections.E  then   x,y = cx+1, cy;
		elseif dir == IsoDirections.SE then   x,y = cx+1, cy+1;
		elseif dir == IsoDirections.S  then   x,y = cx,   cy+1;
		elseif dir == IsoDirections.SW then   x,y = cx-2, cy+1;
		elseif dir == IsoDirections.W  then   x,y = cx-2, cy;
		elseif dir == IsoDirections.NW then   x,y = cx-2, cy-2;
		end
	end
	return x,y,z;
end

function ISRakeLeavesCursor:render(x, y, z, square)
	if self:isRunningAction() then return; end
	x,y,z = self:getTopLeftOfSquares(x, y, z);
	local bValid = self:isValidArea(x, y, z, true);
	if bValid then
		renderIsoRect(x + 1, y + 1, z, self.radius, ghc:getR(), ghc:getG(), ghc:getB(), 0.5, 1);
	else
		renderIsoRect(x + 1, y + 1, z, self.radius, bhc:getR(), bhc:getG(), bhc:getB(), 0.5, 1);
	end
	
	if self.character:getJoypadBind() ~= -1 then return; end
	
end

function ISRakeLeavesCursor:onJoypadPressButton(joypadIndex, joypadData, button)
	if button == Joypad.AButton or button == Joypad.BButton then
		return ISBuildingObject.onJoypadPressButton(self, joypadIndex, joypadData, button);
	end
end

function ISRakeLeavesCursor:getAPrompt()
	return getText("ContextMenu_RakeLeaves");
end

function ISRakeLeavesCursor:getYPrompt()
    return getText("ContextMenu_ChangeRadius");
end

function ISRakeLeavesCursor:getLBPrompt()
	return nil;
end

function ISRakeLeavesCursor:getRBPrompt()
	return nil;
end

function ISRakeLeavesCursor:getSquares(x, y, z)
	local squares = {};
	local square = getCell():getGridSquare(x, y, z);
	table.insert(squares, square);
	for x2=x,x+self.radius-1 do
		for y2=y,y+self.radius-1 do
			local square = getCell():getGridSquare(x2, y2, z);
			if square then
				table.insert(squares, square);
			end
		end
	end
	return squares;
end

function ISRakeLeavesCursor:getClosestSquare(squares)
	local closest = nil;
	local closestDist = 1000000;
	for _,square2 in ipairs(squares) do
		local dist = IsoUtils.DistanceTo(self.character:getX(), self.character:getY(), square2:getX() + 0.5, square2:getY() + 0.5);
		if dist < closestDist then
			closest = square2;
			closestDist = dist;
		end
	end
	return closest;
end

function ISRakeLeavesCursor:rotateKey(key)
	if getCore():isKey("Rotate building", key) then
		self.radius = self.radius - 1;
		if self.radius == 0 then
			self.radius = self.maxRadius;
		end
	end
end

function ISRakeLeavesCursor:new(character, rake)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o:init();
	o.character = character;
	o.player = character:getPlayerNum();
	o.skipBuildAction = true;
	o.noNeedHammer = true;
	o.skipWalk = true;
	o.renderFloorHelper = true;
	o.rake = rake;
	o.radius = 3;
	o.maxRadius = 3;
	return o;
end

Events.OnKeyPressed.Add(rotateKey);
