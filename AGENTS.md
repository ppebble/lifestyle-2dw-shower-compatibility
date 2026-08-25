# Lifestyle + 2D Wardrobe Shower Compatibility Development Guide

- This repository owns only this compatibility mod. Keep dependency Workshop/source mods unchanged.
- Runtime mod files live under `common/`; do not vendor dependency assets or code.
- Preserve the declared mod ID and dependency load order in `common/mod.info`.
- Before claiming completion, run `node tests/lifestyle-2dw-shower-compat.test.cjs`, parse changed Lua when practical, and run `git diff --check`.
- Report source-test results separately from installed-file or in-game evidence.
