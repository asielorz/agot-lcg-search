module Page_Card exposing (Model, Msg, init, update, view)

import Card exposing (Card, CardType(..))
import Query
import Widgets

import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Border as UI_Border

type alias Model = 
    { card : Card
    , header_query : String
    }

type Msg 
    = Msg_QueryChange String
    | Msg_Search

init : Card -> Model
init card = 
    { card = card
    , header_query = ""
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChange new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { query = model.header_query, sort = [], page = 0 })

view : Model -> (String, UI.Element Msg)
view model = 
    ( model.card.name ++ " - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        ]
        [ Widgets.header model.header_query Msg_QueryChange Msg_Search
        , view_card model.card
        ]
    )

view_card : Card -> UI.Element Msg
view_card card = 
    let
        (width, height) = if card.card_type == CardType_Plot then (600, 420) else (420, 600)
    in
        UI.row [ UI.centerX, UI.spacing 10 ]
            [ UI.image 
                [ UI_Border.rounded 10
                , UI.clip
                , UI.width (px width)
                , UI.height (px height)
                , UI.alignTop 
                ] { src = Card.image_url card, description = card.name }
            , UI.column [ UI.alignTop ]
                [ UI.text <| "Name: " ++ card.name
                , UI.text <| "Type: " ++ Card.card_type_to_string card.card_type
                ]
            ]
