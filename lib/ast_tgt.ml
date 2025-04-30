type loc = Lexing.position * Lexing.position

type ident = { id: string; id_loc: loc }

and note = {
    highfreq: int;
    lowfreq: int;
    duration: int; (*Frames*)
}

and waveform =
    | Noise
    | Vpulse
    | Sawtooth
    | Triangle

type voice = (ident * waveform) list

type file = {
    vc1: voice;
    vc2: voice;
    vc3: voice;
}