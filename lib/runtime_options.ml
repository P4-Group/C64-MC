open Exceptions

type t = {
  mutable tgt_ast : bool;
  mutable src_ast : bool;
  mutable debug : bool;
  mutable dasm : bool;
  mutable sym_tab : bool;
}

let runtime_options = {
  tgt_ast = false;
  src_ast = false;
  debug = false;
  dasm = false;
  sym_tab = false;
}

let get_tgt_ast () = runtime_options.tgt_ast
let get_src_ast () = runtime_options.src_ast
let get_debug () = runtime_options.debug
let get_dasm () = runtime_options.dasm
let get_sym_tab () = runtime_options.sym_tab

let set_tgt_ast value = runtime_options.tgt_ast <- value
let set_src_ast value = runtime_options.src_ast <- value
let set_debug value = runtime_options.debug <- value
let set_dasm value = runtime_options.dasm <- value
let set_sym_tab value = runtime_options.sym_tab <- value


let conditional_option debug_options run =
  if List.exists (fun f -> f ()) debug_options then
    run ()
  else
    ()


(* This checks the parameters of the input file and handling errors. *)
let check_file_params () =
  let params = Array.to_list (Array.sub Sys.argv 1 (Array.length Sys.argv - 1)) in
  let src_file_ref = ref None in

  let rec parse_args args =
    match args with
    | [] -> () (* Base case: no more arguments *)

    (* Boolean flags *)
    | "-tgt-ast" :: rest ->
        set_tgt_ast true;
        parse_args rest
    | "-src-ast" :: rest ->
        set_src_ast true;
        parse_args rest
    | "-debug" :: rest ->
        set_debug true;
        parse_args rest
    | "-sym-tab" :: rest ->
        set_sym_tab true;
        parse_args rest
    | "-dasm" :: rest -> 
        set_dasm true;
        parse_args rest

    (* Arguments with values *)
    | "-s" :: file :: rest ->
        if !src_file_ref <> None then
          raise (InsufficientArguments "Option '-s' (source file) specified multiple times.");
        src_file_ref := Some file;
        parse_args rest
    | "-s" :: [] ->
        raise (InsufficientArguments "Option '-s' requires a file path argument.")

    (* Unknown argument *)
    | unknown :: _ ->
        raise (InsufficientArguments ("Invalid argument or unknown option: " ^ unknown ^
          "\nUsage: <program> -s <source_file> [-dasm] [-tgt-ast] [-src-ast] [-sym-tab] [-debug]"))
  in
  parse_args params;

  (* Check if the mandatory source file argument was provided *)
  match !src_file_ref with
  | Some file -> file (* Return the source file path *)
  | None -> raise (InsufficientArguments "Missing mandatory source file argument '-s <file>'.")