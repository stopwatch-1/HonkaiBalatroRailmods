
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
            [1] = 'Gain {C:red}+4{} for each card destroyed',
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
                end,
                message = 'Upgraded!',
				colour = G.C.MULT,
				card = card
                }
        end
        if context.cardarea == G.jokers and context.joker_main then
                return {
                    mult = card.ability.extra.bladeMult,
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

    in_pool = function(self, args)
        for _, card in ipairs(G.playing_cards) do
            if (card.ability and card.ability.effect and card.ability.effect.type == 'enhancement')
                or (card.ability and card.ability.set == 'Enhanced') then
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

    in_pool = function(self, args)
        for _, card in ipairs(G.playing_cards) do
            if (card.ability and card.ability.effect and card.ability.effect.type == 'enhancement')
                or (card.ability and card.ability.set == 'Enhanced') then
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

    in_pool = function(self, args)
        for _, card in ipairs(G.playing_cards) do
            if (card.ability and card.ability.effect and card.ability.effect.type == 'enhancement')
                or (card.ability and card.ability.set == 'Enhanced') then
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
            astaodds = 3,
            levels = 1
        }
    },

    loc_txt = {
        ['name'] = 'Asta',
        ['text'] = {
            [1] = '{C:planet}Planet{} cards have a',
            [2] = '{C:green}#1# in #2#{} chance to ',
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

    loc_vars = function(self, info_queue, card)
        card.ability.extra = card.ability.extra or {}
        card.ability.extra.astaodds = card.ability.extra.astaodds or self.config.extra.astaodds
        return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.astaodds } }
    end,

    calculate = function(self, card, context)
        card.ability.extra = card.ability.extra or {}
        card.ability.extra.astaodds = card.ability.extra.astaodds or self.config.extra.astaodds
        card.ability.extra.levels = card.ability.extra.levels or self.config.extra.levels

        if context.using_consumeable and not context.blueprint and not context.repetition then
            if context.consumeable and context.consumeable.ability.set == 'Planet' then
                local odds = (G.GAME.probabilities.normal or 1) / card.ability.extra.astaodds
                -- Use a float between 0 and 1 for the roll
                local roll = pseudorandom('asta', 0, 10000) / 10000

                if roll < odds then
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

