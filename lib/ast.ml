
type loc = Lexing.position * Lexing.position

type ident = { id: string; id_loc: loc }

type params =
  { tempo : int option ;
    tmsig : (int * int) option ;
    pitch : int option; }

and seqdef =
{ name : ident;
  seq : seq ;}


and transp =
  | Octup
  | Octdwn

and acc =
  | Sharp
  | Flat

and oct =
  | Orig of int
  | Mod of oct * transp

and tonename =
  | A
  | B
  | C
  | D
  | E
  | F
  | G

and tone =
  | Nat of tonename
  | Alt of tonename * acc

and frac =
  | Full
  | Half
  | Quarter
  | Eight
  | Sixteen

and note =
 | Sound of tone * oct * frac
 | Rest of frac

and waveform =
  | Vpulse
  | Triangle
  | Sawtooth
  | Noise

and seq =
  | Simple of note list
  | Comp of seq * seq
  | Loop of seq * int


type channel = (ident * waveform) list

type file = {
  prs: params;
  sqs: seqdef list;
  ch1: channel;
  (* ch2: channel; *)
  (* ch3: channel; *)
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
