open Ast_tgt
open Exceptions

(* Mutable reference to hold params from source AST *)
let params : Ast_src.params ref = ref { Ast_src.tempo = None; Ast_src.timesig = None; Ast_src.stdpitch = None }

(* Semitone offset of tone relative to A (standard pitch) *)
let base_offset = function
  | Ast_src.C -> -9 | Ast_src.D -> -7 | Ast_src.E -> -5 | Ast_src.F -> -4 
  | Ast_src.G -> -2 | Ast_src.A -> 0 | Ast_src.B -> 2

(* Semitone offset for accidental *)
let acc_offset = function
  | Ast_src.Nat -> 0
  | Ast_src.Sharp -> 1
  | Ast_src.Flat -> -1

(* Semitone offset for octave relative to 4th octave (standard pitch) *)
let oct_offset = function
  | Ast_src.Defined o -> (o - 4) * 12
  | _ -> 0

(* Get duration of sixteenth note from tempo and basic note value. 
   Used as reference point for duration of specific notes *)
let get_duration_ref () =
    let tempo_opt = !params.tempo in
    let tempo = Option.value tempo_opt ~default:120 in
    let timesig_opt = !params.timesig in
    let timesig = Option.value timesig_opt ~default:(4,4) in
    let _, bnv = timesig in
    let bnv_duration = 3000 / tempo in
    match bnv with 
    | 1 -> bnv_duration / 16
    | 2 -> bnv_duration / 8
    | 4 -> bnv_duration / 4
    | 8 -> bnv_duration / 2
    | 16 -> bnv_duration
    | _ -> raise (IllegalTimeSignature "Invalid basic note value in time signature")

(* Get duration of specific note *)
let get_note_duration f =
  let duration_ref = get_duration_ref () in
  match f with
    | Ast_src.Whole -> duration_ref * 16
    | Ast_src.Half -> duration_ref * 8
    | Ast_src.Quarter -> duration_ref * 4
    | Ast_src.Eighth -> duration_ref * 2
    | Ast_src.Sixteenth -> duration_ref

(* Translate from Ast_src.note to Ast_tgt.note *)
let note_translate = function
  | Ast_src.Sound (t, a, f, o) ->
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
  | Ast_src.Rest f ->
    let d = get_note_duration f in
    {highfreq = 0; lowfreq = 0; duration = d}

(* Translate from Ast_src.seq to a list of Ast_tgt notes. *)
let seq_translate (seq : Ast_src.seq) = List.map note_translate seq

(* Take id and seq from Ast_src.seqdef, translate seq using seq_translate and 
   update them in the symbol table. *)
let seqdef_translate (seqdef : Ast_src.seqdef) = 
  let seq_id = seqdef.name.id in
  let translated_seq = seq_translate seqdef.seq in
  Symbol_table.update_sequence seq_id translated_seq

(* Translates waveforms from Ast_src to Ast_tgt *)
let waveform_translate = function
  | Ast_src.Noise -> Noise
  | Ast_src.Vpulse -> Vpulse
  | Ast_src.Sawtooth -> Sawtooth
  | Ast_src.Triangle -> Triangle

(* Translates idents from Ast_src to Ast_tgt *)
let ident_translate (id : Ast_src.ident) : Ast_tgt.ident = 
    { Ast_tgt.id = id.id; id_loc = id.id_loc }

(* Translates voice from Ast_src to Ast_tgt *)
let voice_translate vc = List.map (fun (sn,wf) -> (ident_translate sn, waveform_translate wf)) vc

(* Function which sets mutable reference "params" to values from Ast_src *)
let set_params (p : Ast_src.params) =
  params := p

(* Outer function which translates an entire Ast_src file into Ast_tgt format *)
let file_translate (f : Ast_src.file) = 
  set_params f.parameters;
  List.iter seqdef_translate f.sequences;
  {
    vc1 = voice_translate f.voice1;
    vc2 = voice_translate f.voice2;
    vc3 = voice_translate f.voice3;
  }