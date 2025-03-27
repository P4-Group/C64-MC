    (* Function to decide whether letters A-G is tones *)
    let check_tonename = function
        | "a" -> A
        | "b" -> B
        | "c" -> C
        | "d" -> D
        | "e" -> E
        | "f" -> F
        | "g" -> G
        | "r" -> R
        | _ -> failwith "Invalid tonename"