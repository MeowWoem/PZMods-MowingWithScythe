--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISMowing = ISBaseTimedAction:derive("ISMowing");

function ISMowing:isValid()
    return true;
end

function ISMowing:update()
   	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISMowing:start()
    self.item:setJobType(getText("ContextMenu_MowGrass"));
 	self.item:setJobDelta(0.0);

    self:setActionAnim("scything")
    self:setOverrideHandModels(self.item, nil)

    self.sound = self.character:playSound("ScytheGrass")
end

function ISMowing:stop()
    self:stopSound()
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.stop(self);
end

function ISMowing:perform()
    self:stopSound()
    self.item:setJobDelta(0.0);

    ISBaseTimedAction.perform(self);
end

function ISMowing:complete()
    local i = 0

    -- Get grass for every square
    for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                self:getGrass(sq);
                i = i + 1
            end
        end
    end

    -- Reduce the condition of the tool used
    if self.item:damageCheck(0, 1, false) then
        ISWorldObjectContextMenu.checkWeapon(self.character);
    end

    -- Muscle strain
    local skill = self.character:getPerkLevel(Perks.Farming);
    local backStrain = 1 - (skill * 0.05);
    local armStrain = 1 - (skill * 0.05);
    if not (self.item:getType() == "HandScythe" or self.item:hasTag()) then
        backStrain = backStrain / 2;
    end
    self.character:addBackMuscleStrain(backStrain);
    self.character:addArmMuscleStrain(armStrain);


    --Reduce endurance
    local use = self.item:getWeight() * self.character:getFatigueMod() * 0.1;
    local useChargeDelta = 1.0;
    use = use * useChargeDelta * 0.041
    if self.item:isTwoHandWeapon() and self.character:getSecondaryHandItem() ~= self.item then
        use = use + self.item:getWeight() / 1.5 / 10 / 20;
    end
    self.character:getStats():remove(CharacterStat.ENDURANCE, use);

    -- Yep... thats add some xp
    addXp(self.character, Perks.Farming, i);

    return true
end

function ISMowing:getGrass(sq)
	for i=sq:getObjects():size(),1,-1 do
		local object = sq:getObjects():get(i-1)
		if object:getProperties() and object:getProperties():has(IsoFlagType.canBeRemoved) then
			sq:transmitRemoveItemFromSquare(object)
			local items = self.character:getInventory():AddItems("Base.GrassTuft", ZombRand(2,4));
			sendAddItemsToContainer(self.character:getInventory(), items);
		end
	end
end

function ISMowing:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
	local duration = 0;
    local skill = self.character:getPerkLevel(Perks.Farming);
	for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                for i=sq:getObjects():size(),1,-1 do
					local object = sq:getObjects():get(i-1)
					if object:getProperties() and object:getProperties():has(IsoFlagType.canBeRemoved) then
						duration = duration + 20 - skill;
					end
				end
            end
        end
    end
    return duration
end

function ISMowing:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound);
    end
end

function ISMowing:new (character, item, sq, radius)
    local o = ISBaseTimedAction.new(self, character)
    
    o.item = item;
    if item and not radius then
        radius = 3
        if item:getType() == "HandScythe" or item:hasTag(ItemTag.HAND_SCYTHE) then
           radius = 1
        end
    end
    o.radius = radius;
    o.sq = sq or character:getCurrentSquare();
	o.maxTime = o:getDuration();
    return o
end


