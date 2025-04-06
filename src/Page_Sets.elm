module Page_Sets exposing (Model, Msg, init, update, view)

import CardSet exposing (SetOrCycle)
import Query
import Widgets

import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import CardSet exposing (SetOrCycle(..))

type alias Model = 
    { header_query : String
    }

type Msg 
    = Msg_QueryChange String
    | Msg_Search

init : Model
init  = 
    { header_query = ""
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChange new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { query = model.header_query, sort = [], page = 0, duplicates = False })

view : Model -> (String, UI.Element Msg)
view model = 
    ( "Sets - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI.paddingEach { left = 0, right = 0, top = 0, bottom = 20 }
        ]
        [ Widgets.header model.header_query Msg_QueryChange Msg_Search
        , view_sets_table
        ]
    )

view_sets_table : UI.Element msg
view_sets_table = CardSet.all_sets_and_cycles_in_order
    |> List.indexedMap (\i s -> view_set_table_row (modBy 2 i == 0) s)
    |> UI.column 
        [ UI.centerX
        , UI.width <| UI.maximum 1000 UI.fill
        , UI_Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }
        , UI_Border.color Widgets.separator_color
        ]

view_set_table_row : Bool -> SetOrCycle -> UI.Element msg
view_set_table_row even set = UI.link 
    [ UI.width UI.fill
    , UI_Border.widthEach { top = 1, left = 1, right = 1, bottom = 0 }
    , UI_Border.color Widgets.separator_color
    , UI_Background.color <| if even then Widgets.page_background_color else Widgets.background_color
    , UI.mouseOver [ UI_Background.color Widgets.background_color_hover ]
    , UI.padding 5
    , UI_Font.size 16
    ]
    { url = "/search?q=set%3D" ++ CardSet.set_or_cycle_code_name set ++ "&dup=t"
    , label = UI.row 
        [ UI.spacing 5
        , UI.width UI.fill
        ]
        [ padding_between_icon_and_name set
        , Widgets.set_icon [] set
        , UI.text <| CardSet.set_or_cycle_full_name set
        , UI.el [ UI.alignRight ] <| set_or_cycle_release_date_element set
        , UI.el [ UI.alignRight, UI.width (px 100) ] <| UI.el [ UI.alignRight ] <| UI.text <| (String.fromInt <| cards_in_set_or_cycle set) ++ " cards"
        ]
    }

padding_between_icon_and_name : SetOrCycle -> UI.Element msg
padding_between_icon_and_name set = if CardSet.is_set_in_cycle set
    then UI.el [ UI.width (px 20) ] UI.none
    else UI.none

cards_in_set_or_cycle : SetOrCycle -> Int
cards_in_set_or_cycle set_or_cycle = case set_or_cycle of
    SetOrCycle_Set set -> (CardSet.data_of_set set).cards
    SetOrCycle_Cycle _ -> 120

set_or_cycle_release_date_element : SetOrCycle -> UI.Element msg
set_or_cycle_release_date_element set_or_cycle = case set_or_cycle of
    SetOrCycle_Cycle _ -> UI.none
    SetOrCycle_Set set -> 
        let
            to_str x =
                let
                    str = String.fromInt x
                in
                    if String.length str < 2
                        then "0" ++ str
                        else str
            date = (CardSet.data_of_set set).release_date
            date_text = case (date.month, date.day) of
                (Just month, Just day) -> to_str date.year ++ "-" ++ to_str month ++ "-" ++ to_str day
                (Just month, Nothing) -> to_str date.year ++ "-" ++ to_str month
                _ -> to_str date.year
        in
            UI.text date_text
