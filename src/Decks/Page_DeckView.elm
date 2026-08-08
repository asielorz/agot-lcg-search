module Decks.Page_DeckView exposing  (main)

import Decks.Deck as Deck exposing (Deck)
import Decks.DeckView as DeckView
import Widgets

import Browser
import Element as UI exposing (px)
import Element.Input as UI_Input
import Element.Font as UI_Font

main : Program () Model Msg
main = Browser.document 
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

type alias Model =
    { deck : Deck
    , hovered_card_id : String
    }

init : () -> (Model, Cmd Msg)
init = \_ -> 
    (   { deck = Deck.test_deck
        , hovered_card_id = ""
        }
    , Cmd.none
    )

type Msg
    = Msg_Noop
    | Msg_HoverCard String
    | Msg_StopHover

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Msg_Noop -> (model, Cmd.none)
    Msg_HoverCard card_id -> ({ model | hovered_card_id = card_id }, Cmd.none)
    Msg_StopHover -> ({ model | hovered_card_id = "" }, Cmd.none)

view : Model -> Browser.Document Msg
view model = Widgets.layout 
    ("AGoT LCG deck view"
    , deck_view model.deck model.hovered_card_id
    )

deck_view : Deck -> String -> UI.Element Msg
deck_view deck hovered_card_id = 
    UI.column 
        [ UI.width <| UI.maximum 800 UI.fill
        , UI.centerX
        , UI_Font.size 16
        , UI.spacing 10
        ]
        [ UI.paragraph
            [ UI_Font.size 20
            , UI.clip
            ]
            [ UI.text deck.name
            ]
        , UI.paragraph
            [ UI_Font.size 15
            , UI.height <| UI.maximum 200 UI.shrink
            , UI.scrollbarY
            ]
            [ UI.text deck.description
            ]
        , UI.row [ UI.spacing 40 ]
            [ UI.text "Format"
            , UI_Input.checkbox [] { onChange = always Msg_Noop, checked = deck.joust, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Joust") }
            , UI_Input.checkbox [] { onChange = always Msg_Noop, checked = deck.melee, icon = UI_Input.defaultCheckbox, label = UI_Input.labelLeft [] (UI.text "Melee") }
            ]
        , DeckView.deck_view hovered_card_id deck { hover_card = Msg_HoverCard, stop_hover = Msg_StopHover, add_card = Nothing, remove_card = Nothing }
        , UI.el [ UI.height (px 30) ] UI.none
        , DeckView.deck_legality_diagnostics deck
        ]
