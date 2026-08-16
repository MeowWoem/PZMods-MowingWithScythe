require("TimedActions/ISRemoveBush");

local old_ISRemoveBush_getBushObject = ISRemoveBush.getBushObject;

function ISRemoveBush:getBushObject(square)
    local o = old_ISRemoveBush_getBushObject(self, square);
	if(not o) then 
        for i=1,square:getObjects():size() do
            local o = square:getObjects():get(i-1)
            local props = o:getProperties();
            local customName = "";
            if(props and props:get("CustomName")) then
                customName = props:get("CustomName");
            end
            if(o:getSprite():getName():find("bushes") or customName == "Bush") then
                return o;
            end
        end
	end
	return o;
end

local old_ISRemoveBush_complete = ISRemoveBush.complete;

function ISRemoveBush:complete()

    old_ISRemoveBush_complete(self);

    local sq = self.square

	if sq and not self.wallVine then
        for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            local props = o:getProperties();
            local customName = "";
            if(props and props:get("CustomName")) then
                customName = props:get("CustomName");
            end
            if(o:getSprite() and o:getSprite():getName() and o:getSprite():getName():find("bushes") or customName == "Bush") then
                sq:transmitRemoveItemFromSquare(o)
                if ZombRand(2) == 0 then
                    sq:AddWorldInventoryItem("Base.TreeBranch2", 0, 0, 0);
                end
                if ZombRand(1) == 0 then
                    sq:AddWorldInventoryItem("Base.Twigs", 0, 0, 0);
                end
            end
        end
    end

    --[[ if (not self.weapon) and (not self.wallVine) then
        local skill = self.character:getPerkLevel(Perks.Farming)
        self.character:addBackMuscleStrain(1 - (skill * 0.05))
    end
	local sq = self.square

	if sq then
		if self.wallVine then
			local object,index = self:getWallVineObject(sq)
			if object and index then
				object:RemoveAttachedAnim(index)
				object:transmitUpdatedSpriteToClients()
				sq:removeErosionObject("WallVines")
			end
			-- and the top one, if any
			local topSq = getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ() + 1)
			local object,index = self:getWallVineObject(topSq)
			if object and index then
				object:RemoveAttachedAnim(index)
				object:transmitUpdatedSpriteToClients()
				topSq:removeErosionObject("WallVines")
			end
		else
			for i=0,sq:getObjects():size()-1 do
				local object = sq:getObjects():get(i);
				if object:getProperties():has(IsoFlagType.canBeCut) then
					sq:transmitRemoveItemFromSquare(object)
					if ZombRand(2) == 0 then
						sq:AddWorldInventoryItem("Base.TreeBranch2", 0, 0, 0);
					end
					if ZombRand(1) == 0 then
						sq:AddWorldInventoryItem("Base.Twigs", 0, 0, 0);
					end
					i = i - 1; -- FIXME: illegal in Lua
				end
			end
		end
	end ]]

	return true;
end