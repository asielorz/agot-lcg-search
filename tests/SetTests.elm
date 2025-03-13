module SetTests exposing (..)

import CardSet

import Expect
import Test exposing (..)
import List.Extra

code_names_are_unique : Test
code_names_are_unique = test
    "Code names are unique"
    (\_ ->
        let
            code_names = List.map .code_name CardSet.set_data ++ List.map .code_name CardSet.cycle_data
            deduped_code_names = List.Extra.unique code_names
        in
            Expect.equal code_names deduped_code_names
    )
