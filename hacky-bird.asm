; Flap wings with key W

; $00-01	=> screen location of Duck, stored as two bytes, where the first
;           byte is the pixel and the second is the strip.
; $02 		=> direction	; 1 => up	(bin 0001)
        				 	; 2 => down	(bin 0010)
; $03-??	=> pipe pixels (in byte pairs)

;The screens is divided in 8 strips of 8x32 "pixels". Each strip
;is stored in a page, having their own most significant byte. Each
;page has 256 bytes, starting at $00 and ending at $ff.

;   ------------------------------------------------------------
;1  | $0200 - $02ff                                            |
;2  |                                                          |
;3  |                                                          |
;4  |                                                          |
;5  |                                                          |
;6  |                                                          |
;7  |                                                          |
;8  |                                                          |
;   ------------------------------------------------------------
;9  | $03 - $03ff                                              |
;10 |                                                          |
;11 |                                                          |
;12 |                                                          |
;13 |                                                          |
;14 |                                                          |
;15 |                                                          |
;16 |                                                          |
;   ------------------------------------------------------------
;17 | $04 - $03ff                                              |
;18 |                                                          |
;19 |                                                          |
;20 |                                                          |
;21 |                                                          |
;22 |                                                          |
;23 |                                                          |
;24 |                                                          |
;   ------------------------------------------------------------
;25 | $05 - $03ff                                              |
;26 |                                                          |
;27 |                                                          |
;28 |                                                          |
;29 |                                                          |
;30 |                                                          |
;31 |                                                          |
;32 |                                                          |
;   ------------------------------------------------------------

define duckP			$00 ;screen location of duck, pixel
define duckS			$01 ;screen location of duck, strip
define duckDirection	$02 ;direction (possible values are below)
define pipeStart		$03 ;start of pipe byte pairs
define pipeLength       $04 ; pipe length, in bytes (possible variance of high and low pipes)

; Directions (each using a separate bit)
define movingUp		1
define movingDown	2

; ASCII values of keys controlling the duck flight
define ASCII_w      $77

; System variables
define sysRandom    $fe
define sysLastKey   $ff

; Colors
define duckColor    $07
define pipeColor    $0d

	jsr init  ;jump to subroutine init
	jsr loop  ;jump to subroutine loop

init: 
	jsr initDuck        ;jump to subroutine initDuck
	jsr generatePipe	;jump to subroutine generatePipe
	rts

  
initDuck:
	;start the duck in the middle of the screen
	
	;initial direction (2 => down)
	lda #movingDown
	sta duckDirection
	
	;initial duck position
	lda #$11	;pixel
	sta duckP
	lda #$04	;strip
	sta duckS
    rts			;return
  
generatePipe:
    ;generate pipe length
    
    lda sysRandom ;load a random number between 0 and 255 from address $fe into register A
    
    ;AND: logical AND with accumulator. Apply logical AND with hex $03 to value in
    ;register A. Hex 07 is binary 00000111, so only the two least significant bits
    ;are kept, resulting in a value between 0 (bin 00000000) and 7 (bin 00000111).
    ;Add 5 to the result, giving a random value between 5 and 12
    and #$07        ;mask out lowest 2 bits
    clc             ;clear carry flag 
    adc #5          ;add to register A, using carry bit for overflow.
    sta pipeLength  ;store value of y coordinate from register A into address $01

    lda #$05
    ldx #$00

generateInitialPipePositions:
    
    sta $05ff
    jsr shouldStopPipeGeneration
    sta $05df
    jsr shouldStopPipeGeneration
    sta $05bf
    jsr shouldStopPipeGeneration
    sta $059f
    jsr shouldStopPipeGeneration
    sta $057f
    jsr shouldStopPipeGeneration
    sta $055f
    jsr shouldStopPipeGeneration
    sta $053f
    jsr shouldStopPipeGeneration
    sta $051f
    jsr shouldStopPipeGeneration
    sta $04ff
    jsr shouldStopPipeGeneration
    sta $04df
    jsr shouldStopPipeGeneration
    sta $04bf
    jsr shouldStopPipeGeneration
    sta $049f
    jsr shouldStopPipeGeneration
    
shouldStopPipeGeneration:
    inx
    cpx pipeLength
    beq stopPipeGeneration
    rts
    
stopPipeGeneration:
    brk

checkPipeCollision:
    lda duckP
    cmp pipeStart
    bne doneCheckingPipeCollision
    lda duckS
    cmp pipeLength
    beq doneCheckingPipeCollision 
    rts ; if no collision

doneCheckingPipeCollision:
    jsr gameOver
;movePipeValues:
;
;drawPipe:
;

;loop:
  ;jsr keyHandler
  ;jsr checkPipeCollision
  ;jsr drawDuck
  ;jsr drawPipe
 ; jmp loop

  
drawDuck:
    lda #7
    sta duckS
    lda #7
    sta duckP

keyHandler:
 lda $ff        ;load the value of the latest keypress from address $ff into register A
 cmp #$77       ;compare value in register A to hex $77 (W)
; beq duckMover      ;Branch On Equal, to upKey
 



 
gameOver:
    BRK ;ends it all
    
    
    
    
    
;    ldx #0

;draw:

;lda #1
;sta (pipePixels,x)
;inx 
;cpx #11
;bne draw

;pipePixels:
;dcw $05ff,$05df,$05bf,$059f,$057f,$055f,$053f,$051f,$04ff,$04df,$04bf,$049f

;pipeStrips:
;dcb $05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04