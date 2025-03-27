(* Token Declarations *)

{ 
    Open Token
    Open Lexer
    Open Utils
}

%token <int> INT
%token <int> TEMPO
%token  <string> LETTER
%token <tonename> TONENAME
%token ACC
%token LCB
%token RCB
%token EOF

%start prog

(* ---Context Free Grammer--- *)

(*
{}: contains semantic action 
$: used for accessing the value of non-terminals or tokens
*)

prog:
    | EOF {}


seq:
    | LCB note_list RCB {Simple $2}

note: 
    | tone oct frac {$1 $2 $3}

tone:
    | tonename
    | tonename ACC {$1 $2}

oct:


frac:


tonename: 
    | 




