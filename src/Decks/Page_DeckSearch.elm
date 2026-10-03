module Decks.Page_DeckSearch exposing  (main)

import Card exposing (House, CardId(..))
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
    { house_stark : Bool
    , house_lannister : Bool
    , house_baratheon : Bool
    , house_targaryen : Bool
    , house_greyjoy : Bool
    , house_martell : Bool
    , house_neutral : Bool
    , cards_included : List CardId
    , cards_excluded : List CardId
    , hovered_card_id : CardId
    , included_search_box : String
    , excluded_search_box : String
    }

init : () -> (Model, Cmd Msg)
init = \_ -> 
    (   { house_stark = False
        , house_lannister = False
        , house_baratheon = False
        , house_targaryen = False
        , house_greyjoy = False
        , house_martell = False
        , house_neutral = False
        , cards_included = []
        , cards_excluded = []
        , hovered_card_id = CardId ""
        }
    , Cmd.none
    )

type Msg
    = Msg_Noop
    | Msg_HoverCard CardId
    | Msg_StopHover
    | Msg_CheckboxStark Bool
    | Msg_CheckboxBaratheon Bool
    | Msg_CheckboxLannister Bool
    | Msg_CheckboxTargaryen Bool
    | Msg_CheckboxGreyjoy Bool
    | Msg_CheckboxMartell Bool
    | Msg_CheckboxNeutral Bool
    | Msg_AddCardIncluded CardId
    | Msg_RemoveCardIncluded CardId
    | Msg_AddCardExcluded CardId
    | Msg_RemoveCardExcluded CardId


-- TO DO
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    _ -> (model, Cmd.none)


view : Model -> Browser.Document Msg
view model = Widgets.layout 
    ("AGoT LCG deck view"
    , UI.text "TO DO"
    )
