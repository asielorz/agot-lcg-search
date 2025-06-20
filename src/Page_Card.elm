module Page_Card exposing (Model, Msg, init, update, view)

import Card exposing (Card, CardType(..), Crest(..), Icon(..), Legality(..), Errata, House)
import Cards
import CardSet exposing (SetOrCycle(..))
import Colors
import Faqs
import Query exposing (default_search_state)
import Widgets
import Window exposing (Window)

import Browser.Navigation as Navigation
import Element as UI exposing (px, rgb, rgb255, rgba)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Html.Attributes

type alias Model = 
    { card : Card
    , header : Widgets.HeaderModel
    }

type Msg 
    = Msg_Header Widgets.HeaderModel
    | Msg_Search

init : Card -> String -> Model
init card query = 
    { card = card
    , header = Widgets.header_init query
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_Header new_header -> ({ model | header = new_header }, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key <| Query.search_url { default_search_state | query = model.header.search_buffer })

view : Model -> Window -> (String, UI.Element Msg)
view model window =
    ( model.card.name ++ " - A Game of Thrones LCG card search"
    , if window.width >= 850 then view_pc model window else view_mobile model window
    )

view_pc : Model -> Window -> UI.Element Msg
view_pc model window = UI.column 
    [ UI.centerX
    , UI.spacing 20
    , UI.width UI.fill
    , UI_Font.size 15
    , UI.height UI.fill
    ]
    [ Widgets.header model.header Msg_Header Msg_Search window.width
    , view_card model.card
    , UI.text "" -- Dummy widget to add 20 padding more between.
    , view_card_faqs <| faqs_that_mention model.card
    , Widgets.footer
    ]

view_mobile : Model -> Window -> UI.Element Msg
view_mobile model window = 
    let
        max_width = if model.card.card_type == CardType_Plot then 600 else 420
        with_side_padding content = if content == UI.none
            then UI.none
            else UI.el [ UI.width UI.fill, UI.paddingXY 10 0 ] content
    in
        UI.column 
            [ UI.centerX
            , UI.spacing 20
            , UI.width UI.fill
            , UI_Font.size 15
            , UI.height UI.fill
            ]
            [ Widgets.header model.header Msg_Header Msg_Search window.width
            , with_side_padding <| view_card_image [ UI.width <| UI.maximum max_width UI.fill, UI.centerX ] model.card
            , with_side_padding <| view_card_description [ UI.width UI.fill, UI.padding 10 ] model.card
            , with_side_padding <| view_card_faqs <| faqs_that_mention model.card
            , Widgets.footer
            ]

view_card : Card -> UI.Element Msg
view_card card = if card.card_type == CardType_Plot
    then UI.column [ UI.centerX, UI.spacing 10 ]
        [ view_card_image [ UI.htmlAttribute <| Html.Attributes.style "z-index" "2", UI.width (px 600), UI.height (px 420) ] card
        , view_card_description
            [ UI.paddingEach { left = 10, right = 10, top = 20, bottom = 10 }
            , UI.moveRight 20
            , UI.moveUp 20
            , UI.htmlAttribute <| Html.Attributes.style "z-index" "1"
            , UI.width (px 600)
            ]
            card
        ]
    else UI.row [ UI.centerX, UI.spacing 10 ]
        [ view_card_description 
            [ UI.height UI.fill
            , UI.width (px 420)
            , UI.paddingEach { left = 10, right = 20, top = 10, bottom = 10 }
            ]
            card
        , view_card_image [ UI.moveLeft 20, UI.moveDown 20, UI.width (px 420), UI.height (px 600) ] card
        ]

view_card_description : List (UI.Attribute msg) -> Card -> UI.Element msg
view_card_description attrs card = UI.column 
    ([ UI.alignTop
    , UI_Border.width 1
    , UI_Border.color Colors.border
    , UI_Border.rounded 10
    , UI.spacing 5
    , UI_Background.color Colors.background
    ] 
    ++ attrs) <|
    [ UI.row [ UI.spacing 10, UI.width UI.fill ]
        [ cost_widget card.cost (List.member Crest_Shadow card.crest)
        , if card.unique then UI.image [ UI_Border.rounded 3, UI.clip, UI.width (px 20) ] { src = "/images/unique.png", description = "Unique" } else UI.none
        , UI.text card.name
        , houses_widget card.house
        ]
    , Widgets.separator
    , UI.paragraph [] [ UI.text <| type_and_traits_line card ]
    , Widgets.separator
    ]
    ++ maybe_text [] card.rules_text card.erratas
    ++ maybe_text [ UI_Font.italic ] card.flavor_text []
    ++
    [ if card.card_type == CardType_Character || card.card_type == CardType_Plot then Widgets.separator else UI.none
    , character_line card
    , plot_line card
    , Widgets.separator
    , UI.paragraph [] [ UI.text <| "Illustrated by " ++ card.illustrator ]
    , Widgets.separator
    , set_line card
    , Widgets.separator
    , legality_line card.legality_joust card.legality_melee
    , versions_widget (all_cards_with_name card.name) card.id
    ]

view_card_image : List (UI.Attribute msg) -> Card -> UI.Element msg
view_card_image attrs card = UI.image 
    ([ UI_Border.rounded 10
    , UI.clip
    ] ++ attrs)
    { src = Card.full_image_url card
    , description = card.name
    }

houses_widget : List House -> UI.Element msg
houses_widget houses = houses
    |> List.map (\house -> UI.image [ UI.height (px 30) ] 
        { src = Card.house_icon house
        , description = "House " ++ Card.house_to_string house 
        })
    |> UI.row [ UI.alignRight, UI.spacing 5 ]
    

type_and_traits_line : Card -> String
type_and_traits_line card = if List.isEmpty card.traits
    then Card.card_type_to_string card.card_type
    else Card.card_type_to_string card.card_type ++ " — " ++ String.join ", " card.traits

maybe_text : List (UI.Attribute msg) -> Maybe String -> List Errata -> List (UI.Element msg)
maybe_text attrs text erratas = case text of
    Nothing -> []
    Just actual_text -> 
        let
            lines = String.split "\n" actual_text
        in
            lines |> List.indexedMap (\index line -> UI.paragraph attrs <| apply_erratas 0 line (List.filter (\e -> e.line == index) erratas))

apply_erratas : Int -> String -> List Errata -> List (UI.Element msg)
apply_erratas offset text erratas = case erratas of
    [] -> [ UI.text text ]
    (errata::rest) ->
        let
            before_errata = String.slice 0 (errata.start - offset) text
            with_errata = String.slice (errata.start - offset) (errata.end - offset) text
            after_errata = String.dropLeft (errata.end - offset) text
        in
            [ UI.text before_errata
            , UI.el [ UI_Font.color (rgb255 255 100 100) ] <| UI.text with_errata
            ]
            ++ apply_erratas (offset + errata.end) after_errata rest

image_with_text_inside : String -> String -> UI.Element msg
image_with_text_inside source text = UI.image 
    [ UI.width (px 30)
    , UI.inFront <| UI.el
        [ UI.centerX
        , UI.centerY
        , UI_Font.color (rgb 0 0 0)
        , UI_Font.size 20
        ]
        (UI.text <| text)
    ]
    { src = source, description = "" }

image_with_number_inside : String -> Int -> UI.Element msg
image_with_number_inside source number = image_with_text_inside source (String.fromInt number)

cost_widget : Maybe Int -> Bool -> UI.Element msg
cost_widget cost is_shadow = case cost of
    Nothing -> UI.none
    Just actual_cost -> image_with_text_inside "/images/gold.png" <| String.fromInt actual_cost ++ if is_shadow then "s" else ""

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

plot_line : Card -> UI.Element msg
plot_line card = case (card.income, card.initiative, card.claim) of
    (Just income, Just initiative, Just claim) -> UI.row [ UI.spacing 10 ]
        [ image_with_number_inside "/images/gold.png" income
        , image_with_number_inside "/images/initiative.png" initiative
        , image_with_number_inside "/images/claim.png" claim
        ]
    _ -> UI.none

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
set_line card = UI.link 
    [ UI_Border.rounded 5
    , UI.mouseOver [ UI_Background.color (rgb255 100 100 100) ]
    , UI.width UI.fill
    ] 
    { url = CardSet.set_url (CardSet.data_of_set card.set).code_name
    , label = UI.row [ UI.spacing 10 ]
        [ Widgets.set_icon [] (SetOrCycle_Set card.set)
        , UI.paragraph [] [ UI.text <| (CardSet.data_of_set card.set).full_name ++ " — #" ++ String.fromInt card.number ++ " — " ++ quantity_text card.quantity ]
        ]
    }

quantity_text : Int -> String
quantity_text quantity = if quantity == 1
    then "1 copy"
    else String.fromInt quantity ++ " copies"

legality_line : Legality -> Legality -> UI.Element msg
legality_line joust melee = UI.wrappedRow [ UI.spacingXY 50 5 ]
    [ legality_widget "Joust" joust 
    , legality_widget "Melee" melee 
    ]

legality_widget : String -> Legality -> UI.Element msg
legality_widget format legality = 
    let
        color = case legality of
            Legality_Legal -> rgb255 104 172 89
            Legality_Restricted -> rgb255 234 156 28
            Legality_Banned -> rgb255 205 125 131
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
            , UI_Border.color Colors.border
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
        , UI_Border.color Colors.border
        , UI.centerX
        , UI.spacing 10
        , UI.width <| UI.maximum 600 UI.fill
        , UI.padding 10
        , UI_Background.color Colors.background
        ]
        ( [ UI.paragraph [ UI_Font.bold, UI_Font.size 20 ] [ UI.text "FAQs and clarifications" ]
        , Widgets.separator
        ]
        ++ (faqs |> List.map view_single_card_faq |> List.intersperse [ Widgets.separator ] |> List.concat)
        )

view_single_card_faq : String -> List (UI.Element msg)
view_single_card_faq faq = faq
    |> String.split "\n"
    |> List.map (\text -> if String.endsWith "?" text 
        then UI.paragraph [ UI_Font.italic ] [ UI.text text ]
        else UI.paragraph [] [ UI.text text ] )

faqs_that_mention : Card -> List String
faqs_that_mention card = Faqs.all_faqs 
    |> List.filter (\f -> List.member card.id f.cards_mentioned)
    |> List.map .text
