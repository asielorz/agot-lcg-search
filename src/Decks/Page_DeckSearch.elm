module Decks.Page_DeckSearch exposing  (main)

import Card exposing (Card, House(..), CardId(..))
import CardSet exposing (SetOrCycle(..))
import Colors
import Decks.SearchState as SearchState exposing (SearchState)
import Decks.Deck as Deck
import Decks.DeckView as DeckView
import Widgets
import Window exposing (Window)

import Browser
import Element as UI exposing (px)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Element.Input as UI_Input
import Element.Events as UI_Events
import List.Extra

main : Program () Model Msg
main = Browser.document 
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

type ModelSearchState = SearchState_None | SearchState_Left SearchState | SearchState_Right SearchState

type alias Model =
    { house_stark : Bool
    , house_lannister : Bool
    , house_baratheon : Bool
    , house_targaryen : Bool
    , house_greyjoy : Bool
    , house_martell : Bool
    , house_neutral : Bool
    , cards_included : List Card
    , cards_excluded : List Card
    , hovered_card_id : CardId
    , included_search_text : String
    , excluded_search_text : String
    , search_state : ModelSearchState
    }

init : () -> (Model, Cmd Msg)
init = \_ -> 
    (   { house_stark = False
        , house_lannister = False
        , house_baratheon = False
        , house_targaryen = False
        , house_greyjoy = False
        , house_martell = False
        , house_neutral = False
        , cards_included = []
        , cards_excluded = []
        , hovered_card_id = CardId ""
        , included_search_text = ""
        , excluded_search_text = ""
        , search_state = SearchState_None
        }
    , Cmd.none
    )

type Msg
    = Msg_Noop
    | Msg_HoverCard CardId
    | Msg_StopHover
    | Msg_ModelChanged Model
    | Msg_AddCardIncluded CardId
    | Msg_RemoveCardIncluded CardId
    | Msg_AddCardExcluded CardId
    | Msg_RemoveCardExcluded CardId
    | Msg_FocusSearchIncluded
    | Msg_FocusSearchExcluded
    | Msg_UnfocusSearch
    | Msg_EditSearchTextIncluded String
    | Msg_EditSearchTextExcluded String
    | Msg_AddCurrent
    | Msg_SearchSelectedScroll Int
    | Msg_SearchSelect Int

-- TO DO
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Msg_Noop -> (model, Cmd.none)
    Msg_ModelChanged new_model -> (new_model, Cmd.none)
    Msg_FocusSearchIncluded -> (update_search_state_included model.included_search_text model, Cmd.none)
    Msg_FocusSearchExcluded -> (update_search_state_excluded model.excluded_search_text model, Cmd.none)
    Msg_UnfocusSearch -> ({model | search_state = SearchState_None}, Cmd.none)
    Msg_EditSearchTextIncluded new_text -> (update_search_state_included new_text model, Cmd.none)
    Msg_EditSearchTextExcluded new_text -> (update_search_state_excluded new_text model, Cmd.none)
    Msg_SearchSelectedScroll scroll -> ({ model | search_state = update_search_state (SearchState.scroll scroll) model.search_state }, Cmd.none)
    Msg_SearchSelect index -> ({ model | search_state = update_search_state (SearchState.set_index index) model.search_state }, Cmd.none)
    _ -> (model, Cmd.none)

update_search_state_included : String -> Model -> Model
update_search_state_included new_buffer model = { model | included_search_text = new_buffer, search_state = left (SearchState.make new_buffer Deck.empty) model.search_state }

update_search_state_excluded : String -> Model -> Model
update_search_state_excluded new_buffer model = { model | excluded_search_text = new_buffer, search_state = right (SearchState.make new_buffer Deck.empty) model.search_state }


get_left : ModelSearchState -> Maybe SearchState
get_left state = case state of
    SearchState_Left s -> Just s
    _ -> Nothing

set_left : Maybe SearchState -> ModelSearchState
set_left state = case state of
    Just s -> SearchState_Left s
    Nothing -> SearchState_None

left : (Maybe SearchState -> Maybe SearchState) -> (ModelSearchState -> ModelSearchState)
left f = \s -> s |> get_left |> f |> set_left

get_right : ModelSearchState -> Maybe SearchState
get_right state = case state of
    SearchState_Right s -> Just s
    _ -> Nothing

set_right : Maybe SearchState -> ModelSearchState
set_right state = case state of
    Just s -> SearchState_Right s
    Nothing -> SearchState_None

right : (Maybe SearchState -> Maybe SearchState) -> (ModelSearchState -> ModelSearchState)
right f = \s -> s |> get_right |> f |> set_right

update_search_state : (Maybe SearchState -> Maybe SearchState) -> ModelSearchState -> ModelSearchState
update_search_state f state = case state of
    SearchState_None -> SearchState_None
    SearchState_Left _ -> left f state
    SearchState_Right _ -> right f state

view : Model -> Browser.Document Msg
view model = Widgets.layout 
    ("AGoT LCG deck view"
    , view_search model mock_window
    )

-- TODO: Remove this
mock_window : Window
mock_window = { width = 1920, height = 1080 }

view_search : Model -> Window -> UI.Element Msg
view_search model window = UI.column 
    [ UI.centerX
    , UI.spacing 10
    , UI.width <| UI.maximum 1000 UI.fill
    , UI.paddingXY 20 0
    ]
    [ Widgets.labeled window "House" <| house_checkboxes model 
    , Widgets.separator
    , UI.row [ UI.spacing 10, UI.width UI.fill ]
        [ card_list_editor model.included_search_text model.cards_included (get_left model.search_state) Msg_FocusSearchIncluded Msg_EditSearchTextIncluded UI.onRight
        , card_list_editor model.excluded_search_text model.cards_excluded (get_right model.search_state) Msg_FocusSearchExcluded Msg_EditSearchTextExcluded UI.onLeft
        ]
    , Widgets.separator
    , Widgets.labeled window "" <| search_button model
    ]

house_checkboxes : Model -> UI.Element Msg
house_checkboxes model = UI.column [ UI.width UI.fill, UI.spacing 10 ]
    [ UI.wrappedRow [ UI.spacing 30 ] 
        [ image_checkbox [] (Card.house_icon House_Stark) model.house_stark (\b -> { model | house_stark = b })
        , image_checkbox [] (Card.house_icon House_Lannister) model.house_lannister (\b -> { model | house_lannister = b })
        , image_checkbox [] (Card.house_icon House_Baratheon) model.house_baratheon (\b -> { model | house_baratheon = b })
        , image_checkbox [] (Card.house_icon House_Targaryen) model.house_targaryen (\b -> { model | house_targaryen = b })
        , image_checkbox [] (Card.house_icon House_Greyjoy) model.house_greyjoy (\b -> { model | house_greyjoy = b })
        , image_checkbox [] (Card.house_icon House_Martell) model.house_martell (\b -> { model | house_martell = b })
        , image_checkbox [] (Card.house_icon House_Neutral) model.house_neutral (\b -> { model | house_neutral = b })
        ]
    ]

checkbox : List (UI.Attribute Msg) -> UI.Element Msg -> Bool -> (Bool -> Model) -> UI.Element Msg
checkbox attrs label checked msg = UI_Input.checkbox attrs
    { checked = checked
    , onChange = \b -> Msg_ModelChanged (msg b)
    , icon = UI_Input.defaultCheckbox
    , label = UI_Input.labelRight [] label
    }

image_checkbox : List (UI.Attribute Msg) -> String -> Bool -> (Bool -> Model) -> UI.Element Msg
image_checkbox attrs label checked msg = checkbox attrs (UI.image [ UI.height (px 30) ] { src = label, description = "" }) checked msg

card_list_editor : String -> List Card -> Maybe SearchState -> Msg -> (String -> Msg) -> (UI.Element Msg -> UI.Attribute Msg) -> UI.Element Msg
card_list_editor search_text card_list search_state msg_focus msg_edit preview_pos = UI.column [ UI.width UI.fill ]
    [ Widgets.input_text 
        [ UI_Events.onFocus <| msg_focus
        , UI_Events.onLoseFocus <| Msg_UnfocusSearch
        , UI.below <| candidate_list search_state preview_pos
        , Widgets.on_key_down [("ArrowUp", Widgets.no_modifiers, Msg_SearchSelectedScroll -1), ("ArrowDown", Widgets.no_modifiers, Msg_SearchSelectedScroll 1)]
        ]
        search_text "Search for a card..." msg_edit Msg_AddCurrent
    ]

search_button : Model -> UI.Element Msg
search_button model = UI.link
    Widgets.button_style_attributes
    { url = "/TODO"
    , label = UI.text "Search"
    }

candidate_list : Maybe SearchState -> (UI.Element Msg -> UI.Attribute Msg) -> UI.Element Msg
candidate_list search_state preview_pos = case search_state of
    Nothing -> UI.none
    Just state -> if List.isEmpty state.candidates
        then UI.none
        else UI.column 
            [ UI.padding 5
            , UI.spacing 5
            , UI_Border.width 1
            , UI_Border.color Colors.border
            , UI_Background.color Colors.background
            , UI.width UI.fill
            , UI.alignTop
            , preview_pos <| candidate_preview search_state
            ] 
            (List.indexedMap (\i c -> candidate c i (i == state.index)) state.candidates)

candidate : Card -> Int -> Bool -> UI.Element Msg
candidate card index focused = UI.row 
    [ UI.spacing 10
    , UI_Background.color <| if focused then (UI.rgb255 54 122 177) else Colors.background
    , UI.width UI.fill
    , UI_Events.onMouseEnter <| Msg_SearchSelect index
    , UI_Events.onClick <| Msg_AddCurrent
    ]
    [ Widgets.set_icon [] (SetOrCycle_Set card.set)
    , UI.el [ UI.width (px 30), UI_Font.size 12 ] <| UI.text <| "#" ++ String.fromInt card.number
    , UI.text card.name
    ]

candidate_preview : Maybe SearchState -> UI.Element msg
candidate_preview search_state = case search_state of
    Nothing -> UI.none
    Just state -> case List.Extra.getAt state.index state.candidates of
        Nothing -> UI.none
        Just card -> DeckView.card_preview card

