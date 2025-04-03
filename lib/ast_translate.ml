open Ast_final

exception Error of Ast.loc option * string

let error ?loc s = raise (Error (loc, s))

(*Insert specific errors here*)

(* Insert params if needed *)

let notes = function
  | Ast.Sound (t, a, f, o) -> 
    note_translate(t, a, f, o);
    note {highfreq: hf; lowfreq: lf; duration: d;}
  | Ast.Rest t ->
    let d = get_note_duration f;
    note {highfreq: 0; lowfreq: 0; duration: d}

let note_translate (t, a, f, o) = 
    let frequency = ref Ast.stdpitch; (*Frequency starts at standard pitch*)
    (*Depending on tone, move frequency up by n semitones in this formula:
    fn = f0 * 2^(n/12)
    where f0 is fixed starting pitch (standard pitch), and fn is resulting pitch  *)
    begin match t with
        | C -> frequency = frequency * 2^(-9/12) (* Start tone of fourth octave *)
        | D -> frequency = frequency * 2^(-7/12)
        | E -> frequency = frequency * 2^(-5/12)
        | F -> frequency = frequency * 2^(-4/12)
        | G -> frequency = frequency * 2^(-2/12)
        | A -> (*Nothing happens, this is already standard pitch*)
        | B -> frequency = frequency * 2^(2/12)
    end
    (*Depending on accidental, move up or down one semitone*)
    begin match a with
        | None -> (*Nothing happens*)
        | Sharp -> frequency = frequency * 2^(1/12)
        | Flat -> frequency = frequency * 2^(-1/12)
    end
    frequency = (frequency * o) / 4 (* Move tone to correct octave *)
    frequency = frequency / 0.06097 (* Convert frequency output to oscillator decimal *)
    let hf = int_of_float (frequency/256) (* High frequency *)
    let lf = frequency - (256 * hf) (* Low frequency *)

    let d = get_note_duration f 
    (*TODO: Fix syntax, check calculations with unit tests*)

    let get_qn_duration =
        let bnv_duration = 60000 / Ast.tempo
        let qn_duration = ref bnv_duration
        begin match Ast.timesig(1) with 
            | 1 -> qn_duration = bnv_duration / 4
            | 2 -> qn_duration = bnv_duration / 2
            | 4 -> (* Nothing happens *)
            | 8 -> qn_duration = bnv_duration * 2
            | 16 -> qn_duration = bnv_duration * 4
        end

    let get_note_duration = function
        | Whole -> qn_duration * 4
        | Half -> qn_duration * 2
        | Quarter -> (* Nothing happens*)
        | Eighth -> qn_duration / 2
        | Sixteenth -> qn_duration / 4