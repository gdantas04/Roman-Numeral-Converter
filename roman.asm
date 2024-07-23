;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer



;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------



inicio:
			mov #2929, R5			; numero que queremos converter
			mov #RESULTADO, R10		; endereço de memória do resultado
			call #dividir_por_1000

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; SUBROTINA QUE EFETUA DIVISÃO	(FAZ R5/R6) (RESTO = R7) (QUOCIENTE = R8)
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

divisao:
divide:
    		mov #0, R7
   			mov #0, R8
		    cmp #0, R6
		    jz trap
		    CMP #0, R5
		    jz trap
		    mov R5, R9

loop_div:
		    cmp R9, R6
		    jc loop_div_final
		    inc R8
		    sub R6, R9
		    jmp loop_div

loop_div_final:
   			mov R9, R7

trap:
    		ret


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; MILHARES
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

dividir_por_1000:
			mov #1000, R6
			call #divisao		; aqui eu terei valores de resto e quociente

			cmp #0, R8			; quociente > 0
			jhs montar_1000

montar_1000:
			cmp #0,R8

			jeq dividir_por_100
			mov.b R_M, 0(R10)
			inc R10
			dec R8
			jmp montar_1000


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; CENTENAS
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

dividir_por_100:
			cmp #0,R7
			jeq trap2
			mov R7, R5
			mov #100, R6
			call #divisao		; divide o resto da operação anterior por 100


			cmp #0, R8			; quociente > 0
			jhs parametros_100

parametros_100:					; ve onde centena se enquadra (menor que 4, 4, entre 4 e 9, 9)
			cmp.b #4, R8
			jeq montar4_100

			cmp.b #9, R8
			jeq montar9_100

			cmp.b #4, R8
			jlo montar_menor_que_4_100

			jhs montar_entre_4_e_9_100


montar4_100:

			mov.b R_C, 0(R10)
			inc R10
			mov.b R_D, 0(R10)
			inc R10
			jmp dividir_por_10

montar9_100:

			mov.b R_C, 0(R10)
			inc R10
			mov.b R_M, 0(R10)
			inc R10

			jmp dividir_por_10

montar_menor_que_4_100:
			cmp #0,R8
			jeq dividir_por_10
			mov.b R_C, 0(R10)
			inc R10
			dec R8
			jmp montar_menor_que_4_100

montar_entre_4_e_9_100:
			mov.b R_D, 0(R10)
			inc R10
			sub #5, R8

subrot_montar_entre_4_e_9_100:
			cmp #0,R8
			jeq dividir_por_10
			mov.b R_I, 0(R10)
			inc R10
			dec R8
			jmp subrot_montar_entre_4_e_9_100

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; DEZENAS
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


dividir_por_10:
			cmp #0,R7
			jeq trap2
			mov R7, R5
			mov #10, R6
			call #divisao		; divide o resto da operação anterior por 10

			cmp #0, R8			; quociente > 0
			jhs parametros_10

parametros_10:					; ve onde dezena se enquadra (menor que 4, 4, entre 4 e 9, 9)
			cmp.b #4, R8
			jeq montar4_10

			cmp.b #9, R8
			jeq montar9_10

			cmp.b #4, R8
			jlo montar_menor_que_4_10

			jhs montar_entre_4_e_9_10


montar4_10:
			mov.b R_X, 0(R10)
			inc R10
			mov.b R_L, 0(R10)
			inc R10
			jmp montar_unidades

montar9_10:
			mov.b R_X, 0(R10)
			inc R10
			mov.b R_C, 0(R10)
			inc R10
			jmp montar_unidades

montar_menor_que_4_10:
			cmp #0,R8
			jeq montar_unidades
			mov.b R_X, 0(R10)
			inc R10
			dec R8
			jmp montar_menor_que_4_10

montar_entre_4_e_9_10:
			mov.b R_L, 0(R10)
			inc R10
			sub #5, R8

subrot_montar_entre_4_e_9_10:
			cmp #0,R8
			jeq montar_unidades
			mov.b R_I, 0(R10)
			inc R10
			dec R8
			jmp subrot_montar_entre_4_e_9_10


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; UNIDADES
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

montar_unidades:
			cmp #0,R7
			jeq trap2


parametros_1:					; ve onde unidade se enquadra (menor que 4, 4, entre 4 e 9, 9)

			cmp.b #4, R7
			jeq montar4_1

			cmp.b #9, R7
			jeq montar9_1

			cmp.b #4, R7
			jlo montar_menor_que_4_1

			jhs montar_entre_4_e_9_1


montar4_1:
			mov.b R_I, 0(R10)
			inc R10
			mov.b R_V, 0(R10)
			inc R10
			jmp trap2

montar9_1:
			mov.b R_I, 0(R10)
			inc R10
			mov.b R_X, 0(R10)
			inc R10
			jmp trap2

montar_menor_que_4_1:
			cmp #0, R7
			jeq trap2
			mov.b R_I, 0(R10)
			inc R10
			dec R7
			jmp montar_menor_que_4_1

montar_entre_4_e_9_1:
			mov.b R_V, 0(R10)
			inc R10
			sub #5, R7

subrot_montar_entre_4_e_9_1:
			cmp #0, R7
			jeq trap2
			mov.b R_I, 0(R10)
			inc R10
			dec R7
			jmp subrot_montar_entre_4_e_9_1


trap2:
			mov.b		#0,0(R10)
			jmp $
			nop


				.data

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Memória em 0x2400
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


RESULTADO: 		.byte		"000000000000000000",0


R_I:			.byte		"I"
R_V:			.byte		"V"
R_X:			.byte		"X"
R_L:			.byte		"L"
R_C:			.byte		"C"
R_D:			.byte		"D"
R_M:			.byte		"M"


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
