module Page_404 exposing (Model, Msg, init, update, view)

import Query
import Widgets

import Browser.Navigation as Navigation
import Element as UI
import Element.Border as UI_Border

type alias Model = 
    { header_query : String
    }

type Msg 
    = Msg_HeaderQueryChanged String
    | Msg_HeaderSearch

init : Model
init = 
    { header_query = "" 
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_HeaderQueryChanged new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_HeaderSearch -> (model, Navigation.pushUrl key (Query.search_url { query = model.header_query, sort = [], page = 0 }))

view : Model -> (String, UI.Element Msg)
view model = 
    ( "404 - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI.height UI.fill
        ]
        [ Widgets.header model.header_query Msg_HeaderQueryChanged Msg_HeaderSearch
        , UI.image [ UI.centerX, UI.centerY, UI_Border.rounded 20, UI.clip ] { src = "/images/404.png", description = "404 Page not Found" }
        ]
    )
