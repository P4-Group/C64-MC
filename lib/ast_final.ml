type loc = Lexing.position * Lexing position

type ident = { id: string; id_loc: loc }

type params = {
    tempo : int;
    timesig : int * int;
    stdpitch : int;
}

and sedef = {
    name: ident;
    seq: note list;
}

and note = {
    pitch = int;
    duration = int;
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