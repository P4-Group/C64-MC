(* Token Declarations *)

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
(*%token LOOP*)
%token SP (* start paranthesis *)
%token EP (* end paranthesis *)
%token LCB (* left curly bracket *)
%token RCB (* right curly bracket *)
%token LSB (* left square bracket *)
%token RSB (* right square bracket *)
%token COLON COMMA
%token ASSIGN (* = *)
%token EOF

%start prog (* axiom *)
%type <Ast_src.file> prog

(* ---Semantic Actions--- *)

(* ---Context Free Grammar--- *)

(*
{}: contains semantic action
$: used for accessing the value of non-terminals or tokens
*)

%%


(* CFG: 
   List of nonterminals with syntax and semantic action in the following structure:
    nonterminal:
      | syntax { semantic action }
   Each option of how to interpret a nonterminal starts with a |.
   The first nonterminal, prog, is the axiom.
 *)

 (* nonterminal: 
    Name of the nonterminal we want to expand on below.
    Example:
      seqdef:
    Parses syntax and defines semantic action of the seqdef nonterminal.
 *)

 (* syntax: 
    Structure of tokens (written in all caps) and local variables (written as variable_name = nonterminal)
    Example: 
      | SEQUENCE id = ident ASSIGN LCB sb = seq RCB
    Parses sequences in the generalized form (from source language):
      sequence ident = { seq }, 
    such as: 
      sequence mySequence = { a4:2 b2:2 }
    where 'id' holds the nonterminal ident and 'sb' holds the nonterminal seq
 *)

 (* semantic action: 
    Defines the relevant building blocks of the source AST and assigns values from the local variables above.
    Example: 
      { {name = id; seq = sb} } 
    Takes the value of 'id' (which as seen above is an ident) and assigns it to the 'name' of source AST's seqdef
    Takes the value of 'sb' (which as seen above is a seq) and assigns it to the 'seq' of source AST's seqdef
*)

prog:
    | p = params seql = list(seqdef) vc1 = voice1 vc2 = voice2 vc3 = voice3 EOF (* Overall file structure: Define parameters, define sequences, define voices *)
    { {parameters = p; sequences = seql; voice1 = vc1; voice2 = vc2; voice3 = vc3 } }


params:
  | TEMPO ASSIGN t = INT (* tempo = int; *)
    TIMESIG ASSIGN SP npm = INT COMMA bnv = INT EP (* timeSignature = (int,int) *)
    STDPITCH ASSIGN sp = INT (* standardPitch = int; *)
    { {tempo = Some t; timesig = Some (npm,bnv); stdpitch = Some sp} } (* all params use Some since they are optional/options (?) *)

seqdef:
    | SEQUENCE id = ident ASSIGN LCB sb = seq RCB (* sequence ident = { seq } *)

    (* Checks if there already exists a sequence with the specified id in the symbol table.
      If not, add the sequence to the symbol table. *)
    { add_sequence id.id sb;
      {name = id; seq = sb}  
    }

seq:
    | nl = nonempty_list(note) { nl } (* actual sequence of notes within curly brackets *)
    (*| s1 = seq s2 = seq { Comp (s1, s2) } *) (* won't work as is, maybe we scrap compound sequences *)
    (*| LOOP SP RCB s = seq LCB COMMA l = INT EP { Loop (s, l) }*) (* loop({seq}, int) *) (* TODO: Is it fine that loop function is also in curly brackets? *)
    (* TODO: Maybe add compound sequence if we can find a nice way to do it *)

note:
  | t = ident a = acc COLON f = frac COLON? o = oct (* ident accidental octave : fraction *)
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
        | _ -> raise (InvalidArgumentError "Invalid tone, expected 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'r'") in
      Sound (t, a, f, o) 
      } (* Full note with octave and fraction *)

acc:
  | { Nat }
  | SHARP { Sharp }
  | FLAT  { Flat }

oct:
  | { None }
  | i = INT 
    { if (i >= 0 && i < 8) then Defined i 
      else raise (InvalidArgumentError "Invalid octave, expected an integer between 0 and 7")}

frac:
  | i = INT { match i with
              | 1 -> Whole
              | 2 -> Half
              | 4 -> Quarter
              | 8 -> Eighth
              | 16 -> Sixteenth
              | _ -> raise (InvalidArgumentError "Invalid duration, expected '1', '2', '4', '8', '16'") }

voice1:
  | VOICE1 ASSIGN LSB ch1 = separated_list(COMMA, seqwv) RSB (* voice = [seqwv+] *)
      { ch1 }

voice2:
  | VOICE2 ASSIGN LSB ch2 = separated_list(COMMA, seqwv) RSB (* voice = [seqwv+] *)
      { ch2 }

voice3:
  | VOICE3 ASSIGN LSB ch3 = separated_list(COMMA, seqwv) RSB (* voice = [seqwv+] *)
      { ch3 }


seqwv:
    | SP seqid = ident COMMA wv = waveform EP  

    { 
      (* Calls a helper function to check if the defined sequence id exists in the symbol table.
        If not, an error will be thrown. *)
      check_sequence seqid.id;
      (seqid, wv) 
    } (* (ident,waveform) *)


(*Has IDENT in case that a user something other than one of the four keywords*)
waveform:
    | NOISE       { Noise }
    | VPULSE      { Vpulse }
    | SAWTOOTH    { Sawtooth }
    | TRIANGLE    { Triangle }
    | IDENT { raise (InvalidArgumentError "Invalid waveform, expected 'noise', 'vPulse', 'sawtooth', 'triangle'") }


ident:
| id = IDENT { { id = id; id_loc = $startpos, $endpos } } (*ident both has id (the corresponding string) and a start and end position (used in error handling etc)*)
;