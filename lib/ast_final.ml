type loc = Lexing.position * Lexing position

type ident = { id: string; id_loc: loc }

and seqdef = {
    name: ident;
    seq: note list;
}

and note = {
    highfreq = int;
    lowfreq = int;
    duration = int; (*Milliseconds*)
}

and waveform =
    | Vpulse
    | Triangle
    | Sawtooth
    | Noise

type channel = (ident * waveform) list

type file = {
    sqs: seqdef list;
    ch1: channel;
    ch2: channel;
    ch3: channel;
}