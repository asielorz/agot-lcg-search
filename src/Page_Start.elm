module Page_Start exposing (Model, Msg, init, update, view)

import Query exposing (default_search_state)
import Widgets

import Browser.Navigation as Navigation
import Element as UI

type alias Model = 
    { query : String
    }

type Msg 
    = Msg_QueryChanged String
    | Msg_Search

init : Model
init = { query = "" }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChanged new_query -> ({ model | query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key (Query.search_url { default_search_state | query = model.query }))

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
            , UI.paddingXY 5 0
            ]
            [ UI.image [ UI.centerX, UI.centerY, UI.width <| UI.maximum 600 UI.fill ] { src = "/images/logo.png", description = "A Game of Thrones: the card game" }
            , Widgets.search_bar model.query Msg_QueryChanged Msg_Search
            , UI.column [ UI.spacing 5, UI.centerX ]
                [ UI.row [ UI.spacing 5, UI.centerX ] 
                    [ Widgets.link_button "Advanced search" "/advanced"
                    , Widgets.link_button "Syntax guide" "/syntax"
                    , Widgets.link_button "All sets" "/sets"
                    ]
                , UI.row [ UI.spacing 5, UI.centerX ] 
                    [ Widgets.link_button "Random card" "/random"
                    , Widgets.new_tab_link_button "Download cards JSON" "/cards.json"
                    ]
                ]
            ]
        , Widgets.footer
        ]
    )
