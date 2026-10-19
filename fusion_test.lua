-- Fusion Test Deck: start with both ingredients and enough money to fuse them.
-- `jokers` and `dollars` are applied by the base game at run start (like Yellow Deck's +$10).

local BASE_DOLLARS = 4 -- vanilla starting money (get_starting_params)

SMODS.Back {
    key = 'fusion_test',
    pos = { x = 0, y = 4 }, -- vanilla Challenge Deck art
    config = {
        jokers = { 'j_wrathful_joker', 'j_gluttenous_joker' },
        dollars = 20 - BASE_DOLLARS,
    },
    loc_txt = {
        name = 'Fusion Test Deck',
        text = {
            'Start with {C:attention}Wrathful Joker{}',
            'and {C:attention}Gluttonous Joker{}',
            'Start with {C:money}$#1#{}',
        },
    },
    loc_vars = function(self)
        return { vars = { BASE_DOLLARS + self.config.dollars } }
    end,
}
