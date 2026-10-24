module Page_Resources exposing (Model, Msg, init, update, view)

import Colors
import Query exposing (default_search_state)
import Widgets
import Window exposing (Window)

import Browser.Navigation as Navigation
import Element as UI
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import CardSet exposing (SetOrCycle(..))

type alias Model = 
    { header : Widgets.HeaderModel
    }

type Msg 
    = Msg_Header Widgets.HeaderModel
    | Msg_Search

init : Model
init  = 
    { header = Widgets.header_init ""
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_Header new_header -> ({ model | header = new_header }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| (Query.search_url { default_search_state | query = model.header.search_buffer }))

view : Model -> Window -> (String, UI.Element Msg)
view model window =
    ( "Resources - A Game of Thrones LCG card search"
    , UI.column
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI.height UI.fill
        ]
        [ Widgets.header model.header Msg_Header Msg_Search window.width
        , view_resources_table
        , Widgets.footer
        ]
    )

type alias Resource =
    { display_text : String
    , url : String
    }

resources : List Resource
resources =
    [ Resource "Cards JSON" "/resources/cards.json"
    --, Resource "All card images" "/resources/card_images.zip"
    , Resource "Core set rules" "/resources/rules-core-set.pdf"
    , Resource "FAQs and errata" "/resources/faq.pdf"
    , Resource "Shadows mechanic rules" "/resources/rules-shadows.pdf"
    , Resource "Joust and melee keyword rules" "/resources/rules-joust-melee.pdf"
    , Resource "Hand of the king variant format" "/resources/rules-format-hand-of-the-king.pdf"
    , Resource "Kingsmoot variant format" "/resources/rules-format-kingsmoot.pdf"
    , Resource "Civil war variant format" "/resources/rules-format-civil-war.pdf"
    , Resource "Tournament deck sheet" "/resources/deck-sheet.pdf"
    , Resource "Joust tournament score sheet" "/resources/scoresheet-joust.pdf"
    , Resource "Melee tournament score sheet" "/resources/scoresheet-melee.pdf"
    , Resource "Game night signup sheet" "/resources/game-night-signup.pdf"
    ]

view_resources_table : UI.Element msg
view_resources_table = resources
    |> List.indexedMap (\i s -> view_resource_table_row (modBy 2 i == 0) s)
    |> UI.column 
        [ UI.centerX
        , UI.width <| UI.maximum 1000 UI.fill
        , UI_Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , UI_Border.color Colors.separator
        ]

view_resource_table_row : Bool -> Resource -> UI.Element msg
view_resource_table_row even resource = UI.newTabLink 
    [ UI.width UI.fill
    , UI_Border.widthEach { top = 1, left = 1, right = 1, bottom = 0 }
    , UI_Border.color Colors.separator
    , UI_Background.color <| if even then Colors.page_background else Colors.background
    , UI.mouseOver [ UI_Background.color Colors.background_hover ]
    , UI.padding 5
    , UI_Font.size 16
    ]
    { url = resource.url
    , label = UI.text resource.display_text
    }
