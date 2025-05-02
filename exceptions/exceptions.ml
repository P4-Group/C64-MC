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

(*-------------------------*)
(*Parser Exceptions*)
(*-------------------------*)

exception InvalidOctaveError of string
exception InvalidDurationError of string
exception InvalidWaveformError of string

(*-------------------------*)
(*Symbol Table Exceptions*)
(*-------------------------*)
exception DuplicateSequenceError of string
exception MissingSequenceError of string
exception MissingMemoryAddressError of string
exception InvalidArgumentError of string


(*-------------------------*)
(*Utils Exceptions*)
(*-------------------------*)
exception InvalidToneError of string

(*-------------------------*)
(*AST Translate Exceptions*)
(*-------------------------*)
exception InvalidTimeSignatureError of string
