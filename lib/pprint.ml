open Ast

type ast_file =
  | Ast of Ast.file
  | Ast_final of Ast_final.file

(* Define a generic AST type *)
type generic_ast =
  | Node of string * (generic_ast list) 
  | Leaf of string                      

(* Conversion of our AST's to a generic AST *)
let rec ast_to_generic_ast (file : ast_file) : generic_ast =
  match file with
  | Ast f ->
    let params_node =
      Node ("Parameters", [
        Leaf (Printf.sprintf "Tempo: %s" (match f.parameters.tempo with Some t -> string_of_int t | None -> "None"));
        Leaf (Printf.sprintf "Time Signature: %s"
                (match f.parameters.timesig with
                  | Some (n, d) -> Printf.sprintf "%d/%d" n d
                  | None -> "None"));
        Leaf (Printf.sprintf "Standard Pitch: %s"
                (match f.parameters.stdpitch with Some p -> string_of_int p | None -> "None"))
      ])
    in
    let sequences_node =
      Node ("Sequences", List.map (fun seqdef ->
        Node ("Sequence", [
          Leaf (Printf.sprintf "Identifier: %s" seqdef.name.id);
          ast_to_generic_seq seqdef.seq
        ])
      ) f.sequences)
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
      channels_node "Channel 1" f.channel1;
      channels_node "Channel 2" f.channel2;
      channels_node "Channel 3" f.channel3
    ])
  | Ast_final f ->
    let sequences_node =
      Node ("Sequences", List.map (fun seqdef ->
        Node ("Sequence", [
          Leaf (Printf.sprintf "Identifier: %s" seqdef.name.id);
          Node ("Assembly Note", [
            Leaf (Printf.sprintf "High frequency: %s Hz" (string_of_int highfreq));
            Leaf (Printf.sprintf "Low frequency: %s Hz" (string_of_int lowfreq));
            Leaf (Printf.sprintf "Duration: %s ms" (string_of_int duration))
          ])
        ])
      ) f.sequences) (*TODO: we don't have f.sequences for ast_final, need helper function(s) in symbol table*)
    in
    let channels_node name channel =
      Node (name, List.map (fun (ident, waveform) ->
        Node ("Channel", [
          Leaf (Printf.sprintf "Identifier: %s" ident.Ast_final.id);
          Leaf (Printf.sprintf "Waveform: %s" (match waveform with
            | Ast_final.Vpulse -> "Pulse"
            | Ast_final.Triangle -> "Triangle"
            | Ast_final.Sawtooth -> "Sawtooth"
            | Ast_final.Noise -> "Noise"))
        ])
      ) channel)
    in
    Node ("File", [
      channels_node "Channel 1" f.ch1;
      channels_node "Channel 2" f.ch2;
      channels_node "Channel 3" f.ch3
    ])

  and ast_to_generic_seq seq = Node ("Note list", List.map ast_to_generic_note seq)

  and ast_to_generic_note note =
    match note with
    | Ast.Sound (tone, acc, frac, oct) ->
        Node ("Sound Note", [
          Leaf (Printf.sprintf "Tone: %s" (pprint_tone tone));
          Leaf (Printf.sprintf "Accidental: %s" (pprint_acc acc));
          Leaf (Printf.sprintf "Fraction: %s" (pprint_frac frac));
          Leaf (Printf.sprintf "Octave: %s" (pprint_oct oct))
        ])
    | Ast.Rest frac ->
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