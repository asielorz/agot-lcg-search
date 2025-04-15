module Page_404 exposing (Model, Msg, init, update, view)

import Query exposing (default_search_state)
import Widgets
import Window exposing (Window)

import Browser.Navigation as Navigation
import Element as UI
import Element.Border as UI_Border

type alias Model = 
    { header : Widgets.HeaderModel
    }

type Msg 
    = Msg_Header Widgets.HeaderModel
    | Msg_Search

init : Model
init = 
    { header = Widgets.header_init "" 
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_Header new_header -> ({ model | header = new_header }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key (Query.search_url { default_search_state | query = model.header.search_buffer }))

view : Model -> Window -> (String, UI.Element Msg)
view model window =
    ( "404 - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI.height UI.fill
        ]
        [ Widgets.header model.header Msg_Header Msg_Search window.width
        , UI.image 
            [ UI.centerX
            , UI.centerY
            , UI_Border.rounded 20
            , UI.clip
            , UI.width <| UI.maximum 588 UI.fill
            ] 
            { src = "/images/404.png"
            , description = "404 Page not Found"
            }
        , Widgets.footer
        ]
    )
