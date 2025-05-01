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