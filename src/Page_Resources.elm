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

type Line 
    = Resource { display_text : String, url : String }
    | Category { display_text : String }

resources : List Line
resources =
    [ Category { display_text = "Card data" }
    , Resource { display_text = "Cards JSON", url = "/resources/cards.json" }
    , Resource { display_text = "All card images at highest available resolution", url = "https://patrins.com/f/299c29a1c37d" }
    , Category { display_text = "Rulebooks" }
    , Resource { display_text = "Core set rules", url = "/resources/rules-core-set.pdf" }
    , Resource { display_text = "FAQs and errata", url = "/resources/faq.pdf" }
    , Resource { display_text = "Shadows mechanic rules", url = "/resources/rules-shadows.pdf" }
    , Resource { display_text = "Joust and melee keyword rules", url = "/resources/rules-joust-melee.pdf" }
    , Resource { display_text = "Hand of the king variant format", url = "/resources/rules-format-hand-of-the-king.pdf" }
    , Resource { display_text = "Kingsmoot variant format", url = "/resources/rules-format-kingsmoot.pdf" }
    , Resource { display_text = "Civil war variant format", url = "/resources/rules-format-civil-war.pdf" }
    , Category { display_text = "Tournament sheets" }
    , Resource { display_text = "Tournament deck sheet", url = "/resources/deck-sheet.pdf" }
    , Resource { display_text = "Joust tournament score sheet", url = "/resources/scoresheet-joust.pdf" }
    , Resource { display_text = "Melee tournament score sheet", url = "/resources/scoresheet-melee.pdf" }
    , Resource { display_text = "Game night signup sheet", url = "/resources/game-night-signup.pdf" }
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

view_resource_table_row : Bool -> Line -> UI.Element msg
view_resource_table_row even line = case line of
    Resource resource -> UI.newTabLink 
        [ UI.width UI.fill
        , UI_Border.widthEach { top = 1, left = 1, right = 1, bottom = 0 }
        , UI_Border.color Colors.separator
        , UI_Background.color <| if even then Colors.page_background else Colors.background
        , UI.mouseOver [ UI_Background.color Colors.background_hover ]
        , UI.paddingEach { top = 5, bottom = 5, right = 5, left = 40 }
        , UI_Font.size 16
        ]
        { url = resource.url
        , label = UI.text resource.display_text
        }
    Category category -> UI.el
        [ UI.width UI.fill
        , UI_Border.widthEach { top = 1, left = 1, right = 1, bottom = 0 }
        , UI_Border.color Colors.separator
        , UI_Background.color <| if even then Colors.page_background else Colors.background
        , UI.padding 5
        , UI_Font.size 16
        ]
        (UI.text category.display_text)
