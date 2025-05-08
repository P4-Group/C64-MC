open OUnit2

module IG = Codegen.InstructionGen
module EXC = Exceptions


(*---------------- CODEGEN TESTS ----------------*)


(* Asserts that the construct_instruction method returns the correct instruction as a string *)  
let test_construct_instruction1 _ctx =
  let instruction_list = ["$FD"; "$FC"] in
  assert_equal "dc.b $FD, $FC" (IG.construct_instruction "dc.b" instruction_list)


(* Asserts that the construct_instruction method throws an error if the incorrect assembly instruction is entered *)
let test_construct_instruction2 _ctx =
  let instruction_list = ["$FD"; "$FC"] in
  assert_raises (EXC.InstructionNotFoundException "Instruction 'db.c' not found") 
      (fun () -> IG.construct_instruction "db.c" instruction_list)


(* Asserts that the construct_instruction method throws an error if the argument count is too high *)
let test_construct_instruction3 _ctx =
  let instruction_list = ["$FD"; "$FC"; "$FC"] in
  assert_raises (EXC.TooManyInstructionArgumentsException "ADC requires at most 2 arguments, but got 3") 
      (fun () -> IG.construct_instruction "ADC" instruction_list)


(* Asserts that the construct_instruction method throws an error if the argument count is too low *)
let test_construct_instruction4 _ctx =
  let instruction_list = [] in
  assert_raises (EXC.InsufficientInstructionArgumentsException "ADC requires at least 1 arguments, but got 0") 
      (fun () -> IG.construct_instruction "ADC" instruction_list)

(* Asserts that the int_to_hex method returns the correct hexadecimal value for decimal value 255 *)
let test_int_to_hex _ctx =
  let n = 255 in
  assert_equal "FF" (IG.int_to_hex n)


(* Asserts that the int_to_hex method raises an error if a negative integer is input *)
let test_int_to_hex_negative _ctx =
  let n = -1 in
  assert_raises (EXC.InvalidArgumentException "Negative integers cannot be converted to hexadecimal") 
      (fun () -> IG.int_to_hex n)


