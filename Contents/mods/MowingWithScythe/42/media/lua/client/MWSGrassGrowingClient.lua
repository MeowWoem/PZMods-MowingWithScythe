--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "MWSGrassGrowingShared"

MWSGrassGrowingClient = MWSGrassGrowingClient or {}

local MODULE_NAME = "MWSGrassGrowing"

function MWSGrassGrowingClient.requestPlantSeeds(square, player)
    if not MWSGrassGrowing.canPlantSeeds(square) then
        return false
    end

    local args = {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
    }

    if isMultiplayer() and isClient() then
        sendServerCommand(MODULE_NAME, "requestPlantSeeds", args)
    else
        MWSGrassGrowing.plantSeedsOnSquare(square)
    end

    return true
end

function MWSGrassGrowingClient.OnServerCommand(module, command, args)
    if module ~= MODULE_NAME then return end

    if command == "confirmPlantSeeds" then
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        if square then
            MWSGrassGrowing.plantSeedsOnSquare(square)
        end

    elseif command == "denyPlantSeeds" then
        local player = getSpecificPlayer(0)
        if player then
            HaloTextHelper.addText(player, "Unable to plant here", HaloTextHelper.getColorRed())
        end
    end
end

Events.OnServerCommand.Add(MWSGrassGrowingClient.OnServerCommand)
