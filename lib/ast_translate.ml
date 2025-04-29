open Ast_final
open Exceptions

(* Mutable reference to hold params from Ast *)
let params : Ast.params ref = ref { Ast.tempo = None; Ast.timesig = None; Ast.stdpitch = None }

(* Semitone offset of tone relative to A (standard pitch) *)
let base_offset = function
  | Ast.C -> -9 | Ast.D -> -7 | Ast.E -> -5 | Ast.F -> -4 
  | Ast.G -> -2 | Ast.A -> 0 | Ast.B -> 2

(* Semitone offset for accidental *)
let acc_offset = function
  | Ast.Nat -> 0
  | Ast.Sharp -> 1
  | Ast.Flat -> -1

(* Semitone offset for octave relative to 4th octave (standard pitch) *)
let oct_offset = function
  | Ast.Orig o -> (o - 4) * 12
  | _ -> 0

(* Get duration of quarter note from tempo and basic note value. 
   Used as reference point for duration of specific notes *)
let get_qn_duration () =
    let tempo_opt = !params.tempo in
    let tempo = Option.value tempo_opt ~default:120 in
    let timesig_opt = !params.timesig in
    let timesig = Option.value timesig_opt ~default:(4,4) in
    let _, bnv = timesig in
    let bnv_duration = 3000 / tempo in
    match bnv with 
    | 1 -> Printf.printf "Whole note"; bnv_duration / 4
    | 2 -> Printf.printf "Half note"; bnv_duration / 2
    | 4 -> Printf.printf "Quarter note"; bnv_duration
    | 8 -> Printf.printf "Eighth note"; bnv_duration * 2
    | 16 -> Printf.printf "Sixteenth note"; bnv_duration * 4
    | _ -> raise (IllegalTimeSignature "Invalid basic note value in time signature")

(* Get duration of specific note *)
let get_note_duration f =
  let qn_duration = get_qn_duration () in
  match f with
    | Ast.Whole -> qn_duration * 4
    | Ast.Half -> qn_duration * 2
    | Ast.Quarter -> qn_duration
    | Ast.Eighth -> qn_duration / 2
    | Ast.Sixteenth -> qn_duration / 4

(* Translate from Ast.note to Ast_final.note *)
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

(* Translate from Ast.seq to a list of Ast_final notes. *)
let seq_translate (seq : Ast.seq) = List.map note_translate seq

(* Take id and seq from Ast.seqdef, translate seq using seq_translate and 
   update them in the symbol table. *)
let seqdef_translate (seqdef : Ast.seqdef) = 
  let seq_id = seqdef.name.id in
  let translated_seq = seq_translate seqdef.seq in
  Symbol_table.update_sequence seq_id translated_seq None

(* Translates waveforms from Ast to Ast_final *)
let waveform_translate = function
  | Ast.Noise -> Noise
  | Ast.Vpulse -> Vpulse
  | Ast.Sawtooth -> Sawtooth
  | Ast.Triangle -> Triangle

(* Translates idents from Ast to Ast_final *)
let ident_translate (id : Ast.ident) : Ast_final.ident = 
    { Ast_final.id = id.id; id_loc = id.id_loc }

(* Translates voice from Ast to Ast_final *)
let voice_translate vc = List.map (fun (sn,wf) -> (ident_translate sn, waveform_translate wf)) vc

(* Function which sets mutable reference "params" to values from Ast *)
let set_params (p : Ast.params) =
  params := p

(* Outer function which translates an entire Ast file into Ast_final format *)
let file_translate (f : Ast.file) = 
  set_params f.parameters;
  List.iter seqdef_translate f.sequences;
  {
    vc1 = voice_translate f.voice1;
    vc2 = voice_translate f.voice2;
    vc3 = voice_translate f.voice3;
  }