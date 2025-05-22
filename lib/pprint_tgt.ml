open Ast_tgt

(* Define a generic AST type for printing *)
type generic_ast =
  | Node of string * (generic_ast list) 
  | Leaf of string

(* Convert a note to a generic AST *)
let note_to_generic (note : note) : generic_ast =
  Node ("Note", [
    Leaf (Printf.sprintf "High frequency: %d" note.highfreq);
    Leaf (Printf.sprintf "Low frequency: %d" note.lowfreq);
    Leaf (Printf.sprintf "Duration: %d frames" note.duration);
  ])

(* Helper function to convert waveform to string *)
let waveform_to_string = function
  | Noise -> "$F9"
  | Vpulse -> "$FA"
  | Sawtooth -> "$FB"
  | Triangle -> "$FC"

(* Convert a voice to a generic AST *)
let voice_to_generic (name : string) (voice : voice) : generic_ast =
  Node (name, List.map (fun (ident, waveform) ->
    Node ("Voice", [
      Leaf (Printf.sprintf "Identifier: %s" ident);
      Leaf (Printf.sprintf "Waveform: %s" (waveform_to_string waveform));
    ])
  ) voice)

(* Convert a file to a generic AST *)
let file_to_generic (file : file) : generic_ast =
  Node ("Target AST", [
    voice_to_generic "Voice 1" file.vc1;
    voice_to_generic "Voice 2" file.vc2;
    voice_to_generic "Voice 3" file.vc3;
  ])

(* Pretty-print a generic AST with indentation *)
let rec pprint_generic_ast ?(indent_level=0) ast =
  let indent = String.make (indent_level * 2) ' ' in
  match ast with
    | Node (name, children) ->
        Printf.printf "%s%s:\n" indent name;
        List.iter (pprint_generic_ast ~indent_level:(indent_level + 1)) children
    | Leaf value ->
        Printf.printf "%s- %s\n" indent value

(* Main function for pretty-printing a file *)
let pprint_file file =
  let generic_ast = file_to_generic file in
  pprint_generic_ast generic_ast

(* Pretty-print a single note *)
let pprint_note note =
  let generic_ast = note_to_generic note in
  pprint_generic_ast generic_ast

(* Pretty-print a single voice *)
let pprint_voice name voice =
  let generic_ast = voice_to_generic name voice in
  pprint_generic_ast generic_ast

(* Pretty-print multiple notes *)
let pprint_notes notes =
  let generic_ast = Node ("Notes", List.map note_to_generic notes) in
  pprint_generic_ast generic_ast