module Page_Card exposing (Model, Msg, init, update, view)

import Card exposing (Card, CardType(..), Crest(..), Icon(..), Legality(..), Errata)
import Cards
import CardSet exposing (SetOrCycle(..))
import Query
import Widgets

import Browser.Navigation as Navigation
import Element as UI exposing (px, rgb, rgb255, rgba)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font

type alias Model = 
    { card : Card
    , header_query : String
    }

type Msg 
    = Msg_QueryChange String
    | Msg_Search

init : Card -> Model
init card = 
    { card = card
    , header_query = ""
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_QueryChange new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { query = model.header_query, sort = [], page = 0 })

view : Model -> (String, UI.Element Msg)
view model = 
    ( model.card.name ++ " - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20 
        , UI.width UI.fill
        , UI_Font.size 15
        ]
        [ Widgets.header model.header_query Msg_QueryChange Msg_Search
        , view_card model.card
        , UI.text "" -- Dummy widget to add 20 padding more between.
        , view_card_faqs model.card.faqs
        ]
    )

view_card : Card -> UI.Element Msg
view_card card = 
    let
        (width, height) = if card.card_type == CardType_Plot then (600, 420) else (420, 600)
    in
        UI.row [ UI.centerX, UI.spacing 10 ]
            [ UI.column 
                [ UI.alignTop
                , UI.paddingEach { left = 10, right = 20, top = 10, bottom = 10 }
                , UI_Border.width 1
                , UI_Border.color Widgets.border_color
                , UI_Border.rounded 10
                , UI.height UI.fill
                , UI.width (px 420)
                , UI.spacing 5
                , UI_Background.color Widgets.background_color
                ]
                [ UI.row [ UI.spacing 10 ]
                    [ cost_widget card.cost
                    , if card.unique then UI.image [ UI_Border.rounded 3, UI.clip, UI.width (px 20) ] { src = "/images/unique.png", description = "Unique" } else UI.none
                    , UI.text card.name
                    ]
                , Widgets.separator
                , UI.text <| type_and_traits_line card
                , Widgets.separator
                , maybe_text [] card.rules_text card.erratas
                , maybe_text [ UI_Font.italic ] card.flavor_text []
                , if card.card_type == CardType_Character then Widgets.separator else UI.none
                , character_line card
                , Widgets.separator
                , UI.text <| "Illustrated by " ++ card.illustrator
                , Widgets.separator
                , set_line card
                , Widgets.separator
                , legality_line card.legality_joust card.legality_melee
                , versions_widget (all_cards_with_name card.name) card.id
                ]
            , UI.image 
                [ UI_Border.rounded 10
                , UI.clip
                , UI.width (px width)
                , UI.height (px height)
                , UI.alignTop
                , UI.moveLeft 20
                , UI.moveDown 20
                ] { src = Card.image_url card, description = card.name }
            ]

type_and_traits_line : Card -> String
type_and_traits_line card = if List.isEmpty card.traits
    then Card.card_type_to_string card.card_type
    else Card.card_type_to_string card.card_type ++ " — " ++ String.join ", " card.traits

maybe_text : List (UI.Attribute msg) -> Maybe String -> List Errata -> UI.Element msg
maybe_text attrs text erratas = case text of
    Nothing -> UI.none
    Just actual_text -> UI.paragraph attrs <| apply_erratas 0 actual_text erratas

apply_erratas : Int -> String -> List Errata -> List (UI.Element msg)
apply_erratas offset text erratas = case erratas of
    [] -> [ UI.text text ]
    ((start, end)::rest) ->
        let
            before_errata = String.slice 0 (start - offset) text
            with_errata = String.slice (start - offset) (end - offset) text
            after_errata = String.dropLeft (end - offset) text
        in
            [ UI.text before_errata
            , UI.el [ UI_Font.color (rgb255 255 100 100) ] <| UI.text with_errata
            ]
            ++ apply_erratas (offset + end) after_errata rest

image_with_number_inside : String -> Int -> UI.Element msg
image_with_number_inside source number = UI.image 
    [ UI.width (px 30)
    , UI.inFront <| UI.el
        [ UI.centerX
        , UI.centerY
        , UI_Font.color (rgb 0 0 0)
        , UI_Font.size 20
        ]
        (UI.text <| String.fromInt number)
    ]
    { src = source, description = "" }

cost_widget : Maybe Int -> UI.Element msg
cost_widget cost = case cost of
    Nothing -> UI.none
    Just actual_cost -> image_with_number_inside "/images/gold.png" actual_cost

character_line : Card -> UI.Element msg
character_line card = case card.strength of
    Nothing -> UI.none
    Just str -> UI.row [ UI.spacing 10 ]
        [ image_with_number_inside "/images/strength.png" str
        , if List.member (Icon_Military { naval = False }) card.icons 
            then UI.image [ UI.width (px 30) ] { src = "/images/icons/military.png", description = "Military icon" }
            else UI.none
        , if List.member (Icon_Military { naval = True }) card.icons 
            then UI.image [ UI.width (px 30), naval_icon ] { src = "/images/icons/military.png", description = "Military (Naval) icon" }
            else UI.none
        , if List.member (Icon_Intrigue { naval = False }) card.icons 
            then UI.image [ UI.width (px 30) ] { src = "/images/icons/intrigue.png", description = "Intrigue icon" }
            else UI.none
        , if List.member (Icon_Intrigue { naval = True }) card.icons 
            then UI.image [ UI.width (px 30), naval_icon ] { src = "/images/icons/intrigue.png", description = "Intrigue (Naval) icon" }
            else UI.none
        , if List.member (Icon_Power { naval = False }) card.icons 
            then UI.image [ UI.width (px 30) ] { src = "/images/icons/power.png", description = "Power icon" }
            else UI.none
        , if List.member (Icon_Power { naval = True }) card.icons 
            then UI.image [ UI.width (px 30), naval_icon ] { src = "/images/icons/power.png", description = "Power (Naval) icon" }
            else UI.none
        , if List.member Crest_Holy card.crest 
            then UI.image [ UI.width (px 30) ] { src = "/images/crests/holy.png", description = "Holy crest" }
            else UI.none
        , if List.member Crest_Noble card.crest
            then UI.image [ UI.width (px 30) ] { src = "/images/crests/noble.png", description = "Noble crest" }
            else UI.none
        , if List.member Crest_War card.crest
            then UI.image [ UI.width (px 30) ] { src = "/images/crests/war.png", description = "War crest" }
            else UI.none
        , if List.member Crest_Learned card.crest
            then UI.image [ UI.width (px 30) ] { src = "/images/crests/learned.png", description = "Learned crest" }
            else UI.none
        , if List.member Crest_Shadow card.crest
            then UI.image [ UI.width (px 30) ] { src = "/images/crests/shadow.png", description = "Shadow crest" }
            else UI.none
        ]

naval_icon : UI.Attribute msg
naval_icon = UI.inFront <| UI.image 
    [ UI.width (px 20)
    , UI.alignBottom
    , UI.alignRight
    , UI.moveDown 5
    , UI.moveRight 5
    ]
    { src = "/images/naval.png", description = "Naval icon modifier" }

set_line : Card -> UI.Element msg
set_line card = UI.row [ UI.spacing 10 ]
    [ Widgets.set_icon [] (SetOrCycle_Set card.set)
    , UI.text <| (CardSet.data_of_set card.set).full_name ++ " — #" ++ String.fromInt card.number ++ " — " ++ quantity_text card.quantity
    ]

quantity_text : Int -> String
quantity_text quantity = if quantity == 1
    then "1 copy"
    else String.fromInt quantity ++ " copies"

legality_line : Legality -> Legality -> UI.Element msg
legality_line joust melee = UI.row [ UI.spacing 50 ]
    [ legality_widget "Joust" joust 
    , legality_widget "Melee" melee 
    ]

legality_widget : String -> Legality -> UI.Element msg
legality_widget format legality = 
    let
        color = case legality of
            Legality_Legal -> rgb255 104 172 89
            Legality_Restricted -> rgb255 234 156 28
    in
        UI.row [ UI.spacing 10 ]
            [ UI.el 
                [ UI_Background.color color
                , UI_Border.rounded 5
                , UI.padding 5
                , UI_Font.color (rgb 0 0 0)
                ]
                <| UI.text <| Card.legality_to_string legality
            , UI.text format
            ]

versions_widget : List Card -> String -> UI.Element msg
versions_widget cards current_id = if List.length cards <= 1
    then UI.none
    else cards
        |> List.map (\card -> UI.link 
            [ UI.padding 5
            , UI.width UI.fill
            , if card.id == current_id then UI_Background.color (rgb255 50 50 50) else UI_Background.color (rgba 0 0 0 0)
            , UI.mouseOver [ UI_Background.color (rgb255 100 100 100) ]
            , UI_Border.rounded 10
            ]
            { label = UI.row 
                [ UI.width UI.fill
                , UI.spacing 5
                ]
                [ Widgets.set_icon [] (SetOrCycle_Set card.set)
                , UI.text <| (CardSet.data_of_set card.set).full_name ++ " #" ++ String.fromInt card.number
                ]
            , url = Card.page_url card 
            })
        |> UI.column 
            [ UI_Border.rounded 10
            , UI_Border.width 1
            , UI_Border.color Widgets.border_color
            , UI.width UI.fill
            , UI.alignBottom
            ]

all_cards_with_name : String -> List Card
all_cards_with_name name = Cards.all_cards |> List.filter (\card -> card.name == name)

view_card_faqs : List String -> UI.Element msg
view_card_faqs faqs = if List.isEmpty faqs
    then UI.none
    else UI.column
        [ UI_Border.rounded 10
        , UI_Border.width 1
        , UI_Border.color Widgets.border_color
        , UI.centerX
        , UI.spacing 10
        , UI.width (px 600)
        , UI.padding 10
        , UI_Background.color Widgets.background_color
        ]
        ( (UI.el [ UI_Font.bold, UI_Font.size 20 ] <| UI.text "FAQs and clarifications")
        :: (faqs |> List.map (\f -> UI.paragraph [] [ UI.text f ]))
        )
