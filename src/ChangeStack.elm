module ChangeStack exposing (ChangeStack, new, current, length, is_current_head, push, update, undo, redo)

import List.Extra

type ChangeStack a = ChangeStack (ChangeStackState a)

type alias ChangeStackState a =
    { initial : a -- Shouldn't be needed but we need it to be able to give a decent interface because elm doesn't have unwrap
    , changes : List a
    , currently_active : Int
    }

get_state : ChangeStack a -> ChangeStackState a
get_state stack = case stack of
    ChangeStack s -> s

new : a -> ChangeStack a
new initial = ChangeStack 
    { initial = initial
    , changes = [ initial ]
    , currently_active = 0
    }

current : ChangeStack a -> a
current stack = (get_state stack).changes
    |> List.Extra.getAt (get_state stack).currently_active
    |> Maybe.withDefault (get_state stack).initial

length : ChangeStack a -> Int
length stack = List.length (get_state stack).changes

is_current_head : ChangeStack a -> Bool
is_current_head stack = (get_state stack).currently_active == List.length ((get_state stack).changes) - 1

push : a -> ChangeStack a -> ChangeStack a
push new_value stack = if new_value == current stack
    then stack
    else let
            state = get_state stack
            new_index = state.currently_active + 1
            drop_redo = state.changes |> List.take new_index
            new_changes = drop_redo ++ [ new_value ]
        in
            ChangeStack { state | changes = new_changes, currently_active = new_index }

update : (a -> a) -> ChangeStack a -> ChangeStack a
update f stack = push (f <| current stack) stack

undo : ChangeStack a -> ChangeStack a
undo stack =
    let
        state = get_state stack
        new_index = max 0 (state.currently_active - 1)
    in
        ChangeStack { state | currently_active = new_index }

redo : ChangeStack a -> ChangeStack a
redo stack =
    let
        state = get_state stack
        new_index = if is_current_head stack
            then state.currently_active
            else state.currently_active + 1
    in
        ChangeStack { state | currently_active = new_index }
