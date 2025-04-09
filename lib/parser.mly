(* Token Declarations *)

%{
    open Ast
    open Utils

    (*Creating a hashtable to save sequence indentifiers and the sequence body
      We only save the identifier string not the location
      we declare a variable with the type hashtable, with a string as key and a seq as value. 
      Lastly we we initialise the variable to a hashtable with 10 spaces.
    *)
    let sequence_list : (string, seq) Hashtbl.t = Hashtbl.create 10
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
(*%token LOOP*)
%token SP (* start paranthesis *)
%token EP (* end paranthesis *)
%token LCB (* left curly bracket *)
%token RCB (* right curly bracket *)
%token LSB (* left square bracket *)
%token RSB (* right square bracket *)
%token COLON SEMICOLON COMMA
%token ASSIGN (* = *)
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
    Defines the relevant building blocks of the AST and assigns values from the local variables above.
    Example: 
      { {name = id; seq = sb} } 
    Takes the value of 'id' (which as seen above is an ident) and assigns it to the 'name' of AST's seqdef
    Takes the value of 'sb' (which as seen above is a seq) and assigns it to the 'seq' of AST's seqdef
*)

prog:
    | p = params seql = list(seqdef) ch1 = channel1 ch2 = channel2 ch3 = channel3 EOF (* Overall file structure: Define parameters, define sequences, define channels *)
    { {parameters = p; sequences = seql; channel1 = ch1; channel2 = ch2; channel3 = ch3 } }


params:
  | TEMPO ASSIGN t = INT SEMICOLON (* tempo = int; *)
    TIMESIG ASSIGN SP npm = INT COMMA bnv = INT EP SEMICOLON (* timeSignature = (int,int) *)
    STDPITCH ASSIGN sp = INT SEMICOLON (* standardPitch = int; *)
    { {tempo = Some t; timesig = Some (npm,bnv); stdpitch = Some sp} } (* all params use Some since they are optional/options (?) *)

seqdef:
    | SEQUENCE id = ident ASSIGN LCB sb = seq RCB (* sequence ident = { seq } *)
    { (*We save sequences only if the identifier is unique and hasn't been used before
        If a sequence exists we fail *)
      if Hashtbl.mem sequence_list id.id then (*Checking only the name of the ident not the location*)
        failwith "Sequences with the same name cannot be defined twice";

      Hashtbl.add sequence_list id.id sb; 
      {name = id; seq = sb}  
    }

seq:
    | nl = nonempty_list(note) { Simple nl } (* actual sequence of notes within curly brackets *)
    (*| s1 = seq s2 = seq { Comp (s1, s2) } *) (* won't work as is, maybe we scrap compound sequences *)
    (*| LOOP SP RCB s = seq LCB COMMA l = INT EP { Loop (s, l) }*) (* loop({seq}, int) *) (* TODO: Is it fine that loop function is also in curly brackets? *)
    (* TODO: Maybe add compound sequence if we can find a nice way to do it *)

note:
  | t = ident a = acc COLON f = frac COLON? o = oct (* ident accidental octave : fraction *)
  { if (t.id = "r") then ( Rest f )
    else (let t = (ident_to_tone t.id) in (*Replaces tone ident with actual AST tone type*)
    Sound (t, a, f, o)) } (* Full note with octave and fraction *)

acc:
  | { None }
  | SHARP { Sharp }
  | FLAT  { Flat }

oct:
  | { None }
  | i = INT { Orig i }

frac:
  | i = INT { match i with
              | 1 -> Full
              | 2 -> Half
              | 4 -> Quarter
              | 8 -> Eighth
              | 16 -> Sixteenth
              | _ -> failwith "wrong duration" }

channel1:
  | CHANNEL1 ASSIGN LSB ch1 = separated_list(COMMA, seqwv) RSB (* channel = [seqwv+] *)
      { ch1 }

channel2:
  | CHANNEL2 ASSIGN LSB ch2 = separated_list(COMMA, seqwv) RSB (* channel = [seqwv+] *)
      { ch2 }

channel3:
  | CHANNEL3 ASSIGN LSB ch3 = separated_list(COMMA, seqwv) RSB (* channel = [seqwv+] *)
      { ch3 }


seqwv:
    | SP seqid = ident COMMA wv = waveform EP  
    { (*We add sequences to the channels only if the identifier is declared
        If a sequence doesn't exists we fail *)
      if not (Hashtbl.mem sequence_list seqid.id) then (*Checking only the name of the ident not the location*)
        failwith "Sequences must be defined before adding to a channel";
      
      (seqid, wv) 
    } (* (ident,waveform) *)


(*Has IDENT in case that a user something other than one of the four keywords*)
waveform:
    | VPULSE      { Vpulse }
    | TRIANGLE    { Triangle }
    | SAWTOOTH    { Sawtooth }
    | NOISE       { Noise }
    | IDENT { failwith "Has to be a valid waveform: vPulse, triangle, sawtooth, noise" }


ident:
| id = IDENT { { id = id; id_loc = $startpos, $endpos } } (*ident both has id (the corresponding string) and a start and end position (used in error handling etc)*)
;