--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"


ISRakeLeaves = ISBaseTimedAction:derive("ISRakeLeaves");

function ISRakeLeaves:isValid()
    return true;
end

function ISRakeLeaves:update()
   	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISRakeLeaves:start()
    self.item:setJobType(getText("ContextMenu_RakeLeaves"));
 	self.item:setJobDelta(0.0);

    self:setActionAnim("ScrubFloor_Mop");
    self:setOverrideHandModels(self.item, nil);

    self.sound = self.character:playSound("ScytheGrass");
end

function ISRakeLeaves:stop()
    self:stopSound();
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.stop(self);
end

function ISRakeLeaves:perform()
    self:stopSound();
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.perform(self);
end

function ISRakeLeaves:complete()
    local i = 0

    for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                i = i + self:getLeaves(sq);
            end
        end
    end

    local maintenanceSkill = self.character:getPerkLevel(Perks.Farming);

    if self.item:damageCheck(maintenanceSkill, 10, true, true, self.character) then
        ISWorldObjectContextMenu.checkWeapon(self.character);
    end

    local skill = self.character:getPerkLevel(Perks.Farming);
    local backStrain = 1 - (skill * 0.05);
    local armStrain = 1 - (skill * 0.05);
    self.character:addBackMuscleStrain(backStrain);
    self.character:addArmMuscleStrain(armStrain);

    local use = self.item:getWeight() * self.character:getFatigueMod() * 0.1;
    local useChargeDelta = 1.0;
    use = use * useChargeDelta * 0.041
    if self.item:isTwoHandWeapon() and self.character:getSecondaryHandItem() ~= self.item then
        use = use + self.item:getWeight() / 1.5 / 10 / 20;
    end
    self.character:getStats():remove(CharacterStat.ENDURANCE, use);

    addXp(self.character, Perks.Farming, i);

    return true
end

function ISRakeLeaves.isLeaves(object)

    local props = object:getProperties();
    local customName = "";
    if(props and props:get("CustomName")) then
        customName = props:get("CustomName");
    end

    return (object:isGrassLike() and customName:find("Leaves"));
end

function ISRakeLeaves:getLeaves(sq)
    local j = 0;
	for i=sq:getObjects():size(),1,-1 do
		local o = sq:getObjects():get(i-1)
		if self.isLeaves(o) then
			sq:transmitRemoveItemFromSquare(o)
			local items = self.character:getInventory():AddItems("MWSMod.DeadLeaves", ZombRand(4,8));
			sendAddItemsToContainer(self.character:getInventory(), items);
            j = j + 0.5;
		end
	end
    return j;
end

function ISRakeLeaves:getDuration()
    if self.character:isTimedActionInstant() then
        return 1;
    end
	local duration = 0;
    local skill = self.character:getPerkLevel(Perks.Farming);
	for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                for i=sq:getObjects():size(),1,-1 do
					local o = sq:getObjects():get(i-1);
					if o and self.isLeaves(o) then
						duration = duration + 10 - skill;
					end
				end
            end
        end
    end
    return duration;
end

function ISRakeLeaves:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound);
    end
end

function ISRakeLeaves:new (character, item, sq, radius)
    local o = ISBaseTimedAction.new(self, character)
    
    o.item = item;
    if item and not radius then
        radius = 3;
    end
    o.radius = radius;
    o.sq = sq or character:getCurrentSquare();
	o.maxTime = o:getDuration();
    return o;
end


