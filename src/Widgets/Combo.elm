module Widgets.Combo exposing (..)

import Fontawesome

import Element as UI
import Element.Background as UI_Background
import Element.Border as UI_Border
import Html.Events
import Json.Decode
import Widgets

type Msg id model
    = Msg_Open id
    | Msg_Close
    | Msg_Select (model -> model)

update : (Maybe id -> model) -> Msg id model -> model
update update_combo_state msg = case msg of
    Msg_Open id_to_open -> update_combo_state <| Just id_to_open
    Msg_Close ->  update_combo_state Nothing
    Msg_Select select -> update_combo_state Nothing |> select

view : List (UI.Attribute (Msg id model)) -> Maybe id -> { id : id, curr : a, view : a -> UI.Element Never, options : List a, select : a -> model -> model } -> UI.Element (Msg id model)
view attrs current_id args = 
    let
        open = current_id == Just args.id
        option_button opt = UI.el
            [ UI.mouseOver [ UI_Background.color Widgets.background_color_hover ]
            , onClickStopPropagation <| Msg_Select <| args.select opt
            , UI.paddingXY 5 3
            , UI.width UI.fill
            ]
            <| UI.map (always Msg_Close) <| args.view opt
        options = if open
            then UI.column 
                [ UI_Background.color Widgets.background_color
                , UI_Border.color Widgets.border_color
                , UI_Border.width 1
                , UI.width UI.fill
                ]
                <| List.map option_button args.options
            else UI.none
        button_attrs =
            [ UI.below options
            , onClickStopPropagation <| if open then Msg_Close else Msg_Open args.id
            , UI.pointer
            ]
    in
        UI.el
            (Widgets.button_style_attributes ++ button_attrs ++ attrs)
            <| UI.row [ UI.width UI.fill ]
                [ UI.map (always Msg_Close) <| args.view args.curr
                , Fontawesome.text [ UI.alignRight ] "\u{f0d7}"
                ] 


onClickStopPropagation : msg -> UI.Attribute msg
onClickStopPropagation m = UI.htmlAttribute <| Html.Events.stopPropagationOn "click" <| Json.Decode.succeed <| (m, True)
