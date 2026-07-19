module DeckLegality exposing (is_legal)

import Card exposing (Card, CardType(..), Legality(..))
import Cards
import Deck exposing (Deck)
import Utils

import Maybe.Extra
import List.Extra
import Dict

is_legal : Deck -> List String
is_legal deck =
    let
        predicates = 
            [ \d -> if Maybe.Extra.isJust d.house then [] else [ "You forgot to pick a house card." ]
            , rule_number_of_agendas
            , rule_number_of_plots
            , rule_card_copy_limit
            , rule_deck_size_limit
            , rule_cards_belong_to_house
            , rule_dark_wings_dark_words_event_limit
            , rule_joust_banned
            , rule_joust_restricted
            , rule_melee_banned
            , rule_melee_restricted
            ]
    in
        predicates
            |> List.map (\p -> p deck)
            |> List.concat

has_card : String -> Deck -> Bool
has_card card_id deck = case card_with_id card_id of
    Nothing -> False
    Just card -> Deck.has_card card deck

card_with_id : String -> Maybe Card
card_with_id id = Cards.all_cards
    |> List.Extra.find (\c -> c.id == id)

extra_context : Bool -> String -> String -> String
extra_context pred extra msg = if pred
    then msg ++ extra
    else msg

rule_number_of_agendas : Deck -> List String
rule_number_of_agendas deck =
    let
        agendas = Deck.cards_of_type CardType_Agenda deck
        north_agendas = List.Extra.count (\(card, _) -> card.traits |> List.Extra.elemIndex "The North" |> Maybe.Extra.isJust) agendas
        non_north_agendas = List.Extra.count (\(card, _) -> card.traits |> List.Extra.elemIndex "The North" |> Maybe.Extra.isNothing) agendas
    in
        if List.length agendas == 0 || List.length agendas == 1
            then []
            -- Not necessarily illegal because The North agendas allow playing more than 1 agenda
            else if north_agendas == 0
                then [ "A deck cannot have more than one agenda (except for The North agendas)" ]
                else if non_north_agendas > 0
                    then [ "A deck cannot mix The North agendas with other kinds of agendas" ]
                    else let
                            is_night_watch = has_card "dotn_19" deck || has_card "dotn_59" deck || has_card "dotn_99" deck
                            is_wildling = has_card "dotn_39" deck || has_card "dotn_79" deck || has_card "dotn_119" deck
                        in if is_night_watch && is_wildling
                            then [ "A deck cannot mix Night's Watch and Wildling agendas. When playing with The North agendas, you can either play Night's Watch agendas (The Rangers, The Builders, The Stewards) or Wildling agendas (The Free Folk, The Last Giants, Blood of the First Men), but you cannot mix them." ]
                            else []

rule_number_of_plots : Deck -> List String
rule_number_of_plots deck =
    let
        defiance = if has_card "cad_2" deck then 3 else 0
        betrayal_at_the_wall = if has_card "kr_79" deck then 1 else 0
        allowed_number_of_plots = 7 + defiance + betrayal_at_the_wall
        number_of_plots = Deck.count_cards <| Deck.cards_of_type CardType_Plot deck
    in if number_of_plots == allowed_number_of_plots
        then []
        else "The number of plot cards in your deck is not allowed. Your deck has " ++ String.fromInt number_of_plots ++ " plot card" ++ Utils.plural number_of_plots ++ ", when it should have " ++ String.fromInt allowed_number_of_plots ++ "."
            |> extra_context (defiance > 0 || betrayal_at_the_wall > 0) " A deck usually should have 7 plot cards. However, in your case, because you are playing "
            |> extra_context (defiance > 0) "\"Defiance\" as your agenda, you need to have 3 extra plot cards"
            |> extra_context (defiance > 0 && betrayal_at_the_wall > 0) " and because you are playing "
            |> extra_context (betrayal_at_the_wall > 0) "the plot card \"Betrayal at the Wall\", you need to have one extra plot card"
            |> extra_context (defiance > 0 || betrayal_at_the_wall > 0) "."
            |> List.singleton

rule_card_copy_limit : Deck -> List String
rule_card_copy_limit deck =
    let
        cards_by_name = List.foldl
            (\(card, amount) dict -> dict |> Dict.update card.name (\v -> case v of
                Nothing -> Just [ (card, amount) ]
                Just list -> Just ((card, amount) :: list)
            ))
            Dict.empty
            (Deck.all_cards deck)
        limit_of cards = case cards of
            [] -> 3
            (card, _)::_ -> card.limit
    in
        cards_by_name
            |> Dict.toList
            |> List.filterMap (\(name, cards) -> 
                let
                    count = Deck.count_cards cards
                    limit = limit_of cards
                    format_one = \(card, amount) -> if amount == 1
                        then "1 copy of \"" ++ card.name ++ "\" (" ++ card.id ++ ")"
                        else String.fromInt amount ++ " copies of \"" ++ card.name ++ "\" (" ++ card.id ++ ")"
                    format_human_readable = (\card_list -> card_list |> List.reverse |> List.map format_one |> Utils.join_human_readable)
                in if count > limit
                    then "You have " ++ String.fromInt count ++ " cards named " ++ name ++ " but the limit is " ++ String.fromInt limit ++ "."
                        |> extra_context (List.length cards > 1) (" A deck may have a maximum of three cards with the same name, even if they are different cards. You have " ++ format_human_readable cards ++ " to a total of " ++ String.fromInt count ++ " cards, which is above the limit of " ++ String.fromInt limit ++ ".")
                        |> Just
                    else Nothing
            )

rule_deck_size_limit : Deck -> List String
rule_deck_size_limit deck =
    let
        the_long_voyage = has_card "asots_60" deck
        dark_wings_dark_words = has_card "cad_80" deck
        deck_minimum_size = if the_long_voyage then 85 else if dark_wings_dark_words then 75 else 60
        deck_size = Deck.number_of_cards_in_main_deck deck
    in if deck_size >= deck_minimum_size
        then []
        else "Your main deck has " ++ String.fromInt deck_size ++ " card" ++ Utils.plural deck_size ++ " but the minimum size is " ++ String.fromInt deck_minimum_size ++ "."
            |> extra_context the_long_voyage " Regular deck limit is 60 cards but you are playing the agenda \"The Long Voyage\" that increases the limit to 85."
            |> extra_context (dark_wings_dark_words && not the_long_voyage) " Regular deck limit is 60 cards but you are playing the agenda \"Dark Wings, Dark Words\" that increases the limit to 75."
            |> List.singleton

rule_cards_belong_to_house : Deck -> List String
rule_cards_belong_to_house deck = 
    let
        city_of_shadows = has_card "kl_20" deck
    in
        case Deck.house deck of
            Nothing -> []
            Just house -> Deck.all_cards deck
                |> List.filterMap (\(card, _) -> if (card.legal_in_houses |> List.Extra.elemIndex house |> Maybe.Extra.isJust) || (city_of_shadows && Card.is_shadow card)
                    then Nothing
                    else Just <| "Card " ++ card.name ++ " is only allowed in decks of house " ++ (card.legal_in_houses |> List.map Card.house_to_string |> Utils.join_human_readable) ++ " but your deck has house " ++ Card.house_to_string house ++ "."
                )

rule_dark_wings_dark_words_event_limit : Deck -> List String
rule_dark_wings_dark_words_event_limit deck = if not (has_card "cad_80" deck)
    then []
    else deck.events
        |> List.filter (\(_, amount) -> amount > 1)
        |> List.map (\(card, amount) -> "Since you are playing the agenda \"Dark Wings, Dark Words\", you cannot have more than one copy of each event card in your deck. However, you have " ++ String.fromInt amount ++ " copies of \"" ++ card.name ++ "\".") 

rule_restricted : Deck -> Bool -> String -> (Card -> Legality) -> List String
rule_restricted deck deck_targets_format format_name card_legality = if not deck_targets_format
    then []
    else 
        let
            restricted_cards = Deck.all_cards deck 
                |> List.filter (\(card, _) -> card_legality card == Legality_Restricted)
                |> List.map (\(card, _) -> "\"" ++ card.name ++ "\"")
        in if List.length restricted_cards <= 1
            then []
            else "You have " ++ String.fromInt (List.length restricted_cards) ++ " cards that are restricted in " ++ format_name ++ " format. Your deck cannot contain more than one different restricted card, but you can have any number of copies of that card. The restricted cards in yor deck are " ++ Utils.join_human_readable restricted_cards ++ "."
                |> List.singleton


rule_banned : Deck -> Bool -> String -> (Card -> Legality) -> List String
rule_banned deck deck_targets_format format_name card_legality = if not deck_targets_format
    then []
    else 
        let
            banned_cards = Deck.all_cards deck 
                |> List.filter (\(card, _) -> card_legality card == Legality_Banned)
                |> List.map (\(card, _) -> "\"" ++ card.name ++ "\"")
            banned_card_count = List.length banned_cards
        in if banned_card_count <= 0
            then []
            else "You have " ++ String.fromInt banned_card_count ++ " card" ++ Utils.plural banned_card_count ++ " that " ++ Utils.plural_form banned_card_count "is" "are" ++ " banned in " ++ format_name ++ " format. The banned card" ++ Utils.plural banned_card_count ++ " " ++ Utils.plural_form banned_card_count "is" "are" ++ " " ++ Utils.join_human_readable banned_cards ++ "."
                |> List.singleton

rule_joust_banned : Deck -> List String
rule_joust_banned deck = rule_banned deck deck.joust "Joust" .legality_joust

rule_joust_restricted : Deck -> List String
rule_joust_restricted deck = rule_restricted deck deck.joust "Joust" .legality_joust

rule_melee_banned : Deck -> List String
rule_melee_banned deck = rule_banned deck deck.melee "Melee" .legality_melee

rule_melee_restricted : Deck -> List String
rule_melee_restricted deck = rule_restricted deck deck.melee "Melee" .legality_melee
