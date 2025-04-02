open Ast

let pprint_params params =
  Printf.printf "Tempo: %s\n" (match params.tempo with Some t -> string_of_int t | None -> "None");
  Printf.printf "Time Signature: %s\n"
    (match params.timesig with
     | Some (n, d) -> Printf.sprintf "%d/%d" n d
     | None -> "None");
  Printf.printf "Standard Pitch: %s\n" (match params.stdpitch with Some p -> string_of_int p | None -> "None")

let pprint_ident ident =
  Printf.printf "Identifier: %s\n" ident.id

let rec pprint_seq seq =
  match seq with
  | Simple notes -> Printf.printf "Simple Sequence:\n"; List.iter pprint_note notes
  | Comp (seq1, seq2) ->
      Printf.printf "Compound Sequence:\n";
      pprint_seq seq1;
      pprint_seq seq2
  | Loop (seq, count) ->
      Printf.printf "Loop Sequence (Count: %d):\n" count;
      pprint_seq seq

and pprint_note note =
  match note with
  | Sound (tone, acc, frac, oct) ->
      Printf.printf "Sound Note: %s %s %s %s\n"
        (pprint_tone tone) (pprint_acc acc) (pprint_frac frac) (pprint_oct oct)
  | Rest frac -> Printf.printf "Rest Note: %s\n" (pprint_frac frac)

and pprint_tone tone =
  match tone with
  | A -> "A" | B -> "B" | C -> "C" | D -> "D" | E -> "E" | F -> "F" | G -> "G"

and pprint_acc acc =
  match acc with
  | None -> "Natural"
  | Sharp -> "Sharp"
  | Flat -> "Flat"

and pprint_frac frac =
  match frac with
  | Full -> "Full"
  | Half -> "Half"
  | Quarter -> "Quarter"
  | Eighth -> "Eighth"
  | Sixteenth -> "Sixteenth"

and pprint_oct oct =
  match oct with
  | None -> "None"
  | Orig i -> Printf.sprintf "Original(%d)" i
  | Mod (oct, transp) ->
      Printf.sprintf "Modified(%s, %s)" (pprint_oct oct) (pprint_transp transp)

and pprint_transp transp =
  match transp with
  | Octup -> "Octave Up"
  | Octdwn -> "Octave Down"

let pprint_channel channel =
  List.iter (fun (ident, waveform) ->
    pprint_ident ident;
    Printf.printf "Waveform: %s\n"
      (match waveform with
       | Vpulse -> "Pulse"
       | Triangle -> "Triangle"
       | Sawtooth -> "Sawtooth"
       | Noise -> "Noise")
  ) channel

let pprint_file file =
  Printf.printf "File Parameters:\n";
  pprint_params file.parameters;
  Printf.printf "\nSequences:\n";
  List.iter (fun seqdef ->
    pprint_ident seqdef.name;
    pprint_seq seqdef.seq
  ) file.sequences;
  Printf.printf "\nChannel 1:\n";
  pprint_channel file.channel1;
  Printf.printf "\nChannel 2:\n";
  pprint_channel file.channel2;
  Printf.printf "\nChannel 3:\n";
  pprint_channel file.channel3

(* Remove or comment out the following block *)
(*
let () =
  let ast =
    let lexbuf = Lexing.from_channel stdin in
    Parser.prog Lexer.read lexbuf
  in
  pprint_file ast
*)