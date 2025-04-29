
(*open Pprint*)
open Exceptions

(* Variant types, so the seq can hold both the sequence of the first and second AST concurrently *)
type sequence_type = 
  | RawSequence of Ast.seq
  | FinalSequence of Ast_final.note list
  
type memory_address = int

type symbol_info = (* a record data structure used for grouping related information *)
  | SequenceSymbol of { (* the key is the sequence id, the value is sequence and mem address *)
    seq : sequence_type; (* list of notes *)
    mutable mem_address : memory_address option; (* the memory address where the sequence is stored *)
    (* the memory address is type mutable, meaning the value can change. we do this because we
     dont need the memory address at the first iteration as we are not converting to assembly
     until the second iteration. So at first, we just need to check that there are duplications 
     of sequence identifiers and the memory address is there optional as it will be updated later. *)
  }
  | LabelSymbol of { (* the key is the label name, the value is the memory address. *)
    memory_address : memory_address; 
  }


(* Creating symbol table *)
let symbol_table : (string, symbol_info) Hashtbl.t = Hashtbl.create 10


(*------------------------------Helper Functions------------------------------*)


(*---Parser Helper Functions---*)


(* Adds a sequence to the symbol table. If a sequence with the specified id already exists
an error will be thrown. *)
let add_sequence id seq = 
  if Hashtbl.mem symbol_table id then 
    raise (DuplicateSequenceError "Sequences id's cannot be duplicated. Each sequence must have a unique id.");

  let symbol = SequenceSymbol {seq = RawSequence seq; mem_address = None} in 
  Hashtbl.add symbol_table id symbol;
  Printf.printf "Added sequence: %s \n" id

  (* we use pprint to print the sequence of the first AST *)
  (* match symbol with
  | SequenceSymbol {seq = RawSequence raw_seq; _} ->
      let generic = ast_to_generic_seq raw_seq in
      pprint_generic_ast generic
  | SequenceSymbol _ -> () 
  | LabelSymbol _ -> () *)

(* Checks if the sequence id exists. If not, an error will be thrown. *)
let check_sequence id =
  if not (Hashtbl.mem symbol_table id) then
    raise (MissingSequenceError "Sequences must be defined before adding to a voice")


(*---Translator Helper Functions---*)


(* Updates the sequence in the translator *)
let update_sequence id seq mem_address = 
  if not (Hashtbl.mem symbol_table id) then
    raise (MissingSequenceError "This sequence could not be updated as it does not exist");

  let symbol = SequenceSymbol {seq = FinalSequence seq; mem_address = mem_address} in 
  Hashtbl.replace symbol_table id symbol;
  Printf.printf "Updated sequence: %s \n" id;


  match symbol with
  | SequenceSymbol {seq = FinalSequence final_seq; _} ->
      Pprint_final.pprint_notes final_seq
  | _ -> raise (MissingSequenceError "Updated sequence not found")


(*---Pprint Helper Functions---*)


(* Retrieves a sequence (value) from the symbol table by the id (key)*)
let get_sequence id =
  match Hashtbl.find_opt symbol_table id with 
  | Some (SequenceSymbol {seq;_}) -> seq (* ;_ ignores memory address*)
  | Some (LabelSymbol _) -> raise (InvalidArgument "They key must be a sequence id")
  | None -> raise (MissingSequenceError ("Sequence not found for id: " ^ id))


(* Retrieves the memory address of a sequence *)
let get_seq_memory_address id =
  match Hashtbl.find_opt symbol_table id with 
    | Some (SequenceSymbol {mem_address;_}) -> mem_address
    | Some (LabelSymbol _) -> raise (InvalidArgument "They key must be a sequence id")
    | None -> raise (MissingSequenceError ("Sequence not found for id: " ^ id))


(*---Assembly Helper Functions---*)


(* Retrieves the memory address of a label *)
let get_label_memory_address label =
  match Hashtbl.find_opt symbol_table label with 
    | Some (SequenceSymbol _) -> raise (InvalidArgument "Expected a label, not a sequence id")
    | Some (LabelSymbol {memory_address}) -> memory_address
    | None -> raise (MissingMemoryAddressError ("Memory address not found for label: " ^ label))

(*Retrieves the whole symbol table containing sequence ID's and symbol info*)
let get_symbol_table () = symbol_table;