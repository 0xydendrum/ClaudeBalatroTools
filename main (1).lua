-- Example Fusion
-- Fusion Jokers loads first (priority -10000), so FusionJokers.fusions and the
-- 'fuse_fusion' rarity already exist by the time these files run.

SMODS.load_file('jokers/example_fusion.lua')()
SMODS.load_file('decks/fusion_test.lua')()
