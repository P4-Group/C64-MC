open C64MC
open Exceptions 
open Codegen

let () =
  try
    if Array.length Sys.argv < 2 then
      raise (InsufficientArguments "Usage: <program> <input_file>")
    else
      let input_filename = Sys.argv.(1) in
      Printf.printf "Opening file: %s\n" input_filename; (* Debugging line *)
      if not (Sys.file_exists input_filename) then
        raise (FileNotFoundError ("File not found: " ^ input_filename))
      else
        let input_channel = 
          try open_in_bin input_filename 
          with Sys_error _ -> raise (FilePermissionError ("Permission denied or file cannot be opened: " ^ input_filename)) 
        in
        let lexbuf = Lexing.from_channel input_channel in
        Printf.printf "File opened successfully. Parsing...\n"; (* Debugging line *)
        let _ast = Parser.prog Lexer.read lexbuf in
        (* Pretty-print the parsed AST *)
        (*Pprint.pprint_file _ast;*)

        let fin_ast = Ast_translate.file_translate _ast in
        (* Pretty-print the final AST *)
        Pprint_final.pprint_file fin_ast;


      InstructionGen.clean_build ();
      InstructionGen.run_example ();
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
  | e ->
      Printf.eprintf "Unexpected Error: %s\n" (Printexc.to_string e);
      raise e