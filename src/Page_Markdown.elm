module Page_Markdown exposing (Model, Msg, init, update, view)

import Colors
import Query exposing (default_search_state)
import Widgets

import Browser.Navigation as Navigation
import Element as UI
import Element.Background as UI_Background
import Element.Font as UI_Font
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer
import Markdown.Renderer.ElmUi

type alias Model = 
    { title : String
    , content : String
    , header_query : String
    }

type Msg 
    = Msg_QueryChange String
    | Msg_Search

init : String -> String -> Model
init title content = 
    { title = title
    , content = content
    , header_query = ""
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChange new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { default_search_state | query = model.header_query })

view : Model -> (String, UI.Element Msg)
view model = 
    ( model.title ++ " - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20
        , UI.width UI.fill
        ]
        [ Widgets.header model.header_query Msg_QueryChange Msg_Search
        , UI.column [ UI.centerX, UI.spacing 15, UI.width <| UI.maximum 750 UI.fill ] (model.content |> parse_markdown |> Result.withDefault [])
        , Widgets.footer
        ]
    )

parse_markdown : String -> Result Markdown.Renderer.ElmUi.Error (List (UI.Element msg))
parse_markdown markdown_source =
    Markdown.Parser.parse markdown_source
        |> Result.mapError Markdown.Renderer.ElmUi.ParseError
        |> Result.andThen
            (\blocks ->
                Markdown.Renderer.render markdown_renderer blocks
                    |> Result.mapError Markdown.Renderer.ElmUi.RenderError
            )

markdown_renderer : Markdown.Renderer.Renderer (UI.Element msg)
markdown_renderer =
    let
        defaultRenderer =
            Markdown.Renderer.ElmUi.renderer
    in
        { defaultRenderer
        | link = \{ destination } body -> Widgets.link [] { url = destination, label = UI.paragraph [] body }
        , codeSpan = code_span
        , unorderedList = unordered_list
        }

code_span : String -> UI.Element msg
code_span raw_text = UI.el 
    [ UI_Font.family [ UI_Font.monospace ]
    , UI_Font.size 17
    , UI_Background.color Colors.background
    ] 
    <| UI.text raw_text

unordered_list : List (Markdown.Block.ListItem (UI.Element msg)) -> UI.Element msg
unordered_list items =
    List.map unordered_list_item items
        |> UI.column [ UI.spacing 5 ]

unordered_list_item : Markdown.Block.ListItem (UI.Element msg) -> UI.Element msg
unordered_list_item (Markdown.Block.ListItem _ children) =
    let
        bullet =
            UI.el
                [ UI.paddingEach { top = 4, bottom = 0, left = 2, right = 8 }
                , UI.alignTop
                ]
            <|
                UI.text "•"
    in
        UI.row []
            [ bullet
            , UI.paragraph [ UI.width UI.fill ] children
            ]
