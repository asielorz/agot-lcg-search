module Widgets.Combo exposing (..)

import Fontawesome

import Element as UI
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Input as UI_Input
import Element.Events as UI_Events
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
            , UI_Events.onClick <| Msg_Select <| args.select opt
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
    in
        UI_Input.button
            (Widgets.button_style_attributes ++ (UI.below options) :: attrs)
            { onPress = if open then Just Msg_Close else Just <| Msg_Open args.id
            , label = UI.row [ UI.spacing 20, UI.width UI.fill ]
                [ UI.map (always Msg_Close) <| args.view args.curr
                , Fontawesome.text [ UI.alignRight ] "\u{f0d7}"
                ] 
            }
