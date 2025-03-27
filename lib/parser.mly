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
%token CHANNEL
%token VPULSE SAWTOOTH TRIANGLE NOISE
%token SEQUENCE
(* %token LOOP *)
%token SP (* start paranthesis *)
%token EP (* end paranthesis *)
%token LCB (* left curly bracket *)
%token RCB (* right curly bracket *)
%token LSB (* left square bracket *)
%token RSB (* right square bracket *)
%token COLON EQ
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
    | p = params
      sl = list(seqdef)
      c1 = channel (* c2 = channel c3 = channel *) EOF
    { {prs = p; sqs = sl; ch1 = c1; (* ch2 = c2; ch3 = c3 *)} }

params:
  | TEMPO EQ tmo = INT
    TIMESIG EQ SP i = INT COMMA j = INT EP
    STDPITCH EQ k = INT {
    {tempo = Some tmo; tmsig = Some (i,j); pitch = Some k} }

seqdef:
    | SEQUENCE id = ident EQ LCB sbody = seqb RCB
    { {name = id; seq = sbody} }

seqb:
    | nl = nonempty_list(note)
    { Simple nl }
    (* TODO: add two rules later for composition and loops *)

note:
  | n = ident a = option(acc) o = oct COLON f = frac
  { let tnm = (id2tonename n.id) in
    let tn = match a with
     | None     -> Nat tnm
     | Some acc -> Alt (tnm, acc) in                                   Sound (tn, o, f) }
  | r = ident f = frac
     { if not (r.id = "R")
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
  | CHANNEL EQ LSB ch = separated_list(COMMA, seqwv) RSB
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
