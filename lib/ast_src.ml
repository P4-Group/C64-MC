type params = {
  tempo : int option;
  timesig : (int * int) option;
  stdpitch : int option; 
}


type ident = string

and seq = note list

and seqdef = { 
  name : ident;
  seq : seq;
}

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
  | Defined of int

and waveform =
  | Noise
  | Vpulse
  | Sawtooth
  | Triangle

type voice = (ident * waveform) list

type file = {
  parameters: params;
  sequences: seqdef list;
  voice1: voice;
  voice2: voice;
  voice3: voice;
}
