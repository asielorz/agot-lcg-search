module Widgets exposing (..)

import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Element.Input as UI_Input
import Html.Events
import Json.Decode
import Browser

border_color : UI.Color
border_color = rgb255 168 160 149

border_color_hover : UI.Color
border_color_hover = rgb255 208 200 180

background_color : UI.Color
background_color = rgb255 34 36 38

background_color_hover : UI.Color
background_color_hover = rgb255 44 46 48

disabled_color : UI.Color
disabled_color = rgb255 100 100 100

separator_color : UI.Color
separator_color = rgb255 56 56 56

button_style_attributes = 
    [ UI_Background.color background_color
    , UI_Border.color border_color
    , UI_Border.width 1
    , UI_Border.rounded 10
    , UI.padding 5
    , UI.mouseOver 
        [ UI_Background.color background_color_hover
        , UI_Border.color border_color_hover
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
            ([ UI_Background.color background_color
            , UI_Border.color border_color
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
            [ UI_Background.color background_color
            , UI_Border.color border_color
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
link_button text url = UI.link
    (button_style_attributes ++
    [ UI.padding 8
    , UI_Font.size 16
    ])
    { url = url
    , label = UI.text text
    }

conditional_link_button : Bool -> String -> String -> UI.Element msg
conditional_link_button enable text url = if enable
    then link_button text url
    else UI.el
        [ UI_Background.color background_color
        , UI_Border.color disabled_color
        , UI_Font.color disabled_color
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
            [ UI_Background.color <| UI.rgb255 24 26 27
            , UI_Font.color <| UI.rgb255 211 207 201
            ] 
            content
        ]
    }

header : String -> (String -> msg) -> msg -> UI.Element msg
header search_buffer query_change_msg search_msg = 
    let
        search = search_bar search_buffer query_change_msg search_msg
        logo = UI.link [] { url = "/", label = UI.image [ UI.height (px 50) ] { src = "/images/logo.png", description = "" } }
        links = UI.row [ UI.alignRight, UI.spacing 5 ] 
            [ link_button "Advanced" "/advanced"
            , link_button "Syntax" "/syntax"
            , link_button "Sets" "/sets"
            ]
    in
        UI.el 
            [ UI_Background.color (rgb255 32 32 32)
            , UI.width UI.fill
            , UI_Border.color separator_color
            , UI_Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            , UI.padding 5
            ]
            <| UI.row 
                [ UI.spacing 10
                , UI.width <| UI.maximum 1000 UI.fill
                , UI.centerX
                ] 
                [ logo, search, links ]

separator : UI.Element msg
separator = UI.el [ UI.height (px 1), UI.width UI.fill, UI_Background.color separator_color ] UI.none