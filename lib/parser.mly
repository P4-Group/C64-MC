(* Token Declarations *)

{ 
    Open Token
    Open Lexer
    Open Utils
}

%token <int> INT
%token <int> STDPITCH
%token <int> TEMPO
%token <int*int> TIMESIG
%token <string> LETTER
%token <string> ID
%token ACC
%token SEQ
%token LOOP
%token SP (* start paranthesis *)
%token EP (* end paranthesis *)
%token LCB (* left curly bracket *)
%token RCB (* right curly bracket *)
%token LSB (* left square bracket *)
%token RSB (* right square bracket *)
%token COLON
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

prog:
    | p = params c1 = channel c2 = channel c3 = channel EOF {
         {prs = p; ch1 = c1; ch2 = c2; ch3 = c3} }

params:
    | to = TEMPO? so = TIMESIG? po = STDPITCH? { 
        {tmp = to; sig = so; pitch = po} }
      

channel:
    | LSB ch = separated_list(COMMA, seqwv) RSB { ch }

seqwv:  
    | SP s = seq COMMA wv = waveform EP  { (seq, wv) }
    

seq:
    | LCB note_list RCB {Simple $2}

note: 
    | tone oct frac {$1 $2 $3}

tone:
    | tonename
    | tonename ACCIDENTAL {$1 $2}

oct:


frac:


tonename: 
    | 

waveform: 




