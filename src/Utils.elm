module Utils exposing (..)

import List.Extra

plural : Int -> String
plural amount = plural_form amount "" "s"

plural_form : Int -> String -> String -> String
plural_form amount if_singular if_plural = if amount == 1 then if_singular else if_plural

join_human_readable : List String -> String
join_human_readable parts = case List.Extra.unconsLast parts of
    Nothing -> ""
    Just (last, []) -> last
    Just (last, rest) -> String.join ", " rest ++ " and " ++ last
