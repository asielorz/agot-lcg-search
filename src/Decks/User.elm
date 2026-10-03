module Decks.User exposing (..)

type UserId = UserId Int

type Role = Role_Admin | Role_Regular | Role_Unknown

type alias User =
    { id : UserId
    , name : String
    , bio : String
    , role : Role
    }

url : User -> String
url user = "/user/" ++ String.fromInt (unwrap_id user.id)

unwrap_id : UserId -> Int
unwrap_id id = case id of
    UserId x -> x
