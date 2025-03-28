(* Specifies how to recognise the tokens - the "rules"
to find the vocabulary in the input text.
the actual implementation of the lexical analysis
that scans the input and matches regular expressions to
the tokens (defined in token.mli)
Converts input into corresponding tokens

In a lexer everything is read as a sequence of characters (string).
*)

{ (* Header *)
    open Lexing
    open Parser
    (* open Utils *)

 exception Lexical_error of string

  let id_or_keyword =
    let h = Hashtbl.create 17 in
    List.iter (fun (s,k) -> Hashtbl.add h s k)
      [ "Vpulse", VPULSE;
        "Sequence", SEQUENCE ];
    fun s -> try Hashtbl.find h s with Not_found -> IDENT s

  let stack = ref [0]  (* indentation stack *)

  let rec unindent n = match !stack with
    | m :: _ when m = n -> []
    | m :: st when m > n -> stack := st; END :: unindent n
    | _ -> raise (Lexical_error "bad indentation")

  let update_stack n =
    match !stack with
    | m :: _ when m < n ->
      stack := n :: !stack;
      [NEWLINE; BEGIN]
    | _ -> assert false

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
let ident = letter (letter | '-' | '_' | digit)* (* identity for a sequence *)
let space = ' ' | '\t'
let comment = "#" [^'\n']*
let integer = '0' | ['1'-'9'] digit*

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
    | '\n' {new_line lexbuf; update_stack (indentation lexbuf)}
    | whitespace {read lexbuf} (* calls itself recursively *)
    (* | newline {next_line lexbuf; read lexbuf} (* define in utils *) *)
    | ident as s { [id_or_keyword s] }
    | integer as s
            { try [CST (Cint (Int.of_string s))]
              with _ -> raise (Lexing_error ("constant too large: " ^ s)) }
    (* | float (FLOAT (float_of_string (Lexing.lexeme lexbuf))) *)
    | "#"  {SHARP}
    |  "_" {FLAT}
    | "/*" {comment lexbuf}
    | "{" {LCB}
    | "}" {RCB}
    | "[" {LSB}
    | "]" {RSB}
    | "(" {SP}
    | ")" {EP}
    | ":" {COLON}
    | "," {COMMA}
    | eof {EOF}

(*
and next_line = parse
   | _  { assert false }
*)

(* --Mutual Recursive Rules-- *)

and comment = parse
    | "*/" {read lexbuf}
    | _ {comment lexbuf}
    | eof {failwith "non terminated comment"}

and indentation = parse
  | (space | comment)* '\n'
      { new_line lexbuf; indentation lexbuf }
  | space* as s
      { String.length s }

(* and sequence = parse
    | "}" {read lexbuf}
    | tonename {TONENAME (tonename_of_string (Lexing.lexeme lexbuf))}



and channel = parse
    | "]" {read lexbuf}
 *)
