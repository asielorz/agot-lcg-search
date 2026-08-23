module Decks.Deck exposing (..)

import Card exposing (Card, CardId(..), CardType(..))
import CardExtra
import CardSet

import List.Extra
import Card exposing (House(..))

type alias Deck = 
    { name : String
    , description : String
    , joust : Bool
    , melee : Bool
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
    , joust = False
    , melee = False
    , house = Nothing
    , agendas = []
    , plots = []
    , characters = []
    , attachments = []
    , events = []
    , locations = []
    }

rename : String -> Deck -> Deck
rename name deck = { deck | name = String.left 100 name }

change_description : String -> Deck -> Deck
change_description description deck = { deck | description = String.left 5000 description }

make_legal_in_joust : Bool -> Deck -> Deck
make_legal_in_joust joust deck = { deck | joust = joust }

make_legal_in_melee : Bool -> Deck -> Deck
make_legal_in_melee melee deck = { deck | melee = melee }

cards_of_type : CardType -> Deck -> List (Card, Int)
cards_of_type card_type deck = case card_type of
    CardType_House -> house_card_as_list deck
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
            Nothing -> (c, 1) :: cards |> List.sortBy (\(cc, amount) -> (Card.cost_sort_order cc, -amount, Card.set_sort_order cc))
        cards_after = if card.card_type == CardType_House
            then [ (card, 1) ]
            else add_card_to_category card (cards_of_type card.card_type deck)
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

has_card : Card -> Deck -> Bool
has_card card deck = cards_of_type card.card_type deck
    |> List.any (\(c, _) -> c.id == card.id)

number_of_cards_in_main_deck : Deck -> Int
number_of_cards_in_main_deck deck =
    count_cards deck.characters + count_cards deck.attachments + count_cards deck.events + count_cards deck.locations

house_card_as_list : Deck -> List (Card, Int)
house_card_as_list deck = case deck.house of
    Nothing -> []
    Just card -> [(card, 1)]

count_cards : List (Card, Int) -> Int
count_cards cards = cards |> List.map (\(_, n) -> n) |> List.sum

all_cards : Deck -> List (Card, Int)
all_cards deck = house_card_as_list deck ++ deck.agendas ++ deck.plots ++ deck.characters ++ deck.attachments ++ deck.events ++ deck.locations

house : Deck -> Maybe House
house deck = deck.house
    |> Maybe.map (\card -> card.house |> List.head |> Maybe.withDefault House_Neutral)

-- TODO: Remove this
test_deck : Deck
test_deck =
    let
        card_with_id : CardId -> Card
        card_with_id id = CardExtra.card_with_id id
            |> Maybe.withDefault { id = CardId "", name = "", card_type = Card.CardType_Attachment, set = CardSet.Set_Core, number = 1, quantity = 1, limit = 3, legality_joust = Card.Legality_Legal, legality_melee = Card.Legality_Legal, illustrator = "", house = [], legal_in_houses = [], unique = True, rules_text = Nothing, flavor_text = Nothing, cost = Nothing, icons = [], crest = [], traits = [], strength = Nothing, income = Nothing, initiative = Nothing, claim = Nothing, influence = Nothing, erratas = [], duplicate_id = Nothing }
    in
        { empty | name = "Stark Asedio", description = "Mazo de asedio de Invernalia. Midrange. Va de controlar la mesa.", joust = True }
            |> add_card (card_with_id <| CardId "core_209")
            |> add_card (card_with_id <| CardId "low_48")
            |> add_card (card_with_id <| CardId "asots_59")
            |> add_card (card_with_id <| CardId "core_206")
            |> add_card (card_with_id <| CardId "core_200")
            |> add_card (card_with_id <| CardId "core_201")
            |> add_card (card_with_id <| CardId "qod_49")
            |> add_card (card_with_id <| CardId "low_53")
            |> add_card (card_with_id <| CardId "low_55")
            |> add_card (card_with_id <| CardId "pots_38")
            |> add_card (card_with_id <| CardId "ator_83")
            |> add_card (card_with_id <| CardId "ator_83")
            |> add_card (card_with_id <| CardId "ator_83")
            |> add_card (card_with_id <| CardId "dotn_81")
            |> add_card (card_with_id <| CardId "ator_16")
            |> add_card (card_with_id <| CardId "ator_16")
            |> add_card (card_with_id <| CardId "ator_16")
            |> add_card (card_with_id <| CardId "low_8")
            |> add_card (card_with_id <| CardId "core_2")
            |> add_card (card_with_id <| CardId "core_29")
            |> add_card (card_with_id <| CardId "core_29")
            |> add_card (card_with_id <| CardId "core_29")
            |> add_card (card_with_id <| CardId "kotst_45")
            |> add_card (card_with_id <| CardId "kotst_45")
            |> add_card (card_with_id <| CardId "kotst_45")
            |> add_card (card_with_id <| CardId "low_18")
            |> add_card (card_with_id <| CardId "low_18")
            |> add_card (card_with_id <| CardId "low_18")
            |> add_card (card_with_id <| CardId "low_47")
            |> add_card (card_with_id <| CardId "low_47")
            |> add_card (card_with_id <| CardId "low_47")
            |> add_card (card_with_id <| CardId "kotse_38")
            |> add_card (card_with_id <| CardId "kotse_38")
            |> add_card (card_with_id <| CardId "kotse_38")
            |> add_card (card_with_id <| CardId "kl_2")
            |> add_card (card_with_id <| CardId "kl_2")
            |> add_card (card_with_id <| CardId "kl_2")
            |> add_card (card_with_id <| CardId "ator_103")
            |> add_card (card_with_id <| CardId "ator_103")
            |> add_card (card_with_id <| CardId "ator_103")
            |> add_card (card_with_id <| CardId "bwb_21")
            |> add_card (card_with_id <| CardId "bwb_21")
            |> add_card (card_with_id <| CardId "bwb_21")
            |> add_card (card_with_id <| CardId "atoc_82")
            |> add_card (card_with_id <| CardId "atoc_82")
            |> add_card (card_with_id <| CardId "atoc_82")
            |> add_card (card_with_id <| CardId "kotse_45")
            |> add_card (card_with_id <| CardId "kl_1")
            |> add_card (card_with_id <| CardId "bwb_101")
            |> add_card (card_with_id <| CardId "atoc_101")
            |> add_card (card_with_id <| CardId "kl_61")
            |> add_card (card_with_id <| CardId "kl_97")
            |> add_card (card_with_id <| CardId "kr_54")
            |> add_card (card_with_id <| CardId "kr_93")
            |> add_card (card_with_id <| CardId "cad_18")
            |> add_card (card_with_id <| CardId "acoa_101")
            |> add_card (card_with_id <| CardId "acoa_101")
            |> add_card (card_with_id <| CardId "w_92")
            |> add_card (card_with_id <| CardId "kl_77")
            |> add_card (card_with_id <| CardId "acoa_65")
            |> add_card (card_with_id <| CardId "low_22")
            |> add_card (card_with_id <| CardId "pots_37")
            |> add_card (card_with_id <| CardId "soo_21")
            |> add_card (card_with_id <| CardId "soo_1")
            |> add_card (card_with_id <| CardId "pots_39")
            |> add_card (card_with_id <| CardId "core_5")
            |> add_card (card_with_id <| CardId "low_7")
            |> add_card (card_with_id <| CardId "core_139")
            |> add_card (card_with_id <| CardId "qod_43")
