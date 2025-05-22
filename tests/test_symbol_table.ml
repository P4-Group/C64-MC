open OUnit2

module SYM = C64MC.Symbol_table
module EXC = Exceptions
module AST_TGT = C64MC.Ast_tgt


(*---------------- SYMBOL TABLE TESTS ----------------*)

(* Asserts that a sequence is added to the symbol table *)
let test_add_sequence1 id seq = 
  let symbol_table = SYM.get_symbol_table () in
  SYM.add_sequence id seq;
  assert_bool "Symbol table does not contain the expected ID" (Hashtbl.mem symbol_table id)


(* Asserts that an error is thrown if sequences identifiers are used twice *)
let test_add_sequence2 id seq =
  SYM.add_sequence id seq;
  assert_raises (EXC.SyntaxErrorException "Sequences id's cannot be duplicated. Each sequence must have a unique id.") 
      (fun () -> SYM.add_sequence id seq)
    

(* Asserts that exception is thrown if a sequence is not added to the symbol table before adding it to a voice*)
let test_check_sequence _ctx =
  assert_raises (EXC.SyntaxErrorException "Sequences must be defined before adding to a voice") 
      (fun () -> SYM.check_sequence "undefined_id")


(* Asserts that the get sequence method returns the same key/value pair *)
let test_get_sequence1 id seq =
  SYM.add_sequence id seq;
  let retrieved_seq = match SYM.get_sequence id with
    | RawSequence s -> s
    | FinalSequence _ -> assert_failure "Could not retrieve the raw sequence from the symbol table";
  in
  assert_equal seq retrieved_seq


(* Asserts that the get sequence raises an error if the sequence is not added to the symbol table *)
let test_get_sequence2 id _seq =
  assert_raises (EXC.SyntaxErrorException ("Sequence not found for id: new_seq")) (fun () -> SYM.get_sequence id)


(* Asserts that the get sequence method returns the expected key/value pair after updating it *)
let test_update_sequence1 id seq = 
  SYM.add_sequence id seq;
  let expected_seq = [
    { AST_TGT.highfreq = 16; AST_TGT.lowfreq = 195; AST_TGT.duration = 96 };
    { AST_TGT.highfreq = 0; AST_TGT.lowfreq = 0; AST_TGT.duration = 96 }; 
    { AST_TGT.highfreq = 37; AST_TGT.lowfreq = 162; AST_TGT.duration = 96 }
  ] in
  SYM.update_sequence id expected_seq;

  (* Verify the updated sequence *)
  match SYM.get_sequence id with
    | FinalSequence seq -> assert_equal expected_seq seq
    | _ -> assert_failure "Could not retrieve the updated sequence from the symbol table"
  