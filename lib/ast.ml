type params = 
  { tmp : int option ; 
    sig : (int * int) option ;
    pitch : int option; }


type transp = 
  | Octup
  | Octdwn

type acc = 
  | Sharp
  | Flat

type oct = 
  | Orig of int
  | Mod of oct * transp

type tonename = 
  | A 
  | B
  | C 
  | D 
  | E 
  | F 
  | G 

type tone = 
  | Nat of tonename
  | Alt of tonename * acc

type frac = 
  | Full
  | Half
  | Quarter
  | Eight
  | Sixteen
  
type note = tone * oct * frac

type waveform = 
  | Vpulse
  | Triangle
  | Sawtooth
  | Noise

type pattern =
  | Up
  | Down
  | Updown

type chord = {
  notes: (tone * oct) list
}

type seq = 
  | Simple of note list
  | Comp of seq * seq
  | Loop of seq * int
  | Arpeg of chord * int * pattern * int

type channel = (seq * waveform) list

type file = {
  prs: params;
  ch1: channel;
  ch2: channel;
  ch3: channel;
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