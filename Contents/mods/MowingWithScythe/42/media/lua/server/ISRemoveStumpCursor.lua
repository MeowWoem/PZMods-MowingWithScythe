--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "BuildingObjects/ISBuildingObject";
require "MWSGrassGrowingShared";

ISRemoveStumpCursor = ISBuildingObject:derive("ISRemoveStumpCursor");

local ghc = getCore():getGoodHighlitedColor();
local bhc = getCore():getBadHighlitedColor();


function ISRemoveStumpCursor:create(x, y, z, north, sprite)
	local playerObj = self.character;
	local sq = getSquare(x, y, z);
	ISInventoryPaneContextMenu.equipWeapon(self.shovel, true, true, playerObj:getPlayerNum());
	self:walkTo(x, y, z);
	ISTimedActionQueue.add(ISRemoveStump:new(playerObj, self.shovel, sq));
end

function ISRemoveStumpCursor:walkTo(x, y, z)
	local playerObj = self.character;
	local sq = getSquare(x, y, z);
    if playerObj:getCurrentSquare() == sq then
        return true;
    end
    local adjacent = AdjacentFreeTileFinder.Find(sq, self.character);
    if not adjacent then return false; end
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent));
	return true;
end


function ISRemoveStumpCursor:isValid(square)
	return self:isValidArea(square:getX(), square:getY(), square:getZ());
end

function ISRemoveStumpCursor:isValidArea(x, y, z, renderMode)
	renderMode = renderMode or false;
	local sq = getCell():getGridSquare(x, y, z);
	if not sq then return false; end

	local isValid = false;

	for i=sq:getObjects():size(),1,-1 do
		local obj = sq:getObjects():get(i-1);
		local props = obj:getProperties();
		local customName = "";
		if(props and props:get("CustomName")) then
			customName = props:get("CustomName");
		end
		if obj:getSprite() and obj:getSprite():getName() and obj:getSprite():getName():find("stump") or customName == "Stump" then
			if(renderMode) then
				obj:setHighlighted(true);
				obj:setHighlightColor(ghc:getR(), ghc:getG(), ghc:getB(), 1.0);
			end
			isValid = true;
		end
	end
	
	local isCouldSee = sq:isCouldSee(self.character:getPlayerNum());

	return isValid and isCouldSee;
end

function ISRemoveStumpCursor:isRunningAction()
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.character);
    return actionQueue and actionQueue.queue and actionQueue.queue[1];
end

function ISRemoveStumpCursor:render(x, y, z, square)
	if self:isRunningAction() then return; end

	local bValid = self:isValidArea(x, y, z, true);
	if bValid then
		renderIsoRect(x + 1, y + 1, z, 1, ghc:getR(), ghc:getG(), ghc:getB(), 0.5, 1);
	else
		renderIsoRect(x + 1, y + 1, z, 1, bhc:getR(), bhc:getG(), bhc:getB(), 0.5, 1);
	end
end

function ISRemoveStumpCursor:onJoypadPressButton(joypadIndex, joypadData, button)
	if button == Joypad.AButton or button == Joypad.BButton then
		return ISBuildingObject.onJoypadPressButton(self, joypadIndex, joypadData, button);
	end
end

function ISRemoveStumpCursor:getAPrompt()
	return getText("ContextMenu_Remove_Stump");
end

function ISRemoveStumpCursor:getYPrompt()
	return nil;
end

function ISRemoveStumpCursor:getLBPrompt()
	return nil;
end

function ISRemoveStumpCursor:getRBPrompt()
	return nil;
end

function ISRemoveStumpCursor:new(character, shovel)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o:init();
	o.character = character;
	o.shovel = shovel;
	o.player = character:getPlayerNum();
	o.skipBuildAction = true;
	o.noNeedHammer = true;
	o.renderFloorHelper = true;
	return o;
end
