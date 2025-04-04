(* ---Instruction Set for the Commodore 64's 6502 Microprocessor---*)

let test_func (x : int) = Printf.printf "%d \n" x;


type instruction = {
  name : string;
  mnemonic : string; 
  (* mnemonics are the textual codes that correspond to binary CPU instructions *)
}

let instructions = [
  { name = "Add with Carry"; mnemonic = "ADC" };
  { name = "Logical AND"; mnemonic = "AND" };
  { name = "Arithmetic Shift Left"; mnemonic = "ASL" };
  { name = "Branch if Carry Clear"; mnemonic = "BCC" };
  { name = "Branch if Carry Set"; mnemonic = "BCS" };
  { name = "Branch if Equal"; mnemonic = "BEQ" };
  { name = "Bit Test"; mnemonic = "BIT" };
  { name = "Branch if Minus"; mnemonic = "BMI" };
  { name = "Branch if Not Equal"; mnemonic = "BNE" };
  { name = "Branch if Positive"; mnemonic = "BPL" };
  { name = "Break"; mnemonic = "BRK" };
  { name = "Branch if Overflow Clear"; mnemonic = "BVC" };
  { name = "Branch if Overflow Set"; mnemonic = "BVS" };
  { name = "Clear Carry Flag"; mnemonic = "CLC" };
  { name = "Clear Decimal Mode"; mnemonic = "CLD" };
  { name = "Clear Interrupt Disable"; mnemonic = "CLI" };
  { name = "Clear Overflow Flag"; mnemonic = "CLV" };
  { name = "Compare"; mnemonic = "CMP" };
  { name = "Compare X Register"; mnemonic = "CPX" };
  { name = "Compare Y Register"; mnemonic = "CPY" };
  { name = "Decrement Memory"; mnemonic = "DEC" };
  { name = "Decrement X Register"; mnemonic = "DEX" };
  { name = "Decrement Y Register"; mnemonic = "DEY" };
  { name = "Exclusive OR"; mnemonic = "EOR" };
  { name = "Increment Memory"; mnemonic = "INC" };
  { name = "Increment X Register"; mnemonic = "INX" };
  { name = "Increment Y Register"; mnemonic = "INY" };
  { name = "Jump"; mnemonic = "JMP" };
  { name = "Jump to Subroutine"; mnemonic = "JSR" };
  { name = "Load Accumulator"; mnemonic = "LDA" };
  { name = "Load X Register"; mnemonic = "LDX" };
  { name = "Load Y Register"; mnemonic = "LDY" };
  { name = "Logical Shift Right"; mnemonic = "LSR" };
  { name = "No Operation"; mnemonic = "NOP" };
  { name = "Logical Inclusive OR"; mnemonic = "ORA" };
  { name = "Push Accumulator"; mnemonic = "PHA" };
  { name = "Push Processor Status"; mnemonic = "PHP" };
  { name = "Pull Accumulator"; mnemonic = "PLA" };
  { name = "Pull Processor Status"; mnemonic = "PLP" };
  { name = "Rotate Left"; mnemonic = "ROL" };
  { name = "Rotate Right"; mnemonic = "ROR" };
  { name = "Return from Interrupt"; mnemonic = "RTI" };
  { name = "Return from Subroutine"; mnemonic = "RTS" };
  { name = "Subtract with Carry"; mnemonic = "SBC" };
  { name = "Set Carry Flag"; mnemonic = "SEC" };
  { name = "Set Decimal Flag"; mnemonic = "SED" };
  { name = "Set Interrupt Disable"; mnemonic = "SEI" };
  { name = "Store Accumulator"; mnemonic = "STA" };
  { name = "Store X Register"; mnemonic = "STX" };
  { name = "Store Y Register"; mnemonic = "STY" };
  { name = "Transfer Accumulator to X"; mnemonic = "TAX" };
  { name = "Transfer Accumulator to Y"; mnemonic = "TAY" };
  { name = "Transfer Stack Pointer to X"; mnemonic = "TSX" };
  { name = "Transfer X to Accumulator"; mnemonic = "TXA" };
  { name = "Transfer X to Stack Pointer"; mnemonic = "TXS" };
  { name = "Transfer Y to Accumulator"; mnemonic = "TYA" };
]