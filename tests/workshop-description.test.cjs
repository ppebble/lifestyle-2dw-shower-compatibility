const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const workshopPath = path.join(__dirname, "..", "workshop", "workshop.txt");
const text = fs.readFileSync(workshopPath, "utf8");

assert.match(text, /^id=3789887641$/m);
assert.match(text, /^title=Lifestyle \+ 2D Wardrobe Shower Compatibility$/m);
assert.match(text, /id=3790696431/);
assert.match(text, /Take A Bath And Shower \+ 2D Wardrobe Compatibility/);
assert.ok(
  text.indexOf("Using Take A Bath And Shower?") <
    text.indexOf("Build 42 compatibility patch"),
  "TABAS guidance must remain at the top of the Workshop description",
);
assert.match(text, /id=3403870858/);
assert.match(text, /id=3497748766/);
assert.match(text, /^tags=Build 42;QoL$/m);
assert.match(text, /^visibility=public$/m);

console.log("Lifestyle Workshop description contract passed.");
