open Ast

(* Define a generic AST type *)
type generic_ast =
  | Node of string * (generic_ast list) 
  | Leaf of string                      

(* Conversion of our AST's to a generic AST *)
let rec ast_to_generic_ast (file : Ast.file) : generic_ast =
  let params_node =
    Node ("Parameters", [
      Leaf (Printf.sprintf "Tempo: %s" (match file.parameters.tempo with Some t -> string_of_int t | None -> "None"));
      Leaf (Printf.sprintf "Time Signature: %s"
              (match file.parameters.timesig with
               | Some (n, d) -> Printf.sprintf "%d/%d" n d
               | None -> "None"));
      Leaf (Printf.sprintf "Standard Pitch: %s"
              (match file.parameters.stdpitch with Some p -> string_of_int p | None -> "None"))
    ])
  in
  let sequences_node =
    Node ("Sequences", List.map (fun seqdef ->
      Node ("Sequence", [
        Leaf (Printf.sprintf "Identifier: %s" seqdef.name.id);
        ast_to_generic_seq seqdef.seq
      ])
    ) file.sequences)
  in
  let channels_node name channel =
    Node (name, List.map (fun (ident, waveform) ->
      Node ("Channel", [
        Leaf (Printf.sprintf "Identifier: %s" ident.id);
        Leaf (Printf.sprintf "Waveform: %s" (match waveform with
          | Vpulse -> "Pulse"
          | Triangle -> "Triangle"
          | Sawtooth -> "Sawtooth"
          | Noise -> "Noise"))
      ])
    ) channel)
  in
  Node ("File", [
    params_node;
    sequences_node;
    channels_node "Channel 1" file.channel1;
    channels_node "Channel 2" file.channel2;
    channels_node "Channel 3" file.channel3
  ])

  and ast_to_generic_seq seq = Node ("Simple Sequence", List.map ast_to_generic_note seq)

  and ast_to_generic_note note =
    match note with
    | Sound (tone, acc, frac, oct) ->
        Node ("Sound Note", [
          Leaf (Printf.sprintf "Tone: %s" (pprint_tone tone));
          Leaf (Printf.sprintf "Accidental: %s" (pprint_acc acc));
          Leaf (Printf.sprintf "Fraction: %s" (pprint_frac frac));
          Leaf (Printf.sprintf "Octave: %s" (pprint_oct oct))
        ])
    | Rest frac ->
        Node ("Rest Note", [Leaf (Printf.sprintf "Fraction: %s" (pprint_frac frac))])

  and pprint_tone tone =
    match tone with
    | A -> "A" | B -> "B" | C -> "C" | D -> "D" | E -> "E" | F -> "F" | G -> "G"

  and pprint_acc acc =
    match acc with
    | Nat -> "Natural"
    | Sharp -> "Sharp"
    | Flat -> "Flat"

  and pprint_frac frac =
    match frac with
    | Whole -> "Whole"
    | Half -> "Half"
    | Quarter -> "Quarter"
    | Eighth -> "Eighth"
    | Sixteenth -> "Sixteenth"

  and pprint_oct oct =
    match oct with
    | None -> "None"
    | Orig i -> Printf.sprintf "Original(%d)" i

  (* Pretty-print a generic AST *)
  let rec pprint_generic_ast ?(indent_level=0) ast =
    let indent = String.make (indent_level * 2) ' ' in
    match ast with
    | Node (name, children) ->
        Printf.printf "%s%s:\n" indent name;
        List.iter (pprint_generic_ast ~indent_level:(indent_level + 1)) children
    | Leaf value ->
        Printf.printf "%s- %s\n" indent value

  (* Entry point for pretty-printing a file *)
  let pprint_file file =
    let generic_ast = ast_to_generic_ast file in
    pprint_generic_ast generic_ast