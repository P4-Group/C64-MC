type loc = Lexing.position * Lexing position

type ident = { id: string; id_loc: loc }

type params = {
    tempo : int;
    timesig : int * int;
    stdpitch : int;
}

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
    prs: params;
    sqs: seqdef list;
    ch1: channel;
    ch2: channel;
    ch3: channel;
}