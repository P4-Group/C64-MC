type ident = string

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