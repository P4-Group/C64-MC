
{
  open Parser
  open Exceptions

  (* ----------- Helper Functions ----------- *)

  (* This helper function maps strings to either reserved keyword tokens or IDENT tokens.
    They keyword is the key, and the token is the value.
    The reserved keywords and their associated tokens are stored in a hashtable by iterating 
    over a list of pairs and adds the pairs to the hashtable. 
    This function is called in the main read function, checking if the input string 's' matches any 
    of the keywords in the hashtable. If so, it will be tokenised as the keywords associated token.
    If not, it will be tokenised as an IDENT. *)
    
  let ident_or_keyword =
    let hashtbl = Hashtbl.create 17 in
    List.iter (fun (keyword,token) -> Hashtbl.add hashtbl keyword token)
      [ "tempo", TEMPO 120;
        "timeSignature", TIMESIG (4,4);
        "standardPitch", STDPITCH 440;
        "sequence", SEQUENCE;
        "voice1", VOICE1;
        "voice2", VOICE2;
        "voice3", VOICE3;
        "noise", NOISE;
        "vPulse", VPULSE;
        "sawtooth", SAWTOOTH;
        "triangle", TRIANGLE;
        ];
    fun s -> try Hashtbl.find hashtbl s with Not_found -> IDENT s


  (* Helper function for error handling of unterminated comments.
    'a is a polymorphic type variable, meaning it's an unspecified type. 'a is used, 
    because the lexer expects a return value of type token, but this function does not return
    anything but raises an exception. a' is therefore used as a placeholder for a return value.
    The function has parameter lexbuf and returns 'a. *)

  let unterminated_comment lexbuf : 'a =
    let pos = Lexing.lexeme_start_p lexbuf in (* gets the start position of the current lexeme *)
    let line = pos.pos_lnum in (* gets the linenumber of the position *)
    raise (SyntaxErrorException (Printf.sprintf "Unterminated comment at line %d" line))


  (* This helper function is used for lexical and parsing errors. It retrieves the position of the
    lexeme that is currently being processed in lexbuf and returns a string that indicates the line and character
    position of the lexeme. *)

  let lexeme_error lexbuf : 'a =
    let start_pos = Lexing.lexeme_start_p lexbuf in
    let end_pos = Lexing.lexeme_end_p lexbuf in
    let start_ch = start_pos.pos_cnum - start_pos.pos_bol +1 in
    let end_ch = end_pos.pos_cnum - end_pos.pos_bol in
    let line = start_pos.pos_lnum in
    if start_ch == end_ch then 
      (Printf.sprintf "at line %d character %d" 
      line start_ch)
    else
      (Printf.sprintf "at line %d character %d-%d" 
      line start_ch end_ch)
}

(* ----------- Regular Expressions ----------- *)


let digit = ['0'-'9'] (* matches any single character between 0-9*)
let int = digit+ (* '+' means one or more occurences of previous pattern, so 124,22,456 etc *)

let whitespace = [' ' '\t' '|']+ (*| is to use in the sequences, to separate bars *)
let newline = "\r\n" | '\n' | '\r'
let tone = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "r" 
let letter = ['a'-'z' 'A'-'Z']
let ident = letter (letter | '-' | digit)+ (* identity for a sequence *)


(* ---Lexing Rules--- *)

(* The read function is the main function of our lexer. It reads the input and tokenises it by matching 
   segments of the input string to the regex patterns. If it matches a regex pattern, the lexer 
   will perform the semantic action paired with the matched regex. If it does not match any of the 
   regex patterns, it raises a Lexical Error Exception. 
   It uses a recursive descent approach to process the input. *)

rule read = parse
  | whitespace {read lexbuf} (* calls itself recursively *)
  | newline {Lexing.new_line lexbuf; read lexbuf} 
  | tone {TONE (Lexing.lexeme lexbuf)}
  | ident as s {ident_or_keyword s}
  | int {INT (int_of_string (Lexing.lexeme lexbuf))}
  | "/*" {comment lexbuf}
  | "#"  {SHARP}
  | "_" {FLAT}
  | "{" {LCB}
  | "}" {RCB}
  | "[" {LSB}
  | "]" {RSB}
  | "(" {SP}
  | ")" {EP}
  | ":" {COLON}
  | "," {COMMA}
  | "=" {ASSIGN}
  | eof {EOF}
  | _ {raise (LexicalErrorException 
      ("Invalid input, expected a token " ^ lexeme_error lexbuf))}

(* ----------- Lexer States ----------- *)

and comment = parse
  | "*/" {read lexbuf}
  | newline {unterminated_comment lexbuf} 
  | _ {comment lexbuf}
  | eof {unterminated_comment lexbuf}




