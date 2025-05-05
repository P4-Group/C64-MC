%{
    open Ast_src
    open Symbol_table
    open Exceptions
%}

%token <int> INT
%token <int> STDPITCH
%token <int> TEMPO
%token <int*int> TIMESIG
%token <string> IDENT
%token SHARP FLAT
%token SEQUENCE
%token VOICE1 VOICE2 VOICE3
%token VPULSE SAWTOOTH TRIANGLE NOISE
%token SP EP (* start and end paranthesis *)
%token LCB RCB (* left and right curly bracket *)
%token LSB RSB (* left and right square bracket *)
%token COLON COMMA
%token ASSIGN (* = *)
%token EOF

%start prog (* axiom *)
%type <Ast_src.file> prog

%%

(* Source file is parsed starting from the axiom. *)
prog:
    | p = params seql = list(seqdef) vc1 = voice1 vc2 = voice2 vc3 = voice3 EOF
    { {parameters = p; sequences = seql; voice1 = vc1; voice2 = vc2; voice3 = vc3 } }


(* Parameter assignment is parsed. Ensures that basic note value is valid. *)
params:
  | TEMPO ASSIGN t = INT
    TIMESIG ASSIGN SP npm = INT COMMA bnv = INT EP
    STDPITCH ASSIGN sp = INT
    { let bnv = match bnv with
        | 1 | 2 | 4 | 8 | 16 -> bnv
        | _ -> raise (InvalidArgumentException "Invalid basic note value in time signature, expected '1', '2', '4', '8', '16'") in
      {tempo = Some t; timesig = Some (npm,bnv); stdpitch = Some sp} }

(* List of sequence definitions is parsed. Ensures that there are no duplicate sequences. *)
seqdef:
    | SEQUENCE id = ident ASSIGN LCB sb = seq RCB

    (* Adds sequence to the symbol table. Raises an exception if a sequence with the same id is already in the table. *)
    { add_sequence id.id sb;
      {name = id; seq = sb}  
    }

(* Sequence is parsed as a list of notes. *)
seq:
    | nl = nonempty_list(note) { nl }

(* Notes are parsed, either as sound or rest subtype. Ensures that tone is valid. *)
note:
  | t = ident a = acc COLON f = frac COLON? o = oct
  { if (t.id = "r") then ( Rest f )
    else
      let t = match t.id with
        | "a" -> A
        | "b" -> B
        | "c" -> C
        | "d" -> D
        | "e" -> E
        | "f" -> F
        | "g" -> G
        | _ -> raise (InvalidArgumentException "Invalid tone, expected 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'r'") in
      Sound (t, a, f, o) 
      }

(* Accidentals, octaves and fractions are parsed. *)
acc:
  | { Nat }
  | SHARP { Sharp }
  | FLAT  { Flat }

oct:
  | { None }
  | i = INT 
    { if (i >= 0 && i < 8) then Defined i 
      else raise (InvalidArgumentException "Invalid octave, expected an integer between 0 and 7")}

frac:
  | i = INT { match i with
              | 1 -> Whole
              | 2 -> Half
              | 4 -> Quarter
              | 8 -> Eighth
              | 16 -> Sixteenth
              | _ -> raise (InvalidArgumentException "Invalid duration, expected '1', '2', '4', '8', '16'") }

(* The three voices are parsed. *)
voice1:
  | VOICE1 ASSIGN LSB ch1 = separated_list(COMMA, seqwv) RSB
      { ch1 }

voice2:
  | VOICE2 ASSIGN LSB ch2 = separated_list(COMMA, seqwv) RSB
      { ch2 }

voice3:
  | VOICE3 ASSIGN LSB ch3 = separated_list(COMMA, seqwv) RSB
      { ch3 }

(* Sequence id and waveform pair of a voice is parsed. Ensures that sequence has been defined. *)
seqwv:
    | SP seqid = ident COMMA wv = waveform EP  

    { 
      (* Checks if the sequence exists in the the symbol table. Raises an exception if it is not. *)
      check_sequence seqid.id;
      (seqid, wv) 
    }

(* Waveform is parsed. Raise exception if value does not correspond to a waveform keyword. *)
waveform:
    | NOISE       { Noise }
    | VPULSE      { Vpulse }
    | SAWTOOTH    { Sawtooth }
    | TRIANGLE    { Triangle }
    | IDENT { raise (InvalidArgumentException "Invalid waveform, expected 'noise', 'vPulse', 'sawtooth', 'triangle'") }

(* Ident is parsed with both id and location. *)
ident:
| id = IDENT { { id = id; id_loc = $startpos, $endpos } }
;