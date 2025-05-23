module Query exposing (parse, search_url, search_url_from, search, Comparison(..), split_words_quoted, SearchState, default_search_state, encode, decode)

import Card exposing(Card, CardType, House, Legality, Icon, Crest, Legality(..), CardType(..), Crest(..), House(..), Icon(..))
import CardSet exposing (SetOrCycle(..), Set)

import List.Extra
import Parser exposing (Parser, (|.), (|=))
import Result.Extra
import Url exposing (Url)

encode : String -> String
encode query = query
    |> String.replace " " "+"
    |> Url.percentEncode

decode : String -> String
decode encoded_query = encoded_query
    |> Url.percentDecode
    |> Maybe.withDefault encoded_query
    |> String.replace "+" " "

type alias SearchState = { query : String, sort : List String, page : Int, duplicates : Bool }
default_search_state : SearchState
default_search_state = { query = "", sort = [], page = 0, duplicates = False }

parse : Maybe String -> SearchState
parse query_line = 
    let
        parts = query_line |> Maybe.map (String.split "&") |> Maybe.withDefault []
        parse_part part result = 
            if String.startsWith "q=" part then 
                { result | query = decode (String.dropLeft 2 part) }
            else if String.startsWith "page=" part then
                case String.toInt (String.dropLeft 5 part) of
                    Just page -> { result | page = page }
                    Nothing -> result
            else if String.startsWith "sort=" part then
                { result | sort = part |> String.dropLeft 5 |> decode |> String.split "," }
            else if String.startsWith "dup=" part && is_true_string_representation (String.dropLeft 4 part) then
                { result | duplicates = True }
            else if String.startsWith "dup=" part && is_false_string_representation (String.dropLeft 4 part) then
                { result | duplicates = False }
            else
                result
    in
        List.foldl parse_part default_search_state parts

is_true_string_representation : String -> Bool
is_true_string_representation str = String.toLower str == "t" || String.toLower str == "true" || str == "1"

is_false_string_representation : String -> Bool
is_false_string_representation str = String.toLower str == "f" || String.toLower str == "false" || str == "0"

make_query : SearchState -> Maybe String
make_query search_state = if search_state == default_search_state
    then Nothing
    else let
            query = if search_state.query == "" then "" else "q=" ++ encode search_state.query
            page = if search_state.page == 0 then "" else "page=" ++ String.fromInt search_state.page
            sort = if search_state.sort == [] then "" else "sort=" ++ (search_state.sort |> String.join "," |> encode)
            duplicates = if search_state.duplicates then "dup=t" else ""
        in
            [query, page, sort, duplicates] |> List.filter (not << String.isEmpty) |> String.join "&" |> Just

search_url : SearchState -> String
search_url state = case make_query state of
    Nothing -> "/search"
    Just query -> "/search?" ++ query 

search_url_from : Url -> SearchState -> String
search_url_from url query = Url.toString { url | query = make_query query }

search : { a | query : String, sort : List String, duplicates : Bool } -> List Card -> Result String (List Card)
search args cards =
    let
        tokens = split_words_quoted args.query
        predicates = List.map parse_predicate_from_token tokens
        (order, sort_errors) = parse_sort_orders args.sort
        errors = sort_errors
        deduplicate = if args.duplicates then identity else List.Extra.uniqueBy Card.duplicate_id
    in
        if List.isEmpty errors
            then cards 
                |> List.filter (card_passes_predicates predicates)
                |> deduplicate
                |> List.sortWith order 
                |> Ok
            else errors |> String.join "\n" |> Err


type Comparison
    = Comparison_Equal
    | Comparison_NotEqual
    | Comparison_GreaterThan
    | Comparison_GreaterThanOrEqual
    | Comparison_LessThan
    | Comparison_LessThanOrEqual

type Predicate
    = Predicate_Name String
    | Predicate_Number Comparison Int
    | Predicate_Quantity Comparison Int
    | Predicate_Cost Comparison Int
    | Predicate_Strength Comparison Int
    | Predicate_Income Comparison Int
    | Predicate_Initiative Comparison Int
    | Predicate_Claim Comparison Int
    | Predicate_Influence Comparison Int
    | Predicate_Text String
    | Predicate_Flavor String
    | Predicate_Type CardType
    | Predicate_Set Comparison SetOrCycle
    | Predicate_Illustrator String
    | Predicate_House Comparison (List House)
    | Predicate_Unique Bool
    | Predicate_LegalityJoust (List Legality)
    | Predicate_LegalityMelee (List Legality)
    | Predicate_Traits String
    | Predicate_Icons Comparison (List Icon)
    | Predicate_Crest Comparison (List Crest)
    | Predicate_Negate(Predicate)

card_passes_predicate : Predicate -> Card -> Bool
card_passes_predicate predicate card = case predicate of
    Predicate_Name s -> string_contains_predicate s (Just card.name)
    Predicate_Number c n -> int_comparison_predicate n c (Just card.number)
    Predicate_Quantity c n -> int_comparison_predicate n c (Just card.quantity)
    Predicate_Cost c n -> int_comparison_predicate n c card.cost
    Predicate_Strength c n -> int_comparison_predicate n c card.strength
    Predicate_Income c n -> int_comparison_predicate n c card.income
    Predicate_Initiative c n -> int_comparison_predicate n c card.initiative
    Predicate_Claim c n -> int_comparison_predicate n c card.claim
    Predicate_Influence c n -> int_comparison_predicate n c card.influence
    Predicate_Text s -> string_contains_predicate s card.rules_text
    Predicate_Flavor s -> string_contains_predicate s card.flavor_text
    Predicate_Type t -> card.card_type == t
    Predicate_Set c s -> set_predicate s c card.set
    Predicate_Illustrator s -> string_contains_predicate s (Just card.illustrator)
    Predicate_House c h -> house_predicate h c card.house
    Predicate_Unique b -> card.unique == b
    Predicate_LegalityJoust ls -> List.member card.legality_joust ls
    Predicate_LegalityMelee ls -> List.member card.legality_melee ls
    Predicate_Traits t -> traits_predicate t card.traits
    Predicate_Icons c p -> icons_predicate p c card.icons card.card_type
    Predicate_Crest c p -> crests_predicate p c card.crest
    Predicate_Negate p -> not <| card_passes_predicate p card

string_contains_predicate : String -> Maybe String -> Bool
string_contains_predicate predicate value = case value of
    Nothing -> False
    Just v -> String.contains predicate (String.toLower v)

int_comparison_predicate : Int -> Comparison -> Maybe Int -> Bool
int_comparison_predicate predicate comparison value = case value of
    Nothing -> False
    Just v -> case comparison of
        Comparison_Equal -> v == predicate
        Comparison_NotEqual -> v /= predicate
        Comparison_GreaterThan -> v > predicate
        Comparison_GreaterThanOrEqual -> v >= predicate
        Comparison_LessThan -> v < predicate
        Comparison_LessThanOrEqual -> v <= predicate

traits_predicate : String -> List String -> Bool
traits_predicate predicate traits = List.any (\trait -> String.contains predicate (String.toLower trait)) traits

set_predicate_less_than : SetOrCycle -> Set -> Bool
set_predicate_less_than predicate set = case predicate of
    SetOrCycle_Set predicate_set -> CardSet.set_sort_order set < CardSet.set_sort_order predicate_set
    SetOrCycle_Cycle cycle -> CardSet.set_sort_order set < CardSet.set_sort_order (CardSet.first_set_in_cycle cycle)

set_predicate_greater_than : SetOrCycle -> Set -> Bool
set_predicate_greater_than predicate set = case predicate of
    SetOrCycle_Set predicate_set -> CardSet.set_sort_order set > CardSet.set_sort_order predicate_set
    SetOrCycle_Cycle cycle -> CardSet.set_sort_order set > CardSet.set_sort_order (CardSet.last_set_in_cycle cycle)

set_predicate : SetOrCycle -> Comparison -> Set -> Bool
set_predicate predicate comparison set = case comparison of
    Comparison_Equal -> CardSet.set_belongs_to predicate set
    Comparison_NotEqual -> not <| CardSet.set_belongs_to predicate set
    Comparison_LessThan -> set_predicate_less_than predicate set
    Comparison_LessThanOrEqual -> CardSet.set_belongs_to predicate set || set_predicate_less_than predicate set
    Comparison_GreaterThan -> set_predicate_greater_than predicate set
    Comparison_GreaterThanOrEqual -> CardSet.set_belongs_to predicate set || set_predicate_greater_than predicate set

list_less_than : List a -> List a -> Bool
list_less_than a b = List.length a < List.length b && List.all (\h -> List.member h b) a

house_less_than : List House -> List House -> Bool
house_less_than a b = 
    if List.member House_Neutral a
        then False -- House_Neutral is greater than every other, so it is never less than
        else if List.member House_Neutral b
            then True
            else list_less_than a b

icons_less_than : List Icon -> List Icon -> Bool
icons_less_than a b =  a /= b
    && List.all (\i -> List.member i b || (not (Card.icon_is_naval i) && List.member (Card.icon_make_naval True i) b)) a
    --&& List.all (\i -> List.member i b) a

house_predicate : List House -> Comparison -> List House -> Bool
house_predicate predicate comparison house = case comparison of
    Comparison_Equal -> predicate == house
    Comparison_NotEqual -> predicate /= house
    Comparison_GreaterThan -> house_less_than predicate house
    Comparison_GreaterThanOrEqual -> predicate == house || house_less_than predicate house
    Comparison_LessThan -> house_less_than house predicate
    Comparison_LessThanOrEqual -> predicate == house || house_less_than house predicate

icons_predicate : List Icon -> Comparison -> List Icon -> CardType -> Bool
icons_predicate predicate comparison icons card_type = if card_type /= CardType_Character
    then False
    else case comparison of
        Comparison_Equal -> predicate == icons
        Comparison_NotEqual -> predicate /= icons
        Comparison_GreaterThan -> icons_less_than predicate icons
        Comparison_GreaterThanOrEqual -> predicate == icons || icons_less_than predicate icons
        Comparison_LessThan -> icons_less_than icons predicate
        Comparison_LessThanOrEqual -> predicate == icons || icons_less_than icons predicate

crests_predicate : List Crest -> Comparison -> List Crest -> Bool
crests_predicate predicate comparison crests = case comparison of
    Comparison_Equal -> predicate == crests
    Comparison_NotEqual -> predicate /= crests
    Comparison_GreaterThan -> list_less_than predicate crests
    Comparison_GreaterThanOrEqual -> predicate == crests || list_less_than predicate crests
    Comparison_LessThan -> list_less_than crests predicate
    Comparison_LessThanOrEqual -> predicate == crests || list_less_than crests predicate

card_passes_predicates : List Predicate -> Card -> Bool
card_passes_predicates predicates card = List.all (\p -> card_passes_predicate p card) predicates

insertion_pos : List Int -> Int -> Int
insertion_pos list new = case list of
    [] -> 0
    (first::next) -> if first > new then 0 else 1 + insertion_pos next new

adjacent_pairs : List a -> List (a, a)
adjacent_pairs list = case list of
    [] -> []
    [_] -> []
    (a::b::rest) -> (a, b) :: adjacent_pairs (b::rest)

split_words_quoted : String -> List String
split_words_quoted query =
    let
        quotes = String.indices "\"" query
        spaces = String.indices " " query
        -- We only split at spaces that are not between two quotes
        splits = spaces |> List.filter (\i -> (insertion_pos quotes i |> modBy 2) == 0)
        slices = adjacent_pairs ((-1::splits) ++ [ String.length query ])
    in
        slices
            |> List.map (\(first, last) -> String.slice (first + 1) last query)
            |> List.map (String.replace "\"" "")
            |> List.map String.toLower
            |> List.filter (String.isEmpty >> not)

parse_predicate_from_token : String -> Predicate
parse_predicate_from_token token = 
    Parser.run (parse_predicate ()) token
        |> Result.withDefault (Predicate_Name token)

parse_predicate : () -> Parser Predicate
parse_predicate _ = Parser.oneOf
    [ Parser.succeed Predicate_Number |. Parser.symbol "number" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Quantity |. Parser.symbol "quantity" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Cost |. Parser.symbol "cost" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Strength |. Parser.symbol "strength" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Income |. Parser.symbol "income" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Initiative |. Parser.symbol "initiative" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Claim |. Parser.symbol "claim" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Influence |. Parser.symbol "influence" |= parse_comparison |= Parser.int |. Parser.end
    , Parser.succeed Predicate_Text |. Parser.symbol "text:" |= parse_until_end
    , Parser.succeed Predicate_Flavor |. Parser.symbol "flavor:" |= parse_until_end
    , Parser.succeed Predicate_Type |. Parser.symbol "type:" |= parse_type
    , Parser.succeed Predicate_Set |. Parser.symbol "set" |= parse_comparison |= parse_set
    , Parser.succeed Predicate_Illustrator |. Parser.symbol "illustrator:" |= parse_until_end
    , Parser.succeed Predicate_House |. Parser.symbol "house" |= parse_comparison |= parse_houses
    , Parser.succeed Predicate_Unique |. Parser.symbol "unique:" |= parse_tf_bool |. Parser.end
    , Parser.succeed Predicate_LegalityJoust |. Parser.symbol "joust:" |= parse_legalities
    , Parser.succeed Predicate_LegalityMelee |. Parser.symbol "melee:" |= parse_legalities
    , Parser.succeed Predicate_Traits |. Parser.symbol "trait:" |= parse_until_end
    , Parser.succeed Predicate_Icons |. Parser.symbol "icon" |= parse_comparison |= parse_icons
    , Parser.succeed Predicate_Crest |. Parser.symbol "crest" |= parse_comparison |= parse_crests
    , Parser.succeed Predicate_Negate |. Parser.symbol "!" |= (Parser.lazy parse_predicate)
    , Parser.succeed Predicate_Name |= parse_until_end
    ]

parse_comparison : Parser Comparison
parse_comparison = Parser.oneOf 
    [ Parser.succeed Comparison_LessThanOrEqual |. Parser.symbol "<="
    , Parser.succeed Comparison_GreaterThanOrEqual |. Parser.symbol ">="
    , Parser.succeed Comparison_LessThan |. Parser.symbol "<"
    , Parser.succeed Comparison_GreaterThan |. Parser.symbol ">"
    , Parser.succeed Comparison_Equal |. Parser.symbol "="
    , Parser.succeed Comparison_NotEqual |. Parser.symbol "!="
    ]

parse_until_end : Parser String
parse_until_end = Parser.chompWhile (always True) |> Parser.getChompedString

parse_type : Parser CardType
parse_type = parse_until_end
    |> Parser.andThen (\s -> case s of 
        "character" -> Parser.succeed CardType_Character
        "c" -> Parser.succeed CardType_Character
        "event" -> Parser.succeed CardType_Event
        "e" -> Parser.succeed CardType_Event
        "location" -> Parser.succeed CardType_Location
        "l" -> Parser.succeed CardType_Location
        "attachment" -> Parser.succeed CardType_Attachment
        "at" -> Parser.succeed CardType_Attachment
        "plot" -> Parser.succeed CardType_Plot
        "p" -> Parser.succeed CardType_Plot
        "agenda" -> Parser.succeed CardType_Agenda
        "ag" -> Parser.succeed CardType_Agenda
        "house" -> Parser.succeed CardType_House
        "h" -> Parser.succeed CardType_House
        other -> Parser.problem ("\"" ++ other ++ "\" is not a card type")
    )

parse_set : Parser SetOrCycle
parse_set = parse_until_end
    |> Parser.andThen (\s -> case List.Extra.find (\d -> d.code_name == s) CardSet.set_data of
        Just data -> Parser.succeed <| SetOrCycle_Set data.set
        Nothing -> case List.Extra.find (\d -> d.code_name == s) CardSet.cycle_data of
            Just data -> Parser.succeed <| SetOrCycle_Cycle data.cycle
            Nothing-> Parser.problem <| "'" ++ s ++ "' is not the name of a set or cycle."
    )

parse_tf_bool : Parser Bool
parse_tf_bool = Parser.oneOf 
    [ Parser.succeed True |. Parser.symbol "t"
    , Parser.succeed False |. Parser.symbol "f"
    ]

parse_legalities : Parser (List Legality)
parse_legalities = parse_until_end
    |> Parser.andThen (\s -> s
        |> String.toList
        |> List.map parse_legality_char
        |> Result.Extra.combine
        |> (\r -> case r of
            Ok houses -> Parser.succeed houses
            Err msg -> Parser.problem msg
        )
    )

parse_legality_char : Char -> Result String Legality
parse_legality_char c =  case c of
    'l' -> Ok Legality_Legal
    'r' -> Ok Legality_Restricted
    'b' -> Ok Legality_Banned
    other -> Err <| "\"" ++ String.fromChar other ++ "\" is not a legality. Allowed legalities are 'l', 'r' and 'b'."

parse_crest : Char -> Result String Crest
parse_crest name = case name of
    'h' -> Ok Crest_Holy
    'n' -> Ok Crest_Noble
    'w' -> Ok Crest_War
    'l' -> Ok Crest_Learned
    's' -> Ok Crest_Shadow
    other -> Err <| "\"" ++ String.fromChar other ++ "\" is not a crest. Allowed houses are 'h', 'n', 'w', 'l' and 's'."

parse_crests : Parser (List Crest)
parse_crests = parse_list parse_crest Card.crest_sort_order

parse_house : Char -> Result String House
parse_house name = case name of
    's' -> Ok House_Stark
    'l' -> Ok House_Lannister
    'b' -> Ok House_Baratheon
    't' -> Ok House_Targaryen
    'm' -> Ok House_Martell
    'g' -> Ok House_Greyjoy
    'n' -> Ok House_Neutral
    other -> Err <| "\"" ++ String.fromChar other ++ "\" is not a house. Allowed houses are 's', 'l', 'b', 't', 'm', 'g' and 'n'."

parse_houses : Parser (List House)
parse_houses = parse_list parse_house Card.house_sort_order
    
parse_icons : Parser (List Icon)
parse_icons = Parser.loop []
    (\state -> Parser.oneOf
        [ Parser.succeed (Parser.Loop (Icon_Military { naval = True } :: state)) |. Parser.symbol "mn"
        , Parser.succeed (Parser.Loop (Icon_Military { naval = False } :: state)) |. Parser.symbol "m"
        , Parser.succeed (Parser.Loop (Icon_Intrigue { naval = True } :: state)) |. Parser.symbol "in"
        , Parser.succeed (Parser.Loop (Icon_Intrigue { naval = False } :: state)) |. Parser.symbol "i"
        , Parser.succeed (Parser.Loop (Icon_Power { naval = True } :: state)) |. Parser.symbol "pn"
        , Parser.succeed (Parser.Loop (Icon_Power { naval = False } :: state)) |. Parser.symbol "p"
        , Parser.succeed () |> Parser.map (\_ -> state
            |> List.sortBy Card.icon_sort_order
            |> List.Extra.unique
            |> Parser.Done
        )
        ]
    )

parse_list : (Char -> Result String a) -> (a -> Int) -> Parser (List a)
parse_list parse_single sort_order = parse_until_end
    |> Parser.andThen (\s -> s
        |> String.toList
        |> List.map parse_single
        |> Result.Extra.combine
        |> Result.map (List.sortBy sort_order)
        |> Result.map List.Extra.unique
        |> (\r -> case r of
            Ok houses -> Parser.succeed houses
            Err msg -> Parser.problem msg
        )
    )

lexicographical_combine : (a -> a -> Order) -> (a -> a -> Order) -> (a -> a -> Order)
lexicographical_combine first second = \x y -> case first x y of
    LT -> LT
    GT -> GT
    EQ -> second x y
        
compare_maybe : Maybe comparable -> Maybe comparable -> Order
compare_maybe mx my = case (mx, my) of
    (Nothing, Nothing) -> EQ
    (Nothing, Just _) -> GT
    (Just _, Nothing) -> LT
    (Just x, Just y) -> compare x y


parse_sort_order : String -> Result String (Card -> Card -> Order)
parse_sort_order sort = case sort of
    "date" -> Ok <| \x y -> compare (CardSet.set_sort_order x.set, x.number) (CardSet.set_sort_order y.set, y.number)
    "date>" -> Ok <| \x y -> compare (CardSet.set_sort_order y.set, y.number) (CardSet.set_sort_order x.set, x.number)
    "name" -> Ok <| \x y -> compare x.name y.name
    "name>" -> Ok <| \x y -> compare y.name x.name
    "cost" -> Ok <| \x y -> compare_maybe x.cost y.cost
    "cost>" -> Ok <| \x y -> compare_maybe y.cost x.cost
    "strength" -> Ok <| \x y -> compare_maybe x.strength y.strength
    "strength>" -> Ok <| \x y -> compare_maybe y.strength x.strength
    "str" -> Ok <| \x y -> compare_maybe x.strength y.strength
    "str>" -> Ok <| \x y -> compare_maybe y.strength x.strength
    "income" -> Ok <| \x y -> compare_maybe x.income y.income
    "income>" -> Ok <| \x y -> compare_maybe y.income x.income
    "inc" -> Ok <| \x y -> compare_maybe x.income y.income
    "inc>" -> Ok <| \x y -> compare_maybe y.income x.income
    "initiative" -> Ok <| \x y -> compare_maybe x.initiative y.initiative
    "initiative>" -> Ok <| \x y -> compare_maybe y.initiative x.initiative
    "init" -> Ok <| \x y -> compare_maybe x.initiative y.initiative
    "init>" -> Ok <| \x y -> compare_maybe y.initiative x.initiative
    "claim" -> Ok <| \x y -> compare_maybe x.claim y.claim
    "claim>" -> Ok <| \x y -> compare_maybe y.claim x.claim
    "influence" -> Ok <| \x y -> compare_maybe x.influence y.influence
    "influence>" -> Ok <| \x y -> compare_maybe y.influence x.influence
    "inf" -> Ok <| \x y -> compare_maybe x.influence y.influence
    "inf>" -> Ok <| \x y -> compare_maybe y.influence x.influence
    other -> Err <| "'" ++ other ++ "' is not an order category."

parse_sort_orders : List String -> ((Card -> Card -> Order), List String)
parse_sort_orders orders = 
    let
        (comparisons, errors) = orders
            |> List.map parse_sort_order
            |> Result.Extra.partition
            
        chronological_compare x y = compare (CardSet.set_sort_order x.set, x.number) (CardSet.set_sort_order y.set, y.number)
    in
        if List.isEmpty orders
            then (chronological_compare, [])
            else (List.foldr lexicographical_combine chronological_compare comparisons, errors) 
