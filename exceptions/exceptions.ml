(*---------------*)
(*Main Exceptions*)
(*---------------*)

exception LexicalError of string
exception ParsingError of string
exception InsufficientArgumentsError of string
exception FileNotFoundError of string
exception FilePermissionError of string
exception SyntaxError of string


(*-------------------------*)
(*InstructionGen Exceptions*)
(*-------------------------*)

exception InstructionNotFoundError of string
exception InsufficientInstructionArgumentsError of string * int * int
exception TooManyInstructionArgumentsError of string * int * int



exception InvalidArgumentError of string

(*-------------------------*)
(*Utils Exceptions*)
(*-------------------------*)

(*-------------------------*)
(*AST Translate Exceptions*)
(*-------------------------*)
exception InvalidTimeSignatureError of string 
