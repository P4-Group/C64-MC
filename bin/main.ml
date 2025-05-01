open C64MC
open Exceptions 
open Codegen

let () =
  try
    if Array.length Sys.argv < 2 then
      raise (InsufficientArguments "Usage: <program> <input_file>") (* Check if the input file is provided *)
    else
      let input_filename = Sys.argv.(1) in (* Get the input file name from command line arguments *)
      Printf.printf "Opening file: %s\n" input_filename; 
      if not (Sys.file_exists input_filename) then
        raise (FileNotFoundError ("File not found: " ^ input_filename)) (* Check if the file exists *)
      else
        let input_channel = 
          (* Attempt to open the file in binary mode *)
          (* If it fails, raise a FilePermissionError *)
          try open_in_bin input_filename 
          with Sys_error _ -> raise (FilePermissionError ("Permission denied or file cannot be opened: " ^ input_filename)) 
        in

        (* Attempt to parse the file *)
        (* If it fails, raise a ParsingError *)
        (* The parsing function should be defined in the Parser module *)
        (* The Lexer module should provide the tokenization function *)

        let lexbuf = Lexing.from_channel input_channel in 
        Printf.printf "File opened successfully. Parsing...\n"; (* Debugging line *)
        let ast_src = Parser.prog Lexer.read lexbuf in
        let ast_tgt = Ast_translate.file_translate ast_src in (* Translate the AST from source to target ast *)

        (* Print the original AST for debugging purposes *)
        (* Pretty-print the final AST *)
        Pprint_tgt.pprint_file ast_tgt; (* Prints the final AST *)

        InstructionGen.clean_build (); (* Clean the output file before writing *)
        InstructionGen.run_example (); (* Write the standard library to the output file *)
        InstructionGen.gen_voice ast_tgt; (* Generate the voice code *)
        InstructionGen.gen_sequence (); (* Generate the sequence code *)
        close_in input_channel (* Close the input channel *)
  with
  | InsufficientArguments msg ->
      Printf.eprintf "Error: %s\n" msg
  | FileNotFoundError msg ->
      Printf.eprintf "Error: %s\n" msg
  | FilePermissionError msg ->
      Printf.eprintf "Error: %s\n" msg
  | ParsingError msg ->
      Printf.eprintf "Parsing Error: %s\n" msg
  | e ->
      Printf.eprintf "Unexpected Error: %s\n" (Printexc.to_string e);
      raise e