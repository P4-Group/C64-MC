type loc = Lexing.position * Lexing.position

type ident = { id: string; id_loc: loc }

and note = {
    highfreq: int;
    lowfreq: int;
    duration: int; (*Frames*)
}

and waveform =
    | Vpulse
    | Triangle
    | Sawtooth
    | Noise

type channel = (ident * waveform) list

type file = {
    ch1: channel;
    ch2: channel;
    ch3: channel;
}