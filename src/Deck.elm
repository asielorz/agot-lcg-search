module Deck exposing (..)

import Card exposing (Card, CardType(..))
import CardSet

import List.Extra

type alias Deck = 
    { name : String
    , description : String
    , house : Maybe Card
    , agendas : List (Card, Int)
    , plots : List (Card, Int)
    , characters : List (Card, Int)
    , attachments : List (Card, Int)
    , events : List (Card, Int)
    , locations : List (Card, Int)
    }

empty : Deck
empty = 
    { name = ""
    , description = ""
    , house = Nothing
    , agendas = []
    , plots = []
    , characters = []
    , attachments = []
    , events = []
    , locations = []
    }

rename : String -> Deck -> Deck
rename name deck = { deck | name = name }

change_description : String -> Deck -> Deck
change_description description deck = { deck | description = description }

cards_of_type : CardType -> Deck -> List (Card, Int)
cards_of_type card_type deck = case card_type of
    CardType_House -> case deck.house of
        Nothing -> []
        Just card -> [(card, 1)]
    CardType_Agenda -> deck.agendas
    CardType_Plot -> deck.plots
    CardType_Character -> deck.characters
    CardType_Attachment -> deck.attachments
    CardType_Event -> deck.events
    CardType_Location -> deck.locations

set_cards_of_type : CardType -> List (Card, Int) -> Deck -> Deck
set_cards_of_type card_type cards deck = case card_type of
    CardType_House -> case cards of
        [] -> { deck | house = Nothing }
        ((first, _)::_) -> { deck | house = Just first }
    CardType_Agenda -> { deck | agendas = cards }
    CardType_Plot -> { deck | plots = cards }
    CardType_Character -> { deck | characters = cards }
    CardType_Attachment -> { deck | attachments = cards }
    CardType_Event -> { deck | events = cards }
    CardType_Location -> { deck | locations = cards }

add_card : Card -> Deck -> Deck
add_card card deck = 
    let
        add_card_to_category : Card -> List (Card, Int) -> List (Card, Int)
        add_card_to_category = \c cards -> case List.Extra.findIndex (\(cc, _) -> cc.id == c.id) cards of
            Just index -> cards |> List.Extra.updateAt index (\(cc, amount) -> (cc, min (amount + 1) cc.limit))
            Nothing -> (c, 1) :: cards |> List.sortBy (\(cc, _) -> (cc.cost |> Maybe.withDefault -1, CardSet.set_sort_order cc.set, cc.number))
        cards_after = add_card_to_category card (cards_of_type card.card_type deck)
    in
        set_cards_of_type card.card_type cards_after deck

remove_card : Card -> Int -> Deck -> Deck
remove_card card amount deck = if amount <= 0
    then deck
    else 
        let
            cards = cards_of_type card.card_type deck
            maybe_index = List.Extra.findIndex (\(c, _) -> c.id == card.id) cards
        in
            case maybe_index of
                Nothing -> deck
                Just index -> cards
                    |> List.Extra.updateAt index (\(c, a) -> (c, max 0 (a - amount)))
                    |> List.filter (\(_, a) -> a > 0)
                    |> \cards_after -> set_cards_of_type card.card_type cards_after deck

number_of_cards_in_main_deck : Deck -> Int
number_of_cards_in_main_deck deck = List.length deck.characters + List.length deck.attachments + List.length deck.events + List.length deck.locations
