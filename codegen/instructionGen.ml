open InstructionSet
(*open Exceptions*) (*Uncomment when connected to rest of the program*)


(*Just for testing purposes*)
exception InstructionNotFoundError of string
exception InsufficientInstructionArguments of string * int * int
exception TooManyInstructionArguments of string * int * int


(* Write a line to a file without overwriting existing lines *)
let write_line_tf (line : string) =
  let filename = "IR.asm" in
  let oc = open_out_gen [Open_creat; Open_text; Open_append] 0o666 filename in
  Printf.fprintf oc "%s\n" line;
  close_out oc

(* Construct an instruction from its mnemonic and arguments *)
let construct_instruction (mnemonic : string) (args : string list) =
  let instruction = List.find_opt (fun instr -> instr.mnemonic = mnemonic) instructions in
  match instruction with
  | None -> raise (InstructionNotFoundError (Printf.sprintf "Instruction '%s' not found" mnemonic))
  | Some instr ->
      let arg_count = List.length args in
      Printf.eprintf "Argument count: %d\n" arg_count;
      if arg_count < instr.min_args then
        raise (InsufficientInstructionArguments (mnemonic, instr.min_args, arg_count))
      else if arg_count > instr.max_args then
        raise (TooManyInstructionArguments (mnemonic, instr.max_args, arg_count))
      else
        let constructed_instruction = Printf.sprintf "%s %s" instr.mnemonic (String.concat ", " args) in
        constructed_instruction

let construct_labelled_instructions (label : string) (instruction_table : (string, string list) Hashtbl.t) =
  write_line_tf (label ^ ":");
  Hashtbl.iter (fun mnemonic args ->
    let constructed_instruction = construct_instruction mnemonic args in
    write_line_tf ("  " ^ constructed_instruction)
  ) instruction_table



(* Example usage *)
let () =
  let args = ["10"; "20"] in
  let constructed_instruction = construct_instruction "ADC" args in
  write_line_tf constructed_instruction; 

  let label = "MyLabel" in
  let instruct_hashtbl = Hashtbl.create 10 in
  Hashtbl.add instruct_hashtbl "LDA" ["$00"; "#$FF"];
  Hashtbl.add instruct_hashtbl "STA" ["$01"];
  Hashtbl.add instruct_hashtbl "JMP" ["$02"; "$02"; "$02"; "$02"];
  construct_labelled_instructions label instruct_hashtbl;
    