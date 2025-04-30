open Ast_src
open Exceptions

    (* Function to decide whether letters A-G is tones *)
    let ident_to_tone = function
        | "a" -> A
        | "b" -> B
        | "c" -> C
        | "d" -> D
        | "e" -> E
        | "f" -> F
        | "g" -> G
        | _ -> raise (IllegalToneError "Invalid tone")
