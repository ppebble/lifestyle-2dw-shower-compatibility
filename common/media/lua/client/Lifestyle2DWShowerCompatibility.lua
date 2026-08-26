require "WardrobeChange"
local LSUseShower = require "TimedActions/LSUseShower"
local LSUseTub = require "TimedActions/LSUseTub"

local START_SHOWER_CHANGE = "isBathNoLaundryStart"

-- These are 2D Wardrobe's character face, character-feature, and skin-adapter
-- body locations. Ordinary 2D Wardrobe clothing and accessories are removed.
local protectedLocations = {
    ["tdw:stylehead"] = true,
    ["tdw:stylekemono"] = true,
    ["tdw:styleskin"] = true,
}

local function is2DWItem(item)
    if not item or not item.getFullType then
        return false
    end

    local fullType = item:getFullType()
    return type(fullType) == "string" and string.sub(fullType, 1, 9) == "Base.2dw_"
end

local function isProtectedLocation(location)
    if not location then
        return false
    end

    if TDWRegistries then
        if location == TDWRegistries.Stylehair
            or location == TDWRegistries.Styletail
            or location == TDWRegistries.Styleskin then
            return true
        end
    end

    return protectedLocations[tostring(location)] == true
end

local function isProtectedItem(item)
    return is2DWItem(item)
        and item.getBodyLocation
        and isProtectedLocation(item:getBodyLocation())
end

local function cleanProtectedItem(item, player)
    local bloodLevel = item.getBloodLevel and item:getBloodLevel() or 0
    local dirtiness = item.getDirtiness and item:getDirtiness() or 0
    if bloodLevel <= 0 and dirtiness <= 0 then
        return false
    end

    local bloodClothingType = item.getBloodClothingType and item:getBloodClothingType()
    local coveredParts = bloodClothingType and BloodClothingType.getCoveredParts(bloodClothingType)
    if coveredParts and item.setBlood and item.setDirt then
        for index = 0, coveredParts:size() - 1 do
            local part = coveredParts:get(index)
            item:setBlood(part, 0)
            item:setDirt(part, 0)
        end
    end

    if item.setBloodLevel then
        item:setBloodLevel(0)
    end
    if item.setDirtiness then
        item:setDirtiness(0)
    end
    if syncItemFields then
        syncItemFields(player, item)
    end

    return true
end

local function cleanProtectedWornItems(player)
    if not player then
        return false
    end

    local cleanedAny = false
    local items = player:getInventory():getItems()
    for index = 0, items:size() - 1 do
        local item = items:get(index)
        if player:isEquippedClothing(item)
            and isProtectedItem(item)
            and cleanProtectedItem(item, player) then
            cleanedAny = true
        end
    end

    if cleanedAny then
        player:getInventory():setDrawDirty(true)
        player:resetModelNextFrame()
        if syncVisuals then
            syncVisuals(player)
        end
        triggerEvent("OnClothingUpdated", player)
    end

    return cleanedAny
end

local function hasUnprotectedWornClothing(player)
    local items = player:getInventory():getItems()
    for index = 0, items:size() - 1 do
        local item = items:get(index)
        if player:isEquippedClothing(item)
            and not item:isHidden()
            and item:getType() ~= "NeuralHat"
            and not isProtectedItem(item) then
            return true
        end
    end

    return false
end

local originalClothesAboutToChange = ClothesAboutToChange

if originalClothesAboutToChange and not Lifestyle2DWShowerCompatibilityInstalled then
    Lifestyle2DWShowerCompatibilityInstalled = true

    function ClothesAboutToChange(player, object, optiontype)
        originalClothesAboutToChange(player, object, optiontype)

        if optiontype ~= START_SHOWER_CHANGE or not player then
            return
        end

        local playerData = player:getModData()
        local showerClothes = playerData and playerData.ShowerClothes
        if type(showerClothes) ~= "table" then
            return
        end

        local restoredAny = false
        for index = #showerClothes, 1, -1 do
            local item = showerClothes[index]
            if isProtectedItem(item) then
                table.remove(showerClothes, index)
                player:setWornItem(item:getBodyLocation(), item)
                restoredAny = true
            end
        end

        if restoredAny then
            player:getInventory():setDrawDirty(true)
            player:resetModelNextFrame()
            triggerEvent("OnClothingUpdated", player)
        end
    end
end

local function ensureOrdinaryClothesRemoved(player, object)
    local playerData = player and player:getModData()
    local showerClothes = playerData and playerData.ShowerClothes

    -- Lifestyle already completed its normal clothing-change action.
    if type(showerClothes) == "table" and #showerClothes > 0 then
        return false
    end

    -- Lifestyle's context-menu precheck can miss equipped items whose current
    -- script has no ClothingItem. Its removal function does not require that
    -- field, so use the same equipped-clothing rule here as a fallback.
    if not player or not hasUnprotectedWornClothing(player) then
        return false
    end

    ClothesAboutToChange(player, object, START_SHOWER_CHANGE)
    showerClothes = player:getModData().ShowerClothes

    if type(showerClothes) == "table" and #showerClothes > 0 then
        print("[Lifestyle2DW] Applied fallback ordinary-clothing removal")
        return true
    end

    return false
end

if LSUseShower and not Lifestyle2DWShowerStartPatched then
    Lifestyle2DWShowerStartPatched = true
    local originalShowerStart = LSUseShower.start

    function LSUseShower:start()
        if ensureOrdinaryClothesRemoved(self.character, self.showerObject) then
            self.wearClothes = true
        end
        originalShowerStart(self)
    end
end


if LSUseTub and not Lifestyle2DWTubStartPatched then
    Lifestyle2DWTubStartPatched = true
    local originalTubStart = LSUseTub.start

    function LSUseTub:start()
        if ensureOrdinaryClothesRemoved(self.character, self.mainTubObj) then
            self.wearClothes = true
        end
        originalTubStart(self)
    end
end

if LSUseShower and LSUseShower.complete and not Lifestyle2DWShowerCompletePatched then
    Lifestyle2DWShowerCompletePatched = true
    local originalShowerComplete = LSUseShower.complete

    function LSUseShower:complete()
        local completed = originalShowerComplete(self)
        if completed then
            cleanProtectedWornItems(self.character)
        end
        return completed
    end
end

if LSUseTub and LSUseTub.complete and not Lifestyle2DWTubCompletePatched then
    Lifestyle2DWTubCompletePatched = true
    local originalTubComplete = LSUseTub.complete

    function LSUseTub:complete()
        local completed = originalTubComplete(self)
        if completed then
            cleanProtectedWornItems(self.character)
        end
        return completed
    end
end
