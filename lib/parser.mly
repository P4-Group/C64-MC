(* Token Declarations *)

%{
    open Ast
    open Utils
%}

%token <int> INT
%token <int> STDPITCH
%token <int> TEMPO
%token <int*int> TIMESIG
%token <string> IDENT
%token SHARP FLAT
%token SEQUENCE
%token CHANNEL1 CHANNEL2 CHANNEL3
%token VPULSE SAWTOOTH TRIANGLE NOISE
(* %token LOOP *)
%token SP (* start paranthesis *)
%token EP (* end paranthesis *)
%token LCB (* left curly bracket *)
%token RCB (* right curly bracket *)
%token LSB (* left square bracket *)
%token RSB (* right square bracket *)
%token COLON EQUAL
%token COMMA
%token EOF

%start prog (* axiom *)
%type <Ast.file> prog

(* ---Semantic Actions--- *)

(* ---Context Free Grammar--- *)

(*
{}: contains semantic action
$: used for accessing the value of non-terminals or tokens
*)

%%

prog:
    | p = params seql = list(seqdef) ch1 = channel (* ch2 = channel ch3 = channel *) EOF
    { {parameters = p; sequences = seql; channel1 = ch1; (* channel2 = ch2; channel3 = ch3 *)} }

params:
  | TEMPO ASSIGN t = INT
    TIMESIG ASSIGN SP npm = INT COMMA bnv = INT EP
    STDPITCH ASSIGN sp = INT {
    {tempo = Some t; timesig = Some (npm,bnv); stdpitch = Some sp} }

seqdef:
    | SEQUENCE id = ident ASSIGN LCB sb = seq RCB
    { {name = id; seq = sb} }

seq:
    | nl = nonempty_list(note) { Simple nl }
    | s1 = seq s2 = seq { Comp (s1, s2) }
    | s = seq l = INT { Loop (s, l) }

note:
  | tn = ident a = option(acc) o = oct COLON f = frac
  { let tn = (id2tonename t.id) in (*rename function ident_to_tone*)
    let t = match a with
     | None     -> Nat tn
     | Some acc -> Alt (tn, acc) in 
     Sound (t, o, f) }
  | r = ident f = frac
     { if not (r.id = "r")
       then failwith "not a pause"
       else Rest f }
acc:
  | SHARP { Sharp }
  | FLAT  { Flat }

oct:
  | i = INT { Orig i }

frac:
  | i = INT { match i with
              | 1 -> Full
              | 2 -> Half
              | 4 -> Quarter
              | 8 -> Eight
              | 16 -> Sixteen
              | _ -> failwith "wrong duration" }

channel:
  | CHANNEL ASSIGN LSB ch = separated_list(COMMA, seqwv) RSB
      { ch }


seqwv:
    | SP seqid = ident COMMA wv = waveform EP  { (seqid, wv) }


waveform:
    | VPULSE      { Vpulse }
    | TRIANGLE    { Triangle }
    | SAWTOOTH    { Sawtooth }
    | NOISE       { Noise }


ident:
| id = IDENT { { id = id; id_loc = $startpos, $endpos } }
;
