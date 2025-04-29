open Ast_final

(* Define a generic AST type for printing *)
type generic_ast =
  | Node of string * (generic_ast list) 
  | Leaf of string

(* Convert a note to a generic AST *)
let note_to_generic (note : note) : generic_ast =
  Node ("Note", [
    Leaf (Printf.sprintf "High frequency: %d" note.highfreq);
    Leaf (Printf.sprintf "Low frequency: %d" note.lowfreq);
    Leaf (Printf.sprintf "Duration: %d ms" note.duration);
  ])

(* Helper function to convert waveform to string *)
let waveform_to_string = function
  | Noise -> "$F9"
  | Vpulse -> "$FA"
  | Sawtooth -> "$FB"
  | Triangle -> "$FC"

(* Convert a channel to a generic AST *)
let channel_to_generic (name : string) (channel : channel) : generic_ast =
  Node (name, List.map (fun (ident, waveform) ->
    Node ("Channel Voice", [
      Leaf (Printf.sprintf "Identifier: %s" ident.id);
      Leaf (Printf.sprintf "Waveform: %s" (waveform_to_string waveform));
    ])
  ) channel)

(* Convert a file to a generic AST *)
let file_to_generic (file : file) : generic_ast =
  Node ("Final AST", [
    channel_to_generic "Channel 1" file.ch1;
    channel_to_generic "Channel 2" file.ch2;
    channel_to_generic "Channel 3" file.ch3;
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

(* Pretty-print a single channel *)
let pprint_channel name channel =
  let generic_ast = channel_to_generic name channel in
  pprint_generic_ast generic_ast

(* Pretty-print multiple notes *)
let pprint_notes notes =
  let generic_ast = Node ("Notes", List.map note_to_generic notes) in
  pprint_generic_ast generic_ast