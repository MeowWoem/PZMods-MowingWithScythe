--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"
require "MWSGrassGrowingShared"

ISPlantGrassSeed = ISBaseTimedAction:derive("ISPlantGrassSeed");

ISPlantGrassSeed.SEEDS_ITEM = "GrassSeeds";
ISPlantGrassSeed.SEEDS_REQUIRED = 5;

function ISPlantGrassSeed:isValid()
    return MWSGrassGrowing.canPlantSeeds(self.sq);
end

function ISPlantGrassSeed:update()
    self.character:setMetabolicTarget(Metabolics.LightDomestic);
end

function ISPlantGrassSeed:start()
    self.item:setJobType(getText("ContextMenu_PlantGrassSeeds"));
    self.item:setJobDelta(0.0);
    self:setActionAnim("Loot")
    self:setOverrideHandModels(self.item, nil)
end

function ISPlantGrassSeed:stop()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function ISPlantGrassSeed:perform()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.perform(self);
end

function ISPlantGrassSeed:complete()
    if not MWSGrassGrowing.canPlantSeeds(self.sq) then
        return true;
    end

    local inv = self.character:getInventory();

    local seedCount = inv:getItemCountRecurse(ISPlantGrassSeed.SEEDS_ITEM);
    if seedCount < ISPlantGrassSeed.SEEDS_REQUIRED then
        return true;
    end

    sendRemoveItemsFromContainer(inv, inv:RemoveAll(ISPlantGrassSeed.SEEDS_ITEM, ISPlantGrassSeed.SEEDS_REQUIRED));

    MWSGrassGrowing.requestPlantSeeds(self.sq, self.character);

    if(SandboxVars.MowingWithScythe.XPMultiplierSowingGrass ~= 0) then
        addXp(self.character, Perks.Farming, 2 * SandboxVars.MowingWithScythe.XPMultiplierSowingGrass);
    end

    return true
end

function ISPlantGrassSeed:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    local skill = self.character:getPerkLevel(Perks.Farming);
    return math.max(50, 200 - skill * 10);
end

function ISPlantGrassSeed:new(character, item, sq)
    local o = ISBaseTimedAction.new(self, character)

    o.item = item;
    o.sq = sq or character:getCurrentSquare();
    o.maxTime = o:getDuration();
    return o
end