module Widgets.Combo exposing (..)

import Colors
import Fontawesome

import Element as UI
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Input as UI_Input
import Html.Events
import Json.Decode
import Widgets
import Html.Attributes

type Msg id model
    = Msg_Open id
    | Msg_Close
    | Msg_Select (model -> model)

type Location
    = Location_Below
    | Location_Above

update : (Maybe id -> model) -> Msg id model -> model
update update_combo_state msg = case msg of
    Msg_Open id_to_open -> update_combo_state <| Just id_to_open
    Msg_Close ->  update_combo_state Nothing
    Msg_Select select -> update_combo_state Nothing |> select

view : List (UI.Attribute (Msg id model)) -> Maybe id -> { id : id, curr : a, view : Bool -> a -> UI.Element Never, options : List a, select : a -> model -> model } -> UI.Element (Msg id model)
view attrs current_id args = 
    let
        open = current_id == Just args.id
        option_button opt = UI.el
            [ UI.mouseOver [ UI_Background.color Colors.background_hover ]
            , onClickStopPropagation <| Msg_Select <| args.select opt
            , UI.paddingXY 5 3
            , UI.width UI.fill
            ]
            <| UI.map (always Msg_Close) <| args.view False opt
        options = if open
            then UI.column 
                [ UI_Background.color Colors.background
                , UI_Border.color Colors.border
                , UI_Border.width 1
                , UI.width UI.fill
                , UI.htmlAttribute <| Html.Attributes.style "height" "auto"
                , UI.htmlAttribute <| Html.Attributes.style "max-height" "400px"
                , UI.htmlAttribute <| Html.Attributes.style "overflow-y" "auto"
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
                [ UI.el [ UI.width UI.fill, UI.clip ] <| UI.map (always Msg_Close) <| args.view True args.curr
                , Fontawesome.text [ UI.alignRight ] "\u{f0d7}"
                ] 


multi_combo 
    :  List (UI.Attribute (Msg id model)) 
    -> Maybe id 
    -> { id : id
       , curr : List a
       , view : Bool -> a -> UI.Element Never
       , options : List a
       , select : a -> model -> model
       , unselect : Int -> model -> model
       , location : Location
       , width_override : Maybe UI.Length
       } 
    -> UI.Element (Msg id model)
multi_combo attrs current_id args = 
    let
        open = current_id == Just args.id
        option_button opt = UI.el
            [ UI.mouseOver [ UI_Background.color Colors.background_hover ]
            , onClickStopPropagation <| Msg_Select <| args.select opt
            , UI.paddingXY 5 3
            , UI.width UI.fill
            ]
            <| UI.map (always Msg_Close) <| args.view False opt
        options = if open
            then UI.column 
                [ UI_Background.color Colors.background
                , UI_Border.color Colors.border
                , UI_Border.width 1
                , UI.width <| Maybe.withDefault UI.fill args.width_override
                , UI.htmlAttribute <| Html.Attributes.style "height" "auto"
                , UI.htmlAttribute <| Html.Attributes.style "max-height" "400px"
                , UI.htmlAttribute <| Html.Attributes.style "overflow-y" "auto"
                ]
                <| List.map option_button args.options
            else UI.none
        button_attrs =
            [ case args.location of 
                Location_Below -> UI.below options
                Location_Above -> UI.above options
            , onClickStopPropagation <| if open then Msg_Close else Msg_Open args.id
            , UI.pointer
            ]
        add_combo = UI.el (Widgets.button_style_attributes ++ button_attrs) (UI.text " + ")
    in
        UI.wrappedRow 
            ([ UI.width UI.fill, UI.spacing 5 ] ++ attrs) 
            (add_combo :: List.indexedMap (multi_combo_item (args.view True) args.unselect) args.curr)


multi_combo_item : (a -> UI.Element Never) -> (Int -> model -> model) -> Int -> a -> UI.Element (Msg id model)
multi_combo_item view_item unselect index item = UI_Input.button Widgets.button_style_attributes
    { onPress = Just <| Msg_Select <| unselect index
    , label = view_item item |> UI.map (always Msg_Close)
    }


onClickStopPropagation : msg -> UI.Attribute msg
onClickStopPropagation m = UI.htmlAttribute <| Html.Events.stopPropagationOn "click" <| Json.Decode.succeed <| (m, True)
