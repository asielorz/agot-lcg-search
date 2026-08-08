module Decks.Page_DeckEditor exposing (main)

import Card exposing (Card)
import CardSet exposing (SetOrCycle(..))
import Cards
import ChangeStack exposing (ChangeStack)
import Colors
import Decks.Deck as Deck exposing (Deck)
import Decks.DeckView as DeckView
import Widgets

import Browser
import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Events as UI_Events
import Element.Input as UI_Input
import Element.Font as UI_Font
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
    { deck : ChangeStack Deck
    , search_buffer : String
    , search_state : Maybe SearchState
    , hovered_card_id : String
    }

init : () -> (Model, Cmd Msg)
init = \_ -> 
    (   { deck = ChangeStack.new Deck.empty
        , search_buffer = ""
        , search_state = Nothing 
        , hovered_card_id = ""
        }
    , Cmd.none
    )

type Msg 
    = Msg_Undo
    | Msg_Redo
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
    Msg_Undo -> ({ model | deck = ChangeStack.undo model.deck }, Cmd.none)
    Msg_Redo -> ({ model | deck = ChangeStack.redo model.deck }, Cmd.none)
    Msg_ChangeName new_name -> ({ model | deck = ChangeStack.update (Deck.rename new_name) model.deck }, Cmd.none)
    Msg_ChangeDescription new_description -> ({ model | deck = ChangeStack.update (Deck.change_description new_description) model.deck }, Cmd.none)
    Msg_ChangeFormatJoust joust -> ({ model | deck = ChangeStack.update (Deck.make_legal_in_joust joust) model.deck }, Cmd.none)
    Msg_ChangeFormatMelee melee -> ({ model | deck = ChangeStack.update (Deck.make_legal_in_melee melee) model.deck }, Cmd.none)
    Msg_ChangeSearch new_buffer -> (update_search_state new_buffer model, Cmd.none)
    Msg_FocusSearch -> (update_search_state model.search_buffer model, Cmd.none)
    Msg_UnfocusSearch -> ({ model | search_state = Nothing }, Cmd.none)
    Msg_SearchSelectedScroll scroll -> ({ model | search_state = scroll_search_state scroll model.search_state }, Cmd.none)
    Msg_SearchSelect index -> ({ model | search_state = set_search_state_index index model.search_state }, Cmd.none)
    Msg_AddCurrent -> (add_current model, Cmd.none)
    Msg_HoverCard card_id -> ({ model | hovered_card_id = card_id }, Cmd.none)
    Msg_StopHover -> ({ model | hovered_card_id = "" }, Cmd.none)
    Msg_AddCard card -> ({ model | deck = ChangeStack.update (Deck.add_card card) model.deck }, Cmd.none)
    Msg_RemoveCard card amount -> ({ model | deck = ChangeStack.update (Deck.remove_card card amount) model.deck }, Cmd.none)

update_search_state : String -> Model -> Model
update_search_state new_buffer model = { model | search_buffer = new_buffer, search_state = make_search_state new_buffer (ChangeStack.current model.deck) model.search_state }

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
        Just card -> { model | deck = ChangeStack.update (Deck.add_card card) model.deck } |> update_search_state ""

view : Model -> Browser.Document Msg
view model = Widgets.layout 
    ("AGoT LCG deck editor"
    , deck_editor model
    )

deck_editor : Model -> UI.Element Msg
deck_editor model = 
    let
        deck = ChangeStack.current model.deck
    in
        UI.column 
            [ UI.width <| UI.maximum 800 UI.fill
            , UI.centerX
            , UI_Font.size 16
            , Widgets.on_key_down 
                [ ("z", Widgets.modifiers_ctrl, Msg_Undo)
                , ("y", Widgets.modifiers_ctrl, Msg_Redo)
                ]
            ]
            [ UI_Input.text
                [ UI_Background.color (UI.rgba 0 0 0 0)
                , UI_Border.width 0
                , UI_Font.size 20
                ]
                { text = deck.name
                , onChange = Msg_ChangeName
                , placeholder = Just <| UI_Input.placeholder [] (UI.text "Name your deck...")
                , label = UI_Input.labelHidden "Name"
                }
            , UI_Input.multiline
                [ UI_Background.color (UI.rgba 0 0 0 0)
                , UI_Border.width 0
                , UI_Font.size 15
                ]
                { text = deck.description
                , onChange = Msg_ChangeDescription
                , placeholder = Just <| UI_Input.placeholder [] (UI.text "Describe your deck...")
                , label = UI_Input.labelHidden "Description"
                , spellcheck = True
                }
            , UI.row [ UI.spacing 40, UI.padding 10 ]
                [ UI.text "Format"
                , UI_Input.checkbox [] { onChange = Msg_ChangeFormatJoust, checked = deck.joust, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Joust") }
                , UI_Input.checkbox [] { onChange = Msg_ChangeFormatMelee, checked = deck.melee, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Melee") }
                ]
            , Widgets.input_text 
                [ UI_Events.onFocus <| Msg_FocusSearch
                , UI_Events.onLoseFocus <| Msg_UnfocusSearch
                , UI.below <| candidate_list model.search_state
                , Widgets.on_key_down [("ArrowUp", Widgets.no_modifiers, Msg_SearchSelectedScroll -1), ("ArrowDown", Widgets.no_modifiers, Msg_SearchSelectedScroll 1)]
                ]
                model.search_buffer "Search for a card..." Msg_ChangeSearch Msg_AddCurrent
            , DeckView.deck_view model.hovered_card_id deck { hover_card = Msg_HoverCard, stop_hover = Msg_StopHover, add_card = Just Msg_AddCard, remove_card = Just (\c -> Msg_RemoveCard c 1) }
            , UI.el [ UI.height (px 30) ] UI.none
            , DeckView.deck_legality_diagnostics deck
            ]

candidate_list : Maybe SearchState -> UI.Element Msg
candidate_list search_state = case search_state of
    Nothing -> UI.none
    Just state -> if List.isEmpty state.candidates
        then UI.none
        else UI.row [ UI.width UI.fill ]
            [ UI.column 
                [ UI.padding 5
                , UI.spacing 5
                , UI_Border.width 1
                , UI_Border.color Colors.border
                , UI_Background.color Colors.background
                , UI.width UI.fill
                , UI.alignTop
                ] 
                (List.indexedMap (\i c -> candidate c i (i == state.index)) state.candidates)
            , candidate_preview search_state
            ]

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
        Just card -> DeckView.card_preview card
