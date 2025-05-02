(* Specifies how to recognise the tokens - the "rules"
to find the vocabulary in the input text.
the actual implementation of the lexical analysis
that scans the input and matches regular expressions to
the tokens (defined in token.mli)
Converts input into corresponding tokens

In a lexer everything is read as a sequence of characters (string).
*)

{ (* Header *)

    open Parser
    open Exceptions

  (* ----------- Helper Functions ----------- *)

  (* This function maps strings to either reserved keyword tokens or IDENT tokens.
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
          "triangle", TRIANGLE
          ];
    fun s -> try Hashtbl.find hashtbl s with Not_found -> IDENT s

  (* Helper function for error handling of unterminated comments.
    'a is a polymorphic type variable, meaning it's an unspecified type. 'a is used, 
    because the lexer expects a return value of type token, but this function does not return
    anything but raises an exception. a' is therefore used as a placeholder for a return value.
    The function has parameter lexbuf and returns 'a .  *)

  let unterminated_comment lexbuf : 'a =
      let pos = Lexing.lexeme_start_p lexbuf in (* gets the start position of the current lexeme *)
      let line = pos.pos_lnum in (* gets the linenumber of the position *)
      raise (SyntaxError (Printf.sprintf "Unterminated comment at line %d" line)) 
}

(* ----------- Regular Expressions ----------- *)


(* Regular Expression Patterns *)

(*
 '+' one or more occurences
 '*' zero or more occurences
 '?' indicates an optional component
 '[]' indicates a range
 '()' indicates a group
 '|' indicates or
 *)

let digit = ['0'-'9'] (* matches any single character between 0-9*)
let int = digit+ (* '+' means one or more occurences of previous pattern, so 124,22,456 etc *)
let frac = '.' digit* (* a decimal point followed by zero or more digits*)
let float = digit* frac (* matches zero or more digits before the decimal point*)

let whitespace = [' ' '\t' '|']+ (*| is to use in the sequences, to separate bars *)
let newline = '\n' | '\r'
let letter = ['a'-'z' 'A'-'Z']+
let ident = letter (letter | '-' | digit)* (* identity for a sequence *)

(* ---Lexing Rules--- *)

(* the lexing rules use the regular expression patterns to recognise tokens.
Maps regex patterns to tokens - when the lexer matches a pattern
it returns the corresponding token the parser *)

(*
{}: the action
lexbuf: a lexical buffer that stores the text being analysed.
Lexing: a module that provides functions for manipulating lexbuf
lexeme: the string of characters from the input that matches the current lexer rule
Lexing.lexeme lexbuf: extracts  the matched text as a string
int_of_string: converts the string to an integer
tonename_of_string: converts string to type tonename
{read lexbuf}: read is the main function that reads the input which should
be tokenized. The input is stored in lexbuf. If there's a white space it
calls itself recursively since whitespaces shouldnt be tokenised so it just
continues on reading the input.
{newline}: updates the line counter in the lexing buffer
*)

rule read = parse
    | whitespace {read lexbuf} (* calls itself recursively *)
    | newline {Lexing.new_line lexbuf; read lexbuf} 
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
    | _ {
        let start_pos = Lexing.lexeme_start_p lexbuf in
        let end_pos = Lexing.lexeme_end_p lexbuf in
        let start_ch = start_pos.pos_cnum - start_pos.pos_bol +1 in
        let end_ch = end_pos.pos_cnum - end_pos.pos_bol in
        let line = start_pos.pos_lnum in
        if start_ch == end_ch then 
          raise (LexicalError
                (Printf.sprintf "Invalid input, expected a token at line %d character %d" 
                line start_ch))
        
        else
          raise (LexicalError 
                (Printf.sprintf "Invalid input, expected a token at line %d character %d-%d" 
                line start_ch end_ch))}

(* ----------- Mutual Recursive Rules ----------- *)

and comment = parse
    | "*/" {read lexbuf}
    | newline {unterminated_comment lexbuf} 
    | _ {comment lexbuf}
    | eof {unterminated_comment lexbuf}

(*and sequence = parse
    | "}" {read lexbuf}
    | tone {TONE (tone_of_string (Lexing.lexeme lexbuf))}

and channel = parse
    | "]" {read lexbuf}
} *)



