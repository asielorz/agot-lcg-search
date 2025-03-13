module Fontawesome exposing (fontawesome, fontawesome_external_backup, text)

import Element as UI
import Element.Font as Font


fontawesome : Font.Font
fontawesome =
    Font.external { name = "FontAwesome", url = "/fontawesome/css/all.css" }


fontawesome_external_backup : Font.Font
fontawesome_external_backup =
    Font.external { name = "FontAwesome", url = "https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.css" }


text : List (UI.Attribute msg) -> String -> UI.Element msg
text attributes text_to_render =
    UI.el (Font.family [ fontawesome, fontawesome_external_backup ] :: attributes) <| UI.text <| text_to_render
