exception FileNotFoundException of string
exception FilePermissionException of string

exception LexicalErrorException of string
exception ParsingErrorException of string

exception InvalidArgumentException of string
exception SyntaxErrorException of string

(*-------------------------*)
(*InstructionGen Exceptions*)
(*-------------------------*)

exception InstructionNotFoundException of string
exception InsufficientInstructionArgumentsException of string * int * int
exception TooManyInstructionArgumentsException of string * int * int


