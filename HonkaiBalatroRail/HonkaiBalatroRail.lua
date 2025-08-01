SampleJimbos = {}

assert(SMODS.load_file("globals.lua"))()

-- Hook into the base game's joker calculation function
local old_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context)
    -- Sparkle Revert Hook (runs BEFORE the original logic)
    if self.ability.is_sparkle_disguise and context.end_of_round then

        self:set_ability(self.ability.original_center, true)

        -- Clean up the flags so it's ready for the next round.
        self.ability.is_sparkle_disguise = nil
        self.ability.original_center = nil

        -- Add visual/audio feedback for the reversion.
        self:juice_up(0.7, 0.4)
        -- play_sound('debuff')

        -- By returning true, we stop the now-reverted joker from performing
        -- any further calculations in this "end_of_round" context.
        return true, { message = "Reverting...", colour = G.C.FILTER }
    end

    -- If the revert condition isn't met, call the original function
    return old_calculate_joker(self, context)
end

-- Jokers
local joker_src = NFS.getDirectoryItems(SMODS.current_mod.path .. "jokers")
for _, file in ipairs(joker_src) do
    assert(SMODS.load_file("jokers/" .. file))()
end

