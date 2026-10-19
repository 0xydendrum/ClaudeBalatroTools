-- Example fusion: Wrathful Joker + Gluttonous Joker
-- Wrathful gives +3 Mult per scored Spade, Gluttonous +3 per scored Club.
-- The fusion gives +6 Mult for either suit.

SMODS.Atlas {
    key = 'example_fusion',
    path = 'j_example_fusion.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'example_fusion',
    atlas = 'example_fusion',
    pos = { x = 0, y = 0 },
    rarity = 'fuse_fusion',
    cost = 12,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            mult = 6,
            joker1 = 'j_wrathful_joker',
            joker2 = 'j_gluttenous_joker', -- (sic) the base game's key is misspelled
        }
    },
    loc_txt = {
        name = 'Example Fusion',
        text = {
            'Played cards with {C:spades}Spade{} or',
            '{C:clubs}Club{} suit give {C:mult}+#1#{} Mult',
            'when scored',
            '{C:inactive}(#2# + #3#)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                localize { type = 'name_text', key = card.ability.extra.joker1, set = 'Joker' },
                localize { type = 'name_text', key = card.ability.extra.joker2, set = 'Joker' },
            }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
        (context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs')) then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end,
    -- JokerDisplay (optional mod): without a joker_display_def it draws an empty bar
    -- under this Joker. Adapt the Wrathful/Gluttonous definitions from the user's own
    -- JokerDisplay install (definitions\display_definitions.lua). See CLAUDE.md section 6.
}

FusionJokers.fusions:register_fusion {
    jokers = {
        { name = 'j_wrathful_joker' },
        { name = 'j_gluttenous_joker' },
    },
    result_joker = 'j_exfuse_example_fusion',
    cost = 10,
}
