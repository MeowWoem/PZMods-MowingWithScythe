require("BuildingObjects/ISRemovePlantCursor");

local old_ISRemovePlantCursor_getRemovableObject = ISRemovePlantCursor.getRemovableObject;
function ISRemovePlantCursor:getRemovableObject(square)
    local o = old_ISRemovePlantCursor_getRemovableObject(self, square);
    if(not o) then 
        for i=1,square:getObjects():size() do
            local o = square:getObjects():get(i-1);
            if self.removeType == "bush" then
                local props = o:getProperties();
                local customName = "";
                if(props and props:get("CustomName")) then
                    customName = props:get("CustomName");
                end
                if(o:getSprite() and o:getSprite():getName() and o:getSprite():getName():find("bushes") or customName == "Bush") then
                    return o;
                end
            end
        end
	end
	return o;
end