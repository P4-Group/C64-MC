(*---------------*)
(*Main Exceptions*)
(*---------------*)

exception LexicalError of string
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

(*-------------------------*)
(*Parser Exceptions*)
(*-------------------------*)

exception IllegalOctave of string
exception IllegalDuration of string
exception IllegalWaveform of string

(*-------------------------*)
(*Symbol Table Exceptions*)
(*-------------------------*)
exception DuplicateSequenceError of string
exception MissingSequenceError of string
exception MissingMemoryAddressError of string
exception InvalidArgument of string


(*-------------------------*)
(*Utils Exceptions*)
(*-------------------------*)
exception IllegalToneError of string

(*-------------------------*)
(*AST Translate Exceptions*)
(*-------------------------*)
exception IllegalTimeSignature of string
