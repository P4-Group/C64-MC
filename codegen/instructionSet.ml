(* ---Instruction Set for the Commodore 64's 6502 Microprocessor--- *)

type instruction = {
  name : string;
  mnemonic : string; 
  max_args : int;
  min_args : int;
}

let instructions = [
  { name = "Add with Carry"; mnemonic = "ADC"; max_args = 2; min_args = 1 };
  { name = "Logical AND"; mnemonic = "AND"; max_args = 2; min_args = 1 };
  { name = "Arithmetic Shift Left"; mnemonic = "ASL"; max_args = 1; min_args = 1 };
  { name = "Branch if Carry Clear"; mnemonic = "BCC"; max_args = 1; min_args = 1 };
  { name = "Branch if Carry Set"; mnemonic = "BCS"; max_args = 1; min_args = 1 };
  { name = "Branch if Equal"; mnemonic = "BEQ"; max_args = 1; min_args = 1 };
  { name = "Bit Test"; mnemonic = "BIT"; max_args = 2; min_args = 1 };
  { name = "Branch if Minus"; mnemonic = "BMI"; max_args = 1; min_args = 1 };
  { name = "Branch if Not Equal"; mnemonic = "BNE"; max_args = 1; min_args = 1 };
  { name = "Branch if Positive"; mnemonic = "BPL"; max_args = 1; min_args = 1 };
  { name = "Break"; mnemonic = "BRK"; max_args = 0; min_args = 0 };
  { name = "Branch if Overflow Clear"; mnemonic = "BVC"; max_args = 1; min_args = 1 };
  { name = "Branch if Overflow Set"; mnemonic = "BVS"; max_args = 1; min_args = 1 };
  { name = "Clear Carry Flag"; mnemonic = "CLC"; max_args = 0; min_args = 0 };
  { name = "Clear Decimal Mode"; mnemonic = "CLD"; max_args = 0; min_args = 0 };
  { name = "Clear Interrupt Disable"; mnemonic = "CLI"; max_args = 0; min_args = 0 };
  { name = "Clear Overflow Flag"; mnemonic = "CLV"; max_args = 0; min_args = 0 };
  { name = "Compare"; mnemonic = "CMP"; max_args = 2; min_args = 1 };
  { name = "Compare X Register"; mnemonic = "CPX"; max_args = 2; min_args = 1 };
  { name = "Compare Y Register"; mnemonic = "CPY"; max_args = 2; min_args = 1 };
  { name = "Decrement Memory"; mnemonic = "DEC"; max_args = 1; min_args = 1 };
  { name = "Decrement X Register"; mnemonic = "DEX"; max_args = 0; min_args = 0 };
  { name = "Decrement Y Register"; mnemonic = "DEY"; max_args = 0; min_args = 0 };
  { name = "Exclusive OR"; mnemonic = "EOR"; max_args = 2; min_args = 1 };
  { name = "Increment Memory"; mnemonic = "INC"; max_args = 1; min_args = 1 };
  { name = "Increment X Register"; mnemonic = "INX"; max_args = 0; min_args = 0 };
  { name = "Increment Y Register"; mnemonic = "INY"; max_args = 0; min_args = 0 };
  { name = "Jump"; mnemonic = "JMP"; max_args = 1; min_args = 1 };
  { name = "Jump to Subroutine"; mnemonic = "JSR"; max_args = 1; min_args = 1 };
  { name = "Load Accumulator"; mnemonic = "LDA"; max_args = 2; min_args = 1 };
  { name = "Load X Register"; mnemonic = "LDX"; max_args = 2; min_args = 1 };
  { name = "Load Y Register"; mnemonic = "LDY"; max_args = 2; min_args = 1 };
  { name = "Logical Shift Right"; mnemonic = "LSR"; max_args = 1; min_args = 1 };
  { name = "No Operation"; mnemonic = "NOP"; max_args = 0; min_args = 0 };
  { name = "Logical Inclusive OR"; mnemonic = "ORA"; max_args = 2; min_args = 1 };
  { name = "Push Accumulator"; mnemonic = "PHA"; max_args = 0; min_args = 0 };
  { name = "Push Processor Status"; mnemonic = "PHP"; max_args = 0; min_args = 0 };
  { name = "Pull Accumulator"; mnemonic = "PLA"; max_args = 0; min_args = 0 };
  { name = "Pull Processor Status"; mnemonic = "PLP"; max_args = 0; min_args = 0 };
  { name = "Rotate Left"; mnemonic = "ROL"; max_args = 1; min_args = 1 };
  { name = "Rotate Right"; mnemonic = "ROR"; max_args = 1; min_args = 1 };
  { name = "Return from Interrupt"; mnemonic = "RTI"; max_args = 0; min_args = 0 };
  { name = "Return from Subroutine"; mnemonic = "RTS"; max_args = 0; min_args = 0 };
  { name = "Subtract with Carry"; mnemonic = "SBC"; max_args = 2; min_args = 1 };
  { name = "Set Carry Flag"; mnemonic = "SEC"; max_args = 0; min_args = 0 };
  { name = "Set Decimal Flag"; mnemonic = "SED"; max_args = 0; min_args = 0 };
  { name = "Set Interrupt Disable"; mnemonic = "SEI"; max_args = 0; min_args = 0 };
  { name = "Store Accumulator"; mnemonic = "STA"; max_args = 2; min_args = 1 };
  { name = "Store X Register"; mnemonic = "STX"; max_args = 2; min_args = 1 };
  { name = "Store Y Register"; mnemonic = "STY"; max_args = 2; min_args = 1 };
  { name = "Transfer Accumulator to X"; mnemonic = "TAX"; max_args = 0; min_args = 0 };
  { name = "Transfer Accumulator to Y"; mnemonic = "TAY"; max_args = 0; min_args = 0 };
  { name = "Transfer Stack Pointer to X"; mnemonic = "TSX"; max_args = 0; min_args = 0 };
  { name = "Transfer X to Accumulator"; mnemonic = "TXA"; max_args = 0; min_args = 0 };
  { name = "Transfer X to Stack Pointer"; mnemonic = "TXS"; max_args = 0; min_args = 0 };
  { name = "Transfer Y to Accumulator"; mnemonic = "TYA"; max_args = 0; min_args = 0 };
]