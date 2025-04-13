module Page_AdvancedSearch exposing (Model, Msg, init, update, view)

import Card exposing (CardType(..), House(..))
import CardSet exposing (SetOrCycle(..), Set(..), Cycle(..))
import Fontawesome
import Query exposing (Comparison(..), default_search_state)
import Widgets
import Widgets.Combo

import Browser.Navigation as Navigation
import Element as UI exposing (px)
import Element.Events as UI_Events
import Element.Input as UI_Input
import Maybe.Extra
import CardSet exposing (set_or_cycle_code_name)
import List.Extra

type ListComparison = ListComparison_Exact | ListComparison_AtLeast | ListComparison_AtMost

type Combo 
    = Combo_HouseComparison 
    | Combo_CardType 
    | Combo_Cost
    | Combo_Strength
    | Combo_Income
    | Combo_Initiative
    | Combo_Claim
    | Combo_Influence
    | Combo_Set
    | Combo_IconComparison
    | Combo_CrestComparison
    | Combo_SortOrder

type SearchIcon = SearchIcon_None | SearchIcon_Regular | SearchIcon_Naval

type SortOrder
    = SortOrder_DateAsc
    | SortOrder_DateDesc
    | SortOrder_NameAsc
    | SortOrder_NameDesc
    | SortOrder_CostAsc
    | SortOrder_CostDesc
    | SortOrder_StrengthAsc
    | SortOrder_StrengthDesc
    | SortOrder_IncomeAsc
    | SortOrder_IncomeDesc
    | SortOrder_InitiativeAsc
    | SortOrder_InitiativeDesc
    | SortOrder_ClaimAsc
    | SortOrder_ClaimDesc
    | SortOrder_InfluenceAsc
    | SortOrder_InfluenceDesc

type alias Model = 
    { header_query : String

    , name : String
    , text : String
    , house_stark : Bool
    , house_lannister : Bool
    , house_baratheon : Bool
    , house_targaryen : Bool
    , house_greyjoy : Bool
    , house_martell : Bool
    , house_neutral : Bool
    , house_comparison : ListComparison
    , card_type : Maybe CardType
    , traits : String
    , unique : Bool
    , cost : Maybe Int
    , cost_comparison : Comparison
    , strength : Maybe Int
    , strength_comparison : Comparison
    , income : Maybe Int
    , income_comparison : Comparison
    , initiative : Maybe Int
    , initiative_comparison : Comparison
    , claim : Maybe Int
    , claim_comparison : Comparison
    , influence : Maybe Int
    , influence_comparison : Comparison
    , joust_legal : Bool
    , joust_restricted : Bool
    , melee_legal : Bool
    , melee_restricted : Bool
    , icon_military : SearchIcon
    , icon_intrigue : SearchIcon
    , icon_power : SearchIcon
    , icon_comparison : ListComparison
    , crest_war : Bool
    , crest_noble : Bool
    , crest_holy : Bool
    , crest_learned : Bool
    , crest_shadow : Bool
    , crest_comparison : ListComparison
    , set : Maybe SetOrCycle
    , flavor : String
    , illustrator : String
    , sort_order : List SortOrder
    , show_duplicates : Bool

    , combo : Maybe Combo
    }

type Msg 
    = Msg_Noop
    | Msg_HeaderQueryChanged String
    | Msg_HeaderSearch
    | Msg_ModelChanged Model
    | Msg_Search
    | Msg_Combo (Widgets.Combo.Msg Combo Model)

init : Model
init = 
    { header_query = "" 
    , name = ""
    , text = ""
    , house_stark = False
    , house_lannister = False
    , house_baratheon = False
    , house_targaryen = False
    , house_greyjoy = False
    , house_martell = False
    , house_neutral = False
    , house_comparison = ListComparison_AtLeast
    , card_type = Nothing
    , traits = ""
    , unique = False
    , cost = Nothing
    , cost_comparison = Query.Comparison_Equal
    , strength = Nothing
    , strength_comparison = Query.Comparison_Equal
    , income = Nothing
    , income_comparison = Query.Comparison_Equal
    , initiative = Nothing
    , initiative_comparison = Query.Comparison_Equal
    , claim = Nothing
    , claim_comparison = Query.Comparison_Equal
    , influence = Nothing
    , influence_comparison = Query.Comparison_Equal
    , joust_legal = False
    , joust_restricted = False
    , melee_legal = False
    , melee_restricted = False
    , icon_military = SearchIcon_None
    , icon_intrigue = SearchIcon_None
    , icon_power = SearchIcon_None
    , icon_comparison = ListComparison_AtLeast
    , crest_war = False
    , crest_noble = False
    , crest_holy = False
    , crest_learned = False
    , crest_shadow = False
    , crest_comparison = ListComparison_AtLeast
    , set = Nothing
    , flavor = ""
    , illustrator = ""
    , sort_order = []
    , show_duplicates = False

    , combo = Nothing
    }

update : Navigation.Key -> Msg -> Model -> (Model, Cmd Msg)
update key msg model = case msg of
    Msg_Noop -> (model, Cmd.none)
    Msg_HeaderQueryChanged new_query -> ({ model | header_query = new_query }, Cmd.none)
    Msg_HeaderSearch -> (model, Navigation.pushUrl key (Query.search_url { default_search_state | query = model.header_query }))
    Msg_ModelChanged new_model -> (new_model, Cmd.none)
    Msg_Search -> (model, Navigation.pushUrl key (Query.search_url 
        { query = make_advanced_search_query model
        , sort = List.map sort_order_to_query_string model.sort_order
        , page = 0
        , duplicates = model.show_duplicates }))
    Msg_Combo combo_msg -> (Widgets.Combo.update (\c -> { model | combo = c }) combo_msg, Cmd.none)

view : Model -> (String, UI.Element Msg)
view model = 
    ( "Advanced search - A Game of Thrones LCG card search"
    , UI.column 
        [ UI.centerX
        , UI.spacing 20
        , UI.width UI.fill
        , UI_Events.onClick <| if Maybe.Extra.isJust model.combo then Msg_ModelChanged { model | combo = Nothing } else Msg_Noop
        ]
        [ Widgets.header model.header_query Msg_HeaderQueryChanged Msg_HeaderSearch
        , view_advanced_search model
        , Widgets.footer
        ]
    )

view_advanced_search : Model -> UI.Element Msg
view_advanced_search model = UI.column 
    [ UI.centerX
    , UI.spacing 10
    , UI.width <| UI.maximum 1000 UI.fill
    , UI.paddingXY 20 0
    ]
    [ labeled "Name" <| Widgets.input_text [] model.name "Any words in the name, e.g. \"winterfell\"" (\s -> Msg_ModelChanged { model | name = s }) Msg_Search
    , Widgets.separator
    , labeled "Text" <| Widgets.input_text [] model.text "Card's rules text, e.g. \"draw a card\"" (\s -> Msg_ModelChanged { model | text = s }) Msg_Search
    , Widgets.separator
    , labeled "House" <| house_checkboxes model
    , Widgets.separator
    , labeled "Type" <| card_type_combo model
    , Widgets.separator
    , labeled "Traits" <| traits_row model
    , Widgets.separator
    , labeled "Set" <| set_combo model
    , Widgets.separator
    , labeled "Cost" <| int_row model.combo Combo_Cost model.cost model.cost_comparison (\a -> { model | cost = a }) (\a m -> { m | cost_comparison = a })
    , Widgets.separator
    , labeled "Strength" <| int_row model.combo Combo_Strength model.strength model.strength_comparison (\a -> { model | strength = a }) (\a m -> { m | strength_comparison = a })
    , Widgets.separator
    , labeled "Income" <| int_row model.combo Combo_Income model.income model.income_comparison (\a -> { model | income = a }) (\a m -> { m | income_comparison = a })
    , Widgets.separator
    , labeled "Initiative" <| int_row model.combo Combo_Initiative model.initiative model.initiative_comparison (\a -> { model | initiative = a }) (\a m -> { m | initiative_comparison = a })
    , Widgets.separator
    , labeled "Claim" <| int_row model.combo Combo_Claim model.claim model.claim_comparison (\a -> { model | claim = a }) (\a m -> { m | claim_comparison = a })
    , Widgets.separator
    , labeled "Influence" <| int_row model.combo Combo_Influence model.influence model.influence_comparison (\a -> { model | influence = a }) (\a m -> { m | influence_comparison = a })
    , Widgets.separator
    , labeled "Legality (Joust)" <| legality_joust_row model
    , Widgets.separator
    , labeled "Legality (Melee)" <| legality_melee_row model
    , Widgets.separator
    , labeled "Icons" <| icon_row model
    , Widgets.separator
    , labeled "Crests" <| crest_row model
    , Widgets.separator
    , labeled "Flavor text" <| Widgets.input_text [] model.flavor "Any words in the decorative flavor test, e.g. \"Card designed by\"" (\s -> Msg_ModelChanged { model | flavor = s }) Msg_Search
    , Widgets.separator
    , labeled "Illustrator" <| Widgets.input_text [] model.illustrator "An illustrator's name, e.g. \"Matson\"" (\s -> Msg_ModelChanged { model | illustrator = s }) Msg_Search
    , Widgets.separator
    , labeled "Order" <| sort_order_row model
    , Widgets.separator
    , labeled "Duplicates" <| text_checkbox [] "Show duplicate cards" model.show_duplicates (\b -> { model | show_duplicates = b })
    , Widgets.separator
    , labeled "" <| search_button model
    ]

labeled : String -> UI.Element Msg -> UI.Element Msg
labeled label widget = UI.row [ UI.width UI.fill ]
    [ UI.el 
        [ UI.width (px 200)
        , UI.alignTop
        , UI.alignLeft
        , UI.paddingEach { top = 5, left = 0, right = 0, bottom = 0 } 
        ] 
        (UI.text label)
    , widget
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
    , Widgets.Combo.view [ UI.width (px 250) ] model.combo 
        { id = Combo_HouseComparison
        , curr = model.house_comparison
        , view = \_ c -> c |> list_comparison_to_string "houses" |> UI.text
        , options = [ ListComparison_Exact, ListComparison_AtLeast, ListComparison_AtMost ]
        , select = \opt m -> { m | house_comparison = opt }
        }
        |> UI.map Msg_Combo
    ]

card_type_combo : Model -> UI.Element Msg
card_type_combo model = Widgets.Combo.view [ UI.width (px 200) ] model.combo
    { id = Combo_CardType
    , curr = model.card_type
    , view = \_ t -> card_type_combo_view t
    , options = 
        [ Nothing
        , Just CardType_Character
        , Just CardType_Location
        , Just CardType_Attachment
        , Just CardType_Event
        , Just CardType_Plot
        , Just CardType_Agenda
        , Just CardType_House
        ]
    , select = \opt m -> { m | card_type = opt }
    }
    |> UI.map Msg_Combo

traits_row : Model -> UI.Element Msg
traits_row model = UI.row 
    [ UI.width UI.fill
    , UI.spacing 10 
    ]
    [ Widgets.input_text [] model.traits "Card's traits, e.g. \"knight\"" (\s -> Msg_ModelChanged { model | traits = s }) Msg_Search
    , text_checkbox [ UI.width UI.shrink ] "Unique" model.unique (\b -> { model | unique = b })
    ]

int_row : Maybe Combo -> Combo -> Maybe Int -> Comparison -> (Maybe Int -> Model) -> (Comparison -> Model -> Model) -> UI.Element Msg
int_row curr_combo id value comparison value_change comparison_change = UI.row [ UI.spacing 10 ]
    [ Widgets.Combo.view [ UI.width (px 250) ] curr_combo 
        { id = id
        , curr = comparison
        , view = \_ c -> c |> comparison_to_string |> UI.text
        , options = [ Comparison_Equal, Comparison_NotEqual, Comparison_GreaterThan, Comparison_GreaterThanOrEqual, Comparison_LessThan, Comparison_LessThanOrEqual ]
        , select = \opt m -> comparison_change opt m
        }
        |> UI.map Msg_Combo
    , Widgets.input_text [ UI.width (px 250) ]
        (Maybe.map String.fromInt value |> Maybe.withDefault "") 
        ""
        (\text -> if text == ""
            then Msg_ModelChanged <| value_change Nothing
            else case String.toInt text of
                Nothing -> Msg_Noop
                Just x -> Msg_ModelChanged <| value_change <| Just x
        )
        Msg_Search
    ]

legality_joust_row : Model -> UI.Element Msg
legality_joust_row model = UI.row [ UI.spacing 30 ]
    [ text_checkbox [] "Legal" model.joust_legal (\b -> { model | joust_legal = b })
    , text_checkbox [] "Restricted" model.joust_restricted (\b -> { model | joust_restricted = b })
    ]

legality_melee_row : Model -> UI.Element Msg
legality_melee_row model = UI.row [ UI.spacing 30 ]
    [ text_checkbox [] "Legal" model.melee_legal (\b -> { model | melee_legal = b })
    , text_checkbox [] "Restricted" model.melee_restricted (\b -> { model | melee_restricted = b })
    ]


icon_row : Model -> UI.Element Msg
icon_row model = UI.column [ UI.width UI.fill, UI.spacing 10 ]
    [ UI.wrappedRow [ UI.spacing 30 ]
        [ icon_checkbox "/images/icons/military.png" model.icon_military (\b -> { model | icon_military = b })
        , icon_checkbox "/images/icons/intrigue.png" model.icon_intrigue (\b -> { model | icon_intrigue = b })
        , icon_checkbox "/images/icons/power.png" model.icon_power (\b -> { model | icon_power = b })
        ]
    , Widgets.Combo.view [ UI.width (px 250) ] model.combo 
        { id = Combo_IconComparison
        , curr = model.icon_comparison
        , view = \_ c -> c |> list_comparison_to_string "icons" |> UI.text
        , options = [ ListComparison_Exact, ListComparison_AtLeast, ListComparison_AtMost ]
        , select = \opt m -> { m | icon_comparison = opt }
        }
        |> UI.map Msg_Combo
    ]

crest_row : Model -> UI.Element Msg
crest_row model = UI.column [ UI.width UI.fill, UI.spacing 10 ]
    [ UI.wrappedRow [ UI.spacing 30 ]
        [ image_checkbox [] "/images/crests/war.png" model.crest_war (\b -> { model | crest_war = b })
        , image_checkbox [] "/images/crests/noble.png" model.crest_noble (\b -> { model | crest_noble = b })
        , image_checkbox [] "/images/crests/holy.png" model.crest_holy (\b -> { model | crest_holy = b })
        , image_checkbox [] "/images/crests/learned.png" model.crest_learned (\b -> { model | crest_learned = b })
        , image_checkbox [] "/images/crests/shadow.png" model.crest_shadow (\b -> { model | crest_shadow = b })
        ]
    , Widgets.Combo.view [ UI.width (px 250) ] model.combo 
        { id = Combo_CrestComparison
        , curr = model.crest_comparison
        , view = \_ c -> c |> list_comparison_to_string "crests" |> UI.text
        , options = [ ListComparison_Exact, ListComparison_AtLeast, ListComparison_AtMost ]
        , select = \opt m -> { m | crest_comparison = opt }
        }
        |> UI.map Msg_Combo
    ]

set_combo : Model -> UI.Element Msg
set_combo model = Widgets.Combo.view [ UI.width (px 400) ] model.combo
    { id = Combo_Set
    , curr = model.set
    , view = \preview maybe -> case maybe of
        Nothing -> UI.text "Any"
        Just s -> UI.row [ UI.spacing <| if not preview && CardSet.is_set_in_cycle s then 40 else 5 ]
            [ Widgets.set_icon [] s
            , UI.text <| CardSet.set_or_cycle_full_name s
            ]
    , options = Nothing :: List.map Just CardSet.all_sets_and_cycles_in_order
    , select = \s m -> { m | set = s }
    }
    |> UI.map Msg_Combo


search_button : Model -> UI.Element Msg
search_button model = UI.link
    Widgets.button_style_attributes
    { url = Query.search_url 
        { query = make_advanced_search_query model
        , sort = List.map sort_order_to_query_string model.sort_order
        , page = 0
        , duplicates = model.show_duplicates
        }
    , label = UI.text "Search"
    }

checkbox : List (UI.Attribute Msg) -> UI.Element Msg -> Bool -> (Bool -> Model) -> UI.Element Msg
checkbox attrs label checked msg = UI_Input.checkbox attrs
    { checked = checked
    , onChange = \b -> Msg_ModelChanged (msg b)
    , icon = UI_Input.defaultCheckbox
    , label = UI_Input.labelRight [] label
    }

image_checkbox : List (UI.Attribute Msg) -> String -> Bool -> (Bool -> Model) -> UI.Element Msg
image_checkbox attrs label checked msg = checkbox attrs (UI.image [ UI.height (px 30) ] { src = label, description = "" }) checked msg

icon_checkbox : String -> SearchIcon -> (SearchIcon -> Model) -> UI.Element Msg
icon_checkbox image state msg = UI.row [ UI.spacing 5 ]
    [ UI.column [ UI.spacing 4 ]
        [ UI_Input.checkbox []
            { checked = state == SearchIcon_Regular
            , onChange = \b -> Msg_ModelChanged <| msg <| if b then SearchIcon_Regular else SearchIcon_None
            , icon = UI_Input.defaultCheckbox
            , label = UI_Input.labelHidden "Regular"
            }
        , UI_Input.checkbox []
            { checked = state == SearchIcon_Naval
            , onChange = \b -> Msg_ModelChanged <| msg <| if b then SearchIcon_Naval else SearchIcon_None
            , icon = \b -> if b 
                then UI.el 
                    [ UI.inFront <| UI.image [ UI.width UI.fill, UI.height UI.fill ] { src = "/images/naval.png", description = "" }  
                    ] 
                    (UI_Input.defaultCheckbox False)
                else UI_Input.defaultCheckbox False 
            , label = UI_Input.labelHidden "Naval"
            }
        ]
    , UI.image 
        [ UI.height (px 30)
        , UI_Events.onClick <| Msg_ModelChanged <| msg <| case state of
            SearchIcon_None -> SearchIcon_Regular
            SearchIcon_Regular -> SearchIcon_Naval
            SearchIcon_Naval -> SearchIcon_None
        ] 
        { src = image, description = "" }
    ]

text_checkbox : List (UI.Attribute Msg) -> String -> Bool -> (Bool -> Model) -> UI.Element Msg
text_checkbox attrs label checked msg = checkbox attrs (UI.text label) checked msg

list_comparison_to_string : String -> ListComparison -> String
list_comparison_to_string name cmp = case cmp of
    ListComparison_Exact -> "Exactly these " ++ name
    ListComparison_AtLeast -> "At least these " ++ name
    ListComparison_AtMost -> "At most these " ++ name

card_type_combo_view : Maybe CardType -> UI.Element msg
card_type_combo_view t = 
    let
        (icon, label) = case t of
            Nothing -> ("\u{002a}", "Any") -- fa-asterisk
            Just CardType_Character -> ("\u{f007}", "Character") -- fa-user
            Just CardType_Location -> ("\u{e52f}", "Location") -- fa-mountain-sun
            Just CardType_Attachment -> ("\u{f0c1}", "Attachment") -- fa-link
            Just CardType_Event -> ("\u{f520}", "Event") -- fa-crow
            Just CardType_Plot -> ("\u{f5fd}", "Plot") -- fa-layer-group
            Just CardType_Agenda -> ("\u{f70e}", "Agenda") -- fa-scroll
            Just CardType_House -> ("\u{f132}", "House") -- fa-shield
    in
        UI.row [ UI.spacing 10 ] [ UI.el [UI.width (px 25)] <| Fontawesome.text [ UI.centerX ] icon, UI.text label ]

sort_order_row : Model -> UI.Element Msg
sort_order_row model = Widgets.Combo.multi_combo [] model.combo
    { id = Combo_SortOrder
    , curr = model.sort_order
    , view = \_ a -> UI.text <| sort_order_to_ui_string a
    , options =
        [ SortOrder_DateAsc
        , SortOrder_DateDesc
        , SortOrder_NameAsc
        , SortOrder_NameDesc
        , SortOrder_CostAsc
        , SortOrder_CostDesc
        , SortOrder_StrengthAsc
        , SortOrder_StrengthDesc
        , SortOrder_IncomeAsc
        , SortOrder_IncomeDesc
        , SortOrder_InitiativeAsc
        , SortOrder_InitiativeDesc
        , SortOrder_ClaimAsc
        , SortOrder_ClaimDesc
        , SortOrder_InfluenceAsc
        , SortOrder_InfluenceDesc
        ]
    , select = \a m -> { m | sort_order = List.Extra.unique (m.sort_order ++ [ a ]) }
    , unselect = \i m -> { m | sort_order = List.Extra.removeAt i m.sort_order }
    , location = Widgets.Combo.Location_Above
    , width_override = Just (px 250)
    }
    |> UI.map Msg_Combo

comparison_to_string : Comparison -> String
comparison_to_string cmp = case cmp of
    Comparison_Equal -> "Equal to"
    Comparison_NotEqual -> "Not equal to"
    Comparison_GreaterThan -> "Greater than"
    Comparison_GreaterThanOrEqual -> "Greater than or equal to"
    Comparison_LessThan -> "Less than"
    Comparison_LessThanOrEqual -> "Less than or equal to"

make_advanced_search_query : Model -> String
make_advanced_search_query model =
    let
        string_part name str = if str == "" 
            then Nothing 
            else str |> Query.split_words_quoted |> List.map (\s -> name ++ ":" ++ quote_token_with_spaces s) |> String.join " " |> Just
        search_comparison_str cmp = case cmp of
            ListComparison_Exact -> "="
            ListComparison_AtLeast -> ">="
            ListComparison_AtMost -> "<="
        bools_part name comparison_str bools = bools
            |> List.map (\(b, s) -> if b then s else "")
            |> String.join ""
            |> (\s -> if s == "" then Nothing else Just s)
            |> Maybe.map (\s -> name ++ comparison_str ++ s)
        type_part = case model.card_type of
            Nothing -> Nothing
            Just CardType_Character -> Just "type:c"
            Just CardType_Location -> Just "type:l"
            Just CardType_Attachment -> Just "type:at"
            Just CardType_Event -> Just "type:e"
            Just CardType_Plot -> Just "type:p"
            Just CardType_Agenda -> Just "type:ag"
            Just CardType_House -> Just "type:h"
        int_part name int c =
            let
                comparison_str = case c of
                    Comparison_Equal -> "="
                    Comparison_NotEqual -> "!="
                    Comparison_GreaterThan -> ">"
                    Comparison_GreaterThanOrEqual -> ">="
                    Comparison_LessThan -> "<"
                    Comparison_LessThanOrEqual -> "<="
            in
                int |> Maybe.map (\i -> name ++ comparison_str ++ String.fromInt i)
        parts =
            [ if model.name == "" then Nothing else Just model.name
            , string_part "text" model.text
            , bools_part "house" (search_comparison_str model.house_comparison)
                [ (model.house_stark, "s")
                , (model.house_lannister, "l")
                , (model.house_baratheon, "b")
                , (model.house_targaryen, "t")
                , (model.house_martell, "m") 
                , (model.house_greyjoy, "g") 
                , (model.house_neutral, "n") 
                ]
            , type_part
            , string_part "trait" model.traits
            , if model.unique then Just "unique:t" else Nothing
            , model.set |> Maybe.map (\s -> "set=" ++ set_or_cycle_code_name s)
            , int_part "cost" model.cost model.cost_comparison
            , int_part "strength" model.strength model.strength_comparison
            , int_part "income" model.income model.income_comparison
            , int_part "initiative" model.initiative model.initiative_comparison
            , int_part "claim" model.claim model.claim_comparison
            , int_part "influence" model.influence model.influence_comparison
            , bools_part "joust" ":" [ (model.joust_legal, "l"), (model.joust_restricted, "r") ]
            , bools_part "melee" ":" [ (model.melee_legal, "l"), (model.melee_restricted, "r") ]
            , bools_part "icon" (search_comparison_str model.icon_comparison)
                [ (model.icon_military == SearchIcon_Regular, "m")
                , (model.icon_military == SearchIcon_Naval, "mn")
                , (model.icon_intrigue == SearchIcon_Regular, "i")
                , (model.icon_intrigue == SearchIcon_Naval, "in")
                , (model.icon_power == SearchIcon_Regular, "p")
                , (model.icon_power == SearchIcon_Naval, "pn")
                ]
            , bools_part "crest" (search_comparison_str model.crest_comparison)
                [ (model.crest_war, "w")
                , (model.crest_noble, "n")
                , (model.crest_holy, "h")
                , (model.crest_learned, "l")
                , (model.crest_shadow, "s")
                ]
            , string_part "flavor" model.flavor
            , string_part "illustrator" model.illustrator
            ]
    in
        parts |> List.filterMap identity |> String.join " "

quote_token_with_spaces : String -> String
quote_token_with_spaces token = if String.contains " " token
    then "\"" ++ token ++ "\""
    else token

sort_order_to_query_string : SortOrder -> String
sort_order_to_query_string order = case order of
    SortOrder_DateAsc -> "date"
    SortOrder_DateDesc -> "date>"
    SortOrder_NameAsc -> "name"
    SortOrder_NameDesc -> "name>"
    SortOrder_CostAsc -> "cost"
    SortOrder_CostDesc -> "cost>"
    SortOrder_StrengthAsc -> "str"
    SortOrder_StrengthDesc -> "str>"
    SortOrder_IncomeAsc -> "inc"
    SortOrder_IncomeDesc -> "inc>"
    SortOrder_InitiativeAsc -> "init"
    SortOrder_InitiativeDesc -> "int>"
    SortOrder_ClaimAsc -> "claim"
    SortOrder_ClaimDesc -> "claim>"
    SortOrder_InfluenceAsc -> "inf"
    SortOrder_InfluenceDesc -> "inf>"

sort_order_to_ui_string : SortOrder -> String
sort_order_to_ui_string order = case order of
    SortOrder_DateAsc -> "Oldest to newest"
    SortOrder_DateDesc -> "Newest to oldest"
    SortOrder_NameAsc -> "Name A-Z"
    SortOrder_NameDesc -> "Name Z-A"
    SortOrder_CostAsc -> "Cost (ascending)"
    SortOrder_CostDesc -> "Cost (descending)"
    SortOrder_StrengthAsc -> "Strength (ascending)"
    SortOrder_StrengthDesc -> "Strength (descending)"
    SortOrder_IncomeAsc -> "Income (ascending)"
    SortOrder_IncomeDesc -> "Income (descending)"
    SortOrder_InitiativeAsc -> "Initiative (ascending)"
    SortOrder_InitiativeDesc -> "Initiative (descending)"
    SortOrder_ClaimAsc -> "Claim (ascending)"
    SortOrder_ClaimDesc -> "Claim (descending)"
    SortOrder_InfluenceAsc -> "Influence (ascending)"
    SortOrder_InfluenceDesc -> "Influence (descending)"
