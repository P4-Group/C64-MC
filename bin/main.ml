open C64MC
open Exceptions 
open Codegen

module Runtime_options = C64MC.Runtime_options


(* Assumes dasm is in the PATH and can be called directly *)
(* output.asm is always in path as well, thus making the sys command just be "./dasm output.asm"*)
(* This function assembles the output file using DASM. *)
let assemble_file () =
  let dasm_command =
    if Sys.os_type = "Win32" || Sys.os_type = "Cygwin" then
      "dasm.exe" (* Use dasm.exe on Windows, assuming it's in PATH *)
    else
      "./dasm" (* Use ./dasm on Unix-like systems *)
  in

  let output_asm_file = "output.asm" in (* The output assembly file name *)

  let output_binary_file = Filename.remove_extension output_asm_file ^ ".prg" in

  let command = Printf.sprintf "%s %s %s" dasm_command output_asm_file output_binary_file in
  Printf.printf "Assembling file with command: %s\n" command;
  let result = Sys.command command in
  if result <> 0 then
    let error_msg = Printf.sprintf "Assembly failed (exit code: %d) using command: '%s'. Check if DASM is installed and in your PATH, if the assembly file '%s' is valid, and if you have permissions to execute dasm and write to the output directory." result command output_asm_file in
    raise (FilePermissionError error_msg)
  else
    Printf.printf "File assembled successfully to %s.\n" output_binary_file




(* Main function *)
let () =
  try
    (* Check the input file parameters and get the input file name *)
    let input_filename = Runtime_options.check_file_params () in

    Runtime_options.conditional_option [
      Runtime_options.get_tgt_ast;
      Runtime_options.get_sym_tab;
      Runtime_options.get_debug;
      Runtime_options.get_src_ast
    ] (fun () ->
      Printf.printf "Debug mode or AST/Symbol Table printing enabled.\n";
      Printf.printf "Debug option: %s\n" (if Runtime_options.get_debug () then "true" else "false");
      Printf.printf "DASM option: %s\n" (if Runtime_options.get_dasm () then "true" else "false");
      Printf.printf "Source AST option: %s\n" (if Runtime_options.get_src_ast () then "true" else "false");
      Printf.printf "Target AST option: %s\n" (if Runtime_options.get_tgt_ast () then "true" else "false");
      Printf.printf "Symbol Table option: %s\n" (if Runtime_options.get_sym_tab () then "true" else "false");
    );
    
    Runtime_options.conditional_option [Runtime_options.get_debug] (fun () ->
      Printf.printf "Opening file: %s\n" input_filename;);

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

      Runtime_options.conditional_option [Runtime_options.get_debug] (fun () ->
        Printf.printf "File opened successfully.\n";
        Printf.printf "Starting to lex...\n"; (* Debugging line *)
      );

      (* Create a lexing buffer from the input channel *)
      let lexbuf = Lexing.from_channel input_channel in

      Runtime_options.conditional_option [Runtime_options.get_debug] (fun () ->
        Printf.printf "Lexing buffer created successfully.\n";
        Printf.printf "Starting to parse...\n"; (* Debugging line *)
      );
      (* Attempt to parse the file *)
      (* If it fails, raise a ParsingError *)
      let ast_src = 
        try
          Parser.prog Lexer.read lexbuf
        with
        | Parser.Error ->
          let start_pos = Lexing.lexeme_start_p lexbuf in
          let end_pos = Lexing.lexeme_end_p lexbuf in
          let start_ch = start_pos.pos_cnum - start_pos.pos_bol +1 in
          let end_ch = end_pos.pos_cnum - end_pos.pos_bol in
          raise (ParsingError (Printf.sprintf "Syntax error at line %d, character %d-%d"
            start_pos.pos_lnum start_ch end_ch))
        in

      (* Translate the source AST to the target AST *)
      let ast_tgt = Ast_translate.file_translate ast_src in


      (* Print the source AST if debug or src_ast option is set *)
      Runtime_options.conditional_option
        [Runtime_options.get_debug; Runtime_options.get_src_ast]
        (fun () ->
          Printf.printf "Source AST:\n";
          Pprint_src.pprint_file ast_src);

      (* Print the target AST if debug or tgt_ast option is set *)
      Runtime_options.conditional_option
        [Runtime_options.get_debug; Runtime_options.get_tgt_ast]
        (fun () ->
          Printf.printf "Target AST:\n";
          Pprint_tgt.pprint_file ast_tgt);


      (* Clean the output file before writing *)
      InstructionGen.clean_build ();

      (* Write the standard library to the output file *)
      InstructionGen.run_example ();

      (* Generate the voice code *)
      InstructionGen.gen_voice ast_tgt;

      (* Generate the sequence code *)
      InstructionGen.gen_sequence ();

      Runtime_options.conditional_option [Runtime_options.get_dasm] (fun () ->
        Printf.printf "DASM option is set. Assembling file...\n";
        assemble_file ();
      );

      (* Close the input channel *)
      close_in input_channel
  with
  | InsufficientArgumentsError msg ->
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
