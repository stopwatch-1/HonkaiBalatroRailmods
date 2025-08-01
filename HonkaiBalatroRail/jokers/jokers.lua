-- you can have shared helper functions
function shakecard(self) --visually shake a card
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end

function return_JokerValues() -- not used, just here to demonstrate how you could return values from a joker
    if context.joker_main and context.cardarea == G.jokers then
        return {
            chips = card.ability.extra.chips,       -- these are the 3 possible scoring effects any joker can return.
            mult = card.ability.extra.mult,         -- adds mult (+)
            x_mult = card.ability.extra.x_mult,     -- multiplies existing mult (*)
            card = self,                            -- under which card to show the message
            colour = G.C.CHIPS,                     -- colour of the message, Balatro has some predefined colours, (Balatro/globals.lua)
            message = localize('k_upgrade_ex'),     -- this is the message that will be shown under the card when it triggers.
            extra = { focus = self, message = localize('k_upgrade_ex') }, -- another way to show messages, not sure what's the difference.
        }
    end
end

SMODS.Atlas({
    key = "sample_wee",
    path = "j_sample_wee.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_obelisk",
    path = "j_sample_obelisk.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_specifichand",
    path = "j_sample_specifichand.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_money",
    path = "j_sample_money.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_roomba",
    path = "j_sample_roomba.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_drunk_juggler",
    path = "j_sample_drunk_juggler.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_hackerman",
    path = "j_sample_hackerman.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_baroness",
    path = "j_sample_baroness.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_rarebaseballcard",
    path = "j_sample_rarebaseballcard.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "sample_multieffect",
    path = "j_sample_multieffect.png",
    px = 71,
    py = 95
})

SMODS.Atlas({
    key = "blade_card",
    path = "blade_card.png",
    px = 69,
    py = 93
})



SMODS.Joker{ --Blade
    name = "Blade",
    key = "blade",
    config = {
        extra = {
            bladeMult = 0
        }
    },
    
    loc_txt = {
        ['name'] = 'Blade',
        ['text'] = {
            [1] = 'Gain {C:red}+4{} for each card destroyed.',
            [2] = '{C:inactive}(Currently {}{C:mult}+#1#{}{C:inactive} Mult){}'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'blade_card',

    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.bladeMult}}
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
                return {
                    func = function()
                    card.ability.extra.bladeMult = (card.ability.extra.bladeMult) + 4 * #context.removed
                    return true
                end
                }
        end
        if context.cardarea == G.jokers and context.joker_main then
                return {
                    mult = card.ability.extra.bladeMult
                }
        end
    end
}

SMODS.Joker{ --Rappa
    name = "Rappa",
    key = "rappa",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Rappa',
        ['text'] = {
            [1] = 'Skipping a blind creates',
            [2] = 'an extra random tag',
            [3] = ''
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
                return {
                    func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                    local selected_tag = pseudorandom_element(G.P_TAGS, pseudoseed("create_tag")).key
                    local tag = Tag(selected_tag)
                    tag:set_ability()
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
                    return true
                end,
                    message = "Created Tag!"
                }
        end
    end
}

SMODS.Joker{ --Welt
    name = "Welt",
    key = "welt",
    config = {
        extra = {
            mult = 7
        }
    },
    loc_txt = {
        ['name'] = 'Welt',
        ['text'] = {
            [1] = '{C:enhanced}Enhanced{} cards give',
            [2] = '{C:red}+7{} Mult when scored',
            [3] = ''
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if (function()
        local enhancements = SMODS.get_enhancements(context.other_card)
        for k, v in pairs(enhancements) do
            if v then
                return true
            end
        end
        return false
    end)() then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}

SMODS.Joker{ --Himeko
    name = "Himeko",
    key = "himeko",
    config = {
        extra = {
            chips = 35
        }
    },
    loc_txt = {
        ['name'] = 'Himeko',
        ['text'] = {
            [1] = '{C:enhanced}Enhanced{} cards give',
            [2] = '{C:blue}+35{} Chips when scored'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if (function()
        local enhancements = SMODS.get_enhancements(context.other_card)
        for k, v in pairs(enhancements) do
            if v then
                return true
            end
        end
        return false
    end)() then
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end
}

SMODS.Joker{ --Dan Heng
    name = "Dan Heng",
    key = "danheng",
    config = {
        extra = {
            dollars = 1
        }
    },
    loc_txt = {
        ['name'] = 'Dan Heng',
        ['text'] = {
            [1] = '{C:enhanced}Enhanced{} cards give',
            [2] = '{C:money}+$1{} when scored'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    can_spawn = function()
        for _, card in ipairs(G.playing_cards) do
            if card.ability and card.ability.effect and card.ability.effect.type == 'enhancement' then
                return true
            end
        end
        return false
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if (function()
        local enhancements = SMODS.get_enhancements(context.other_card)
        for k, v in pairs(enhancements) do
            if v then
                return true
            end
        end
        return false
    end)() then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
    end
}

SMODS.Joker{ --Phainon
    name = "Phainon",
    key = "phainon",
    config = {
        extra = {
            ante_value = 1
        }
    },
    loc_txt = {
        ['name'] = 'Phainon',
        ['text'] = {
            [1] = 'When defeating Boss Blind,',
            [2] = '{C:red}-1{} Ante. Banishes itself',
            [3] = 'after triggering (will never appear)',
            [4] = ''
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',
    no_pool_flag = 'phainon_banished',

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and G.GAME.blind.boss and not context.blueprint then
                return {
                    func = function()
                    local mod = -card.ability.extra.ante_value
        ease_ante(mod)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.pool_flags.phainon_banished = true
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + mod
                return true
            end,
        }))
                    return true
                end,
                    message = "Ante -" .. card.ability.extra.ante_value,
                    extra = {
                        func = function()
                card:start_dissolve()
                return true
            end,
                            message = "I wont...forget",
                        colour = G.C.RED
                        }
                }
        end
    end
}

SMODS.Joker{ --Argenti
    name = "Argenti",
    key = "argenti",
    config = {
        extra = {
            argentiMoney = 6
        }
    },
    loc_txt = {
        ['name'] = 'Argenti',
        ['text'] = {
            [1] = 'Earn {C:money}$6{} if all cards',
            [2] = 'held in hand are {C:diamonds}Diamonds{}',
            [3] = 'or {C:hearts}Hearts{} after hand scored'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.argenti } }
    end,

    calculate = function(self, card, context)
    -- After the hand is scored
    if context.after and context.cardarea == G.jokers then
        local valid = true

        -- Loop through all cards in hand
        for _, c in ipairs(G.hand.cards) do
            if not (c:is_suit("Hearts") or c:is_suit("Diamonds")) then
                valid = false
                break
            end
        end

        if valid then
            return {
                dollars = 6,
                extra = {
                    colour = G.C.BLUE
                }
            }
        end
    end
end
}

SMODS.Joker{ --Asta
    name = "Asta",
    key = "asta",
    config = {
        extra = {
            odds = 3,
            levels = 1
        }
    },
    loc_txt = {
        ['name'] = 'Asta',
        ['text'] = {
            [1] = '{C:planet}Planet{} cards have a',
            [2] = '{C:green}1 in 3{} chance to ',
            [3] = 'trigger again',
            [4] = ''
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    calculate = function(self, card, context)
    if context.using_consumeable and not context.blueprint then
        if context.consumeable and context.consumeable.ability.set == 'Planet' then
            if pseudorandom('asta_' .. tostring(G.GAME.round_resets or G.GAME.round or 0), 1, card.ability.extra.odds) == 1 then
                local target_hand = context.consumeable.ability.hand_type or "High Card"

                SMODS.calculate_effect({
                    level_up = card.ability.extra.levels,
                    level_up_hand = target_hand
                }, card)

                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                    message = localize('k_level_up_ex'),
                    colour = G.C.RED
                })
            end
        end
    end
end
}

SMODS.Joker {
    name = "Clara",
    key = "clara",
    config = { },
    loc_txt = {
        ['name'] = 'Clara',
        ['text'] = {
            [1] = '{C:attention}Steel Cards{} provide',
            [2] = '{X:mult,C:white}X2{} Mult instead',
            [3] = 'of {X:mult,C:white}X1.5{} Mult',
        }
    },
    pos = {x = 0, y = 0},
    cost = 4,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    add_to_deck = function(self, card)
        G.P_CENTERS.m_steel.config.h_x_mult = 2.0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if SMODS.get_enhancements(playing_card)["m_steel"] == true then
                playing_card.ability.h_x_mult = 2.0
            end
        end
    end,

    remove_from_deck = function(self, card)
        local other_clara_exists = false
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and j.ability.key and j.ability.key == 'clara' and j ~= self then
                other_clara_exists = true
                break
            end
        end

        if not other_clara_exists then
            G.P_CENTERS.m_steel.config.h_x_mult = 1.5
            for _, playing_card in pairs(G.playing_cards or {}) do
                if SMODS.get_enhancements(playing_card)["m_steel"] == true then
                    playing_card.ability.h_x_mult = 1.5
                end
            end
        end
    end,

    calculate = nil
}

SMODS.Joker {
    name = "Boothill",
    key = "boothill",
    config = { },
    loc_txt = {
        ['name'] = 'Boothill',
        ['text'] = {
            [1] = 'Adds rank of each card',
            [2] = 'played that was not',
            [3] = 'scored to {C:mult}Mult{}'
        }
    },
    pos = {x = 0, y = 0},
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    -- No loc_vars needed for this version
    loc_vars = nil,

    -- This function runs during the score calculation
    calculate = function(self, card, context)
        if context.joker_main and context.cardarea == G.jokers then
            local mult_to_add = 0
            
            local scored_cards_lookup = {}
            for _, scored_card in ipairs(context.scoring_hand) do
                scored_cards_lookup[scored_card:get_id()] = true
            end

            -- Iterate through the full hand and check against the lookup table.
            if context.full_hand then
                for _, card_in_hand in ipairs(context.full_hand) do
                    -- Check if the card's ID is in our lookup table.
                    if not scored_cards_lookup[card_in_hand:get_id()] then
                        mult_to_add = mult_to_add + card_in_hand.base.nominal
                    end
                end
            end

            if mult_to_add > 0 then
                return {
                    mult = mult_to_add
                    -- message = localize{type='variable',key='a_mult',vars={mult_to_add}}
                }
            end
        end
    end
}

SMODS.Joker{
    name = "Sparkle",
    key = "sparkle",
    config = {},
    loc_txt = {
        ['name'] = 'Sparkle',
        ['text'] = {
            "When round begins,",
            "become a copy of a",
            "random different",
            "{C:rare}Rare{} Joker until end of round"
        }
    },
    pos = {x = 0, y = 0},
    cost = 6,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'sample_wee',

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint and not card.ability.is_sparkle_disguise then
            return {
                func = function()
                    -- Create a pool of all Rare jokers, excluding Sparkle itself.
                    local rare_joker_pool = {}
                    for _, joker_center in ipairs(G.P_JOKER_RARITY_POOLS[3]) do
                        if joker_center.key ~= 'sparkle' then
                            table.insert(rare_joker_pool, joker_center)
                        end
                    end

                    if #rare_joker_pool > 0 then
                        -- Select a random joker from the pool.
                        local new_joker_center = pseudorandom_element(rare_joker_pool, pseudoseed('sparkle_transform'..G.GAME.round_resets.ante))
                        
                        card.ability.original_center = self
                        card.ability.is_sparkle_disguise = true
                        
                        card:set_ability(new_joker_center, true)

                        -- Add visual/audio feedback for the transformation.
                        card:juice_up(1, 0.5)
                        play_sound('tarot2')
                    end
                    return true
                end,
                message = "Transforming...",
                colour = G.C.RARE
            }
        end
    end
}
