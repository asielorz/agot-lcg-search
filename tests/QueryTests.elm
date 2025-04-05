module QueryTests exposing (..)

import Card exposing (Card, CardType(..), Legality(..), House(..), Icon(..), Crest(..))
import CardSet exposing (Set(..))
import Query

import Expect
import Test exposing (..)

eddard : Card
eddard = 
    { id = "core_5"
      , name = "Eddard Stark"
      , card_type = CardType_Character
      , set = Set_Core
      , number = 5
      , quantity = 1
      , legality_joust = Legality_Legal
      , legality_melee = Legality_Legal
      , illustrator = "John Matson"
      , house = [ House_Stark ]
      , unique = True
      , rules_text = Just "Stalwart. Renown. Deadly.\nEddard Stark claims 1 power when he comes into play."
      , flavor_text = Just "\"Our way is the older way. The blood of the First Men still flows in the veins of the Starks, and we hold to the belief that the man who passes the sentence should swing the sword.\""
      , cost = Just 4
      , icons = [ Icon_Military { naval = False }, Icon_Power { naval = False } ]
      , crest = [ Crest_Noble ]
      , traits = [ "Lord" ]
      , strength = Just 3
      , income = Nothing
      , initiative = Nothing
      , claim = Nothing
      , influence = Nothing
      , erratas = []
      , faqs = []
      , duplicate_id = Nothing
      }

arrogant_contender : Card
arrogant_contender = 
    { id = "lotr_44"
      , name = "Arrogant Contender"
      , card_type = CardType_Character
      , set = Set_LionsOfTheRock
      , number = 44
      , quantity = 3
      , legality_joust = Legality_Legal
      , legality_melee = Legality_Legal
      , illustrator = "Tiziano Baracchi"
      , house = [ House_Lannister, House_Baratheon ]
      , unique = False
      , rules_text = Just "Melee.\nResponse: After you win a challenge in which Arrogant Contender attacked alone, it claims 1 power for each opposing character."
      , flavor_text = Just "Card designed by the 2010 World Melee Champion Brett Zeiler"
      , cost = Just 3
      , icons = [ Icon_Military { naval = False }, Icon_Intrigue { naval = False } ]
      , crest = [  ]
      , traits = [ "House Tyrell", "Knight", "Ally" ]
      , strength = Just 3
      , income = Nothing
      , initiative = Nothing
      , claim = Nothing
      , influence = Nothing
      , erratas = []
      , faqs = []
      , duplicate_id = Nothing
      }

type TestResult = Match | NoMatch | ParseError

make_test : Card -> String -> TestResult -> Test
make_test card query expected = 
    let
        test_name = case expected of
            Match -> "Card '" ++ card.name ++ "' matches query '" ++ query ++ "'"
            NoMatch -> "Card '" ++ card.name ++ "' does not match query '" ++ query ++ "'"
            ParseError -> "Query '" ++ query ++ "' failes to parse"
    in
        test
            test_name
            (\_ -> Expect.equal
                expected
                ( case Query.search query [] [ card ] of
                    Err _ -> ParseError
                    Ok [] -> NoMatch
                    Ok _ -> Match
                )
            )

test_name_contains_true : Test
test_name_contains_true = make_test 
    eddard "eddard" Match

test_name_contains_false : Test
test_name_contains_false = make_test
    eddard "cersei" NoMatch

out_of_order_words_without_quotes : Test
out_of_order_words_without_quotes = make_test
    eddard "stark eddard" Match

out_of_order_words_with_quotes : Test
out_of_order_words_with_quotes = make_test
    eddard "\"stark eddard\"" NoMatch

case_insensitive : Test
case_insensitive = make_test
    eddard "eDdArD StArK" Match

empty_predicate : Test
empty_predicate = make_test
    eddard "" Match

cost_equal_true : Test
cost_equal_true = make_test
    eddard "cost=4" Match

cost_equal_false : Test
cost_equal_false = make_test
    eddard "cost=3" NoMatch

cost_not_equal_true : Test
cost_not_equal_true = make_test
    eddard "cost!=3" Match

cost_not_equal_false : Test
cost_not_equal_false = make_test
    eddard "cost!=4" NoMatch

cost_stuff_after_number : Test
cost_stuff_after_number = make_test
    eddard "cost==4g" ParseError

strength_greater_than_true : Test
strength_greater_than_true = make_test
    eddard "strength>2" Match

strength_greater_than_false : Test
strength_greater_than_false = make_test
    eddard "strength>3" NoMatch

quantity_greater_than_equal_true : Test
quantity_greater_than_equal_true = make_test
    eddard "quantity>=1" Match

quantity_greater_than_equal_false : Test
quantity_greater_than_equal_false = make_test
    eddard "quantity>=2" NoMatch
    
text_true : Test
text_true = make_test
    eddard "text:power" Match

text_false : Test
text_false = make_test
    eddard "text:funambulista" NoMatch

text_multiword_true : Test
text_multiword_true = make_test
    eddard "text:\"when he comes into play\"" Match

flavor_true : Test
flavor_true = make_test
    eddard "flavor:blood" Match

flavor_false : Test
flavor_false = make_test
    eddard "flavor:funambulista" NoMatch

flavor_multiword_true : Test
flavor_multiword_true = make_test
    eddard "flavor:\"our way is the older way\"" Match

type_true : Test
type_true = make_test
    eddard "type:character" Match
    
type_abbreviation_true : Test
type_abbreviation_true = make_test
    eddard "type:c" Match

type_false : Test
type_false = make_test
    eddard "type:location" NoMatch

type_inexistent : Test
type_inexistent = make_test
    eddard "type:sorcery" ParseError

illustrator_true : Test
illustrator_true = make_test
    eddard "illustrator:john" Match

illustrator_false : Test
illustrator_false = make_test
    eddard "illustrator:michael" NoMatch

unique_true : Test
unique_true = make_test
    eddard "unique:t" Match

unique_false : Test
unique_false = make_test
    eddard "unique:f" NoMatch

unique_parse_error : Test
unique_parse_error = make_test
    eddard "unique:g" ParseError

legality_true : Test
legality_true = make_test
    eddard "legality=l" Match

legality_false : Test
legality_false = make_test
    eddard "legality<=r" NoMatch

crest_true : Test
crest_true = make_test
    eddard "crest:noble" Match

crest_false : Test
crest_false = make_test
    eddard "crest:war" NoMatch

crest_parse_error : Test
crest_parse_error = make_test
    eddard "crest:funambulista" ParseError

house_equal_true : Test
house_equal_true = make_test
    eddard "house=s" Match

house_equal_false : Test
house_equal_false = make_test
    eddard "house=l" NoMatch

house_equal_parse_error : Test
house_equal_parse_error = make_test
    eddard "house=f" ParseError

house_not_equal_true : Test
house_not_equal_true = make_test
    eddard "house!=l" Match

house_not_equal_false : Test
house_not_equal_false = make_test
    eddard "house!=s" NoMatch

house_not_less_than_greater_size_but_different_houses : Test
house_not_less_than_greater_size_but_different_houses = make_test
    arrogant_contender "house>s" NoMatch

house_greater_than_true : Test
house_greater_than_true = make_test
    arrogant_contender "house>l" Match

house_equal_two_true : Test
house_equal_two_true = make_test
    arrogant_contender "house=lb" Match

house_equal_two_out_of_order_true : Test
house_equal_two_out_of_order_true = make_test
    arrogant_contender "house=bl" Match

icon_equal_true : Test
icon_equal_true = make_test
    eddard "icon=mp" Match

icon_equal_out_of_order_true : Test
icon_equal_out_of_order_true = make_test
    eddard "icon=pm" Match

icon_equal_false : Test
icon_equal_false = make_test
    eddard "icon=mip" NoMatch

icon_greater_than_true : Test
icon_greater_than_true = make_test
    eddard "icon>m" Match

icon_greater_than_false_not_contained : Test
icon_greater_than_false_not_contained = make_test
    eddard "icon>i" NoMatch

icon_greater_than_false_equal : Test
icon_greater_than_false_equal = make_test
    eddard "icon>mp" NoMatch
