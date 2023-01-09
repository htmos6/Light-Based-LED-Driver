;******* GPIO REGISTERS ****************
GPIOA EQU 0x40004000 
GPIOB EQU 0x40005000 
GPIOC EQU 0x40006000 
GPIOD EQU 0x40007000
GPIOA_DATA EQU 0x400043FC ;for enabling all bits
GPIOA_DIR EQU 0x40004400
GPIOA_AFSEL EQU 0x40004420
GPIOA_PCTL EQU 0x4000452C
GPIOA_AMSEL EQU 0x40004528
GPIOA_DEN EQU 0x4000451C
GPIOE EQU 0x40024000 
GPIOF EQU 0x40025000 

RCGCGPIO EQU 0x400FE608
	
SSI0 EQU 0x40009000 
SSI0_CR0 EQU    0x40008000
SSI0_CR1 EQU	0x40008004
SSI0_DR  EQU	0x40008008	
SSI0_SR  EQU	0x4000800c
SSI0_CPSR EQU	0x40008010
SSI0_IM  EQU	0x40008014
SSI0_RIS  EQU	0x40008018
SSI0_MIS EQU	0x4000801c
SSI0_CR EQU	0x40008020
SSI0_CC EQU		0x40008FC8
RCGCSSI		EQU		0x400FE61C

LUM_DATA EQU 0x20000500
LT_DATA EQU 0x20000400	
HT_DATA EQU 0x20000420
	

;LABEL       DIRECTIVE   VALUE       COMMENT
			 AREA        SPI0_init1, READONLY, CODE
			 THUMB
			 EXPORT 	SPI0_init	  ; make this subroutine availible externally
			 EXTERN		CNVRT

SPI0_init    PROC
			 PUSH		{R0,R1,R2,LR}
			 ldr 		r0,=RCGCGPIO
			 ldr		r1,[r0]
			 orr		r1,#0xFF
			 str		r1,[r0]
			 NOP
			 NOP
			 NOP
			 
			 ldr 		r0,=RCGCSSI
			 ldr		r1,[r0]
			 orr		r1,#0x01 ;SPI0
			 str		r1,[r0]
			 NOP
			 NOP
			 NOP
			 
	  
			 ldr 		r0,=GPIOA_DEN	;/* set PF1-3 pin digital */
			 ldr		r1,[r0]
			 orr		r1,#0xFF
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_DIR	;/* set PF1-3 pin output */
			 ldr		r1,[r0]
			 orr		r1,#0xFF
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_AMSEL	;/* disable analog functionality RD0 and RD3 */
			 ldr		r1,[r0]
			 BIC		r1,#0xFF
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_AFSEL	;//* enable alternate function of PA2,PA3 and PA5*/
			 ldr		r1,[r0]
			 orr		r1,#0x2C
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_PCTL	;/* assign RD0 and RD3 pins to SPI0 */
			 ldr		r1,[r0]
			 MOV32		r4,#0xF0FF00
			 BIC		r1,r4
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_PCTL	;/* assign RD0 and RD3 pins to SPI0 */
			 ldr		r1,[r0]
			 MOV32		r4,#0x202200
			 orr		r1,r4
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_DATA	 ;/* keep SS idle high */
			 ldr		r1,[r0]
			 orr		r1,#0x08
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_DATA  ;PA6 (reset) set 0
			 ldr		r1,[r0]
			 BIC		r1,#0x40
			 str		r1,[r0]
			 
			 ldr 		r0,=GPIOA_DATA	;PA6 (reset) set 1
			 ldr		r1,[r0]
			 orr		r1,#0x40
			 str		r1,[r0]
			 
				 
	 
			 ldr 		r0,=SSI0_CR1	;/* disable SPI1 and configure it as a Master */
			 ldr		r1,[r0]
			 and		r1,#0x00
			 str		r1,[r0]
			 
			 ldr 		r0,=SSI0_CC	 ;/* Enable System clock Option */
			 ldr		r1,[r0]
			 and		r1,#0x00
			 str		r1,[r0]
			 
			 ldr 		r0,=SSI0_CPSR	 ;/* Select prescaler value of 4 .i.e 16MHz/4 = 4MHz */
			 ldr		r1,[r0]
			 orr		r1,#0x04
			 str		r1,[r0]
			 
			 ldr 		r0,=SSI0_CR0	 ;/* 4MHz SPI1 clock, SPI mode, 8 bit data */
			 ldr		r1,[r0]
			 orr		r1,#0x07
			 str		r1,[r0]
			 
			 ldr 		r0,=SSI0_CR1	 ;/* enable SPI1 */
			 ldr		r1,[r0]
			 orr		r1,#0x02
			 str		r1,[r0]
			 
			 mov		r3,#0x21  ;LCD extended commands
			 BL			SPI1_Write_cmd
					
			 mov		r3,#0xB8
			 BL			SPI1_Write_cmd  ;set LCD Vop (contrast)
					
			 mov		r3,#0x04
			 BL			SPI1_Write_cmd  ;set temp coefficent
					
			 mov		r3,#0x14
			 BL			SPI1_Write_cmd  ;LCD bias mode 1:40
					
			 mov		r3,#0x20
			 BL			SPI1_Write_cmd  ;LCD basic commands
					
			 mov		r3,#0x0C
			 BL			SPI1_Write_cmd  ;normal mode
			 POP		{R0,R1,R2,LR}
			 BX			LR
			 
;LABEL       		DIRECTIVE   VALUE       COMMENT
					AREA        SPI1_Write_cmd1, READONLY, CODE
					THUMB
					EXPORT 	 	SPI1_Write_cmd	  ; make this subroutine availible externally	 
					extern      CNVRT
SPI1_Write_cmd   	PROC
					PUSH		{R0,R1,R2,R3,R4}
					;data will be stored in R3
					ldr 		r0,=GPIOA_DATA	 ;PA7 DC
					ldr			r1,[r0]
					BIC			r1,#0x80
					str			r1,[r0]
					
					ldr 		r0,=GPIOA_DATA	 ;PA3 CE
					ldr			r1,[r0]
					BIC			r1,#0x08
					str			r1,[r0]
					
SR_LOOP				ldr			r4,=0x02
					ldr			r0,=SSI0_SR
					ldr			r1,[r0]
					AND	 		r4,r4,r1
					mov			r1,#0x00
					cmp			r4,r1
					beq			SR_LOOP 	;/* wait untill Tx FIFO is not full */
					
					ldr			r0,=SSI0_DR
					str			r3,[r0]			;/* transmit byte over SSI0Tx line */
SR_LOOP_2			ldr			r4,=0x10
					ldr			r0,=SSI0_SR
					ldr			r1,[r0]
					AND	 		r4,r4,r1
					mov			r1,#0x00
					cmp			r4,r1
					bne			SR_LOOP_2			;/* wait until transmit complete */
					
					ldr 		r0,=GPIOA_DATA	 ;/* keep selection line (PF2) high in idle condition */
					ldr			r1,[r0]
					ORR			r1,#0x80
					str			r1,[r0]
					
					ldr 		r0,=GPIOA_DATA	 ;/* keep selection line (PF2) high in idle condition */
					ldr			r1,[r0]
					ORR			r1,#0x08
					str			r1,[r0]		;/* Make PF2 Selection line (SS) low */
					
					POP			{R0,R1,R2,R3,R4}
					BX			LR
					
;LABEL       		DIRECTIVE   VALUE       COMMENT
					AREA        SPI1_Write_data1, READONLY, CODE
					THUMB
					EXPORT 	 	SPI1_Write_data	  ; make this subroutine availible externally	 
					EXTERN		CNVRT
SPI1_Write_data   	PROC
					PUSH		{R0,R1,R2,R3,R4}
					;data will be stored in R3
					ldr 		r0,=GPIOA_DATA	 ;/* Make PF2 Selection line (SS) low */
					ldr			r1,[r0]
					BIC			r1,#0x08
					str			r1,[r0]
					
					ldr 		r0,=GPIOA_DATA	 ;/ high DC */
					ldr			r1,[r0]
					orr			r1,#0x80
					str			r1,[r0]
					
DSR_LOOP			ldr			r4,=0x02
					ldr			r0,=SSI0_SR
					ldr			r1,[r0]
					AND	 		r4,r4,r1
					mov			r1,#0x00
					cmp			r4,r1
					beq			DSR_LOOP 	;/* wait untill Tx FIFO is not full */
					
					ldr			r0,=SSI0_DR
					str			r3,[r0]			;/* transmit byte over SSI0Tx line */
DSR_LOOP_2			ldr			r4,=0x10
					ldr			r0,=SSI0_SR
					ldr			r1,[r0]
					AND	 		r4,r4,r1
					mov			r1,#0x00
					cmp			r4,r1
					bne			DSR_LOOP_2			;/* wait until transmit complete */
					
					ldr 		r0,=GPIOA_DATA	 ;/* keep selection line (PF2) high in idle condition */
					ldr			r1,[r0]
					ORR			r1,#0x08
					str			r1,[r0]
					
					ldr 		r0,=GPIOA_DATA	 ;/* keep selection line (PF2) high in idle condition */
					ldr			r1,[r0]
					BIC			r1,#0x80
					str			r1,[r0]		;/* Make PF2 Selection line (SS) low */
					
					POP			{R0,R1,R2,R3,R4}
					BX			LR				
					
					
;LABEL      		DIRECTIVE   VALUE       COMMENT
					AREA        update , READONLY, CODE
					THUMB
					EXPORT 		updateLCD	  ; make this subroutine availible externally
					EXTERN		CNVRT
					EXTERN		autoText

					
updateLCD			proc
					push	{LR}
					;BL		SPI0_init
					
				
					;------------------------for clear------------------------				
					mov		r4,#0x1F8
clear				mov		r3,#0x00
					BL		SPI1_Write_data
					sub		r4,#0x01
					cmp		r4,r3
					bne		clear
	;-----------------------for clear--------------------------
					
					BL		autoText
					
					ldr		r0,=LUM_DATA
					ldr		r4,[r0]
					mov		r5,#0x00;  write to HT
					BL		CNVRT
					
					ldr		r0,=LT_DATA
					ldr		r4,[r0]
					mov		r5,#0x01;  write to HT
					BL		CNVRT
					
					ldr		r0,=HT_DATA
					ldr		r4,[r0]
					mov		r5,#0x02;  write to HT
					BL		CNVRT
					
					pop		{LR}
					BX		LR


			 