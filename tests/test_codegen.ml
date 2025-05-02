open OUnit2

module Sym = C64MC.Symbol_table
module Utils = C64MC.Utils
module Ig = Codegen.InstructionGen
module Exc = Exceptions
module AST_TRSL = C64MC.Ast_translate
module AST_SRC = C64MC.Ast_src
module AST_TGT = C64MC.Ast_tgt
module PP_TGT = C64MC.Pprint_tgt
module PP_SRC = C64MC.Pprint_src


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
  assert_raises (Exc.TooManyInstructionArguments ("ADC", 2, 3)) 
      (fun () -> Ig.construct_instruction "ADC" instruction_list)


(* Asserts that the construct_instruction method throws an error if the argument count is too low *)
let test_construct_instruction4 _ctx =
  let instruction_list = [] in
  assert_raises (Exc.InsufficientInstructionArguments ("ADC", 1, 0)) 
      (fun () -> Ig.construct_instruction "ADC" instruction_list)
  
(* Asserts that the int_to_hex method returns the correct hexadecimal value *)
let test_int_to_hex _ctx =
  let n = 255 in
  let hex = Ig.int_to_hex n in
  assert_equal hex "FF"

(* Asserts that the int_to_hex method raises an error if a negative integer is input *)
let test_int_to_hex_negative _ctx =
  let n = -1 in
  assert_raises (Invalid_argument "Negative integers cannot be converted to hexadecimal") 
      (fun () -> Ig.int_to_hex n)


