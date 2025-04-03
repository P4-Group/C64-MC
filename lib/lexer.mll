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

 exception Lexical_error of string

(* TODO: comments and move to Utils *)
  let ident_or_keyword =
    let h = Hashtbl.create 17 in
    List.iter (fun (s,k) -> Hashtbl.add h s k)
      [ "tempo", TEMPO 120;
        "timeSignature", TIMESIG (4,4);
        "standardPitch", STDPITCH 440;
        "sequence", SEQUENCE;
        "channel1", CHANNEL1;
        "channel2", CHANNEL2;
        "channel3", CHANNEL3;
        "vPulse", VPULSE;
        "triangle", TRIANGLE;
        "sawtooth", SAWTOOTH;
        "noise", NOISE
        ];
    fun s -> try Hashtbl.find h s with Not_found -> IDENT s
}

(* ---Regular Expressions--- *)

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

let whitespace = [' ' '\t']+
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
Lexing.lexeme lexbuf: extracts  the matched text as a string
int_of_string: converts the string to an integer
tonename_of_string: converts string to type tonename
{read lexbuf}: read is the main function that reads the input which should
be tokenized. The input is stored in lexbuf. If there's a white space it
calls itself recursively since whitespaces shouldnt be tokenized so it just
continues on reading the input.
{next_line lexbuf}: updates the line counter in the lexing buffer
*)

rule read = parse
    | whitespace {print_string " "; read lexbuf} (* calls itself recursively *)
    | newline {Lexing.new_line lexbuf; print_endline ""; read lexbuf} (* define in utils *)
    | ident as s { print_string "ident"; ident_or_keyword s }
    | int {print_string "int"; INT (int_of_string (Lexing.lexeme lexbuf))}
    (* | float (FLOAT (float_of_string (Lexing.lexeme lexbuf))) *)
    | "/*" {comment lexbuf}
    | "#"  {print_string "#"; SHARP}
    | "_" {print_string "_"; FLAT}
    | "{" {print_string "{"; LCB}
    | "}" {print_string "}"; RCB}
    | "[" {print_string "["; LSB}
    | "]" {print_string "]"; RSB}
    | "(" {print_string "("; SP}
    | ")" {print_string ")"; EP}
    | ":" {print_string ":"; COLON}
    | ";" {print_string ";"; SEMICOLON}
    | "," {print_string ","; COMMA}
    | "=" {print_string "="; ASSIGN}
    | eof {print_endline "EOF"; EOF}

(* --Mutual Recursive Rules-- *)

and comment = parse
    | "*/" {read lexbuf}
    | _ {comment lexbuf}
    | eof {failwith "non terminated comment"}

(* and sequence = parse
    | "}" {read lexbuf}
    | tonename {TONENAME (tonename_of_string (Lexing.lexeme lexbuf))}

and channel = parse
    | "]" {read lexbuf}
} *)
