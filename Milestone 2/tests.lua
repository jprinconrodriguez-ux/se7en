-- tests.lua
-- Basic automated checks for Jokers Gambit

love = { math = { random = math.random } }

local Deck = require("deck")
local Jokers = require("jokers")
local Attacks = require("attacks")
local SaveLoad = require("saveload")
local Scoring = require("scoring")
local GS = require("gamestate")

local function deep_eq(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k,v in pairs(a) do if not deep_eq(v, b[k]) then return false end end
  for k,v in pairs(b) do if not deep_eq(v, a[k]) then return false end end
  return true
end

-- Turn flow: joker use capped at 1
do
  local S = {}
  Jokers.init(S, love.math)
  Jokers.gain_from_pool(S, 2, love.math)
  assert(#S.jokers.hand >= 2, "need two jokers for test")
  local r1 = Jokers.use(S, 1, {})
  assert(r1.ok, "first joker should succeed")
  local r2 = Jokers.use(S, 1, {})
  assert(not r2.ok, "second joker should be blocked")
end
print("Turn flow test: passed")

-- Attack scaling probabilities snapshot
do
  local expected = {
    [1] = { ["High Card"]=21,["Pair"]=18,["Two Pair"]=16,["Three of a Kind"]=14,["Flush"]=12,["Straight"]=8,["Full House"]=7,["Four of a Kind"]=4 },
    [2] = { ["High Card"]=16,["Pair"]=16,["Two Pair"]=15,["Three of a Kind"]=14,["Flush"]=12,["Straight"]=10,["Full House"]=10,["Four of a Kind"]=7 },
    [3] = { ["High Card"]=12,["Pair"]=14,["Two Pair"]=14,["Three of a Kind"]=14,["Flush"]=14,["Straight"]=12,["Full House"]=12,["Four of a Kind"]=8 },
    [4] = { ["High Card"]=10,["Pair"]=12,["Two Pair"]=12,["Three of a Kind"]=14,["Flush"]=14,["Straight"]=12,["Full House"]=14,["Four of a Kind"]=12 },
    [5] = { ["High Card"]=8,["Pair"]=10,["Two Pair"]=12,["Three of a Kind"]=14,["Flush"]=14,["Straight"]=14,["Full House"]=14,["Four of a Kind"]=14 },
  }
  for t=1,5 do
    local probs = Attacks.probs_for_threshold(t)
    assert(deep_eq(probs, expected[t]), "Attack table mismatch at T"..t)
  end
end
print("Attack scaling test: passed")

-- Save/Load round trip
do
  local deck = Deck.new(1)
  GS:reset()
  local S = {}
  Scoring.init(S)
  Jokers.init(S, love.math)
  Jokers.gain_from_pool(S, 2, love.math)
  local hand = deck:draw(5)
  S.meta.score = 42
  S.meta.threshold = 2
  GS.playedHands["Pair"] = true
  deck:discardCards({deck.cards[#deck.cards]})
  Attacks.announce(S, love.math)
  GS.turn = 3
  GS.limits.discard_used = true
  local UI = {}

  local saved = SaveLoad.build_state(deck, hand, GS, S, UI)

  -- mutate everything
  deck = Deck.new(1)
  hand = deck:draw(3)
  GS:reset()
  S.meta = {}
  S.jokers = nil
  UI = {}

  hand = SaveLoad.apply_state(saved, deck, GS, S, UI, Scoring, Jokers)

  assert(S.meta.score == 42, "score mismatch")
  assert(S.meta.threshold == 2, "threshold mismatch")
  assert(GS.turn == 3, "turn mismatch")
  assert(GS.playedHands["Pair"], "played hand lost")
  assert(GS.limits.discard_used == true, "discard flag lost")
  assert(#deck.discard == 1, "discard pile mismatch")
  assert(S.combat.current_attack == saved.gs.current_attack, "attack mismatch")
  assert(#S.jokers.hand == #saved.jokers.hand, "joker hand mismatch")
  assert(#hand == #saved.hand, "hand size mismatch")
end
print("Save/Load round trip test: passed")

print("All tests passed.")

