module Decks.DeckView exposing (deck_view, card_preview, deck_legality_diagnostics, view_deck_as_card_images)

import Card exposing (Card, CardId)
import CardSet exposing (SetOrCycle(..))
import Colors
import Decks.Deck as Deck exposing (Deck)
import Decks.DeckLegality as DeckLegality
import Fontawesome
import Utils
import Widgets
import Window exposing (Window)

import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Events as UI_Events
import Element.Input as UI_Input
import Element.Font as UI_Font
import List.Extra

type alias Messages msg =
    { hover_card : CardId -> msg
    , stop_hover : msg
    , add_card : Maybe (Card -> msg)
    , remove_card : Maybe (Card -> msg)
    }

mock_window : Window
mock_window = { width = 1920, height = 1080 }

deck_view : CardId -> Deck -> Messages msg -> UI.Element msg
deck_view hovered_card_id deck messages = UI.row [ UI.width UI.fill, UI.spacing 20 ]
    [ UI.column [ UI.width UI.fill, UI.alignTop ]
        [ deck_category "House" (Deck.house_card_as_list deck) hovered_card_id Nothing messages UI.onRight
        , deck_category "Agenda" deck.agendas hovered_card_id Nothing messages UI.onRight
        , deck_category "Plots" deck.plots hovered_card_id Nothing messages UI.onRight
        , deck_category "Characters" deck.characters hovered_card_id (Just <| Deck.number_of_cards_in_main_deck deck) messages UI.onRight
        ]
    , UI.column [ UI.width UI.fill, UI.alignTop ]
        [ deck_category "Attachments" deck.attachments hovered_card_id (Just <| Deck.number_of_cards_in_main_deck deck) messages UI.onLeft
        , deck_category "Events" deck.events hovered_card_id (Just <| Deck.number_of_cards_in_main_deck deck) messages UI.onLeft
        , deck_category "Locations" deck.locations hovered_card_id (Just <| Deck.number_of_cards_in_main_deck deck) messages UI.onLeft
        ]
    ]

deck_category : String -> List (Card, Int) -> CardId -> Maybe Int -> Messages msg -> (UI.Element msg -> UI.Attribute msg) -> UI.Element msg
deck_category name cards hovered_card_id total messages preview_pos = UI.column [ UI.width UI.fill, UI.paddingEach { top = 20, bottom = 0, left = 0, right = 0 }, UI.spacing 5 ]
    <| (deck_category_heading name (Deck.count_cards cards) total) :: (List.map (card_row hovered_card_id messages preview_pos) cards)

deck_category_heading : String -> Int -> Maybe Int -> UI.Element msg
deck_category_heading name card_amount total = UI.row [ UI.width UI.fill ]
    [ UI.el [ UI_Font.bold, UI_Font.size 15 ] (UI.text name)
    , UI.el [ UI_Font.size 12, UI.alignRight ] <| UI.text <| case total of
        Nothing -> String.fromInt card_amount ++ " card" ++ Utils.plural card_amount
        Just t -> String.fromInt card_amount ++ "/" ++ String.fromInt t ++ " cards"
    ]

card_amount_button_style_attributes : List (UI.Attribute msg)
card_amount_button_style_attributes = 
    [ UI.width (px 20)
    , UI.mouseOver 
        [ UI_Background.color Colors.background_hover
        , UI_Border.color Colors.border_hover
        ]
    ]


card_row : CardId -> Messages msg -> (UI.Element msg -> UI.Attribute msg) -> (Card, Int) -> UI.Element msg
card_row hovered_card_id messages preview_pos (card, amount) = UI.row
    [ UI.spacing 10
    , UI.width UI.fill
    , UI_Events.onMouseEnter <| messages.hover_card card.id
    , UI_Events.onMouseLeave <| messages.stop_hover
    , preview_pos <| if hovered_card_id == card.id then card_preview card else UI.none
    ]
    [ add_remove_card_buttons card messages
    , UI.text <| String.fromInt amount
    , Widgets.set_icon [] (SetOrCycle_Set card.set)
    , UI.el [ UI.width (px 30), UI_Font.size 12 ] <| UI.text <| "#" ++ String.fromInt card.number
    , UI.text card.name
    , Widgets.cost_widget [ UI.alignRight ] 20 card.cost (Card.is_shadow card)
    ]

add_remove_card_buttons : Card -> Messages msg -> UI.Element msg
add_remove_card_buttons card messages = case (messages.add_card, messages.remove_card) of
    (Just add_card, Just remove_card) -> UI.column [ UI_Font.size 12 ]
        [ UI_Input.button card_amount_button_style_attributes { onPress = Just <| add_card card, label = Fontawesome.text [ UI.centerX ] "\u{f0d8}" } -- fa-caret_up
        , UI_Input.button card_amount_button_style_attributes { onPress = Just <| remove_card card, label = Fontawesome.text [ UI.centerX ] "\u{f0d7}" } -- fa-caret-down
        ]
    _ -> UI.none

card_preview : Card -> UI.Element msg
card_preview card = UI.image [] { src = Card.preview_image_absolute_url card, description = card.name }

deck_legality_diagnostics : Deck -> UI.Element msg
deck_legality_diagnostics deck = case DeckLegality.is_legal deck of
    [] -> UI.column
        [ UI_Border.width 1
        , UI_Border.color (UI.rgb255 31 163 70)
        , UI_Border.rounded 25
        , UI_Background.color (UI.rgb255 17 89 38)
        , UI.width UI.fill
        , UI.padding 20
        ]
        [ if deck.joust && deck.melee
            then UI.paragraph [ UI_Font.justify ] [ UI.text "Your deck is legal in both joust and melee." ]
            else if deck.joust
                then UI.paragraph [ UI_Font.justify ] [ UI.text "Your deck is legal in joust." ]
                else if deck.melee
                    then UI.paragraph [ UI_Font.justify ] [ UI.text "Your deck is legal in melee." ]
                    else UI.paragraph [ UI_Font.justify ] [ UI.text "Your deck is legal according to general legality rules, but you forgot to pick a format." ]
        ]
    errors -> UI.column
        [ UI_Border.width 1
        , UI_Border.color (UI.rgb255 150 0 0)
        , UI_Border.rounded 25
        , UI_Background.color (UI.rgb255 80 0 0)
        , UI.width UI.fill
        , UI.padding 20
        , UI.spacing 20
        ]
        <| List.map (\err -> UI.paragraph [ UI_Font.justify ] [ UI.text err ]) errors

view_deck_as_card_images : Deck -> UI.Element msg
view_deck_as_card_images deck = UI.column [ UI.spacing 20, UI.width UI.fill ]
    [ view_card_images (Deck.expand (Deck.house_card_as_list deck ++ deck.agendas)) min_vertical_card_width max_vertical_card_width mock_window
    , view_card_images (Deck.expand deck.plots) min_horizontal_card_width max_horizontal_card_width mock_window
    , view_card_images (Deck.expand deck.characters) min_vertical_card_width max_vertical_card_width mock_window
    , view_card_images (Deck.expand deck.attachments) min_vertical_card_width max_vertical_card_width mock_window
    , view_card_images (Deck.expand deck.events) min_vertical_card_width max_vertical_card_width mock_window
    , view_card_images (Deck.expand deck.locations) min_vertical_card_width max_vertical_card_width mock_window
    ]

view_card_images : List Card -> Int -> Int -> Window -> UI.Element msg
view_card_images cards min_width max_width window = 
    let
        column_width = min (window.width - 20) 1000
        column_count = column_count_for min_width column_width
        cards_in_rows = List.Extra.greedyGroupsOf column_count cards
        card_width = min max_width (card_width_for column_count column_width)
    in
        if List.isEmpty cards
            then UI.none
            else cards_in_rows
                |> List.map (view_row_of_card_images column_count card_width)
                |> List.map (UI.el [ UI.width (px column_width), UI.centerX ] << UI.row [ UI.spacing 6, UI.centerX ])
                |> UI.column [ UI.spacing 9, UI.width UI.fill ]

view_row_of_card_images : Int -> Int -> List Card -> List (UI.Element msg)
view_row_of_card_images column_count card_width cards = 
    let
        card_widgets = List.map (view_card card_width) cards
        dummy = UI.el [ UI.width (px card_width) ] UI.none
        dummies = List.repeat (column_count - List.length cards) dummy
    in
        card_widgets ++ dummies

view_card : Int -> Card -> UI.Element msg
view_card width card = UI.link []
    { label = UI.image 
        [ UI.width (px width)
        , UI_Border.rounded 10
        , UI.clip
        ] 
        { src = Card.preview_image_absolute_url card
        , description = card.name
        }
    , url = Card.page_absolute_url card
    }

card_padding : Int
card_padding = 8
max_vertical_card_width : Int
max_vertical_card_width = 245
min_vertical_card_width : Int
min_vertical_card_width = 180
max_horizontal_card_width : Int
max_horizontal_card_width = 345
min_horizontal_card_width : Int
min_horizontal_card_width = 300

column_width_for : Int -> Int -> Int
column_width_for min_card_width card_count = min_card_width * card_count + card_padding * (card_count - 1)

column_count_for : Int -> Int -> Int
column_count_for min_card_width column_width = 
    if column_width >= column_width_for min_card_width 4 then -- 815
        4
    else if column_width >= column_width_for min_card_width 3 then -- 610
        3
    else if column_width >= column_width_for min_card_width 2 then -- 405
        2
    else
        1

card_width_for : Int -> Int -> Int
card_width_for column_count column_width = (column_width - (column_count - 1) * card_padding) // column_count
