module Page_Search exposing (Model, Msg, init, update, view)

import Card exposing (Card, CardType(..))
import Cards exposing(all_cards)
import Widgets
import Window exposing (Window)

import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Border as UI_Border
import Element.Font as UI_Font
import Query exposing (SearchState, default_search_state)
import List.Extra

cards_per_page : Int
cards_per_page = 60

type Msg 
    = Msg_Header Widgets.HeaderModel
    | Msg_Search

type alias Model = 
    { last_searched_query : SearchState
    , header : Widgets.HeaderModel
    , cards : List Card
    }

init : Maybe String -> Model
init query = 
    let
        parsed = Query.parse query
        all_cards_found = Query.search parsed all_cards |> Result.withDefault []
        (plots, cards) = List.partition (\c -> c.card_type == CardType_Plot ) all_cards_found
    in
        { last_searched_query = parsed
        , header = Widgets.header_init parsed.query
        , cards = cards ++ plots -- Move all plots to the end
        }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_Header new_header -> ({ model | header = new_header }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { default_search_state | query = model.header.search_buffer })

view : Model -> Window -> (String, UI.Element Msg)
view model window =
    let
        (cards, plots) = cards_in_current_page model
    in
        ( model.last_searched_query.query ++ " - A Game of Thrones LCG card search"
        , UI.column 
            [ UI.spacing 20 
            , UI.width UI.fill
            , UI.height UI.fill
            ]
            [ Widgets.header model.header Msg_Header Msg_Search window.width
            , number_of_results_line model
            , navigation_buttons model
            , view_results cards min_vertical_card_width max_vertical_card_width window
            , view_results plots min_horizontal_card_width max_horizontal_card_width window
            , navigation_buttons model
            , Widgets.footer
            ]
        )

number_of_results_line : Model -> UI.Element Msg
number_of_results_line model = UI.el
    [ UI_Font.size 15
    , UI.centerX
    ] 
    <| UI.text <| number_of_results_text model

number_of_results_text : Model -> String
number_of_results_text model =
    let
        first = model.last_searched_query.page * cards_per_page + 1
        total = List.length model.cards
        last = min (first + 59) total
    in
        if total == 0
            then "No cards found"
            else String.fromInt first ++ " - " ++ String.fromInt last ++ " of " ++ String.fromInt total ++ " cards"

view_results : List Card -> Int -> Int -> Window -> UI.Element msg
view_results cards min_width max_width window = 
    let
        column_width = min (window.width - 20) 1000
        column_count = column_count_for min_width column_width
        cards_in_rows = List.Extra.greedyGroupsOf column_count cards
        card_width = min max_width (card_width_for column_count column_width)
    in
        if List.isEmpty cards
            then UI.none
            else cards_in_rows
                |> List.map (view_card_row column_count card_width)
                |> List.map (UI.el [ UI.width (px column_width), UI.centerX ] << UI.row [ UI.spacing 6, UI.centerX ])
                |> UI.column [ UI.spacing 9, UI.width UI.fill ]

view_card_row : Int -> Int -> List Card -> List (UI.Element msg)
view_card_row column_count card_width cards = 
    let
        card_widgets = List.map (view_card card_width) cards
        dummy = UI.el [ UI.width (px card_width) ] UI.none
        dummies = List.repeat (column_count - List.length cards) dummy
    in
        card_widgets ++ dummies

view_card : Int -> Card -> UI.Element msg
view_card width card = UI.link []
    { label = UI.image 
        [ UI.width (px width)
        , UI_Border.rounded 10
        , UI.clip
        ] 
        { src = Card.preview_image_url card
        , description = card.name
        }
    , url = Card.page_url card
    }

card_padding : Int
card_padding = 8
max_vertical_card_width : Int
max_vertical_card_width = 245
min_vertical_card_width : Int
min_vertical_card_width = 180
max_horizontal_card_width : Int
max_horizontal_card_width = 345
min_horizontal_card_width : Int
min_horizontal_card_width = 300

column_width_for : Int -> Int -> Int
column_width_for min_card_width card_count = min_card_width * card_count + card_padding * (card_count - 1)

column_count_for : Int -> Int -> Int
column_count_for min_card_width column_width = 
    if column_width >= column_width_for min_card_width 4 then -- 815
        4
    else if column_width >= column_width_for min_card_width 3 then -- 610
        3
    else if column_width >= column_width_for min_card_width 2 then -- 405
        2
    else
        1

card_width_for : Int -> Int -> Int
card_width_for column_count column_width = (column_width - (column_count - 1) * card_padding) // column_count

navigation_buttons : Model -> UI.Element msg
navigation_buttons model = 
    let
        last = page_count model - 1
        search = model.last_searched_query
        page = search.page
    in
        UI.row
            [ UI.spacing 10
            , UI.centerX 
            ]
            [ Widgets.conditional_link_button (page /= 0) "|<<" (Query.search_url { search | page = 0 })
            , Widgets.conditional_link_button (page /= 0) "< Previous" (Query.search_url { search | page = max 0 (page - 1) })
            , Widgets.conditional_link_button (page /= last) "> Next" (Query.search_url { search | page = min last (page + 1) })
            , Widgets.conditional_link_button (page /= last) ">>|" (Query.search_url { search | page = last })
            ]

cards_in_current_page : Model -> (List Card, List Card)
cards_in_current_page model = model.cards
    |> List.drop (cards_per_page * model.last_searched_query.page)
    |> List.take cards_per_page
    |> List.partition (\c -> c.card_type /= CardType_Plot)

page_count : Model -> Int
page_count model = ((List.length model.cards - 1) // cards_per_page) + 1
