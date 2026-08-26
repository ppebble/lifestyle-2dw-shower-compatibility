# Lifestyle + 2D Wardrobe Shower Compatibility

Build 42 compatibility patch for:

- Lifestyle: Hobbies (`LifestyleHobbies`, Workshop `3403870858`)
- 2Dimension Wardrobe (`4123567854998`, Workshop `3497748766`)

Lifestyle temporarily removes equipped clothing before its shower and bathtub
actions. This patch lets that normal flow run, then removes only 2D Wardrobe
items in `tdw:stylehead`, `tdw:stylekemono`, and `tdw:styleskin` from
Lifestyle's restore list and immediately equips them again. The
`tdw:stylekemono` slot contains character features such as ears, tails, and
other appearance parts, rather than tails only. Other clothing is still
removed and restored by Lifestyle as usual.

The Workshop/source copies of both dependencies are left unchanged.

The patch also guards Lifestyle's per-tick invention inventory refresh until
both player inventory UI pages exist. Lifestyle currently dereferences those
pages without a nil check, which can otherwise produce a repeating
`CLSInv.lua:33` error while an inventory UI replacement is still initializing.
Once both pages are ready, Lifestyle's original refresh function runs unchanged.

## Installation and load order

Subscribe to and enable both required mods, then enable this compatibility
patch. Keep it after Lifestyle: Hobbies and 2Dimension Wardrobe in the mod
list. The dependency declaration also prevents the patch from loading without
either required mod.

## Workshop publication

Published with permission from the 2Dimension Wardrobe author. This package
contains only the compatibility patch; it does not redistribute files from
Lifestyle: Hobbies or 2Dimension Wardrobe.

The patch also handles a Lifestyle precheck mismatch: some equipped clothing
can have no current `ClothingItem`, causing Lifestyle to skip its clothing
change action entirely. At the beginning of a shower or bath, this mod invokes
Lifestyle's existing removal flow only when ordinary worn clothing is still
present, and marks the action to restore those clothes afterward.
