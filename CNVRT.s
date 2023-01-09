;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        DEGERLER , READONLY, CODE
            THUMB
            EXPORT      CNVRT       ; Make available
			EXTERN		SPI1_Write_data
			EXTERN		SPI1_Write_cmd
			EXTERN		writeDigit
LUXWrite	mov		r3,#0x40	 ;Y to 0. segment
			BL		SPI1_Write_cmd	
			cmp     r0,#0x00
			beq		lsb
			cmp     r0,#0x01
			beq		secondDigit
			cmp     r0,#0x02
			beq		thirdDigit
			cmp     r0,#0x03
			beq		msb		
lsb			mov		r3,#0xB1     ;X to beginning for LSB digit 
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
secondDigit	mov		r3,#0xA9     ;X to beginning for 2nd digit 
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
thirdDigit	mov		r3,#0xA1     ;X to beginning for msb digit    
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
msb 		mov		r3,#0x99     ;X to beginning for 3rd digit 
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
LTWrite		mov		r3,#0x42	 ;Y to 1. segment
			BL		SPI1_Write_cmd			
			cmp     r0,#0x00
			beq		lsbLT
			cmp     r0,#0x01
			beq		secondDigitLT
			cmp     r0,#0x02
			beq		thirdDigitLT
			cmp     r0,#0x03
			beq		msbLT			
lsbLT		mov		r3,#0xB1     ;X to beginning for LSB digit
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam			
secondDigitLT	mov		r3,#0xA9     ;X to beginning for 2nd digit  
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
thirdDigitLT	mov		r3,#0xA1     ;X to beginning for msb digit    
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam			
msbLT 		mov		r3,#0x99     ;X to beginning for 3rd digit  
			add		r3,#0x10		
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam
HTWrite		mov		r3,#0x44	 ;Y to 2. segment
			BL		SPI1_Write_cmd		
			cmp     r0,#0x00
			beq		lsbHT
			cmp     r0,#0x01
			beq		secondDigitHT
			cmp     r0,#0x02
			beq		thirdDigitHT
			cmp     r0,#0x03
			beq		msbHT		
lsbHT			mov		r3,#0xB1     ;X to beginning for LSB digit  
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
secondDigitHT	mov		r3,#0xA9     ;X to beginning for 2nd digit
			add		r3,#0x10	
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
thirdDigitHT	mov		r3,#0xA1     ;X to beginning for msb digit 
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam		
msbHT 		mov		r3,#0x99     ;X to beginning for 3rd digit    
			add		r3,#0x10
			BL		SPI1_Write_cmd
			BL		writeDigit
			B		devam
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        convert , READONLY, CODE
            THUMB
            EXPORT      CNVRT       ; Make available
			EXTERN		SPI1_Write_data
			EXTERN		SPI1_Write_cmd
			EXTERN		writeDigit
CNVRT       PROC 
			push        {r0,r5,LR} ; since these register are used in CNVRT the values from before should be stored in stack
			mov			r2, #10     	; r2 holds 10
			mov			r0, #0          ; counter
loop1		udiv		r1, r4,r2 		; A/10		
			mul			r1, r1,r2   	; 10*(A/10)
			sub			r1, r4,r1   	; A-B*(A/B)  we performed modulo operation r1 holds lsb in decimal
			cmp         r4, #0			; look if r1 is 0
			beq			exit			; if r1 is zero carry set in the cmp line and branch to exit		
			cmp			r5,#0x00        ; check if r5 indicate LUM data
			beq			LUXWrite
			cmp			r5,#0x01        ; check if r5 indicate LT data
			beq			LTWrite
			cmp			r5,#0x02        ; check if r5 indicate HT data
			beq			HTWrite		
devam		udiv     	r4,r4,r2		 ; least significant bit of r4 dropped
			b           loop1            ; 
exit		
			pop			{r0,r5,LR} ; pop the values
			BX          LR          	;  link register to prev value
			endp						; end of cnvrt