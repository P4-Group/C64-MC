open Ast_final

exception Error of Ast.loc option * string

let error ?loc s = raise (Error (loc, s))

(*Insert specific errors here*)

(* Insert params if needed *)

let notes = function
  | Ast.Sound (t, a, f, o) -> 
    note_translate(t, a, f, o);
    note {highfreq: hf; lowfreq: lf; duration: d;}

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
    (*TODO: Fix syntax, check calculations and add calculation from fraction to duration in ms*)
