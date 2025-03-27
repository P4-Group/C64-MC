open PrTest

let () =
  if Array.length Sys.argv < 2 then
    Printf.eprintf "Usage: %s <input_file>\n" Sys.argv.(0)
  else
    let input_filename = Sys.argv.(1) in
    let input_channel = open_in input_filename in
    try
      let lexbuf = Lexing.from_channel input_channel in
      let ast = PrTest.Parser.file PrTest.Lexer.token lexbuf in (* Removed incorrect type annotation *)
      let output = Codegen.compile ast in
      Printf.printf "Output:\n%s\n" output;
      close_in input_channel
    with
    | e -> close_in input_channel; raise e