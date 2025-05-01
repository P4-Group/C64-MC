open C64MC
open Exceptions 
open Codegen

module Runtime_options = C64MC.Runtime_options

(* This module is responsible for checking the parameters of the input file and handling errors. *)
let check_file_params () =
  let params = Array.to_list (Array.sub Sys.argv 1 (Array.length Sys.argv - 1)) in
  let rec parse_options options files = function
    | [] -> (options, files)
    | "-tgt-ast" :: rest -> parse_options ("-tgt-ast" :: options) files rest
    | "-src-ast" :: rest -> parse_options ("-src-ast" :: options) files rest
    | "-debug" :: rest -> parse_options ("-debug" :: options) files rest
    | "-dasm" :: rest -> parse_options ("-dasm" :: options) files rest
    | "-sym-tab" :: rest -> parse_options ("-sym-tab" :: options) files rest
    | "-s" :: file :: rest when Sys.file_exists file ->
        parse_options options (file :: files) rest
    | "-s" :: _ -> raise (FileNotFoundError "The specified source file does not exist.")
    | _ -> raise (InsufficientArguments "Invalid arguments. Usage: <program> -s <source_file> [options]")
  in
  let options, files = parse_options [] [] params in
  List.iter
    (function
      | "-tgt-ast" -> Runtime_options.set_tgt_ast true
      | "-src-ast" -> Runtime_options.set_src_ast true
      | "-debug" -> Runtime_options.set_debug true 
      | "-dasm" -> Runtime_options.set_dasm true 
      | "-sym-tab" -> Runtime_options.set_sym_tab true 
      | _ -> ())
    options;
  match files with
  | [file] ->
      List.iter (fun opt -> Printf.printf "Option enabled: %s\n" opt) options;
      Printf.printf "Source file specified with '-s': %s\n" file;
      file
  | _ -> raise (InsufficientArguments "Usage: <program> -s <source_file> [options]")



let () =
  try
    (* Check the input file parameters and get the input file name *)
    let input_filename = check_file_params () in

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
      let ast_src = Parser.prog Lexer.read lexbuf in

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
