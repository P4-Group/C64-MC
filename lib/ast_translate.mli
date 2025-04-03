exception Error of Ast.loc option * string

val program: debug:bool -> Ast.file -> Ast_final.file 