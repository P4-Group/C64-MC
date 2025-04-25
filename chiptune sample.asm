;; Isolate
                processor 6502
                org 2049

byteHoven       = $fb
bitsOfBach      = $fc


sys:            
                dc.b $0b,$08
                dc.b $0a,$00
                dc.b $9e
                dc.b $32,$30,$36,$31
                dc.b $00
                dc.b $00,$00

start:          
                jsr $1000

                sei

                lda #<raster
                sta $0314
                lda #>raster
                sta $0315

                lda #50
                sta $d012
                lda $d011
                and #$7f
                sta $d011

                lda #$7f
                sta $dc0d

                lda #$01
                sta $d01a

                lda $dc0d

                cli

                rts


raster:         
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop

                jsr play

                dec $d019
                jmp $ea31

                org $1000

;; Isolate Play
play_init:      
                ldx #$00

                lda #$00
                sta $d417

                lda #$0f
                sta $d418

                lda #<channel1
                sta c_ptrlo,x
                lda #>channel1
                sta c_ptrhi,x

                inx
                lda #<channel2
                sta c_ptrlo,x
                lda #>channel2
                sta c_ptrhi,x

                inx
                lda #<channel3
                sta c_ptrlo,x
                lda #>channel3
                sta c_ptrhi,x

                rts

;; Isolate note Initiation
gatebit_off:    
                lda #$00
                sta c_waveform,x
                jmp counter_init

note_init:      
                lda c_freqlo_new,x
                beq gatebit_off
                sta c_freqlo,x
                lda c_freqhi_new,x
                sta c_freqhi,x

                ldy c_instr,x

                lda i_pulselo,y
                sta c_pulselo,x
                lda i_pulsehi,y
                sta c_pulsehi,x

                lda i_waveform,y
                sta c_waveform,x

                lda i_ad,y
                sta c_ad,x
                lda i_sr,y
                sta c_sr,x

counter_init:   
                lda c_counternew,x
                sta c_counter,x

                jmp update_sid

;; Isolate Play loop
play:           
                ldx #$00

play_loop:      
                lda c_counter,x
                beq note_init

                cmp #$02
                beq fetch

update_sid:     
                dec c_counter,x
                ldy c_regindex,x

                lda c_freqlo,x
                sta $d400,y
                lda c_freqhi,x
                sta $d401,y

                lda c_pulselo,x
                sta $d402,y
                lda c_pulsehi,x
                sta $d403,y

                lda c_waveform,x
                sta $d404,y

                lda c_ad,x
                sta $d405,y
                lda c_sr,x
                sta $d406,y

next_channel:   
                inx
                cpx #$03
                bcc play_loop
                rts

;; Isolate Fetch Notes/sequences
fetch:          
                lda c_ptrlo,x
                sta byteHoven
                lda c_ptrhi,x
                sta bitsOfBach

                ldy #$00

fetch_loop:     
                lda (byteHoven),y

                cmp #$f9
                bcc fetch_note
                
                iny

                cmp #$fd
                bcc load_instr

                beq jump_addr

                cmp #$fe
                beq enter_seq

                jmp exit_seq

enter_seq:      
                lda byteHoven

                clc
                adc #$04
                sta c_rtnlo,x

                lda bitsOfBach
                adc #$00
                sta c_rtnhi,x

jump_addr       
                lda (byteHoven),y
                sta c_ptrlo,x

                iny
                lda (byteHoven),y
                sta c_ptrhi,x

                jmp fetch

exit_seq:       
                lda c_rtnlo,x
                sta c_ptrlo,x
                lda c_rtnhi,x
                sta c_ptrhi,x

                jmp fetch

load_instr:     
                sec
                sbc #$F9
                sta c_instr,x
                jmp fetch_loop

fetch_note:     
                sta c_freqlo_new,x

                iny
                lda (byteHoven),y
                sta c_freqhi_new,x

                iny
                lda (byteHoven),y
                sta c_counternew,x

                lda c_waveform,x
                and #$fe
                sta c_waveform,x

                iny
                tya
                clc
                adc byteHoven
                sta c_ptrlo,x

                lda bitsOfBach
                adc #$00
                sta c_ptrhi,x

                jmp update_sid

;; Isolate channel data
c_regindex:     dc.b $00,$07,$0E
c_freqlo:       dc.b $00,$00,$00
c_freqlo_new:   dc.b $00,$00,$00
c_freqhi:       dc.b $00,$00,$00
c_freqhi_new:   dc.b $00,$00,$00
c_instr         dc.b $00,$00,$00
c_pulselo       dc.b $00,$00,$00
c_pulsehi       dc.b $00,$00,$00
c_waveform:     dc.b $00,$00,$00
c_ad:           dc.b $00,$00,$00
c_sr:           dc.b $00,$00,$00
c_counter:      dc.b $02,$02,$02
c_counternew:   dc.b $00,$00,$00
c_ptrlo:        dc.b $00,$00,$00
c_ptrhi:        dc.b $00,$00,$00
c_rtnlo:        dc.b $00,$00,$00
c_rtnhi:        dc.b $00,$00,$00

;; Isolate instrument data
i_pulselo:      dc.b $00,$00,$00,$00
i_pulsehi:      dc.b $00,$02,$00,$00
i_pulsespeed:   dc.b $00,$20,$00,$00
i_ad:           dc.b $0a,$09,$58,$0a
i_sr:           dc.b $00,$00,$aa,$00
i_waveform:     dc.b $81,$41,$21,$11


;; Actual code which needs to be generated
channel1:       
                dc.b $FA
                dc.b $FE
                dc.w seq_1

                dc.b $FA
                dc.b $FE
                dc.w seq_2

                dc.b $FD
                dc.w channel1

channel2:       
                dc.b $FB
                dc.b $FE
                dc.w bass_1

                dc.b $FB
                dc.b $FE
                dc.w bass_2

                dc.b $FD
                dc.w channel2

channel3:       
                dc.b $FC
                dc.b $FE
                dc.w arpeg

                dc.b $FD
                dc.w channel3

seq_1:          
                dc.b $d1, $12, $0E
                dc.b $1f, $15, $0E
                dc.b $60, $16, $0E
                dc.b $1f, $15, $0E
                dc.b $60, $16, $0E
                dc.b $1f, $15, $0E
                dc.b $d1, $12, $0E
                dc.b $00, $00, $0E
                dc.b $FF

seq_2:          
                dc.b $d1, $12, $0E
                dc.b $1f, $15, $0E
                dc.b $60, $16, $0E
                dc.b $1f, $15, $0E
                dc.b $d1, $12, $1C
                dc.b $d1, $12, $1C
                dc.b $FF

bass_1:         
                dc.b $B4, $04, $0E
                dc.b $98, $05, $0E
                dc.b $B4, $04, $0E
                dc.b $98, $05, $0E
                dc.b $FF

bass_2:         
                dc.b $98, $05, $0E
                dc.b $0C, $07, $0E
                dc.b $98, $05, $0E
                dc.b $0C, $07, $0E
                dc.b $FF

arpeg:          
                dc.b $68, $09, $0E
                dc.b $30, $0B, $0E
                dc.b $18, $0E, $0E
                dc.b $30, $0B, $0E
                dc.b $FF
