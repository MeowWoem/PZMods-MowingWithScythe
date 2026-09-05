MWSGrassGrowing = MWSGrassGrowing or {};

MWSGrassGrowing.Recipes = MWSGrassGrowing.Recipes or {};
MWSGrassGrowing.Recipes.OnCreate = MWSGrassGrowing.Recipes.OnCreate or {};

local _inspectGrassPossibleResultsUncommon = {
    {
        key = "Base.Basil",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Chives",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Cilantro",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Oregano",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Parsley",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Rosemary",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Sage",
        min = 1,
        max = 4,
    },
    {
        key = "Base.Thyme",
        min = 1,
        max = 4,
    },
};

local _inspectGrassPossibleResultsRare = {
    {
        key = "Base.Plantain",
        min = 1,
        max = 3,
    },
    {
        key = "Base.Comfrey",
        min = 1,
        max = 4,
    },
    {
        key = "Base.WildGarlic2",
        min = 1,
        max = 2,
    },
    {
        key = "Base.CommonMallow",
        min = 1,
        max = 4,
    },
    {
        key = "Base.BlackSage",
        min = 1,
        max = 4,
    },
};

local _inspectGrassPossibleResultsInsects = {
    {
        key = "Base.Cricket"
    },
    {
        key = "Base.Grasshopper"
    },
    {
        key = "Base.Cockroach"
    },
};

local _inspectGrassPossibleResultsCritters = {
    {
        key = "Base.Snail"
    },
    {
        key = "Base.Snail"
    },
    {
        key = "Base.Slug"
    },
    {
        key = "Base.Slug2"
    },
};

function MWSGrassGrowing.Recipes.OnCreate.InspectGrassTufts(craftRecipeData, character)
	if character then
        local chance = ZombRand(1,101);	
		local inv = character:getInventory();

        local items = nil;
		if chance <= 50 then			
            items = inv:AddItems("Base.GrassSeeds", 1);
		elseif chance <= 75 then		
            items = inv:AddItems("Base.GrassSeeds", ZombRand(2,5));
		elseif chance <= 90 then		
            local item = _inspectGrassPossibleResultsUncommon[ZombRand(1, #_inspectGrassPossibleResultsUncommon + 1)];
            sendAddItemsToContainer(inv, inv:AddItems("Base.GrassSeeds", 1));
            items = inv:AddItems(item.key, ZombRand(item.min, item.max));
		else
            local item = _inspectGrassPossibleResultsRare[ZombRand(1, #_inspectGrassPossibleResultsRare + 1)];
            sendAddItemsToContainer(inv, inv:AddItems("Base.GrassSeeds", 1));
            items = inv:AddItems(item.key, ZombRand(item.min, item.max));
		end

        if(items) then
            sendAddItemsToContainer(inv, items);
        end
        
        local crittersChance = ZombRand(1,101);
        if crittersChance <= 95 then			
            
		elseif crittersChance <= 97 then		
            local item = _inspectGrassPossibleResultsInsects[ZombRand(1, #_inspectGrassPossibleResultsInsects + 1)];
            sendAddItemsToContainer(inv, inv:AddItems(item.key, 1));
		elseif crittersChance <= 100 then		
            local item = _inspectGrassPossibleResultsCritters[ZombRand(1, #_inspectGrassPossibleResultsCritters + 1)];
            sendAddItemsToContainer(inv, inv:AddItems(item.key, 1));
		end
	end
    return true;
end