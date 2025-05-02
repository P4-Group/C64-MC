open OUnit2
module Sym = C64MC.Symbol_table
module Ig = Codegen.InstructionGen
module Exc = Exceptions
module AST_TRSL = C64MC.Ast_translate


(*---------------- SYMBOL TABLE TESTS ----------------*)

(*Setup and teardown for symbol table tests*)
let setup_and_teardown_symbol_table test_fn _ctx =

  (* Clear the symbol table before the test *)
  let symbol_table = Sym.get_symbol_table () in
  Hashtbl.clear symbol_table;
  
  let id = "new_seq" in (*Mock new seq id*)
  let seq : C64MC.Ast_src.seq = [ (*Create mock sequence*)
  Sound (C, Nat, Quarter, Defined 4);
  Rest Half;
  Sound (E, Sharp, Eighth, Defined 5)
  ] in
  (* Run the passed test *)
  test_fn id seq;
  
  (* Clear the symbol table after the test *)
  Hashtbl.clear symbol_table



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


(*---------------- CODEGEN TESTS ----------------*)


(* Asserts that the construct_instruction method returns the correct instruction as a string *)  
let test_construct_instruction1 _ctx =
  let instruction_list = ["$FD"; "$FC"] in
  let instruction = Ig.construct_instruction "dc.b" instruction_list in
  assert_equal "dc.b $FD, $FC" instruction


(* Asserts that the construct_instruction method throws an error if the incorrect assembly instruction is entered *)
let test_construct_instruction2 _ctx =
  let instruction_list = ["$FD"; "$FC"] in
  assert_raises (Exc.InstructionNotFoundError "Instruction 'db.c' not found") 
      (fun () -> Ig.construct_instruction "db.c" instruction_list)


(* Asserts that the construct_instruction method throws an error if the argument count is too high *)
let test_construct_instruction3 _ctx =
  let instruction_list = ["$FD"; "$FC"; "$FC"] in
  assert_raises (Exc.TooManyInstructionArgumentsError ("ADC", 2, 3)) 
      (fun () -> Ig.construct_instruction "ADC" instruction_list)


(* Asserts that the construct_instruction method throws an error if the argument count is too low *)
let test_construct_instruction4 _ctx =
  let instruction_list = [] in
  assert_raises (Exc.InsufficientInstructionArgumentsError ("ADC", 1, 0)) 
      (fun () -> Ig.construct_instruction "ADC" instruction_list)
  

(*---------------- AST TRANSLATE TEST ----------------*)




(*Setup of the test suite. The suite consist of sub suites*)
let suite =
  "All Tests" >:::[
    "Symbol Table Tests" >::: [
      "test_add_sequence1" >:: setup_and_teardown_symbol_table test_add_sequence1;
      "test_add_sequence2" >:: setup_and_teardown_symbol_table test_add_sequence2;
      "test_check_sequence" >:: test_check_sequence;
      "test_get_sequenc1" >:: setup_and_teardown_symbol_table test_get_sequence1;
      "test_get_sequenc2" >:: setup_and_teardown_symbol_table test_get_sequence2;
      ];
      "Codegen" >::: [
        "test_construct_instruction1" >:: test_construct_instruction1;
        "test_construct_instruction2" >:: test_construct_instruction2;
        "test_construct_instruction3" >:: test_construct_instruction3;
        "test_construct_instruction4" >:: test_construct_instruction4;
        ];
  ]


(*Runs the actual tests*)  
let () =
  run_test_tt_main suite
