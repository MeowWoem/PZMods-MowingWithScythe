--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

local ContextMenu = {}


local function predicateScythe(item)
	if not item then return false end
	return not item:isBroken() and item:hasTag(ItemTag.SCYTHE)
end

function ContextMenu.onMowGrass(player, scythe)
	local bo = ISMowingCursor:new(player, scythe)
	getCell():setDrag(bo, bo.player)
end

function ContextMenu.addMowContextOption(player, context, worldObjects, test)
	
	local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
    if playerObj:isAsleep() then return end
    
    local scythe = playerInv:getFirstEvalRecurse(predicateScythe)
    if scythe and not playerObj:getVehicle() then
        if test == true then return true end

        local gardeningText = getText("ContextMenu_Gardening")
        local gardeningOption = nil
        local gardeningSubMenu = nil

        for _, opt in ipairs(context.options) do
            if opt.name == gardeningText then
                gardeningOption = opt
                break
            end
        end

        if gardeningOption then
            gardeningSubMenu = context:getSubMenu(gardeningOption.subOption)
        else
            gardeningOption = context:addOption(gardeningText, nil, nil)
            gardeningSubMenu = ISContextMenu:getNew(context)
            context:addSubMenu(gardeningOption, gardeningSubMenu)
        end

        local opt = gardeningSubMenu:addOption(getText("ContextMenu_MowGrass"), playerObj, ContextMenu.onMowGrass, scythe);
		opt.iconTexture = scythe:getTexture();
    end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu.addMowContextOption)

return ContextMenu