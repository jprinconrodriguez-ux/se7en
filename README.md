# Jokers Gambit Updates

## Changes
- Enforced per-turn limits for joker use and discarding with clear messages.
- Save/Load now persists score, threshold, jokers, hand, played hands, discard pile, attack target and turn count.
- Removed legacy scaling mechanic and all related code/UI.
- Extracted save/load helpers to `saveload.lua` and added basic automated tests.

## Running
Ensure Lua is installed. To execute tests:

```bash
cd "Milestone 2"
lua tests.lua
```

Run the game with Love2D as usual:

```bash
love "Milestone 2"
```

