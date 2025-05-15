module Card exposing (..)

import CardSet exposing (Set)

type CardType = CardType_Character | CardType_Event | CardType_Location | CardType_Attachment | CardType_Plot | CardType_Agenda | CardType_House
type House = House_Stark | House_Lannister | House_Baratheon | House_Targaryen | House_Martell | House_Greyjoy | House_Neutral
type Icon = Icon_Military { naval : Bool } | Icon_Intrigue { naval : Bool } | Icon_Power { naval : Bool }
type Crest = Crest_Holy | Crest_Noble | Crest_War | Crest_Learned | Crest_Shadow
type Legality = Legality_Legal | Legality_Restricted

type alias Faq = 
    { cards_mentioned : List String
    , text : String
    }

type alias Errata = 
    { line : Int
    , start : Int
    , end : Int
    }

type alias Card = 
    { id : String
    , name : String
    , card_type : CardType
    , set : Set
    , number : Int
    , quantity : Int
    , limit : Int
    , legality_joust : Legality
    , legality_melee : Legality
    , illustrator : String
    , house : List House
    , legal_in_houses : List House
    , unique : Bool
    , rules_text : Maybe String
    , flavor_text : Maybe String
    , erratas : List Errata
    , duplicate_id : Maybe String

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

    -- Others
    , influence : Maybe Int
    }


card_type_to_string : CardType -> String
card_type_to_string card_type = case card_type of
    CardType_Character -> "Character"
    CardType_Event -> "Event"
    CardType_Location -> "Location"
    CardType_Attachment -> "Attachment"
    CardType_Plot -> "Plot"
    CardType_Agenda -> "Agenda"
    CardType_House -> "House"


legality_to_string : Legality -> String
legality_to_string legality = case legality of
    Legality_Legal -> "Legal"
    Legality_Restricted -> "Restricted"


house_to_string : House -> String
house_to_string house = case house of
    House_Stark -> "Stark"
    House_Lannister -> "Lannister"
    House_Baratheon -> "Baratheon"
    House_Targaryen -> "Targaryen"
    House_Martell -> "Martell"
    House_Greyjoy -> "Greyjoy"
    House_Neutral -> "Neutral"


icon_to_string : Icon -> String
icon_to_string icon = case icon of
    Icon_Military {naval} -> if naval then "Military (Naval)" else "Military" 
    Icon_Intrigue {naval} -> if naval then "Intrigue (Naval)" else "Intrigue"
    Icon_Power {naval} -> if naval then "Power (Naval)" else "Power"
    

crest_to_string : Crest -> String
crest_to_string crest = case crest of
    Crest_Holy -> "Holy"
    Crest_Noble -> "Noble"
    Crest_War -> "War"
    Crest_Learned -> "Learned"
    Crest_Shadow -> "Shadow"


house_sort_order : House -> Int
house_sort_order house = case house of
    House_Stark -> 0
    House_Lannister -> 1
    House_Baratheon -> 2
    House_Targaryen -> 3
    House_Martell -> 4
    House_Greyjoy -> 5
    House_Neutral -> 6

house_icon : House -> String
house_icon house = case house of
    House_Stark -> "/images/houses/stark.png"
    House_Lannister -> "/images/houses/lannister.png"
    House_Baratheon -> "/images/houses/baratheon.png"
    House_Targaryen -> "/images/houses/targaryen.png"
    House_Greyjoy -> "/images/houses/greyjoy.png"
    House_Martell -> "/images/houses/martell.png"
    House_Neutral -> "/images/houses/neutral.png"

icon_sort_order : Icon -> Int
icon_sort_order icon = case icon of
    Icon_Military { naval } -> if naval then 1 else 0
    Icon_Intrigue { naval } -> if naval then 3 else 2
    Icon_Power { naval } -> if naval then 5 else 4

icon_is_naval : Icon -> Bool
icon_is_naval icon = case icon of
    Icon_Military { naval } -> naval
    Icon_Intrigue { naval } -> naval
    Icon_Power { naval } -> naval

icon_make_naval : Bool -> Icon -> Icon
icon_make_naval  naval icon = case icon of
    Icon_Military _ -> Icon_Military { naval = naval }
    Icon_Intrigue _ -> Icon_Intrigue { naval = naval }
    Icon_Power _ -> Icon_Power { naval = naval }

crest_sort_order : Crest -> Int
crest_sort_order crest = case crest of
    Crest_Holy -> 0
    Crest_Noble -> 1
    Crest_War -> 2
    Crest_Learned -> 3
    Crest_Shadow -> 4

page_url : Card -> String
page_url card = "/card/" ++ card.id

full_image_url : Card -> String
full_image_url card = "/images/cards/full/" ++ card.id ++ ".jpg"

preview_image_url : Card -> String
preview_image_url card = "/images/cards/preview/" ++ card.id ++ ".jpg"

duplicate_id : Card -> String
duplicate_id card = Maybe.withDefault card.id card.duplicate_id
