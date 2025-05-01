open C64MC
open Exceptions 
open Codegen

let () =
  try
    (* Check if the input file is provided *)
    if Array.length Sys.argv < 2 then
      raise (InsufficientArguments "Usage: <program> <input_file>")
    else
      (* Get the input file name from command line arguments *)
      let input_filename = Sys.argv.(1) in
      Printf.printf "Opening file: %s\n" input_filename; (* Debugging line *)

      (* Check if the file exists *)
      if not (Sys.file_exists input_filename) then
        raise (FileNotFoundError ("File not found: " ^ input_filename))
      else
        (* Attempt to open the file in binary mode *)
        (* If it fails, raise a FilePermissionError *)
        let input_channel = 
          try open_in_bin input_filename 
          with Sys_error _ -> raise (FilePermissionError ("Permission denied or file cannot be opened: " ^ input_filename)) 
        in

        Printf.eprintf "lexing";

        (* Create a lexing buffer from the input channel *)
        let lexbuf = Lexing.from_channel input_channel in
        Printf.printf "File opened successfully. Parsing...\n"; (* Debugging line *)

        (* Attempt to parse the file *)
        (* If it fails, raise a ParsingError *)
        let ast_src = Parser.prog Lexer.read lexbuf in

        (* Translate the source AST to the target AST *)
        let ast_tgt = Ast_translate.file_translate ast_src in

        (* Pretty-print the final AST *)
        Pprint_tgt.pprint_file ast_tgt;

        (* Clean the output file before writing *)
        InstructionGen.clean_build ();

        (* Write the standard library to the output file *)
        InstructionGen.run_example ();

        (* Generate the voice code *)
        InstructionGen.gen_voice ast_tgt;

        (* Generate the sequence code *)
        InstructionGen.gen_sequence ();

        (* Close the input channel *)
        close_in input_channel
  with
  | InsufficientArguments msg ->
      Printf.eprintf "Error: %s\n" msg
  | FileNotFoundError msg ->
      Printf.eprintf "Error: %s\n" msg
  | FilePermissionError msg ->
      Printf.eprintf "Error: %s\n" msg
  | ParsingError msg ->
      Printf.eprintf "Parsing Error: %s\n" msg
  | LexicalError msg ->
      Printf.eprintf "Lexing Error: %s\n" msg
  | e ->
      Printf.eprintf "Unexpected Error: %s\n" (Printexc.to_string e);
      raise e