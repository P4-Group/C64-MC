open Ast

    (* Function to decide whether letters A-G is tones *)
    let id2tonename = function
        | "a" -> A
        | "b" -> B
        | "c" -> C
        | "d" -> D
        | "e" -> E
        | "f" -> F
        | "g" -> G
        | _ -> failwith "Invalid tonename"
