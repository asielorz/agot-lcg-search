module Widgets exposing (..)

import Colors

import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Element.Input as UI_Input
import Html.Events
import Json.Decode
import Browser
import CardSet exposing (SetOrCycle)
import Fontawesome
import Html.Attributes

button_style_attributes : List (UI.Attribute msg)
button_style_attributes = 
    [ UI_Background.color Colors.background
    , UI_Border.color Colors.border
    , UI_Border.width 1
    , UI_Border.rounded 10
    , UI.padding 5
    , UI.mouseOver 
        [ UI_Background.color Colors.background_hover
        , UI_Border.color Colors.border_hover
        ]
    ]

on_enter : msg -> UI.Attribute msg
on_enter msg =
    UI.htmlAttribute
        (Html.Events.on "keyup"
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Json.Decode.succeed msg

                        else
                            Json.Decode.fail "Not the enter key"
                    )
            )
        )

input_text : List (UI.Attribute msg) -> String -> String -> (String -> msg) -> msg -> UI.Element msg
input_text attrs query hint msg_query_change msg_search = UI_Input.text 
            ([ UI_Background.color Colors.background
            , UI_Border.color Colors.border
            , UI_Border.rounded 10
            , on_enter msg_search
            , UI.centerX
            , UI.width UI.fill
            , UI.padding 5
            ] ++ attrs)
            { onChange = msg_query_change
            , text = query
            , placeholder = Just <| UI_Input.placeholder [] (UI.text hint)
            , label =  UI_Input.labelHidden "Search"  
            }

search_bar : String -> (String -> msg) -> msg -> UI.Element msg
search_bar query msg_query_change msg_search = UI_Input.text 
            [ UI_Background.color Colors.background
            , UI_Border.color Colors.border
            , UI_Border.rounded 20
            , on_enter msg_search
            , UI.centerX
            , UI.width UI.fill
            ] 
            { onChange = msg_query_change
            , text = query
            , placeholder = Just <| UI_Input.placeholder [] (UI.text "Search...")
            , label =  UI_Input.labelHidden "Search"  
            }

simple_button : String -> msg -> UI.Element msg
simple_button label on_press = UI_Input.button 
    (button_style_attributes ++
    [ UI.padding 8
    , UI_Font.size 16
    ]) 
    { label = UI.text label
    , onPress = Just on_press 
    }

link_button : String -> String -> UI.Element msg
link_button text url = link_button_ex [] [] text url

link_button_ex : List (UI.Attribute msg) -> List (UI.Attribute msg) -> String -> String -> UI.Element msg
link_button_ex attrs content_attrs text url = UI.link
    (button_style_attributes ++
    [ UI.padding 8
    , UI_Font.size 16
    ]
    ++ attrs)
    { url = url
    , label = if List.isEmpty content_attrs then UI.text text else UI.el content_attrs <| UI.text text
    }

conditional_link_button : Bool -> String -> String -> UI.Element msg
conditional_link_button enable text url = if enable
    then link_button text url
    else UI.el
        [ UI_Background.color Colors.background
        , UI_Border.color Colors.disabled
        , UI_Font.color Colors.disabled
        , UI_Border.width 1
        , UI_Border.rounded 20
        , UI.padding 8
        , UI_Font.size 16
        ]
        <| UI.text text


layout : (String, UI.Element msg) -> Browser.Document msg
layout (title, content) =
    { title = title
    , body = 
        [ UI.layout 
            [ UI_Background.color Colors.page_background
            , UI_Font.color <| UI.rgb255 211 207 201
            ] 
            content
        ]
    }

type alias HeaderModel =
    { search_buffer : String
    , is_open : Bool
    }

header_init : String -> HeaderModel
header_init initial_buffer = { search_buffer = initial_buffer, is_open = False }

header : HeaderModel -> (HeaderModel -> msg) -> msg -> Int -> UI.Element msg
header model make_msg search_msg window_width = 
    if window_width >= 750 then
        let
            search = search_bar model.search_buffer (\s -> make_msg { model | search_buffer = s }) search_msg
            logo = UI.link [] { url = "/", label = UI.image [ UI.height (px 50) ] { src = "/images/logo_small.png", description = "" } }
            links = UI.row [ UI.alignRight, UI.spacing 5 ] 
                [ link_button "Advanced" "/advanced"
                , link_button "Syntax" "/syntax"
                , link_button "Sets" "/sets"
                , link_button "Random" "/random"
                ]
        in
            UI.el 
                [ UI_Background.color (rgb255 32 32 32)
                , UI.width UI.fill
                , UI_Border.color Colors.separator
                , UI_Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                , UI.padding 5
                ]
                <| UI.row 
                    [ UI.spacing 10
                    , UI.width <| UI.maximum 1000 UI.fill
                    , UI.centerX
                    ] 
                    [ logo, search, links ]
    else
        let 
            search = search_bar model.search_buffer (\s -> make_msg { model | search_buffer = s }) search_msg
            logo = UI.link [] { url = "/", label = UI.image [ UI.height (px 50) ] { src = "/images/logo_small.png", description = "" } }
            menu_toggle = UI_Input.button button_style_attributes
                { onPress = Just <| make_msg { model | is_open = not model.is_open }
                , label = Fontawesome.text [ UI.padding 5 ] "\u{f0c9}" -- fa-bars
                }
            button_attrs = [ UI.width UI.fill, UI.htmlAttribute <| Html.Attributes.style "flex-basis" "0" ]
        in
            UI.column 
                [ UI_Background.color (rgb255 32 32 32)
                , UI.width UI.fill
                , UI_Border.color Colors.separator
                , UI_Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                , UI.padding 5
                , UI.spacing 5
                ]
                [ UI.row 
                    [ UI.spacing 10
                    , UI.width UI.fill
                    , UI.centerX
                    ] 
                    [ logo, search, menu_toggle ]
                , if model.is_open
                    then UI.row [ UI.spacing 5, UI.width UI.fill ]
                        [ link_button_ex button_attrs [ UI.centerX ] "Advanced" "/advanced"
                        , link_button_ex button_attrs [ UI.centerX ] "Syntax" "/syntax"
                        ]
                    else UI.none
                , if model.is_open
                    then UI.row [ UI.spacing 5, UI.width UI.fill ] 
                        [ link_button_ex button_attrs [ UI.centerX ] "Sets" "/sets"
                        , link_button_ex button_attrs [ UI.centerX ] "Random" "/random"
                        ]
                    else UI.none
                ]

footer : UI.Element msg
footer = UI.el 
    [ UI_Background.color (rgb255 32 32 32)
    , UI.width UI.fill
    , UI.height <| UI.minimum 50 UI.shrink
    , UI_Border.color Colors.separator
    , UI_Border.widthEach { bottom = 0, top = 1, left = 0, right = 0 }
    , UI.padding 5
    , UI.alignBottom
    ]
    <| UI.paragraph 
        [ UI.spacing 5
        , UI.width <| UI.maximum 800 UI.fill
        , UI.centerX
        , UI_Font.size 10
        , UI_Font.color Colors.footer_text
        , UI.centerY
        ] 
        [ UI.text "Portions of this page are unofficial Fan Content permitted under the Fantasy Flight Games IP Policy. The literal and graphical information presented on this site about A Game of Thrones: The Card Game, including card images and symbols, is copyright Asmodee North America, Inc. This page is not produced by or endorsed by Fantasy Flight Games."
        ]

separator : UI.Element msg
separator = UI.el [ UI.height (px 1), UI.width UI.fill, UI_Background.color Colors.separator ] UI.none

set_icon : List (UI.Attribute msg) -> SetOrCycle -> UI.Element msg
set_icon attrs s = UI.el (UI.width (px 36) :: attrs)
    <| UI.image 
        [ UI.height (px 20)
        , UI_Border.rounded 5
        , UI.clip
        , UI.centerX
        ]
        { src = CardSet.set_or_cycle_icon s, description = "" }

link : List (UI.Attribute msg) -> { url : String, label : UI.Element msg } -> UI.Element msg
link attributes args =
    UI.link ([ UI_Font.color Colors.link, UI.mouseOver [ UI_Font.color Colors.link_hover ] ] ++ attributes) args
