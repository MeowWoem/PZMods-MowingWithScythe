--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "MWSGrassGrowingShared"

MWSGrassGrowingClient = MWSGrassGrowingClient or {}

function MWSGrassGrowingClient.OnServerCommand(module, command, args)
    if module ~= MWSGrassGrowing.MODULE_NAME then return end

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