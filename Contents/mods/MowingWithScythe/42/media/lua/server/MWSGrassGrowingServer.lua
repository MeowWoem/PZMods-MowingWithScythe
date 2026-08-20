--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "MWSGrassGrowingShared"

MWSGrassGrowingServer = MWSGrassGrowingServer or {}

local NOTIFY_RADIUS = 40

function MWSGrassGrowingServer.OnClientCommand(module, command, player, args)
    if module ~= MWSGrassGrowing.MODULE_NAME then return end

    if command == "requestPlantSeeds" then
        local square = getCell():getGridSquare(args.x, args.y, args.z)

        if not square then
            sendClientCommand(player, MWSGrassGrowing.MODULE_NAME, "denyPlantSeeds", args)
            return
        end

        local dist = IsoUtils.DistanceManhatten(player:getX(), player:getY(), square:getX(), square:getY())
        if dist > 2 then
            sendClientCommand(player, MWSGrassGrowing.MODULE_NAME, "denyPlantSeeds", args)
            return
        end

        local success = MWSGrassGrowing.plantSeedsOnSquare(square)

        if success then
            MWSGrassGrowingServer.notifyNearbyPlayers(square, args)
        else
            sendClientCommand(player, MWSGrassGrowing.MODULE_NAME, "denyPlantSeeds", args)
        end
    end
end

function MWSGrassGrowingServer.notifyNearbyPlayers(square, args)
    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local p = players:get(i)
        local dist = IsoUtils.DistanceManhatten(p:getX(), p:getY(), square:getX(), square:getY())
        if dist <= NOTIFY_RADIUS then
            sendClientCommand(p, MWSGrassGrowing.MODULE_NAME, "confirmPlantSeeds", args)
        end
    end
end

Events.OnClientCommand.Add(MWSGrassGrowingServer.OnClientCommand)