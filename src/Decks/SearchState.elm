module Decks.SearchState exposing (SearchState, make, set_index, scroll)

import Card exposing (Card)
import Cards
import Decks.Deck as Deck exposing (Deck)

import List.Extra

type alias SearchState =
    { candidates : List Card
    , index : Int
    }

make : String -> Deck -> Maybe SearchState -> Maybe SearchState
make query deck prev_state =
    if String.isEmpty query
        then Just { candidates = [], index = 0 }
        else case prev_state of
            Nothing -> Just { candidates = search_candidates query deck, index = 0 }
            Just state ->
                let new_candidates = search_candidates query deck
                in Just { candidates = new_candidates, index = clamp_index new_candidates state.index }

set_index : Int -> Maybe SearchState -> Maybe SearchState
set_index new_index search_state = search_state |> Maybe.map
    (\state -> {state | index = clamp_index state.candidates new_index})

scroll : Int -> Maybe SearchState -> Maybe SearchState
scroll scroll_amount search_state = search_state |> Maybe.map
    (\state -> {state | index = clamp_index state.candidates (state.index + scroll_amount)})

clamp_index : List Card -> Int -> Int
clamp_index candidates index = clamp 0 (max 0 (List.length candidates - 1)) index

-- This needs to be a global so that it is computed only once because it is slow as hell to compute and it makes the typing
-- experience become miserable if we do it on every update to the searcho box.
deduplicated_cards : List Card
deduplicated_cards = List.Extra.uniqueBy Card.duplicate_id Cards.all_cards

search_candidates : String -> Deck -> List Card
search_candidates query deck = 
    let
        query_lowercase = String.toLower query
    in
        deduplicated_cards
            |> List.filter (\card -> String.contains query_lowercase (String.toLower card.name))
            |> List.filter (\card -> not <| Deck.has_card card deck)
            |> List.take 10
