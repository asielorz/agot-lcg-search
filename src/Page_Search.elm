module Page_Search exposing (main)

import Card exposing (Card, CardType(..))
import Cards exposing(all_cards)
import Widgets

import Browser
import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Font as UI_Font
import Url exposing (Url)
import Query

main : Program () Model Msg
main =
    Browser.application
        { init = \() url key -> (init url key, Cmd.none)
        , view = view >> Widgets.layout
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = Msg_UrlRequest
        , onUrlChange = Msg_UrlChange
        }

cards_per_page : Int
cards_per_page = 60

type Msg 
    = Msg_QueryChange String
    | Msg_Search
    | Msg_UrlRequest Browser.UrlRequest
    | Msg_UrlChange Url

type alias Model = 
    { url : Url
    , navigation_key : Navigation.Key
    , last_searched_query : String
    , new_query_buffer : String
    , cards : List Card
    , sort : List String
    , page : Int
    }

init : Url -> Navigation.Key -> Model
init url key = 
    let
        parsed = Query.parse url.query
    in
        { url = url
        , navigation_key = key
        , last_searched_query = parsed.query
        , new_query_buffer = parsed.query
        , cards = Query.search parsed.query parsed.sort all_cards |> Result.withDefault []
        , sort = parsed.sort
        , page = parsed.page
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Msg_QueryChange new_query -> ({ model | new_query_buffer = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.load <| Query.search_url_from model.url { query = model.new_query_buffer, sort = model.sort, page = 0 })
    Msg_UrlRequest request -> case request of
        Browser.Internal url -> if url |> Url.toString |> String.startsWith "/search?"
            then (model, Navigation.pushUrl model.navigation_key (Url.toString url))
            else (model, Navigation.load <| Url.toString url)
        Browser.External url -> (model, Navigation.load url)
    Msg_UrlChange new_url -> (init new_url model.navigation_key, Cmd.none)

view : Model -> (String, UI.Element Msg)
view model = 
    ( model.last_searched_query ++ " - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI.paddingEach { top = 0, left = 0, right = 0, bottom = 20 }
        ]
        [ Widgets.header model.new_query_buffer Msg_QueryChange Msg_Search
        , number_of_results_line model
        , navigation_buttons model
        , view_results <| cards_in_current_page model
        , navigation_buttons model
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
        first = model.page * cards_per_page + 1
        total = List.length model.cards
        last = min (first + 59) total
    in
        String.fromInt first ++ " - " ++ String.fromInt last ++ " of " ++ String.fromInt total ++ " cards"

view_results : List Card -> UI.Element msg
view_results cards = UI.wrappedRow 
    [ UI.spacingXY 6 9
    , UI.width <| UI.maximum 1000 UI.fill
    , UI.centerX
    ] 
    <| List.map view_card cards

view_card : Card -> UI.Element msg
view_card card = 
    let
        image = if card.card_type == CardType_Plot
            then UI.el 
                [ UI.height (px 350)
                , UI.width (px 245) 
                ] 
                <| UI.image 
                    [ UI.height (px 245)
                    , UI.width (px 350)
                    , UI.rotate <| degrees -90
                    , UI.moveLeft 52, UI.moveDown 52
                    ] 
                    { src = card.image_url
                    , description = card.name 
                    }
            else UI.image 
                [ UI.height (px 350)
                , UI.width (px 245) 
                ] 
                { src = card.image_url
                , description = card.name
                }
    in
        UI.link [] { label = image, url = "/card?id=" ++ Card.card_id card }

navigation_buttons : Model -> UI.Element msg
navigation_buttons model = 
    let
        last = page_count model - 1
    in
        UI.row 
            [ UI.spacing 10
            , UI.centerX 
            ]
            [ Widgets.conditional_link_button (model.page /= 0) "|<<" (Query.search_url_from model.url { query = model.last_searched_query, sort = model.sort, page = 0 })
            , Widgets.conditional_link_button (model.page /= 0) "< Previous" (Query.search_url_from model.url { query = model.last_searched_query, sort = model.sort, page = max 0 (model.page - 1) })
            , Widgets.conditional_link_button (model.page /= last) "> Next" (Query.search_url_from model.url { query = model.last_searched_query, sort = model.sort, page = min last (model.page + 1) })
            , Widgets.conditional_link_button (model.page /= last) ">>|" (Query.search_url_from model.url { query = model.last_searched_query, sort = model.sort, page = last })
            ]

cards_in_current_page : Model -> List Card
cards_in_current_page model = model.cards
    |> List.drop (cards_per_page * model.page)
    |> List.take cards_per_page

page_count : Model -> Int
page_count model = List.length model.cards // cards_per_page + 1
