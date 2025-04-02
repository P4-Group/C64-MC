open Ast

(* Pretty-print the parameters of a music file *)
let pprint_params params =
  (* Print the tempo, or "None" if not specified *)
  Printf.printf "Tempo: %s\n" 
    (match params.tempo with 
     | Some t -> string_of_int t 
     | None -> "None");

  (* Print the time signature, or "None" if not specified *)
  Printf.printf "Time Signature: %s\n"
    (match params.timesig with
     | Some (n, d) -> Printf.sprintf "%d/%d" n d
     | None -> "None");

  (* Print the standard pitch, or "None" if not specified *)
  Printf.printf "Standard Pitch: %s\n" 
    (match params.stdpitch with 
     | Some p -> string_of_int p 
     | None -> "None")

(* Pretty-print an identifier *)
let pprint_ident ident =
  Printf.printf "Identifier: %s\n" ident.id

(* Pretty-print a sequence *)
let rec pprint_seq seq =
  match seq with
  | Simple notes ->
      (* Print a simple sequence of notes *)
      Printf.printf "Simple Sequence:\n";
      List.iter pprint_note notes
  | Comp (seq1, seq2) ->
      (* Print a compound sequence consisting of two sub-sequences *)
      Printf.printf "Compound Sequence:\n";
      pprint_seq seq1;
      pprint_seq seq2
  | Loop (seq, count) ->
      (* Print a loop sequence with a specified count *)
      Printf.printf "Loop Sequence (Count: %d):\n" count;
      pprint_seq seq

(* Pretty-print a note *)
and pprint_note note =
  match note with
  | Sound (tone, acc, frac, oct) ->
      (* Print a sound note with tone, accidental, fraction, and octave *)
      Printf.printf "Sound Note: %s %s %s %s\n"
        (pprint_tone tone) (pprint_acc acc) (pprint_frac frac) (pprint_oct oct)
  | Rest frac ->
      (* Print a rest note with a specified fraction *)
      Printf.printf "Rest Note: %s\n" (pprint_frac frac)

(* Pretty-print a tone *)
and pprint_tone tone =
  match tone with
  | A -> "A" | B -> "B" | C -> "C" | D -> "D" | E -> "E" | F -> "F" | G -> "G"

(* Pretty-print an accidental *)
and pprint_acc acc =
  match acc with
  | None -> "Natural"
  | Sharp -> "Sharp"
  | Flat -> "Flat"

(* Pretty-print a fraction *)
and pprint_frac frac =
  match frac with
  | Full -> "Full"
  | Half -> "Half"
  | Quarter -> "Quarter"
  | Eighth -> "Eighth"
  | Sixteenth -> "Sixteenth"

(* Pretty-print an octave *)
and pprint_oct oct =
  match oct with
  | None -> "None"
  | Orig i -> Printf.sprintf "Original(%d)" i
  | Mod (oct, transp) ->
      (* Print a modified octave with transposition *)
      Printf.sprintf "Modified(%s, %s)" (pprint_oct oct) (pprint_transp transp)

(* Pretty-print a transposition *)
and pprint_transp transp =
  match transp with
  | Octup -> "Octave Up"
  | Octdwn -> "Octave Down"

(* Pretty-print a channel *)
let pprint_channel channel =
  List.iter (fun (ident, waveform) ->
    (* Print the identifier of the channel *)
    pprint_ident ident;
    (* Print the waveform type *)
    Printf.printf "Waveform: %s\n"
      (match waveform with
       | Vpulse -> "Pulse"
       | Triangle -> "Triangle"
       | Sawtooth -> "Sawtooth"
       | Noise -> "Noise")
  ) channel

(* Pretty-print the entire music file *)
let pprint_file file =
  (* Print the file parameters *)
  Printf.printf "File Parameters:\n";
  pprint_params file.parameters;
  Printf.printf "\nSequences:\n";
  (* Print each sequence definition *)
  List.iter (fun seqdef ->
    pprint_ident seqdef.name;
    pprint_seq seqdef.seq
  ) file.sequences;
  (* Print the channels *)
  Printf.printf "\nChannel 1:\n";
  pprint_channel file.channel1;
  Printf.printf "\nChannel 2:\n";
  pprint_channel file.channel2;
  Printf.printf "\nChannel 3:\n";
  pprint_channel file.channel3

(* Remove or comment out the following block *)
(* For testing purposes, since it allows for stdin*)
(*
let () =
  let ast =
    let lexbuf = Lexing.from_channel stdin in
    Parser.prog Lexer.read lexbuf
  in
  pprint_file ast
*)