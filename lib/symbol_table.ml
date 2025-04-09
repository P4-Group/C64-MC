
type memory_address = int

type symbol_info = (* a record data structure used for grouping related information *)
  | SequenceSymbol of { (* the key is the sequence id, the value is sequence and mem address *)
    (* id : string;  *)
    seq : Ast.seq; (* list of notes *)
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


(*---Helper Functions---*)


(* Adds a sequence to the symbol table. If a sequence with the specified id already exists
an error will be thrown. *)
let add_sequence id seq = 
  if Hashtbl.mem symbol_table id then 
    failwith "Sequences id's cannot be duplicated. Each sequence must have a unique id.";

  let symbol = SequenceSymbol {seq = seq; mem_address = None} in 
  Hashtbl.add symbol_table id symbol

(* Checks if the sequence id exists. If not, an error will be thrown. *)
let check_sequence id =
  if not (Hashtbl.mem symbol_table id) then
    failwith "Sequences must be defined before adding to a channel";




