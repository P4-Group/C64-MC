type params =
  { tempo : int option ;
    timesig : (int * int) option ;
    stdpitch : int option; }

type loc = Lexing.position * Lexing.position

type ident = { id: string; id_loc: loc }

and seq = note list

and seqdef =
{ name : ident;
  seq : seq ;}

and note =
  | Sound of tone * acc * frac * oct
  | Rest of frac

and tone =
  | A
  | B
  | C
  | D
  | E
  | F
  | G

and acc =
  | Nat
  | Sharp
  | Flat

and frac =
  | Whole
  | Half
  | Quarter
  | Eighth
  | Sixteenth

and oct =
  | None
  | Orig of int

and waveform =
  | Vpulse
  | Triangle
  | Sawtooth
  | Noise

type channel = (ident * waveform) list

type file = {
  parameters: params;
  sequences: seqdef list;
  channel1: channel;
  channel2: channel;
  channel3: channel;
}



















(*
type tone =
  | C
  | D
  | E
  | F
  | G
  | A
  | B

type octave = int
type frac = float

type sequenceStmt =
  | Note        of tone * octave * frac
  | Transpose   of sequenceStmt list * int

  | Loop        of sequenceStmt list * floopy_controly
    and floopy_controly =
    | x of int
    | While of bool

type Sequence = {
    name      : string;
    formals   : string list;
    body      : sequenceStmt list;
}

type params = string list

type file = {
    params : params;
    sequences : Sequence list;
}
*)
