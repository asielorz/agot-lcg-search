module Main exposing (main)

import Page_AdvancedSearch
import Page_Search
import Page_Start
import Page_404
import Widgets

import Browser
import Browser.Navigation as Navigation
import Element as UI
import Url exposing (Url)
import Url.Parser

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

type Msg
    = Msg_Start Page_Start.Msg
    | Msg_Search Page_Search.Msg
    | Msg_AdvancedSearch Page_AdvancedSearch.Msg
    | Msg_404 Page_404.Msg
    | Msg_UrlRequest Browser.UrlRequest
    | Msg_UrlChange Url

type PageModel
    = Model_Start Page_Start.Model
    | Model_Search Page_Search.Model
    | Model_AdvancedSearch Page_AdvancedSearch.Model
    | Model_404 Page_404.Model

type alias Model = 
    { page : PageModel
    , navigation_key : Navigation.Key
    }

init : Url -> Navigation.Key -> Model
init url key =
    let
        parser = Url.Parser.oneOf
            [ Url.Parser.map (Model_Start Page_Start.init) Url.Parser.top
            , Url.Parser.map (Model_Search <| Page_Search.init url.query) (Url.Parser.s "search")
            , Url.Parser.map (Model_AdvancedSearch Page_AdvancedSearch.init) (Url.Parser.s "advanced")
            ]
        page = Url.Parser.parse parser url 
            |> Maybe.withDefault (Model_404 Page_404.init)
    in
        { page = page, navigation_key = key }
        

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case (msg, model.page) of
    (Msg_Start page_msg, Model_Start page_model) -> Page_Start.update model.navigation_key page_msg page_model 
        |> map_update model Model_Start Msg_Start
    (Msg_Search page_msg, Model_Search page_model) -> Page_Search.update model.navigation_key page_msg page_model 
        |> map_update model Model_Search Msg_Search
    (Msg_AdvancedSearch page_msg, Model_AdvancedSearch page_model) -> Page_AdvancedSearch.update model.navigation_key page_msg page_model 
        |> map_update model Model_AdvancedSearch Msg_AdvancedSearch
    (Msg_404 page_msg, Model_404 page_model) -> Page_404.update model.navigation_key page_msg page_model 
        |> map_update model Model_404 Msg_404
    (Msg_UrlRequest request, _) -> case request of
        Browser.Internal url -> (model, Navigation.pushUrl model.navigation_key (Url.toString url))
        Browser.External url -> (model, Navigation.load url)
    (Msg_UrlChange new_url, _) -> (init new_url model.navigation_key, Cmd.none)
    (_, _) -> (model, Cmd.none) -- Will never happen

map_update : Model -> (model -> PageModel) -> (msg -> Msg) -> (model, Cmd msg) -> (Model, Cmd Msg)
map_update model make_model make_msg (page_model, cmd) = ({ model | page = make_model page_model }, Cmd.map make_msg cmd)

view : Model -> (String, UI.Element Msg)
view model = case model.page of
    Model_Start page_model -> Page_Start.view page_model |> map_view Msg_Start
    Model_Search page_model -> Page_Search.view page_model |> map_view Msg_Search
    Model_AdvancedSearch page_model -> Page_AdvancedSearch.view page_model |> map_view Msg_AdvancedSearch
    Model_404 page_model -> Page_404.view page_model |> map_view Msg_404

map_view : (msg -> Msg) -> (String, UI.Element msg) -> (String, UI.Element Msg)
map_view make_msg (title, content) = (title, content |> UI.map make_msg)
