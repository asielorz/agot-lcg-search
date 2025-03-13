module Page_Start exposing (main)

import Query
import Widgets

import Browser
import Browser.Navigation
import Element as UI

main : Program () Model Msg
main =
    Browser.document
        { init = \() -> (init, Cmd.none)
        , view = view >> Widgets.layout
        , update = update
        , subscriptions = \_ -> Sub.none
        }

type alias Model = 
    { query : String
    }

type Msg 
    = Msg_QueryChanged String
    | Msg_Search

init : Model
init = { query = "" }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Msg_QueryChanged new_query -> ({ model | query = new_query }, Cmd.none)
    Msg_Search -> (model, Browser.Navigation.load (Query.search_url { query = model.query, sort = [], page = 0 }))

view : Model -> (String, UI.Element Msg)
view model = 
    ( "A Game of Thrones LCG card search"
    , UI.column
        [ UI.centerX
        , UI.centerY
        , UI.spacing 20
        ]
        [ UI.image [] { src = "/images/logo.png", description = "A Game of Thrones: the card game" }
        , Widgets.search_bar model.query Msg_QueryChanged Msg_Search
        , UI.row [ UI.spacing 10, UI.centerX ] 
            [ Widgets.link_button "Advanced search" "/advanced"
            , Widgets.link_button "Syntax guide" "/syntax"
            , Widgets.link_button "All sets" "/sets"
            ]
        ]
    )
