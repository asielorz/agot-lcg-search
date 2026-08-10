module CardExtra exposing (..)

import Card exposing (Card, CardId)
import Cards

import List.Extra

-- This module, unlike Card, has access to Cards, and therefore to the array of all cards.
card_with_id : CardId -> Maybe Card
card_with_id id = List.Extra.find (\c -> c.id == id) Cards.all_cards
