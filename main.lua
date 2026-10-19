-- Card back art (assets/1x and assets/2x, built by tools\build_art.ps1)
SMODS.Atlas {
    key = 'example_back',
    path = 'example_back.png',
    px = 71,
    py = 95
}

-- Example Deck: big hands, fewer chances to play them.
-- hand_size / hands / discards are applied by the base game at run start,
-- the same way Painted Deck (+2 hand size) and Black Deck (-1 hand) work.
SMODS.Back {
    key = 'example',
    atlas = 'example_back',
    pos = { x = 0, y = 0 },
    config = { hand_size = 4, hands = -1, discards = -1 },
    loc_txt = {
        name = 'Example Deck',
        text = {
            '{C:attention}+#1#{} hand size',
            '{C:blue}-#2#{} hand and',
            '{C:red}-#3#{} discard',
            'every round',
        },
    },
    loc_vars = function(self)
        return { vars = { self.config.hand_size, -self.config.hands, -self.config.discards } }
    end,
}
