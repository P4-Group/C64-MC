open Ast_final
open Exceptions

exception Error of Ast.loc option * string

let error ?loc s = raise (Error (loc, s))

(*Insert specific errors here*)

let params : Ast.params ref = ref { Ast.tempo = None; Ast.timesig = None; Ast.stdpitch = None }

let base_offset = function
  | Ast.C -> -9 | Ast.D -> -7 | Ast.E -> -5 | Ast.F -> -4 
  | Ast.G -> -2 | Ast.A -> 0 | Ast.B -> 2

let acc_offset = function
  | Ast.Nat -> 0
  | Ast.Sharp -> 1
  | Ast.Flat -> -1

let oct_offset = function
  | Ast.Orig o -> (o - 4) * 12
  | _ -> 0

let get_qn_duration =
    let tempo = match !params.tempo with
      | Some t -> t
      | None -> 120 in
    let timesig = match !params.timesig with
      | Some ts -> ts
      | None -> (4,4) in
    let _, bnv = timesig in
    let bnv_duration = (60000 / tempo) / 20 in
    match bnv with 
    | 1 -> bnv_duration / 4
    | 2 -> bnv_duration / 2
    | 4 -> bnv_duration
    | 8 -> bnv_duration * 2
    | 16 -> bnv_duration * 4
    | _ -> raise (IllegalTimeSignature "Invalid basic note value in time signature")


let get_note_duration f =
  let qn_duration = get_qn_duration in
  match f with
    | Ast.Whole -> qn_duration * 4
    | Ast.Half -> qn_duration * 2
    | Ast.Quarter -> qn_duration
    | Ast.Eighth -> qn_duration / 2
    | Ast.Sixteenth -> qn_duration / 4
    
let note_translate = function
  | Ast.Sound (t, a, f, o) ->
    let stdpitch = match !params.stdpitch with
      | Some sp -> sp
      | None -> 440 in 
    let semitone_offset = base_offset t + acc_offset a + oct_offset o in
    let f_out = float_of_int stdpitch *. (2. ** (float_of_int semitone_offset /. 12.)) in
    let f_n = f_out /. 0.06097 in
    let hf = int_of_float (f_n /. 256.) in
    let lf = int_of_float f_n - (256 * hf) in
    let d = get_note_duration f in
    {highfreq = hf; lowfreq = lf; duration = d}
  | Ast.Rest f ->
    let d = get_note_duration f in
    {highfreq = 0; lowfreq = 0; duration = d}

let seq_translate (seq : Ast.seq) = List.map note_translate seq

let seqdef_translate (seqdef : Ast.seqdef) = 
  let seq_id = seqdef.name.id in
  let translated_seq = seq_translate seqdef.seq in
  Symbol_table.update_sequence seq_id translated_seq None

let waveform_translate = function
  | Ast.Vpulse -> Vpulse
  | Ast.Triangle -> Triangle
  | Ast.Sawtooth -> Sawtooth
  | Ast.Noise -> Noise

  let ident_translate (id : Ast.ident) : Ast_final.ident = 
    { Ast_final.id = id.id; id_loc = id.id_loc }
  

let channel_translate ch = List.map (fun (sn,wf) -> (ident_translate sn, waveform_translate wf)) ch

let set_params (p : Ast.params) =
  params := p

let file_translate (f : Ast.file) = 
  set_params f.parameters;
  List.iter seqdef_translate f.sequences;
  {
    ch1 = channel_translate f.channel1;
    ch2 = channel_translate f.channel2;
    ch3 = channel_translate f.channel3;
  }