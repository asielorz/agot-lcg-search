module Page_Search exposing (Model, Msg, init, update, view)

import Card exposing (Card, CardType(..))
import Cards exposing(all_cards)
import Widgets

import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Border as UI_Border
import Element.Font as UI_Font
import Query

cards_per_page : Int
cards_per_page = 60

type Msg 
    = Msg_QueryChange String
    | Msg_Search

type alias Model = 
    { last_searched_query : String
    , new_query_buffer : String
    , cards : List Card
    , sort : List String
    , page : Int
    }

init : Maybe String -> Model
init query = 
    let
        parsed = Query.parse query
        all_cards_found = Query.search parsed.query parsed.sort all_cards |> Result.withDefault []
        (plots, cards) = List.partition (\c -> c.card_type == CardType_Plot ) all_cards_found
    in
        { last_searched_query = parsed.query
        , new_query_buffer = parsed.query
        , cards = cards ++ plots -- Move all plots to the end
        , sort = parsed.sort
        , page = parsed.page
        }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChange new_query -> ({ model | new_query_buffer = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { query = model.new_query_buffer, sort = model.sort, page = 0 })

view : Model -> (String, UI.Element Msg)
view model =
    let
        (cards, plots) = cards_in_current_page model
    in
        ( model.last_searched_query ++ " - A Game of Thrones LCG card search"
        , UI.column 
            [ UI.centerX
            , UI.spacing 20 
            , UI.width UI.fill
            , UI.paddingEach { top = 0, left = 0, right = 0, bottom = 20 }
            ]
            (List.filterMap identity 
                [ Just <| Widgets.header model.new_query_buffer Msg_QueryChange Msg_Search
                , Just <| number_of_results_line model
                , Just <| navigation_buttons model
                , view_results cards
                , view_results plots
                , Just <| navigation_buttons model
                ]
            )
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
        first = model.page * cards_per_page + 1
        total = List.length model.cards
        last = min (first + 59) total
    in
        if total == 0
            then "No cards found"
            else String.fromInt first ++ " - " ++ String.fromInt last ++ " of " ++ String.fromInt total ++ " cards"

view_results : List Card -> Maybe (UI.Element msg)
view_results cards = Just <| UI.wrappedRow 
    [ UI.spacingXY 6 9
    , UI.width <| UI.maximum 1000 UI.fill
    , UI.centerX
    ] 
    <| List.map view_card cards

view_card : Card -> UI.Element msg
view_card card = 
    let
        image = if card.card_type == CardType_Plot
            then UI.image 
                [ UI.height (px 227)
                , UI.width (px 325) 
                , UI_Border.rounded 10
                , UI.clip
                ] 
                { src = Card.image_url card
                , description = card.name
                }
            else UI.image 
                [ UI.height (px 350)
                , UI.width (px 245) 
                , UI_Border.rounded 10
                , UI.clip
                ] 
                { src = Card.image_url card
                , description = card.name
                }
    in
        UI.link [] { label = image, url = Card.page_url card }

navigation_buttons : Model -> UI.Element msg
navigation_buttons model = 
    let
        last = page_count model - 1
    in
        UI.row 
            [ UI.spacing 10
            , UI.centerX 
            ]
            [ Widgets.conditional_link_button (model.page /= 0) "|<<" (Query.search_url { query = model.last_searched_query, sort = model.sort, page = 0 })
            , Widgets.conditional_link_button (model.page /= 0) "< Previous" (Query.search_url { query = model.last_searched_query, sort = model.sort, page = max 0 (model.page - 1) })
            , Widgets.conditional_link_button (model.page /= last) "> Next" (Query.search_url { query = model.last_searched_query, sort = model.sort, page = min last (model.page + 1) })
            , Widgets.conditional_link_button (model.page /= last) ">>|" (Query.search_url { query = model.last_searched_query, sort = model.sort, page = last })
            ]

cards_in_current_page : Model -> (List Card, List Card)
cards_in_current_page model = model.cards
    |> List.drop (cards_per_page * model.page)
    |> List.take cards_per_page
    |> List.partition (\c -> c.card_type /= CardType_Plot)

page_count : Model -> Int
page_count model = List.length model.cards // cards_per_page + 1
