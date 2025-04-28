open InstructionSet
open Exceptions
open C64MC.Ast_final
open List

(* Global filename for the output file *)
let filename = ref "output.asm"

(* Clean the output file*)
let clean_build ()=
  let oc = open_out !filename in
  close_out oc


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
let write_instr_group (instructions : string list) =
  let indentation = String.make (4 * 4) ' ' in  (* 4 tabs, 4 spaces each = 16 spaces *)
  List.iter (fun instruction ->
    write_line_tf (indentation ^ instruction)
  ) instructions

let write_repeat_channel (channel_def : string) =
  let indentation = String.make (4 * 4) ' ' in  (* 4 tabs, 4 spaces each = 16 spaces *)
  write_line_tf (indentation ^ "db.c $FF");
  write_line_tf (indentation ^ "db.c " ^ channel_def)

let waveform_to_byte = function
  | Vpulse -> "$F9"
  | Triangle -> "$FA"
  | Sawtooth -> "$FB"
  | Noise -> "$FC"


let generate (file : C64MC.Ast_final.file) =
  
  (*Channel code generation structure:
    Write channel label to file;
    Iterate through channel (ident * waveform) list
    Write waveform, enter sequence instruction and sequence id to file
    Write repeat channel instruction
    repeat for the two other channels
  *)

  (*---------------Channel 1---------------*)
  write_line_tf ("channel1:");
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = ["dc.b " ^ wv_byte;"dc.b $FE"; "dc.b $" ^ id.id] in
    write_instr_group instruction_list
  ) file.ch1;
  write_repeat_channel "channel1";

  (*---------------Channel 2---------------*)
  write_line_tf ("channel2:");
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = ["dc.b " ^ wv_byte;"dc.b $FE"; "dc.b $" ^ id.id] in
    write_instr_group instruction_list
  ) file.ch2;
  write_repeat_channel "channel2";
  
  (*---------------Channel 3---------------*)
  write_line_tf ("channel3:");
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = ["dc.b " ^ wv_byte;"dc.b $FE"; "dc.b $" ^ id.id] in
    write_instr_group instruction_list
  ) file.ch3;
  write_repeat_channel "channel3"

  
  
  
  
  (*
  For each channel (always 3 channels... so far)
    
      match wv with
      | Vpulse -> instrutionlist.add "dc.b $F9"
      | Vpulse -> "FA"
      | Vpulse -> "FB"
      | Noise -> "FC"
      write_labelled_instructions (channel ^ i) instructions_list 
  *)


(* Example usage as a runnable function *)

let run_example () =
  write_stdlib Stdlib.init;
  write_stdlib Stdlib.playinit;
  write_stdlib Stdlib.note_initation;
  write_stdlib Stdlib.play_loop;
  write_stdlib Stdlib.fetches;
  write_stdlib Stdlib.channel_data; 
  write_stdlib Stdlib.instrument_data


 
(* **** Deprecated ****

let args = ["10"; "20"] in
let constructed_instruction = construct_instruction "ADC" args in
write_line_tf constructed_instruction; 

let label = "MyLabel" in
let instruct_hashtbl = Hashtbl.create 10 in
Hashtbl.add instruct_hashtbl "LDA" ["$00"; "#$FF"];
Hashtbl.add instruct_hashtbl "STA" ["$01"];
Hashtbl.add instruct_hashtbl "JMP" ["$02"];
write_labelled_instructions label instruct_hashtbl;
*)