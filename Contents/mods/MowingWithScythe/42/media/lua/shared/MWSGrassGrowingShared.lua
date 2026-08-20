--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

MWSGrassGrowing = MWSGrassGrowing or {}

MWSGrassGrowing.MODULE_NAME = "MWSGrassGrowing"

MWSGrassGrowing.GRASS_FLOOR_SPRITE = "blends_natural_01_16"
MWSGrassGrowing.SEEDED_OVERLAY_SPRITE = "blends_natural_01_87"

MWSGrassGrowing.ZONE_TYPE = "GrassRegrowth"
MWSGrassGrowing.ZONE_RADIUS = 20

function MWSGrassGrowing.canPlantSeeds(square)
    if not square then return false end
    if not square:isOutside() then return false end

    local floor = square:getFloor()
    if not floor then return false end

    local props = floor:getSprite():getProperties()

    if props:has("grassFloor") then return false end

    local spriteName = floor:getSprite():getName()
    -- (64/69/70/71 + floors_exterior_natural_16-19)
    if spriteName ~= "blends_natural_01_64" then return false end

    return true
end

function MWSGrassGrowing.getGrassRegrowthZone(square)
    local zones = getWorld():getMetaGrid():getZonesAt(square:getX(), square:getY(), square:getZ())

    for i = 0, zones:size() - 1 do
        local zone = zones:get(i)
        if zone:getType() == MWSGrassGrowing.ZONE_TYPE then
            return zone
        end
    end

    return nil
end

function MWSGrassGrowing.registerRegrowthZone(square)
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local metaGrid = getWorld():getMetaGrid()

    local zone = MWSGrassGrowing.getGrassRegrowthZone(square)
    local timestamp = math.floor(getGameTime():getCalender():getTimeInMillis() / 1000)

    if not zone then
        zone = metaGrid:registerZone(
            "", MWSGrassGrowing.ZONE_TYPE,
            x - MWSGrassGrowing.ZONE_RADIUS,
            y - MWSGrassGrowing.ZONE_RADIUS,
            z,
            MWSGrassGrowing.ZONE_RADIUS * 2,
            MWSGrassGrowing.ZONE_RADIUS * 2
        )
    end

    zone:setLastActionTimestamp(timestamp)
    return zone
end

function MWSGrassGrowing.plantSeedsOnSquare(square)
    if not MWSGrassGrowing.canPlantSeeds(square) then
        return false
    end

    local floor = square:getFloor()

    local grassSprite = getSprite(MWSGrassGrowing.GRASS_FLOOR_SPRITE)
    if not grassSprite then
        print("[MWSGrassGrowing] ERROR : sprite not found -> " .. tostring(MWSGrassGrowing.GRASS_FLOOR_SPRITE))
        return false
    end
    floor:setSprite(grassSprite)

    floor:addAttachedAnimSpriteByName(MWSGrassGrowing.SEEDED_OVERLAY_SPRITE)

    if isServer() then
        floor:transmitUpdatedSpriteToClients()
    end

    square:RecalcProperties()
    square:RecalcAllWithNeighbours(true)

    MWSGrassGrowing.registerRegrowthZone(square)

    return true
end

function MWSGrassGrowing.requestPlantSeeds(square, player)
    if not MWSGrassGrowing.canPlantSeeds(square) then
        return false
    end

    local args = {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
    }

    if isMultiplayer() and isClient() then
        sendServerCommand(MWSGrassGrowing.MODULE_NAME, "requestPlantSeeds", args)
    else
        MWSGrassGrowing.plantSeedsOnSquare(square)
    end

    return true
end