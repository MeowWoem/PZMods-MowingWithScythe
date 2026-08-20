--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

local ContextMenu = {}


local function predicateScythe(item)
	if not item then return false; end
	return not item:isBroken() and item:hasTag(ItemTag.SCYTHE);
end
local function predicateRake(item)
	if not item then return false; end
	return not item:isBroken() and (item:getFullType() == "Base.Rake" or item:getFullType() == "Base.LeafRake");
end

function ContextMenu.onMowGrass(player, scythe)
	local bo = ISMowingCursor:new(player, scythe);
	getCell():setDrag(bo, bo.player);
end

function ContextMenu.onRakeLeaves(player, rake)
	local bo = ISRakeLeavesCursor:new(player, rake);
	getCell():setDrag(bo, bo.player);
end

function ContextMenu.onPlantGrassSeeds(player, seedItem)
	local bo = ISPlantGrassSeedCursor:new(player, seedItem);
	getCell():setDrag(bo, bo.player);
end

function ContextMenu.addMowContextOption(player, context, worldObjects, test)
	
	local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory();
    if playerObj:isAsleep() then return; end;
    
    local gardeningText = getText("ContextMenu_Gardening");
    local gardeningOption = nil;
    local gardeningSubMenu = nil;

    for _, opt in ipairs(context.options) do
        if opt.name == gardeningText then
            gardeningOption = opt;
            break;
        end
    end

    local gardeningMenuExist = false;

    -- TODO Create a subsub menu (lol) for Scythe and add the vanilla option and the mowing option inside
    --      Do the same with the vanilla Rake menu and additionnaly move it into the gardening menu because TIS logic is sometimes strange.
    if gardeningOption then
        gardeningSubMenu = context:getSubMenu(gardeningOption.subOption);
        gardeningMenuExist = true;
    else
        gardeningSubMenu = ISContextMenu:getNew(context);
    end
    
    local gardeningMenuShouldAdded = false;

    local removeBushText = getText("ContextMenu_RemoveBush");
    local removeBushExists = false;
    for _, opt in ipairs(gardeningSubMenu.options) do
        if(opt.name == removeBushText) then
            removeBushExists = true;
            break;
        end
    end

    if(not removeBushExists) then
        for _, obj in ipairs(worldObjects) do
            local props = obj:getProperties();
            local customName = "";
            if(props and props:get("CustomName")) then
                customName = props:get("CustomName");
            end
            
            if(obj:getSprite() and obj:getSprite():getName() and obj:getSprite():getName():find("bushes") or customName == "Bush") then
                gardeningSubMenu:addOption(removeBushText, worldObjects, ISWorldObjectContextMenu.onRemovePlant, false, false, player);
            end
        end
    end

    gardeningMenuShouldAdded = gardeningMenuShouldAdded or ContextMenu.addScytheContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test);
    gardeningMenuShouldAdded = gardeningMenuShouldAdded or ContextMenu.addRakeContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test);
    gardeningMenuShouldAdded = gardeningMenuShouldAdded or ContextMenu.addPlantGrassSeedContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test);


    if(not gardeningMenuExist and gardeningMenuShouldAdded) then
        gardeningOption = context:addOption(gardeningText, nil, nil);
        context:addSubMenu(gardeningOption, gardeningSubMenu);
    end
end

function ContextMenu.addScytheContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test)

    local scythe = playerInv:getFirstEvalRecurse(predicateScythe);

    if scythe and not playerObj:getVehicle() then

        if test == true then return false; end

        local opt = gardeningSubMenu:addOption(getText("ContextMenu_MowGrass"), playerObj, ContextMenu.onMowGrass, scythe);
		opt.iconTexture = scythe:getTexture();
        return true;
    end
    return false;
end

function ContextMenu.addRakeContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test)

    local rake = playerInv:getFirstEvalRecurse(predicateRake);

    if rake and not playerObj:getVehicle() then

        if test == true then return false; end

        local opt = gardeningSubMenu:addOption(getText("ContextMenu_RakeLeaves"), playerObj, ContextMenu.onRakeLeaves, rake);
		opt.iconTexture = rake:getTexture();
        return true;
    end
    return false;
end

function ContextMenu.addPlantGrassSeedContextOption(playerObj, playerInv, gardeningSubMenu, player, context, worldObjects, test)

	local seedCount = playerInv:getItemCountRecurse(ISPlantGrassSeed.SEEDS_ITEM);
	local seedItem = playerInv:getFirstTypeRecurse(ISPlantGrassSeed.SEEDS_ITEM);

    if seedItem and seedCount >= ISPlantGrassSeed.SEEDS_REQUIRED and not playerObj:getVehicle() then

        if test == true then return false; end

        local opt = gardeningSubMenu:addOption(getText("ContextMenu_PlantGrassSeeds"), playerObj, ContextMenu.onPlantGrassSeeds, seedItem);
		opt.iconTexture = seedItem:getTexture();
        return true;
    end
    return false;
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu.addMowContextOption);

return ContextMenu;
