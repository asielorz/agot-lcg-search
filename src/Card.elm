module Card exposing (..)

import CardSet exposing (Set)

import Json.Encode
import Json.Decode
import Json.Decode.Pipeline exposing (required, optional)
import CardSet exposing (data_of_set)
import List.Extra

type CardType = CardType_Character | CardType_Event | CardType_Location | CardType_Attachment | CardType_Plot | CardType_Agenda
type House = House_Stark | House_Lannister | House_Baratheon | House_Targaryen | House_Martell | House_Greyjoy | House_Neutral
type Icon = Icon_Military | Icon_Intrigue | Icon_Power
type Crest = Crest_Holy | Crest_Noble | Crest_War | Crest_Learned | Crest_Shadow
type Legality = Legality_Legal | Legality_Banned | Legality_Restricted

type alias Card = 
    { id : String
    , name : String
    , card_type : CardType
    , set : Set
    , number : Int
    , quantity : Int
    , legality : Legality
    , illustrator : String
    , house : List House
    , unique : Bool
    , rules_text : Maybe String
    , flavor_text : Maybe String

    -- Character
    , cost : Maybe Int
    , icons : List Icon
    , crest : List Crest
    , traits : List String
    , strength : Maybe Int

    -- Plot
    , income : Maybe Int
    , initiative : Maybe Int
    , claim : Maybe Int
    }

card_type_from_json : Json.Decode.Decoder CardType
card_type_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s -> case s of
        "Character" -> Json.Decode.succeed CardType_Character
        "Event" -> Json.Decode.succeed CardType_Event
        "Location" -> Json.Decode.succeed CardType_Location
        "Attachment" -> Json.Decode.succeed CardType_Attachment
        "Plot" -> Json.Decode.succeed CardType_Plot
        "Agenda" -> Json.Decode.succeed CardType_Agenda
        _ -> Json.Decode.fail <| s ++ " is not a card type"
    )

card_type_to_string : CardType -> String
card_type_to_string card_type = case card_type of
    CardType_Character -> "Character"
    CardType_Event -> "Event"
    CardType_Location -> "Location"
    CardType_Attachment -> "Attachment"
    CardType_Plot -> "Plot"
    CardType_Agenda -> "Agenda"

legality_from_json : Json.Decode.Decoder Legality
legality_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s -> case s of
        "Legal" -> Json.Decode.succeed Legality_Legal
        "Restricted" -> Json.Decode.succeed Legality_Restricted
        "Banned" -> Json.Decode.succeed Legality_Banned
        _ -> Json.Decode.fail <| s ++ " is not a legality"
    )

legality_to_string : Legality -> String
legality_to_string legality = case legality of
    Legality_Legal -> "Legal"
    Legality_Restricted -> "Restricted"
    Legality_Banned -> "Banned"

house_from_json : Json.Decode.Decoder House
house_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s -> case s of
        "Stark" -> Json.Decode.succeed House_Stark
        "Lannister" -> Json.Decode.succeed House_Lannister
        "Baratheon" -> Json.Decode.succeed House_Baratheon
        "Targaryen" -> Json.Decode.succeed House_Targaryen
        "Martell" -> Json.Decode.succeed House_Martell
        "Greyjoy" -> Json.Decode.succeed House_Greyjoy
        "Neutral" -> Json.Decode.succeed House_Neutral
        _ -> Json.Decode.fail <| s ++ " is not a house"
    )

house_to_string : House -> String
house_to_string house = case house of
    House_Stark -> "Stark"
    House_Lannister -> "Lannister"
    House_Baratheon -> "Baratheon"
    House_Targaryen -> "Targaryen"
    House_Martell -> "Martell"
    House_Greyjoy -> "Greyjoy"
    House_Neutral -> "Neutral"

icon_from_json : Json.Decode.Decoder Icon
icon_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s -> case s of
        "Military" -> Json.Decode.succeed Icon_Military
        "Intrigue" -> Json.Decode.succeed Icon_Intrigue
        "Power" -> Json.Decode.succeed Icon_Power
        _ -> Json.Decode.fail <| s ++ " is not an icon"
    )

icon_to_string : Icon -> String
icon_to_string icon = case icon of
    Icon_Military -> "Military"
    Icon_Intrigue -> "Intrigue"
    Icon_Power -> "Power"

crest_from_json : Json.Decode.Decoder Crest
crest_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s -> case s of
        "Holy" -> Json.Decode.succeed Crest_Holy
        "Noble" -> Json.Decode.succeed Crest_Noble
        "War" -> Json.Decode.succeed Crest_War
        "Learned" -> Json.Decode.succeed Crest_Learned
        "Shadow" -> Json.Decode.succeed Crest_Shadow
        _ -> Json.Decode.fail <| s ++ " is not a crest"
    )

crest_to_string : Crest -> String
crest_to_string crest = case crest of
    Crest_Holy -> "Holy"
    Crest_Noble -> "Noble"
    Crest_War -> "War"
    Crest_Learned -> "Learned"
    Crest_Shadow -> "Shadow"

set_from_json : Json.Decode.Decoder Set
set_from_json = Json.Decode.string
    |> Json.Decode.andThen (\s ->
        case List.Extra.find (\d -> d.full_name == s) CardSet.set_data of
            Just data -> Json.Decode.succeed data.set
            Nothing -> Json.Decode.fail <| s ++ " is not the name of a set"
    )

maybe : String -> Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
maybe field_name decoder = optional field_name (Json.Decode.map Just decoder) Nothing

card_from_json : Json.Decode.Decoder Card
card_from_json = 
    Json.Decode.succeed Card
        |> required "image_url" Json.Decode.string
        |> required "name" Json.Decode.string
        |> required "card_type" card_type_from_json
        |> required "set" set_from_json
        |> required "number" Json.Decode.int
        |> required "quantity" Json.Decode.int
        |> required "legality" legality_from_json
        |> required "illustrator" Json.Decode.string
        |> required "house" (Json.Decode.list house_from_json)
        |> required "unique" Json.Decode.bool
        |> maybe "rules_text" Json.Decode.string
        |> maybe "flavor_text" Json.Decode.string
        |> maybe "cost" Json.Decode.int
        |> optional "icons" (Json.Decode.list icon_from_json) []
        |> optional "crest" (Json.Decode.list crest_from_json) []
        |> optional "traits" (Json.Decode.list Json.Decode.string) []
        |> maybe "strength" Json.Decode.int
        |> maybe "income" Json.Decode.int
        |> maybe "initiative" Json.Decode.int
        |> maybe "claim" Json.Decode.int

maybe_field : String -> (a -> Json.Encode.Value) -> Maybe a -> Maybe (String, Json.Encode.Value)
maybe_field field_name encode optional_field =
    optional_field |> Maybe.map (\field -> (field_name, encode field))

card_to_json : Card -> Json.Encode.Value
card_to_json card = 
    let 
        fields = List.filterMap identity
            [ Just ("id", Json.Encode.string card.id)
            , Just ("image_url", Json.Encode.string <| image_url card)
            , Just ("name", Json.Encode.string card.name)
            , Just ("card_type", Json.Encode.string <| card_type_to_string card.card_type)
            , Just ("set", card.set |> data_of_set |> .full_name |> Json.Encode.string )
            , Just ("number", Json.Encode.int card.number)
            , Just ("quantity", Json.Encode.int card.quantity)
            , Just ("legality", Json.Encode.string <| legality_to_string card.legality)
            , Just ("illustrator", Json.Encode.string card.illustrator)
            , Just ("house", Json.Encode.list (Json.Encode.string << house_to_string) card.house)
            , Just ("unique", Json.Encode.bool card.unique)
            , Just ("icons", Json.Encode.list (Json.Encode.string << icon_to_string) card.icons)
            , Just ("crest", Json.Encode.list (Json.Encode.string << crest_to_string) card.crest)
            , Just ("traits", Json.Encode.list Json.Encode.string card.traits)
            , maybe_field "rules_text" Json.Encode.string card.rules_text
            , maybe_field "flavor_text" Json.Encode.string card.flavor_text
            , maybe_field "cost" Json.Encode.int card.cost
            , maybe_field "strength" Json.Encode.int card.strength
            , maybe_field "income" Json.Encode.int card.income
            , maybe_field "initiative" Json.Encode.int card.initiative
            , maybe_field "claim" Json.Encode.int card.claim
            ]
    in
        Json.Encode.object fields

house_sort_order : House -> Int
house_sort_order house = case house of
    House_Stark -> 0
    House_Lannister -> 1
    House_Baratheon -> 2
    House_Targaryen -> 3
    House_Martell -> 4
    House_Greyjoy -> 5
    House_Neutral -> 6

icon_sort_order : Icon -> Int
icon_sort_order icon = case icon of
    Icon_Military -> 0
    Icon_Intrigue -> 1
    Icon_Power -> 2

page_url : Card -> String
page_url card = "/card/" ++ card.id

image_url : Card -> String
image_url card = "/images/cards/" ++ card.id ++ ".jpg"
