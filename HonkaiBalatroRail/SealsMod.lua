--- STEAMODDED HEADER
--- MOD_NAME: Modded Seal
--- MOD_ID: seel-mod
--- MOD_AUTHOR: [stupxd]
--- PREFIX: seel
--- MOD_DESCRIPTION: Modded seal example
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-1314c]

----------------------------------------------
------------MOD CODE -------------------------

-- Helper function for debugging
function get_context_keys(context)
    local keys = {}
    if type(context) == 'table' then
        for k, v in pairs(context) do
            table.insert(keys, tostring(k))
        end
    end
    return keys
end

SMODS.Seal {
    name = "Destruction Seal",
    key = "seel_destruction",
    badge_colour = HEX("751d1a"),
    config = { remove_card = true },
    loc_txt = {
        label = 'Destruction Seal',
        name = 'Destruction Seal',
        text = {
            [1] = '{C:attention}Destroy{} this card',
            [2] = 'when scored'
        }
    },
    atlas = "seal_atlas",
    pos = {x=0, y=0},

    calculate = function(self, card, context)
        if context.destroying_card and context.cardarea == G.play and context.destroy_card == card then
            return { remove = true }
        end
    end,
}

SMODS.Seal {
    name = "Abundance Seal",
    key = "seel_abundance",
    badge_colour = HEX("e7d029"),
    config = { extra = { chips = 10 } },
    loc_txt = {
        label = 'Abundance Seal',
        name = 'Abundance Seal',
        text = {
            [1] = 'This {C:attention}card{} permanently',
            [2] = 'gains {C:chips}+#1#{} Chips',
            [3] = 'when scored'
        }
    },
    atlas = "seal_atlas",
    pos = {x=0, y=0},
    
    loc_vars = function(self, info_queue, card)
        return {vars = {10}}
    end,

    calculate = function(self, card, context)
        -- Trigger before scoring to ensure the chips count for this hand
        if context.before and context.cardarea == G.play and not card.debuff then
            -- Add 10 chips to the permanent bonus
            card.ability.perma_bonus = card.ability.perma_bonus or 0
            card.ability.perma_bonus = card.ability.perma_bonus + 10
            
            -- Show visual feedback
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Upgraded!",
                colour = G.C.CHIPS
            })
            
            return {
                message = localize{type='variable',key='a_chips',vars={10}},
                colour = G.C.CHIPS,
                card = card
            }
        end
    end,
}

SMODS.Atlas {
    key = "seal_atlas",
    path = "modded_seal.png",
    px = 71,
    py = 95
}

-- Take ownership of gold seal to change its effect
SMODS.Seal:take_ownership('gold_seal', {
    calculate = function(self, card, context)
        -- This might not be getting called, so we'll handle it in INIT instead
        return nil
    end
}, true)

-- Take ownership of blue seal to change its effect
SMODS.Seal:take_ownership('blue_seal', {
    calculate = function(self, card, context)
        -- This might not be getting called, so we'll handle it in INIT instead
        return nil
    end
}, true)

function SMODS.INIT.seel_mod()
    -- Modify the red seal's localization
    if G and G.localization and G.localization.descriptions and G.localization.descriptions.Other then
        if G.localization.descriptions.Other.red_seal then
            G.localization.descriptions.Other.red_seal.name = "Remembrance Seal"
            G.localization.descriptions.Other.red_seal.label = "Remembrance Seal"
            G.localization.descriptions.Other.red_seal.text = {"Retrigger this", 'card {C:attention}1{} time'}
            sendDebugMessage("Red seal renamed to Remembrance Seal")
        end
        
        -- Modify the gold seal's localization
        if G.localization.descriptions.Other.gold_seal then
            G.localization.descriptions.Other.gold_seal.name = "Preservation Seal"
            G.localization.descriptions.Other.gold_seal.label = "Preservation Seal"
            G.localization.descriptions.Other.gold_seal.text = {"Earn {C:money}$2{} when scored,", "increases by {C:money}$1{} for each", "{C:attention}Preservation Seal{} card", "scored this hand"}
            sendDebugMessage("Gold seal renamed to Preservation Seal")
        end
        
        -- Modify the blue seal's localization
        if G.localization.descriptions.Other.blue_seal then
            G.localization.descriptions.Other.blue_seal.name = "Harmony Seal"
            G.localization.descriptions.Other.blue_seal.label = "Harmony Seal"
            G.localization.descriptions.Other.blue_seal.text = {"When scored in", "{C:attention}winning hand{},", "upgrade {C:attention}2{} random", "{C:attention}hand types{}"}
            sendDebugMessage("Blue seal renamed to Harmony Seal")
        end
    end
    
    -- Try additional label locations
    if G and G.localization then
        if G.localization.misc and G.localization.misc.labels then
            G.localization.misc.labels.red_seal = "Remembrance Seal"
            G.localization.misc.labels.gold_seal = "Preservation Seal"
            G.localization.misc.labels.blue_seal = "Harmony Seal"
        end
        if G.localization.labels then
            G.localization.labels.red_seal = "Remembrance Seal"
            G.localization.labels.gold_seal = "Preservation Seal"
            G.localization.labels.blue_seal = "Harmony Seal"
        end
    end
    
    -- Change badge colors by hooking the get_badge_colour function
    local original_get_badge_colour = get_badge_colour
    get_badge_colour = function(key)
        if key == 'red_seal' then
            return HEX("e98e46")
        elseif key == 'gold_seal' then
            return HEX("4b8bdb")
        elseif key == 'blue_seal' then
            return HEX("9881d8")
        end
        return original_get_badge_colour(key)
    end
    sendDebugMessage("Seal badge colors changed")
    
    -- Hook into Card:get_p_dollars to override gold seal behavior
    local original_get_p_dollars = Card.get_p_dollars
    Card.get_p_dollars = function(self)
        if self.debuff then return 0 end
        local ret = 0
        
        if self.seal == 'Gold' then
            sendDebugMessage("Processing preservation seal for p_dollars")
            
            -- Count preservation seals in the current play area
            local preservation_count = 0
            if G.play and G.play.cards then
                for i = 1, #G.play.cards do
                    if G.play.cards[i].seal == 'Gold' then
                        preservation_count = preservation_count + 1
                    end
                end
            end
            
            -- Find which preservation seal this is (1st, 2nd, 3rd, etc.)
            local seal_position = 1
            if G.play and G.play.cards then
                for i = 1, #G.play.cards do
                    if G.play.cards[i].seal == 'Gold' then
                        if G.play.cards[i] == self then
                            break -- This is our card
                        end
                        seal_position = seal_position + 1
                    end
                end
            end
            
            -- Calculate money: $2 for 1st seal, $3 for 2nd, $4 for 3rd, etc.
            local money_earned = 1 + seal_position
            sendDebugMessage("Preservation seal #" .. seal_position .. " giving $" .. money_earned .. " (total " .. preservation_count .. " seals)")
            
            ret = ret + money_earned
        end
        
        -- Handle other p_dollars effects
        if self.ability.p_dollars > 0 then
            if self.ability.effect == "Lucky Card" then 
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal/15 then
                    self.lucky_trigger = true
                    ret = ret + self.ability.p_dollars
                end
            else 
                ret = ret + self.ability.p_dollars
            end
        end
        
        return ret
    end
    
    -- Hook into Card:get_chip_bonus to ensure perma_bonus updates are reflected immediately
    local original_get_chip_bonus = Card.get_chip_bonus
    Card.get_chip_bonus = function(self)
        local ret = 0
        if original_get_chip_bonus then
            ret = original_get_chip_bonus(self)
        end
        return ret
    end
    
    -- Hook into Card:get_end_of_round_effect to disable original blue seal behavior
    local original_get_end_of_round_effect = Card.get_end_of_round_effect
    Card.get_end_of_round_effect = function(self, context)
        -- If this is a blue seal, completely skip the original function and return empty
        if self.seal == 'Blue' then
            -- Return empty table to prevent planet card creation
            return {}
        end
        
        -- For all other seals, call the original function
        return original_get_end_of_round_effect(self, context)
    end
    
    -- Hook into the main hand evaluation to handle Harmony Seal (only once per hand)
    local original_evaluate_play = G.FUNCS.evaluate_play
    G.FUNCS.evaluate_play = function(e)
        -- Call the original function for actual scoring first
        if original_evaluate_play then
            original_evaluate_play(e)
        end
        
        -- Add delay to ensure hand evaluation is complete for Harmony Seal
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                -- Check for Harmony Seal after hand evaluation
                if G.play and G.play.cards and G.GAME.chips and G.GAME.blind then
                    sendDebugMessage("Checking Harmony Seal: chips=" .. (G.GAME.chips or 0) .. ", blind=" .. (G.GAME.blind.chips or 0))
                    
                    -- Check if this is a winning hand
                    if G.GAME.chips >= G.GAME.blind.chips then
                        sendDebugMessage("Hand is winning, checking for blue seals")
                        
                        -- Look for cards with Blue seal (Harmony Seal) in the played hand
                        for i = 1, #G.play.cards do
                            local card = G.play.cards[i]
                            if card.seal == 'Blue' then
                                sendDebugMessage("Harmony Seal triggered on winning hand for card " .. i)
                                
                                -- Get all available hand types (only unlocked/visible ones)
                                local hand_types = {}
                                for k, v in pairs(G.GAME.hands) do
                                    if type(v) == 'table' and v.level and v.level > 0 and v.visible then
                                        table.insert(hand_types, k)
                                    end
                                end
                                
                                sendDebugMessage("Found " .. #hand_types .. " hand types to upgrade")
                                
                                -- Upgrade 2 random hand types for each Harmony Seal
                                if #hand_types > 0 then
                                    local upgrades_to_do = math.min(2, #hand_types)
                                    local upgraded_hands = {}
                                    
                                    for j = 1, upgrades_to_do do
                                        local random_index = math.floor(pseudorandom('harmony_seal'..i..j) * #hand_types + 1)
                                        if random_index > #hand_types then random_index = #hand_types end
                                        
                                        local hand_to_upgrade = hand_types[random_index]
                                        
                                        -- Avoid upgrading the same hand twice for this seal
                                        local attempts = 0
                                        while upgraded_hands[hand_to_upgrade] and attempts < #hand_types do
                                            random_index = math.floor(pseudorandom('harmony_seal_retry'..i..j..attempts) * #hand_types + 1)
                                            if random_index > #hand_types then random_index = #hand_types end
                                            hand_to_upgrade = hand_types[random_index]
                                            attempts = attempts + 1
                                        end
                                        
                                        if not upgraded_hands[hand_to_upgrade] then
                                            -- Level up the hand using SMODS.calculate_effect like Asta does
                                            SMODS.calculate_effect({
                                                level_up = 1,
                                                level_up_hand = hand_to_upgrade
                                            }, card)
                                            
                                            upgraded_hands[hand_to_upgrade] = true
                                            sendDebugMessage("Harmony Seal upgraded " .. hand_to_upgrade)
                                            
                                            -- Add visual feedback
                                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Harmony!", colour = G.C.BLUE})
                                        end
                                    end
                                end
                                -- Removed break - now continues to process all blue seals
                            end
                        end
                    else
                        sendDebugMessage("Hand is not winning")
                    end
                end
                return true
            end
        }))
    end
end


-- Create consumable that will add this seal.

SMODS.Consumable {
    set = "Spectral",
    key = "honk",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'seel_destruction',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Honk',
        text = {
            "Select {C:attention}#1#{} card to",
            "apply {C:attention}Destruction Seal{}"
        }
    },
    cost = 4,
    atlas = "honk_atlas",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
    for i = 1, math.min(#G.hand.highlighted, self.config.max_highlighted) do
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))
        
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
            G.hand.highlighted[i]:set_seal(self.config.extra, nil, true)
            return true end }))
        
        delay(0.5)
    end
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function() G.hand:unhighlight_all(); return true end }))
end
}

SMODS.Consumable {
    set = "Spectral",
    key = "abundance_giver",
	config = {
        -- How many cards can be selected.
        max_highlighted = 1,
        -- the key of the seal to change to
        extra = 'seel_abundance',
    },
    loc_vars = function(self, info_queue, card)
        -- Handle creating a tooltip with seal args.
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        -- Description vars
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,
    loc_txt = {
        name = 'Prosperity',
        text = {
            "Select {C:attention}#1#{} card to",
            "apply {C:attention}Abundance Seal{}"
        }
    },
    cost = 4,
    atlas = "honk_atlas",
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
    for i = 1, math.min(#G.hand.highlighted, self.config.max_highlighted) do
        G.E_MANAGER:add_event(Event({func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true end }))
        
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
            G.hand.highlighted[i]:set_seal(self.config.extra, nil, true)
            return true end }))
        
        delay(0.5)
    end
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function() G.hand:unhighlight_all(); return true end }))
end
}

SMODS.Atlas {
    key = "honk_atlas",
    path = "honk.png",
    px = 71,
    py = 95
}

----------------------------------------------
------------MOD CODE END----------------------
