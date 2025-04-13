module Page_Start exposing (Model, Msg, init, update, view)

import Card
import Cards
import Query exposing (default_search_state)
import Widgets

import Browser.Navigation as Navigation
import Element as UI
import File.Download
import Json.Encode

type alias Model = 
    { query : String
    }

type Msg 
    = Msg_QueryChanged String
    | Msg_Search
    | Msg_DownloadJson

init : Model
init = { query = "" }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChanged new_query -> ({ model | query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key (Query.search_url { default_search_state | query = model.query }))
    Msg_DownloadJson -> (model, download_json)

download_json : Cmd msg
download_json = Cards.all_cards
    |> Json.Encode.list Card.card_to_json
    |> Json.Encode.encode 4
    |> File.Download.string "cards.json" "application/json"

view : Model -> (String, UI.Element Msg)
view model = 
    ( "A Game of Thrones LCG card search"
    , UI.column
        [ UI.width UI.fill
        , UI.height UI.fill
        , UI.spacing 20
        ]
        [ UI.column 
            [ UI.centerX
            , UI.centerY
           , UI.spacing 20
            ]
            [ UI.image [ UI.centerX, UI.centerY ] { src = "/images/logo.png", description = "A Game of Thrones: the card game" }
            , Widgets.search_bar model.query Msg_QueryChanged Msg_Search
            , UI.row [ UI.spacing 5, UI.centerX ] 
                [ Widgets.link_button "Advanced search" "/advanced"
                , Widgets.link_button "Syntax guide" "/syntax"
                , Widgets.link_button "All sets" "/sets"
                , Widgets.link_button "Random card" "/random"
                , Widgets.simple_button "Download cards JSON" Msg_DownloadJson
                ]
            ]
        , Widgets.footer
        ]
    )
