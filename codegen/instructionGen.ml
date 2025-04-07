open InstructionSet

(* Write a line to a file *)
let write_line_tf (line : string) =
  let filename = "IR.asm" in
  let oc = open_out filename in
  Printf.fprintf oc "%s\n" line;
  close_out oc

(* Construct an instruction from its definition and arguments *)
let construct_instruction (instruction : instruction option) (args : string list) =
  match instruction with
  | None -> failwith "Error: Instruction not found"
  | Some instr ->
      let arg_count = List.length args in
      if arg_count < instr.min_args then
        failwith (Printf.sprintf "Error: Not enough arguments provided. Expected at least %d, but got %d" instr.min_args arg_count)
      else if arg_count > instr.max_args then
        failwith (Printf.sprintf "Error: Too many arguments provided. Expected at most %d, but got %d" instr.max_args arg_count)
      else
        let constructed_instruction = Printf.sprintf "%s %s" instr.mnemonic (String.concat ", " args) in
        constructed_instruction

(* Example usage *)
let () =
  let args = ["10"; "20"] in
  let instruction = List.find_opt (fun instr -> instr.mnemonic = "ADC") instructions in
  let constructed_instruction = construct_instruction instruction args in
  write_line_tf constructed_instruction