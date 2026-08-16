--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISMowing = ISBaseTimedAction:derive("ISMowing");

local function listToSet(list)
    local set = {};
    for _, item in ipairs(list) do
        set[item] = true;
    end
    return set;
end

ISMowing.driedSpriteList = listToSet({
    "vegetation_farm_01_0",
    "vegetation_farm_01_1",
    "vegetation_farm_01_2",
    "vegetation_farm_01_3",
    "vegetation_farm_01_4",
    "vegetation_farm_01_5",
    "vegetation_farm_01_32",
    "vegetation_farm_01_33",
    "vegetation_farm_01_34",
    "vegetation_farm_01_35",
    "vegetation_farm_01_36",
    "vegetation_farm_01_37",
    "vegetation_farm_01_38",
    "vegetation_farm_01_39",
    "vegetation_farm_01_40",
    "vegetation_farm_01_41",
    "vegetation_farm_01_42",
    "vegetation_farm_01_43",
    "vegetation_farm_01_44",
    "vegetation_farm_01_45",
    "vegetation_farm_01_46",
    "vegetation_farm_01_47",
    "vegetation_farm_01_48",
});

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

    for x=self.sq:getX(), self.sq:getX()+self.radius-1 do
        for y=self.sq:getY(), self.sq:getY()+self.radius-1 do
            local sq = getSquare(x, y, self.sq:getZ());
            if sq then
                i = i + self:getGrass(sq);
            end
        end
    end

    local maintenanceSkill = self.character:getPerkLevel(Perks.Farming);
    if self.item:damageCheck(maintenanceSkill, 5, true, true, self.character) then
        ISWorldObjectContextMenu.checkWeapon(self.character);
    end

    local skill = self.character:getPerkLevel(Perks.Farming);
    local backStrain = 1 - (skill * 0.05);
    local armStrain = 1 - (skill * 0.05);
    if not (self.item:getType() == "HandScythe") then
        backStrain = backStrain / 2;
    end
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

function ISMowing.isCuttable(object)

    local props = object:getProperties();
    local customName = "";
    if(props and props:get("CustomName")) then
        customName = props:get("CustomName");
    end

    return (object:isGrassLike() or ISMowing.driedSpriteList[object:getSprite():getName()]) and (
        props and (
            not customName:find("Branch") and
            not customName:find("Leaves") and
            not customName:find("Log") and
            not customName:find("Stone") and
            not customName:find("Stump") and
            not customName:find("Tree") and
            not customName:find("Twigs")
        )
    );
end

function ISMowing:getGrass(sq)
    local j = 0;
	for i=sq:getObjects():size(),1,-1 do
		local o = sq:getObjects():get(i-1)
		if self.isCuttable(o) then
			sq:transmitRemoveItemFromSquare(o)
			local items = self.character:getInventory():AddItems("Base.GrassTuft", ZombRand(2,4));
			sendAddItemsToContainer(self.character:getInventory(), items);
            j = j + 1;
		end
	end
    return j;
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
					local o = sq:getObjects():get(i-1)
					if self.isCuttable(o) then
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


