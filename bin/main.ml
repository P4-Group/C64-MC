open C64MC
open Codegen

let () =
  Printf.printf "Program started.\n"; (* Debugging line *)
  if Array.length Sys.argv < 2 then
    Printf.eprintf "Usage: %s <input_file>\n" Sys.argv.(0)
  else
    let input_filename = Sys.argv.(1) in
    Printf.printf "Opening file: %s\n" input_filename; (* Debugging line *)
    let input_channel = open_in input_filename in
    try
      let lexbuf = Lexing.from_channel input_channel in
      Printf.printf "File opened successfully. Parsing...\n"; (* Debugging line *)
      let _ast = Parser.prog Lexer.read lexbuf in
      (* Pretty-print the parsed AST *)
      Pprint.pprint_file _ast;
      (* let output = Codegen.compile ast in *)
      (* Printf.printf "Output:\n%s\n" output; *)

      InstructionSet.test_func 9;
  
      close_in input_channel;
    with
    | e ->
        close_in input_channel;
        Printf.eprintf "Error: %s\n" (Printexc.to_string e);
        raise e