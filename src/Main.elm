module Main exposing (main)

import Card exposing (Card)
import Cards
import Page_AdvancedSearch
import Page_Card
import Page_Markdown
import Page_Search
import Page_Sets
import Page_Start
import Page_404
import Text_Syntax
import Widgets

import Browser
import Browser.Dom
import Browser.Navigation as Navigation
import Element as UI
import Json.Decode
import List.Extra
import Random
import Task
import Url exposing (Url)
import Url.Parser exposing ((</>))

main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = \args url key ->
            let
                seed = args
                    |> Json.Decode.decodeValue Json.Decode.int
                    |> Result.withDefault 42
            in
                init url key (Random.initialSeed seed)
        , view = view >> Widgets.layout
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = Msg_UrlRequest
        , onUrlChange = Msg_UrlChange
        }

type Msg
    = Msg_Noop
    | Msg_Start Page_Start.Msg
    | Msg_Search Page_Search.Msg
    | Msg_AdvancedSearch Page_AdvancedSearch.Msg
    | Msg_Card Page_Card.Msg
    | Msg_Sets Page_Sets.Msg
    | Msg_Markdown Page_Markdown.Msg
    | Msg_404 Page_404.Msg
    | Msg_UrlRequest Browser.UrlRequest
    | Msg_UrlChange Url

type PageModel
    = Model_Start Page_Start.Model
    | Model_Search Page_Search.Model
    | Model_AdvancedSearch Page_AdvancedSearch.Model
    | Model_Card Page_Card.Model
    | Model_Sets Page_Sets.Model
    | Model_Markdown Page_Markdown.Model
    | Model_404 Page_404.Model

type alias Model = 
    { page : PageModel
    , navigation_key : Navigation.Key
    , random_seed : Random.Seed
    }

type UrlChangeResult = UrlChangeResult_Page PageModel | UrlChangeResult_Redirect String
change_url_impl : Url -> Int -> UrlChangeResult
change_url_impl url random_card_index = 
    let
        page_404 _ = UrlChangeResult_Page <| Model_404 Page_404.init

        card_page_model id = case card_with_id id of
            Nothing -> page_404 ()
            Just card -> UrlChangeResult_Page <| Model_Card <| Page_Card.init card ""

        search_page_model : Page_Search.Model -> UrlChangeResult
        search_page_model inner = case inner.cards of
            [ card ] -> UrlChangeResult_Redirect <| Card.page_url card
            _ -> UrlChangeResult_Page <| Model_Search inner

        random_card_page _ = Cards.all_cards
            |> List.Extra.getAt random_card_index
            |> Maybe.map (\card -> UrlChangeResult_Redirect <| Card.page_url card)
            |> Maybe.withDefault (page_404 ())

        parser = Url.Parser.oneOf
            [ Url.Parser.map (UrlChangeResult_Page <| Model_Start Page_Start.init) Url.Parser.top
            , Url.Parser.map (search_page_model <| Page_Search.init url.query) (Url.Parser.s "search")
            , Url.Parser.map (UrlChangeResult_Page <| Model_AdvancedSearch Page_AdvancedSearch.init) (Url.Parser.s "advanced")
            , Url.Parser.map (UrlChangeResult_Page <| Model_Sets Page_Sets.init) (Url.Parser.s "sets")
            , Url.Parser.map card_page_model (Url.Parser.s "card" </> Url.Parser.string)
            , Url.Parser.map (random_card_page ()) (Url.Parser.s "random")
            , Url.Parser.map (UrlChangeResult_Page <| Model_Markdown <| Page_Markdown.init "Syntax guide" Text_Syntax.text ) (Url.Parser.s "syntax")
            ]
        page = Url.Parser.parse parser url 
            |> Maybe.withDefault (page_404 ())
    in
        page

change_url : Url -> Model -> (Model, Cmd Msg)
change_url url model =
    let
        (random_card_index, new_seed) = Random.step (Random.int 0 (List.length Cards.all_cards - 1)) model.random_seed
    in
        case change_url_impl url random_card_index of
            UrlChangeResult_Page page -> ({ model | page = page, random_seed = new_seed }, Task.perform (always Msg_Noop) (Browser.Dom.setViewport 0 0))
            UrlChangeResult_Redirect new_url -> (model, Navigation.replaceUrl model.navigation_key new_url)

init : Url -> Navigation.Key -> Random.Seed -> (Model, Cmd Msg)
init url key seed =
    let
        dummy_start_model =
            { page = Model_Start Page_Start.init
            , navigation_key = key
            , random_seed = seed
            }
    in
        change_url url dummy_start_model


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case (msg, model.page) of
    (Msg_Start page_msg, Model_Start page_model) -> Page_Start.update model.navigation_key page_msg page_model 
        |> map_update model Model_Start Msg_Start
    (Msg_Search page_msg, Model_Search page_model) -> Page_Search.update model.navigation_key page_msg page_model 
        |> map_update model Model_Search Msg_Search
    (Msg_AdvancedSearch page_msg, Model_AdvancedSearch page_model) -> Page_AdvancedSearch.update model.navigation_key page_msg page_model 
        |> map_update model Model_AdvancedSearch Msg_AdvancedSearch
    (Msg_Card page_msg, Model_Card page_model) -> Page_Card.update model.navigation_key page_msg page_model 
        |> map_update model Model_Card Msg_Card
    (Msg_Sets page_msg, Model_Sets page_model) -> Page_Sets.update model.navigation_key page_msg page_model 
        |> map_update model Model_Sets Msg_Sets
    (Msg_Markdown page_msg, Model_Markdown page_model) -> Page_Markdown.update model.navigation_key page_msg page_model 
        |> map_update model Model_Markdown Msg_Markdown
    (Msg_404 page_msg, Model_404 page_model) -> Page_404.update model.navigation_key page_msg page_model 
        |> map_update model Model_404 Msg_404
    (Msg_UrlRequest request, _) -> case request of
        Browser.Internal url -> (model, Navigation.pushUrl model.navigation_key (Url.toString url))
        Browser.External url -> (model, Navigation.load url)
    (Msg_UrlChange new_url, _) -> init new_url model.navigation_key model.random_seed
    (_, _) -> (model, Cmd.none) -- Will never happen

map_update : Model -> (model -> PageModel) -> (msg -> Msg) -> (model, Cmd msg) -> (Model, Cmd Msg)
map_update model make_model make_msg (page_model, cmd) = ({ model | page = make_model page_model }, Cmd.map make_msg cmd)

view : Model -> (String, UI.Element Msg)
view model = case model.page of
    Model_Start page_model -> Page_Start.view page_model |> map_view Msg_Start
    Model_Search page_model -> Page_Search.view page_model |> map_view Msg_Search
    Model_AdvancedSearch page_model -> Page_AdvancedSearch.view page_model |> map_view Msg_AdvancedSearch
    Model_Card page_model -> Page_Card.view page_model |> map_view Msg_Card
    Model_Sets page_model -> Page_Sets.view page_model |> map_view Msg_Sets
    Model_Markdown page_model -> Page_Markdown.view page_model |> map_view Msg_Markdown
    Model_404 page_model -> Page_404.view page_model |> map_view Msg_404

map_view : (msg -> Msg) -> (String, UI.Element msg) -> (String, UI.Element Msg)
map_view make_msg (title, content) = (title, content |> UI.map make_msg)

card_with_id : String -> Maybe Card
card_with_id id = List.Extra.find (\c -> c.id == id) Cards.all_cards
