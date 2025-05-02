open OUnit2

module Sym = C64MC.Symbol_table
module Utils = C64MC.Utils
module Ig = Codegen.InstructionGen
module Exc = Exceptions
module AST_TRSL = C64MC.Ast_translate

module AST_SRC = C64MC.Ast_src
module AST_TGT = C64MC.Ast_tgt
module PP_TGT = C64MC.Pprint_tgt
module PP_SRC = C64MC.Pprint_src


(*---------------- AST TRANSLATE TEST ----------------*)

let test_base_offset _ctx = 
  assert_equal (-9) (AST_TRSL.base_offset AST_SRC.C);
  assert_equal (-7) (AST_TRSL.base_offset AST_SRC.D);
  assert_equal (-5) (AST_TRSL.base_offset AST_SRC.E);
  assert_equal (-4) (AST_TRSL.base_offset AST_SRC.F);
  assert_equal (-2) (AST_TRSL.base_offset AST_SRC.G);
  assert_equal 0 (AST_TRSL.base_offset AST_SRC.A);
  assert_equal 2 (AST_TRSL.base_offset AST_SRC.B)

let test_acc_offset _ctx = 
  assert_equal 0 (AST_TRSL.acc_offset AST_SRC.Nat);
  assert_equal 1 (AST_TRSL.acc_offset AST_SRC.Sharp);
  assert_equal (-1) (AST_TRSL.acc_offset AST_SRC.Flat)

let test_oct_offset _ctx =
  assert_equal 0 (AST_TRSL.oct_offset (AST_SRC.Defined 4));
  assert_equal (-12) (AST_TRSL.oct_offset (AST_SRC.Defined 3));
  assert_equal (-24) (AST_TRSL.oct_offset (AST_SRC.Defined 2));
  assert_equal (-36) (AST_TRSL.oct_offset (AST_SRC.Defined 1));
  assert_equal (-48) (AST_TRSL.oct_offset (AST_SRC.Defined 0));
  assert_equal (-60) (AST_TRSL.oct_offset (AST_SRC.Defined (-1)));
  assert_equal (-72) (AST_TRSL.oct_offset (AST_SRC.Defined (-2)))


let test_get_duration_ref _ctx =
  (* By default the basic note value is 4 and tempo is 120 *)
  (* The expected duration is (3000 / 120) / 4 = 6.25 = 6 with integer division and multiplication *)
  let duration = AST_TRSL.get_duration_ref () in
  assert_equal duration 6

let test_get_note_duration _ctx =
  (* By default the basic note value is 4 and tempo is 120 *)
  (* The expected duration is (3000 / 120) / 4 * 16 = 96 with integer division and multiplication *)
  let duration = AST_TRSL.get_note_duration AST_SRC.Whole in
  assert_equal duration 96

  
(* Asserts that a whole C4 note is translated properly in the Target AST *)
let test_note_translate_sound _ctx =
  let note = AST_SRC.Sound (C, Nat, Whole, Defined 4) in
  let translated_note = AST_TRSL.note_translate note in
  let expected_note = { AST_TGT.highfreq = 16; AST_TGT.lowfreq = 195; AST_TGT.duration = 96} in
  assert_equal translated_note expected_note


(* Asserts that a whole rest note is translated properly in the Target AST *)
let test_note_translate_rest _ctx =
  let note = AST_SRC.Rest Whole in
  let translated_note = AST_TRSL.note_translate note in
  let expected_note = { AST_TGT.highfreq = 0; AST_TGT.lowfreq = 0; AST_TGT.duration = 96} in
  assert_equal translated_note expected_note


(* Asserts that a quarter C5 note is translated properly in the Target AST *)
let test_seq_translate _ctx =
  let seq = [
    AST_SRC.Sound (C, Nat, Whole, Defined 5);
    AST_SRC.Sound (C, Nat, Whole, Defined 5)
  ] in
  let translated_seq = AST_TRSL.seq_translate seq in
  let expected_seq = [
    { AST_TGT.highfreq = 33; AST_TGT.lowfreq = 134; AST_TGT.duration = 96};
    { AST_TGT.highfreq = 33; AST_TGT.lowfreq = 134; AST_TGT.duration = 96}
  ] in
  assert_equal translated_seq expected_seq



let test_waveform_translate _ctx =
  let waveform = AST_SRC.Noise in
  let translated_waveform = AST_TRSL.waveform_translate waveform in
  let expected_waveform = AST_TGT.Noise in
  assert_equal translated_waveform expected_waveform

let test_ident_translate _ctx =
  let dummy_loc = (Lexing.dummy_pos, Lexing.dummy_pos) in
  let ident : AST_SRC.ident = { id = "test"; id_loc = dummy_loc } in
  let translated_ident : AST_TGT.ident = AST_TRSL.ident_translate ident in
  let expected_ident : AST_TGT.ident = { id = "test"; id_loc = dummy_loc } in
  assert_equal translated_ident expected_ident
  
let test_voice_translate _ctx =
  let dummy_loc = (Lexing.dummy_pos, Lexing.dummy_pos) in
  let input_voice : AST_SRC.voice = [
    ({ AST_SRC.id = "seq1"; id_loc = dummy_loc }, AST_SRC.Triangle);
    ({ AST_SRC.id = "seq2"; id_loc = dummy_loc }, AST_SRC.Noise)
  ] in

  let expected_voice : AST_TGT.voice = [
    ({ AST_TGT.id = "seq1"; id_loc = dummy_loc }, AST_TGT.Triangle);
    ({ AST_TGT.id = "seq2"; id_loc = dummy_loc }, AST_TGT.Noise)
  ] in

  let translated_voice = AST_TRSL.voice_translate input_voice in

  assert_equal expected_voice translated_voice