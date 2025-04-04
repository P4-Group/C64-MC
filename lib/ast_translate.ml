open Ast_final

exception Error of Ast.loc option * string

let error ?loc s = raise (Error (loc, s))

(*Insert specific errors here*)

let base_offset = function
  | C -> -9 | D -> -7 | E -> -5 | F -> -4 
  | G -> -2 | A -> 0 | B -> 2

let acc_offset
  | Nat -> 0
  | Sharp -> 1
  | Flat -> -1

  let oct_offset = function
  | Some o -> (o - 4) * 12
  | None -> 0

let get_qn_duration () =
    let tempo = match Ast.params.tempo with
      | Some t -> t
      | None -> 120 in
    let timesig = match Ast.params.timesig with
      | Some ts -> ts
      | None -> (4,4) in
    let _, bnv = timesig in
    let bnv_duration = 60000 / tempo in
    match bnv with 
    | 1 -> bnv_duration / 4
    | 2 -> bnv_duration / 2
    | 4 -> bnv_duration
    | 8 -> bnv_duration * 2
    | 16 -> bnv_duration * 4
    | _ -> failwith "Invalid basic note value in time signature"

let qn = get_qn_duration ();

let get_note_duration = function
    | Whole -> qn_duration * 4
    | Half -> qn_duration * 2
    | Quarter -> qn_duration
    | Eighth -> qn_duration / 2
    | Sixteenth -> qn_duration / 4
    
let note_translate = function
  | Ast.Sound (t, a, f, o) ->
    let stdpitch = match Ast.params.stdpitch with
      | Some sp -> sp
      | None -> 440 in 
    let semitone_offset = base_offset t + acc_offset a + oct_offset o in
    let f_out = float_of_int !stdpitch *. (2. ** (float_of_int semitone_offset /. 12.)) in
    let f_n = f_out /. 0.06097 in
    let hf = int_of_float in
    let lf = int_of_float f_n - (256 * hf) in
    let d = get_note_duration f in
    {highfreq: hf; lowfreq: lf; duration: d}
  | Ast.Rest f ->
    let d = get_note_duration f in
    {highfreq: 0; lowfreq: 0; duration: d}

let seq_translate = List.map note_translate Ast.seq

let seqdef_translate (Ast.seqdef {name; seq}) =
    { Final_ast.name; seq = seq_translate seq } (* TODO: Should actually update a hashtable insead! *)

let waveform_translate = function
  | Ast.Vpulse -> Vpulse
  | Ast.Triangle -> Triangle
  | Ast.Sawtooth -> Sawtooth
  | Ast.Noise -> Noise

(*TODO: Should use the seqdef.name.id of new hashtable and waveform of waveform_translate *)
let channel_translate = 

let seqdef_list_translate = List.map seqdef_translate Ast.file.sqs (*TODO: Will just be the new hashtable*)

let file_translate = Ast.file -> 
    file.{ 
      sqs: seqdef_list_translate; (*TODO: Should hold the new hashtable*)
      ch1: channel_translate Ast.ch1;
      ch2: channel_translate Ast.ch2; 
      ch3: channel_translate Ast.ch3; 
    }
