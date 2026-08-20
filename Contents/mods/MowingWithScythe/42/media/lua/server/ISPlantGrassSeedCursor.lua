--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "BuildingObjects/ISBuildingObject";
require "MWSGrassGrowingShared";

ISPlantGrassSeedCursor = ISBuildingObject:derive("ISPlantGrassSeedCursor");

local ghc = getCore():getGoodHighlitedColor();
local bhc = getCore():getBadHighlitedColor();


function ISPlantGrassSeedCursor:create(x, y, z, north, sprite)
	local playerObj = self.character
	local sq = getSquare(x, y, z);
	self:walkTo(x, y, z);
	ISTimedActionQueue.add(ISPlantGrassSeed:new(playerObj, self.seedItem, sq));
end

function ISPlantGrassSeedCursor:walkTo(x, y, z)
	local playerObj = self.character
	local sq = getSquare(x, y, z);
    if playerObj:getCurrentSquare() == sq then
        return true
    end
    local adjacent = AdjacentFreeTileFinder.Find(sq, self.character)
    if not adjacent then return false end
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))
	return true
end


function ISPlantGrassSeedCursor:isValid(square)
	return self:isValidArea(square:getX(), square:getY(), square:getZ())
end

function ISPlantGrassSeedCursor:isValidArea(x, y, z, renderMode)
	renderMode = renderMode or false;
	local sq = getCell():getGridSquare(x, y, z);
	if not sq then return false end

	local canPlant = MWSGrassGrowing.canPlantSeeds(sq);

	local playerInv = self.character:getInventory();

	local seedCount = playerInv:getItemCountRecurse(ISPlantGrassSeed.SEEDS_ITEM);
	local seedItem = playerInv:getFirstTypeRecurse(ISPlantGrassSeed.SEEDS_ITEM);

	canPlant = canPlant and seedItem and seedCount >= ISPlantGrassSeed.SEEDS_REQUIRED;
	
	local isCouldSee = sq:isCouldSee(self.character:getPlayerNum());

	return canPlant and isCouldSee;
end

function ISPlantGrassSeedCursor:isRunningAction()
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.character);
    return actionQueue and actionQueue.queue and actionQueue.queue[1]
end

function ISPlantGrassSeedCursor:render(x, y, z, square)
	if self:isRunningAction() then return end

	local bValid = self:isValidArea(x, y, z, true)
	if bValid then
		renderIsoRect(x + 1, y + 1, z, 1, ghc:getR(), ghc:getG(), ghc:getB(), 0.5, 1)
	else
		renderIsoRect(x + 1, y + 1, z, 1, bhc:getR(), bhc:getG(), bhc:getB(), 0.5, 1)
	end
end

function ISPlantGrassSeedCursor:onJoypadPressButton(joypadIndex, joypadData, button)
	if button == Joypad.AButton or button == Joypad.BButton then
		return ISBuildingObject.onJoypadPressButton(self, joypadIndex, joypadData, button)
	end
end

function ISPlantGrassSeedCursor:getAPrompt()
	return getText("ContextMenu_PlantGrassSeeds")
end

function ISPlantGrassSeedCursor:getYPrompt()
	return nil
end

function ISPlantGrassSeedCursor:getLBPrompt()
	return nil
end

function ISPlantGrassSeedCursor:getRBPrompt()
	return nil
end

function ISPlantGrassSeedCursor:new(character, seedItem)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o.character = character
	o.player = character:getPlayerNum()
	o.skipBuildAction = true
	o.noNeedHammer = true
	o.renderFloorHelper = true
	o.seedItem = seedItem
	return o
end
