open InstructionSet
open Exceptions
open List
open C64MC.Ast_final

module Fin_Ast = C64MC.Ast_final
module Sym = C64MC.Symbol_table

(* This module generates assembly code for the C64 music compiler.
   It constructs instructions and writes them to a file. *)

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

(*Writes the assembly code to repeat a voice at the end*)
let write_repeat_voice (voice_def : string) =
  let indentation = String.make (4 * 4) ' ' in  (* 4 tabs, 4 spaces each = 16 spaces *)
  write_line_tf (indentation ^ "dc.b $FD");
  write_line_tf (indentation ^ "dc.w " ^ voice_def)

(*Converts the waveform into the hex byte for assembly*)
let waveform_to_byte = function
  | Noise -> "$F9"
  | Vpulse -> "$FA"
  | Sawtooth -> "$FB"
  | Triangle -> "$FC"

  
  (* Function to write code in the output.asm file
    General structure:
    Write voice label to file;
    Iterate through voice (ident * waveform) list;
    Write waveform, enter-sequence instruction and sequence id to file;
    Write repeat voice instruction;
    repeat for the two other voices
  *)
let gen_voice (file : Fin_Ast.file) =
  (*---------------Voice 1---------------*)
  write_line_tf ("voice1:"); (*write the label*)
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = [ (*Create a list containing instructions for the write_instr_group function*)
      construct_instruction "dc.b" [wv_byte];
      construct_instruction "dc.b" ["$FE"];
      construct_instruction "dc.w" [id.id]
    ] in
    write_instr_group instruction_list (*Write the instructions in the output.asm file*)
  ) file.vc1;
  write_repeat_voice "voice1"; (*write the signal for repeating the sequence*)

  (*---------------Voice 2---------------*)
  write_line_tf ("voice2:");
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = [
      construct_instruction "dc.b" [wv_byte];
      construct_instruction "dc.b" ["$FE"];
      construct_instruction "dc.w" [id.id]
    ] in
    write_instr_group instruction_list
  ) file.vc2;
  write_repeat_voice "voice2";
  
  (*---------------Voice 3---------------*)
  write_line_tf ("voice3:");
  List.iter (fun (id, waveform) ->
    let wv_byte = waveform_to_byte waveform in
    let instruction_list = [
      construct_instruction "dc.b" [wv_byte];
      construct_instruction "dc.b" ["$FE"];
      construct_instruction "dc.w" [id.id]
    ] in
    write_instr_group instruction_list
  ) file.vc3;
  write_repeat_voice "voice3"

  (* Converts an integer to a hexadecimal string *)
  let int_to_hex (n : int) : string =
    if n < 0 then
      raise (Invalid_argument "Negative integers cannot be converted to hexadecimal")
    else
      Printf.sprintf "%02X" n


(*Function to generate code for the sequences in assembly
  Gets the symbol_table and iterates through each sequence.
  For each sequence it writes the identifier
  Then go through the list of notes and write "dc.b $lofreq, $hifreq, $duration"
  Ends by writing dc.b $FF to signal the end of the sequence.  
*)
let gen_sequence () =
  let symbol_table = Sym.get_symbol_table () in
  Hashtbl.iter (fun id value -> 
      match value with
      | Sym.SequenceSymbol {seq;_} -> (*The note lists are here somewhere*)
        match seq with
        | Sym.FinalSequence seq -> (* The definition of the note lists from the final AST *)
          write_line_tf (id ^ ":"); (*Write the label*)
          
          let buffer = ref [] in (* Create a mutable and appendable list *)
          List.iter (fun note ->  
            buffer := !buffer @ [
              construct_instruction "dc.b" [
              "$" ^ int_to_hex note.lowfreq; 
              "$" ^ int_to_hex note.highfreq; 
              "$" ^ int_to_hex note.duration;
              ] (*Appends instruction to buffer*)
            ];
          ) seq;
          buffer := !buffer @ [construct_instruction "dc.b" ["$FF"]]; (*Suffixes buffer with required dc.b $FF*)
          write_instr_group !buffer; (*Write the instructions in the output.asm file*)
        | Sym.RawSequence _ -> (); (*Do nothing, this is for the original AST*)             

      (* Print the last $FF instruction after processing each symbol *)
  ) symbol_table
  
  

let run_example () =
  write_stdlib Stdlib.init;
  write_stdlib Stdlib.playinit;
  write_stdlib Stdlib.note_initation;
  write_stdlib Stdlib.play_loop;
  write_stdlib Stdlib.fetches;
  write_stdlib Stdlib.voice_data; 
  write_stdlib Stdlib.instrument_data

