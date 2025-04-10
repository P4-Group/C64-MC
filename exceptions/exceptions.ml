(*---------------*)
(*Main Exceptions*)
(*---------------*)

exception ParsingError of string
exception InsufficientArguments of string
exception FileNotFoundError of string
exception FilePermissionError of string


(*-------------------------*)
(*InstructionGen Exceptions*)
(*-------------------------*)

exception InstructionNotFoundError of string
exception InsufficientInstructionArguments of string * int * int
exception TooManyInstructionArguments of string * int * int
