local Gamestate = {
  phase = "MAIN",
  turn  = 1,
    playedHands = {},           -- e.g., { ["Pair"]=true }
  limits = { joker_played_this_turn = false }, -- scaffold for 3.2
  meta   = { run_id = 1 }     -- placeholder; increments per restart if desired
}

function Gamestate:reset()
  self.phase = "MAIN"
  self.turn  = 1
  self.playedHands = {}
  self.limits = { joker_played_this_turn = false }
  self.meta = self.meta or { run_id = 1 }
end

return Gamestate