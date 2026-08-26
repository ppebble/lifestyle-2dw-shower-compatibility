const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const modRoot = root;
const modInfo = fs.readFileSync(path.join(modRoot, "common", "mod.info"), "utf8");
const lua = fs.readFileSync(
  path.join(modRoot, "common", "media", "lua", "client", "Lifestyle2DWShowerCompatibility.lua"),
  "utf8",
);

assert.match(modInfo, /^id=Lifestyle2DWShowerCompatibility$/m);
assert.match(modInfo, /^require=LifestyleHobbies,4123567854998$/m);

assert.match(lua, /require "WardrobeChange"/);
assert.match(lua, /\["tdw:stylehead"\] = true/);
assert.match(lua, /\["tdw:stylekemono"\] = true/);
assert.match(lua, /\["tdw:styleskin"\] = true/);
assert.doesNotMatch(lua, /\["tdw:style(?:vest|acca|accb|accc|body)"\] = true/);
assert.match(lua, /location == TDWRegistries\.Styletail/);
assert.match(lua, /string\.sub\(fullType, 1, 9\) == "Base\.2dw_"/);
assert.match(lua, /originalClothesAboutToChange\(player, object, optiontype\)/);
assert.match(lua, /optiontype ~= START_SHOWER_CHANGE/);
assert.match(lua, /table\.remove\(showerClothes, index\)/);
assert.match(lua, /player:setWornItem\(item:getBodyLocation\(\), item\)/);
assert.match(lua, /local LSUseShower = require "TimedActions\/LSUseShower"/);
assert.match(lua, /local LSUseTub = require "TimedActions\/LSUseTub"/);
assert.match(lua, /local function hasUnprotectedWornClothing\(player\)/);
assert.match(lua, /player:isEquippedClothing\(item\)/);
assert.match(lua, /and not isProtectedItem\(item\)/);
assert.match(lua, /local function ensureOrdinaryClothesRemoved\(player, object\)/);
assert.match(lua, /ClothesAboutToChange\(player, object, START_SHOWER_CHANGE\)/);
assert.match(lua, /function LSUseShower:start\(\)/);
assert.match(lua, /function LSUseTub:start\(\)/);
assert.equal((lua.match(/self\.wearClothes = true/g) || []).length, 2);
assert.match(lua, /local function cleanProtectedItem\(item, player\)/);
assert.match(lua, /item:getBloodLevel\(\)/);
assert.match(lua, /item:getDirtiness\(\)/);
assert.match(lua, /BloodClothingType\.getCoveredParts\(bloodClothingType\)/);
assert.match(lua, /item:setBlood\(part, 0\)/);
assert.match(lua, /item:setDirt\(part, 0\)/);
assert.match(lua, /item:setBloodLevel\(0\)/);
assert.match(lua, /item:setDirtiness\(0\)/);
assert.match(lua, /syncItemFields\(player, item\)/);
assert.match(lua, /function LSUseShower:complete\(\)/);
assert.match(lua, /function LSUseTub:complete\(\)/);
assert.equal((lua.match(/cleanProtectedWornItems\(self\.character\)/g) || []).length, 2);

const originalCall = lua.indexOf("originalClothesAboutToChange(player, object, optiontype)");
const protectionPass = lua.indexOf("for index = #showerClothes, 1, -1 do");
assert.ok(originalCall >= 0 && protectionPass > originalCall, "Lifestyle must run before protected items are restored");

const originalShowerComplete = lua.indexOf("local completed = originalShowerComplete(self)");
const showerClean = lua.indexOf("cleanProtectedWornItems(self.character)", originalShowerComplete);
assert.ok(
  originalShowerComplete >= 0 && showerClean > originalShowerComplete,
  "Lifestyle shower completion must run before protected items are cleaned",
);

const originalTubComplete = lua.indexOf("local completed = originalTubComplete(self)");
const tubClean = lua.indexOf("cleanProtectedWornItems(self.character)", originalTubComplete);
assert.ok(
  originalTubComplete >= 0 && tubClean > originalTubComplete,
  "Lifestyle tub completion must run before protected items are cleaned",
);

console.log("Lifestyle + 2D Wardrobe shower compatibility contract passed.");
