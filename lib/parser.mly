(* Token Declarations *)

{ 
    Open Token
    Open Lexer
    Open Utils

    let check_tonename = function
        | "A" -> A
        | "B" -> B
        | "C" -> C
        | "D" -> D
        | "E" -> E
        | "F" -> F
        | "G" -> G
        | _ -> failwith "Invalid tonename"

}

%token <int> INT
%token <int> PITCH
%token <int> TEMPO
%token <int*int> SIG
%token  <string> LETTER
%token <tonename> TONENAME
%token ACC COMMA
%token LCB LSB
%token RCB RSB
%token EOF

%start prog 
%type <Ast.file> prog

(* ---Semantic Actions--- *)

(* ---Context Free Grammer--- *)

(*
{}: contains semantic action 
$: used for accessing the value of non-terminals or tokens
*)

prog:
    | p = params c1 = channel c2 = channel c3 = channel EOF {
         {prs = p; ch1 = c1; ch2 = c2; ch3 = c3} }

params:
    | to = TEMPO? so = SIG? po = PITCH? {
        {tmp = to; sig = so; pitch = po} }
      

channel:
    | LSB ch = separated_list(COMMA, seqwv) RSB { ch }

seqwv:  
    | LP s = seq COMMA wv = waveform RP  { (seq, wv) }
    

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




