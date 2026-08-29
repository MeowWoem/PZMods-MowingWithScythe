require "Items/ProceduralDistributions";

local T = {
    ITEMS = "items",
    JUNK = "junk",
    BOTH = "both",
};

local doProceduralDistributions = function(storage, item, count, t)
    t = t or T.ITEMS;
    ProceduralDistributions = ProceduralDistributions or {};
    ProceduralDistributions.list = ProceduralDistributions.list or {};
    ProceduralDistributions.list[storage] = ProceduralDistributions.list[storage] or {};

    if(t == T.ITEMS or t == T.BOTH) then
        ProceduralDistributions.list[storage].items = ProceduralDistributions.list[storage].items or {};
        table.insert(ProceduralDistributions.list[storage].items, item);
        table.insert(ProceduralDistributions.list[storage].items, count);
    end
    
    if(t == T.JUNK or t == T.BOTH) then
        ProceduralDistributions.list[storage].junk = ProceduralDistributions.list[storage].junk or {};
        ProceduralDistributions.list[storage].junk.items = ProceduralDistributions.list[storage].junk.items or {};
        table.insert(ProceduralDistributions.list[storage].junk.items, item);
        table.insert(ProceduralDistributions.list[storage].junk.items, count);
    end

end

doProceduralDistributions("CrateFarming", "Base.GrassSeedsBag", 2);
doProceduralDistributions("CrateGardening", "Base.GrassSeedsBag", 2);
doProceduralDistributions("GardenStoreMisc", "Base.GrassSeedsBag", 6);
doProceduralDistributions("GigamartFarming", "Base.GrassSeedsBag", 4);
doProceduralDistributions("Homesteading", "Base.GrassSeedsBag", 1);
doProceduralDistributions("ToolStoreFarming", "Base.GrassSeedsBag", 6);
doProceduralDistributions("UniversityDesk_Nature", "Base.GrassSeedsBag", 0.5);
doProceduralDistributions("UniversityFilingCabinet_Nature", "Base.GrassSeedsBag", 0.5);