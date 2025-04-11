let preamble = {|
                processor 6502          ; Specify the 6502 processor
                org 2049                ; Set the origin for the BASIC program

sys:            dc.b $0b,$08            ; Address of the next instruction
                dc.b $0a,$00            ; Line number (10)
                dc.b $9e                ; SYS-token (BASIC command to call machine code)
                dc.b $32,$30,$36,$31    ; 2061 as ASCII (address to jump to)
                dc.b $00                ; Null terminator for the line
                dc.b $00,$00            ; Instruction address 0 terminates the BASIC program

                org $1000               ; Set the origin for the machine code program
|}

