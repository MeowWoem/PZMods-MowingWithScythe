--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction";
require "MWSGrassGrowingShared";

ISRemoveStump = ISBaseTimedAction:derive("ISRemoveStump");

ISRemoveStump.SEEDS_ITEM = "GrassSeeds";
ISRemoveStump.SEEDS_REQUIRED = 5;

function ISRemoveStump:isValid()
    for i=self.sq:getObjects():size(),1,-1 do
		local obj = self.sq:getObjects():get(i-1);
		local props = obj:getProperties();
		local customName = "";
		if(props and props:get("CustomName")) then
			customName = props:get("CustomName");
		end
		if obj:getSprite() and obj:getSprite():getName() and obj:getSprite():getName():find("stump") or customName == "Stump" then
			return true;
		end
	end
    return false;
end

function ISRemoveStump:update()
    self.character:setMetabolicTarget(Metabolics.LightDomestic);
end

function ISRemoveStump:start()
    self.item:setJobType(getText("ContextMenu_Remove_Stump"));
    self.item:setJobDelta(0.0);

    if self.sq then
        self.sound = getSoundManager():PlayWorldSound("Shoveling", self.sq, 0, 10, 1, true);
	end

    local anim = BuildingHelper.getShovelAnim(self.character:getPrimaryHandItem());
	self:setActionAnim(anim);
end

function ISRemoveStump:stop()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function ISRemoveStump:perform()
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.perform(self);
end

function ISRemoveStump:complete()

    for i=self.sq:getObjects():size(),1,-1 do
		local obj = self.sq:getObjects():get(i-1);
		local props = obj:getProperties();
		local customName = "";
		if(props and props:get("CustomName")) then
			customName = props:get("CustomName");
		end
		if obj:getSprite() and obj:getSprite():getName() and obj:getSprite():getName():find("stump") or customName == "Stump" then
            self.sq:transmitRemoveItemFromSquare(obj);
            self.sq:SpawnWorldInventoryItem("Base.UnusableWood", 0.0, 0.0, 0.0);
		end
	end
    
    local use = self.item:getWeight() * self.character:getFatigueMod() * 0.1;   
    local useChargeDelta = 1.0;
    use = use * useChargeDelta * 0.041;
    if self.item:isTwoHandWeapon() and self.character:getSecondaryHandItem() ~= self.item then
        use = use + self.item:getWeight() / 1.5 / 10 / 20;
    end
    self.character:getStats():remove(CharacterStat.ENDURANCE, use);

    -- if(SandboxVars.MowingWithScythe.XPMultiplierSowingGrass ~= 0) then
    --     addXp(self.character, Perks.Farming, 2 * SandboxVars.MowingWithScythe.XPMultiplierSowingGrass);
    -- end

    return true;
end

function ISRemoveStump:getDuration()
    if self.character:isTimedActionInstant() then
        return 1;
    end
    return 450 - (self.character:getPerkLevel(Perks.Strength) * 10);
end

function ISRemoveStump:new(character, item, sq)
    local o = ISBaseTimedAction.new(self, character);

    o.item = item;
    o.sq = sq or character:getCurrentSquare();
    o.maxTime = o:getDuration();
    return o;
end