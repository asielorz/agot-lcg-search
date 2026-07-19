module Page_DeckEditor exposing (main)

import Card exposing (Card)
import CardSet exposing (SetOrCycle(..))
import Cards
import Colors
import Deck exposing (Deck)
import DeckLegality
import Utils
import Widgets

import Browser
import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Events as UI_Events
import Element.Input as UI_Input
import Element.Font as UI_Font
import Fontawesome
import List.Extra
import Url.Parser exposing (query)

main : Program () Model Msg
main = Browser.document 
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

type alias SearchState =
    { candidates : List Card
    , index : Int
    }

type alias Model =
    { deck : Deck
    , search_buffer : String
    , search_state : Maybe SearchState
    , hovered_card_id : String
    }

init : () -> (Model, Cmd Msg)
init = \_ -> 
    (   { deck = Deck.empty
        , search_buffer = ""
        , search_state = Nothing 
        , hovered_card_id = ""
        }
    , Cmd.none
    )

type Msg 
    = Msg_Noop
    | Msg_ChangeName String
    | Msg_ChangeDescription String
    | Msg_ChangeFormatJoust Bool
    | Msg_ChangeFormatMelee Bool
    | Msg_ChangeSearch String
    | Msg_FocusSearch
    | Msg_UnfocusSearch
    | Msg_SearchSelectedScroll Int
    | Msg_SearchSelect Int
    | Msg_AddCurrent
    | Msg_HoverCard String
    | Msg_StopHover
    | Msg_AddCard Card
    | Msg_RemoveCard Card Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Msg_Noop -> (model, Cmd.none)
    Msg_ChangeName new_name -> ({ model | deck = Deck.rename new_name model.deck }, Cmd.none)
    Msg_ChangeDescription new_description -> ({ model | deck = Deck.change_description new_description model.deck }, Cmd.none)
    Msg_ChangeFormatJoust joust -> ({ model | deck = Deck.make_legal_in_joust joust model.deck }, Cmd.none)
    Msg_ChangeFormatMelee melee -> ({ model | deck = Deck.make_legal_in_melee melee model.deck }, Cmd.none)
    Msg_ChangeSearch new_buffer -> (update_search_state new_buffer model, Cmd.none)
    Msg_FocusSearch -> (update_search_state model.search_buffer model, Cmd.none)
    Msg_UnfocusSearch -> ({ model | search_state = Nothing }, Cmd.none)
    Msg_SearchSelectedScroll scroll -> ({ model | search_state = scroll_search_state scroll model.search_state }, Cmd.none)
    Msg_SearchSelect index -> ({ model | search_state = set_search_state_index index model.search_state }, Cmd.none)
    Msg_AddCurrent -> (add_current model, Cmd.none)
    Msg_HoverCard card_id -> ({ model | hovered_card_id = card_id }, Cmd.none)
    Msg_StopHover -> ({ model | hovered_card_id = "" }, Cmd.none)
    Msg_AddCard card -> ({ model | deck = Deck.add_card card model.deck }, Cmd.none)
    Msg_RemoveCard card amount -> ({ model | deck = Deck.remove_card card amount model.deck }, Cmd.none)

update_search_state : String -> Model -> Model
update_search_state new_buffer model = { model | search_buffer = new_buffer, search_state = make_search_state new_buffer model.deck model.search_state }

make_search_state : String -> Deck -> Maybe SearchState -> Maybe SearchState
make_search_state query deck prev_state =
    if String.isEmpty query
        then Just { candidates = [], index = 0 }
        else case prev_state of
            Nothing -> Just { candidates = search_candidates query deck, index = 0 }
            Just state ->
                let new_candidates = search_candidates query deck
                in Just { candidates = new_candidates, index = clamp_index new_candidates state.index }

set_search_state_index : Int -> Maybe SearchState -> Maybe SearchState
set_search_state_index new_index search_state = search_state |> Maybe.map
    (\state -> {state | index = clamp_index state.candidates new_index})

scroll_search_state : Int -> Maybe SearchState -> Maybe SearchState
scroll_search_state scroll search_state = search_state |> Maybe.map
    (\state -> {state | index = clamp_index state.candidates (state.index + scroll)})

clamp_index : List Card -> Int -> Int
clamp_index candidates index = clamp 0 (max 0 (List.length candidates - 1)) index

search_candidates : String -> Deck -> List Card
search_candidates query deck = 
    let
        query_lowercase = String.toLower query
        deduplicated_cards = List.Extra.uniqueBy Card.duplicate_id Cards.all_cards
    in
        deduplicated_cards
            |> List.filter (\card -> String.contains query_lowercase (String.toLower card.name))
            |> List.filter (\card -> not <| Deck.has_card card deck)
            |> List.take 10

add_current : Model -> Model
add_current model = case model.search_state of
    Nothing -> model
    Just state -> case List.Extra.getAt state.index state.candidates of
        Nothing -> model
        Just card -> { model | deck = Deck.add_card card model.deck } |> update_search_state ""

view : Model -> Browser.Document Msg
view model = Widgets.layout 
    ("AGoT LCG deck editor"
    , deck_editor model
    )

deck_editor : Model -> UI.Element Msg
deck_editor model = UI.column 
    [ UI.width <| UI.maximum 800 UI.fill
    , UI.centerX
    , UI_Font.size 16
    ]
    [ UI_Input.text
        [ UI_Background.color (UI.rgba 0 0 0 0)
        , UI_Border.width 0
        , UI_Font.size 20
        ]
        { text = model.deck.name
        , onChange = Msg_ChangeName
        , placeholder = Just <| UI_Input.placeholder [] (UI.text "Name your deck...")
        , label = UI_Input.labelHidden "Name"
        }
    , UI_Input.multiline
        [ UI_Background.color (UI.rgba 0 0 0 0)
        , UI_Border.width 0
        , UI_Font.size 15
        ]
        { text = model.deck.description
        , onChange = Msg_ChangeDescription
        , placeholder = Just <| UI_Input.placeholder [] (UI.text "Describe your deck...")
        , label = UI_Input.labelHidden "Description"
        , spellcheck = True
        }
    , UI.row [ UI.spacing 40, UI.padding 10 ]
        [ UI.text "Format"
        , UI_Input.checkbox [] { onChange = Msg_ChangeFormatJoust, checked = model.deck.joust, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Joust") }
        , UI_Input.checkbox [] { onChange = Msg_ChangeFormatMelee, checked = model.deck.melee, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Melee") }
        ]
    , Widgets.input_text 
        [ UI_Events.onFocus <| Msg_FocusSearch
        , UI_Events.onLoseFocus <| Msg_UnfocusSearch
        , UI.below <| candidate_list model.search_state
        , UI.onRight <| candidate_preview model.search_state
        , Widgets.on_key_down [("ArrowUp", Msg_SearchSelectedScroll -1), ("ArrowDown", Msg_SearchSelectedScroll 1)]
        ]
        model.search_buffer "Search for a card..." Msg_ChangeSearch Msg_AddCurrent
    , deck_view model
    , UI.el [ UI.height (px 30) ] UI.none
    , deck_legality_diagnostics model.deck
    ]

deck_view : Model -> UI.Element Msg
deck_view model = UI.row [ UI.width UI.fill, UI.spacing 20 ]
    [ UI.column [ UI.width UI.fill, UI.alignTop ]
        [ deck_category "House" (Deck.house_card_as_list model.deck) model.hovered_card_id Nothing
        , deck_category "Agenda" model.deck.agendas model.hovered_card_id Nothing
        , deck_category "Plots" model.deck.plots model.hovered_card_id Nothing
        , deck_category "Characters" model.deck.characters model.hovered_card_id (Just <| Deck.number_of_cards_in_main_deck model.deck)
        ]
    , UI.column [ UI.width UI.fill, UI.alignTop ]
        [ deck_category "Attachments" model.deck.attachments model.hovered_card_id (Just <| Deck.number_of_cards_in_main_deck model.deck)
        , deck_category "Events" model.deck.events model.hovered_card_id (Just <| Deck.number_of_cards_in_main_deck model.deck)
        , deck_category "Locations" model.deck.locations model.hovered_card_id (Just <| Deck.number_of_cards_in_main_deck model.deck)
        ]
    ]

deck_category : String -> List (Card, Int) -> String -> Maybe Int -> UI.Element Msg
deck_category name cards hovered_card_id total = UI.column [ UI.width UI.fill, UI.paddingEach { top = 20, bottom = 0, left = 0, right = 0 }, UI.spacing 5 ]
    <| (deck_category_heading name (Deck.count_cards cards) total) :: (List.map (card_row hovered_card_id) cards)

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


card_row : String -> (Card, Int) -> UI.Element Msg
card_row hovered_card_id (card, amount) = UI.row
    [ UI.spacing 10
    , UI.width UI.fill
    , UI_Events.onMouseEnter <| Msg_HoverCard card.id
    , UI_Events.onMouseLeave <| Msg_StopHover
    , UI.onRight <| if hovered_card_id == card.id then card_preview card else UI.none
    ]
    [ UI.column [ UI_Font.size 12 ]
        [ UI_Input.button card_amount_button_style_attributes { onPress = Just <| Msg_AddCard card, label = Fontawesome.text [ UI.centerX ] "\u{f0d8}" } -- fa-caret_up
        , UI_Input.button card_amount_button_style_attributes { onPress = Just <| Msg_RemoveCard card 1, label = Fontawesome.text [ UI.centerX ] "\u{f0d7}" } -- fa-caret-down
        ]
    , UI.text <| String.fromInt amount
    , Widgets.set_icon [] (SetOrCycle_Set card.set)
    , UI.el [ UI.width (px 30), UI_Font.size 12 ] <| UI.text <| "#" ++ String.fromInt card.number
    , UI.text card.name
    , Widgets.cost_widget [ UI.alignRight ] 20 card.cost (Card.is_shadow card)
    ]

candidate_list : Maybe SearchState -> UI.Element Msg
candidate_list search_state = case search_state of
    Nothing -> UI.none
    Just state -> if List.isEmpty state.candidates
        then UI.none
        else UI.column 
            [ UI.padding 5
            , UI.spacing 5
            , UI_Border.width 1
            , UI_Border.color Colors.border
            , UI_Background.color Colors.background
            , UI.width UI.fill
            ] 
            (List.indexedMap (\i c -> candidate c i (i == state.index)) state.candidates)

candidate : Card -> Int -> Bool -> UI.Element Msg
candidate card index focused = UI.row 
    [ UI.spacing 10
    , UI_Background.color <| if focused then (UI.rgb255 54 122 177) else Colors.background
    , UI.width UI.fill
    , UI_Events.onMouseEnter <| Msg_SearchSelect index
    , UI_Events.onClick <| Msg_AddCurrent
    ]
    [ Widgets.set_icon [] (SetOrCycle_Set card.set)
    , UI.el [ UI.width (px 30), UI_Font.size 12 ] <| UI.text <| "#" ++ String.fromInt card.number
    , UI.text card.name
    ]

candidate_preview : Maybe SearchState -> UI.Element msg
candidate_preview search_state = case search_state of
    Nothing -> UI.none
    Just state -> case List.Extra.getAt state.index state.candidates of
        Nothing -> UI.none
        Just card -> card_preview card

card_preview : Card -> UI.Element msg
card_preview card = UI.image [] { src = Card.preview_image_url card, description = card.name }

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
