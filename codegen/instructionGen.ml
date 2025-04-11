open InstructionSet
open Exceptions

(* Global filename for the output file *)
let filename = ref "output.asm"

(* Write a line to a file without overwriting existing lines *)
let write_line_tf (line : string) =
  let oc = open_out_gen [Open_creat; Open_text; Open_append] 0o666 !filename in
  Printf.fprintf oc "%s\n" line;
  close_out oc

(* Write the standard library to a file *)
(* This function appends snippets from the stdlib to the output file *)
let write_stdlib (stdlib_string : string) =
  let oc = open_out_gen [Open_creat; Open_text; Open_append] 0o666 !filename in
  Printf.fprintf oc "%s\n" stdlib_string;
  close_out oc

(* Construct an instruction from its mnemonic and arguments *)
let construct_instruction (mnemonic : string) (args : string list) =
  let instruction = List.find_opt (fun instr -> instr.mnemonic = mnemonic) instructions in
  
  match instruction with (* find the instruction in the instruction set *)
  | None -> raise (InstructionNotFoundError (Printf.sprintf "Instruction '%s' not found" mnemonic))
  | Some instr -> (*Check if instruction has correct arguments/amount of arguments*)
      let arg_count = List.length args in
      Printf.eprintf "Argument count: %d\n" arg_count;
      
      if arg_count < instr.min_args then
        raise (InsufficientInstructionArguments (mnemonic, instr.min_args, arg_count))
      
      else if arg_count > instr.max_args then
        raise (TooManyInstructionArguments (mnemonic, instr.max_args, arg_count))
      
      else
        let constructed_instruction = Printf.sprintf "%s %s" instr.mnemonic (String.concat ", " args) in
        constructed_instruction (* Return full instruction as string*)

(* Construct a labelled instruction block/indented instruction block *)
let write_labelled_instructions (label : string) (instruction_table : (string, string list) Hashtbl.t) =
  write_line_tf (label ^ ":");
  Hashtbl.iter (fun mnemonic args ->
    let constructed_instruction = construct_instruction mnemonic args in
    write_line_tf ("  " ^ constructed_instruction)
  ) instruction_table


  


(* Example usage as a runnable function *)
let run_example () =
  let args = ["10"; "20"] in
  let constructed_instruction = construct_instruction "ADC" args in
  write_line_tf constructed_instruction; 

  let label = "MyLabel" in
  let instruct_hashtbl = Hashtbl.create 10 in
  Hashtbl.add instruct_hashtbl "LDA" ["$00"; "#$FF"];
  Hashtbl.add instruct_hashtbl "STA" ["$01"];
  Hashtbl.add instruct_hashtbl "JMP" ["$02"];
  write_labelled_instructions label instruct_hashtbl;
  write_stdlib Stdlib.preamble;
