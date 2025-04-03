open Ast_final

exception Error of Ast.loc option * string

let error ?loc s = raise (Error (loc, s))

(*Insert specific errors here*)

