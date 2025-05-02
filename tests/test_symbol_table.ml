open OUnit2

module Sym = C64MC.Symbol_table
module Ig = Codegen.InstructionGen
module Exc = Exceptions
module AST_TRSL = C64MC.Ast_translate
module AST_SRC = C64MC.Ast_src
module AST_TGT = C64MC.Ast_tgt
module PP_TGT = C64MC.Pprint_tgt
module PP_SRC = C64MC.Pprint_src


(*---------------- SYMBOL TABLE TESTS ----------------*)
(* Asserts that a sequence is added to the symbol table *)
let test_add_sequence1 id seq = 
  let symbol_table = Sym.get_symbol_table () in
  Sym.add_sequence id seq;
  assert_bool "Symbol table does not contain the expected ID" (Hashtbl.mem symbol_table id)



(* Asserts that an error is thrown if sequences identiers are used twice *)
let test_add_sequence2 id seq =
  Sym.add_sequence id seq;
  assert_raises (Exc.DuplicateSequenceError "Sequences id's cannot be duplicated. Each sequence must have a unique id.") 
      (fun () -> Sym.add_sequence id seq)
  
  

(* Asserts that exception is thrown
if a sequence is not added to the symbol table before adding it to a voice*)
(*_ctx is a OUnit2 parameter that passes some testing context *)
let test_check_sequence _ctx =
  assert_raises (Exc.MissingSequenceError "Sequences must be defined before adding to a voice") 
      (fun () -> Sym.check_sequence "undefined_id")


(* Asserts that the get sequence method returns the same key/value pair *)
let test_get_sequence1 id seq =
  Sym.add_sequence id seq;
  let seq1 = match Sym.get_sequence id with
    | RawSequence s -> s
    | FinalSequence _ -> assert false;
  in
  assert_equal seq seq1


(* Asserts that the get sequence method returns the same key/value pair *)
let test_get_sequence2 id _seq =
  assert_raises (Exc.MissingSequenceError ("Sequence not found for id: new_seq")) (fun () -> Sym.get_sequence id)

let test_update_sequence1 id seq = 
  Sym.add_sequence id seq;

  (* Update the sequence *)
  let expected_seq = [{ AST_TGT.highfreq = 16; AST_TGT.lowfreq = 195; AST_TGT.duration = 96 };
                     { AST_TGT.highfreq = 0; AST_TGT.lowfreq = 0; AST_TGT.duration = 96 }; 
                     { AST_TGT.highfreq = 37; AST_TGT.lowfreq = 162; AST_TGT.duration = 96 }] in
  Sym.update_sequence id expected_seq;

  (* Verify the updated sequence *)
  match Sym.get_sequence id with
  | FinalSequence seq -> assert_equal expected_seq seq
  | _ -> assert_failure "Expected FinalSequence, but got something else"
  