;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        digitWriting , READONLY, CODE
            THUMB
            EXPORT      writeDigit       ; Make available
			EXTERN		SPI1_Write_data
			EXTERN		SPI1_Write_cmd
writeDigit 	PROC
			push		{LR}
			cmp			R1,#0x00
			beq			writeZero
			cmp			R1,#0x01
			beq			writeOne
			cmp			R1,#0x02
			beq			writeTwo
			cmp			R1,#0x03
			beq			writeThree
			cmp			R1,#0x04
			beq			writeFour
			B			devam
			
;0x3e, 0x51, 0x49, 0x45, 0x3e
writeZero			mov		r3,#0x3e
					BL		SPI1_Write_data
					
					mov		r3,#0x51
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x45
					BL		SPI1_Write_data
					
					mov		r3,#0x3e
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x00, 0x42, 0x7f, 0x40, 0x00
writeOne			mov		r3,#0x00
					BL		SPI1_Write_data
					
					mov		r3,#0x42
					BL		SPI1_Write_data
					
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x42, 0x61, 0x51, 0x49, 0x46
writeTwo			mov		r3,#0x42
					BL		SPI1_Write_data
					
					mov		r3,#0x61
					BL		SPI1_Write_data
					
					mov		r3,#0x51
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x46
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x21, 0x41, 0x45, 0x4b, 0x31
writeThree			mov		r3,#0x21
					BL		SPI1_Write_data
					
					mov		r3,#0x41
					BL		SPI1_Write_data
					
					mov		r3,#0x45
					BL		SPI1_Write_data
					
					mov		r3,#0x4b
					BL		SPI1_Write_data
					
					mov		r3,#0x31
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x18, 0x14, 0x12, 0x7f, 0x10
writeFour			mov		r3,#0x18
					BL		SPI1_Write_data
					
					mov		r3,#0x14
					BL		SPI1_Write_data
					
					mov		r3,#0x12
					BL		SPI1_Write_data
					
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x10
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR
					
devam				cmp			R1,#0x05
					beq			writeFive
					cmp			R1,#0x06
					beq			writeSix
					cmp			R1,#0x07
					beq			writeSeven
					cmp			R1,#0x08
					beq			writeEight
					cmp			R1,#0x09
					beq			writeNine

;0x27, 0x45, 0x45, 0x45, 0x39
writeFive			mov		r3,#0x27
					BL		SPI1_Write_data
					
					mov		r3,#0x45
					BL		SPI1_Write_data
					
					mov		r3,#0x45
					BL		SPI1_Write_data
					
					mov		r3,#0x45
					BL		SPI1_Write_data
					
					mov		r3,#0x39
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x3c, 0x4a, 0x49, 0x49, 0x30
writeSix			mov		r3,#0x3c
					BL		SPI1_Write_data
					
					mov		r3,#0x4a
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x30
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x01, 0x71, 0x09, 0x05, 0x03
writeSeven			mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x71
					BL		SPI1_Write_data
					
					mov		r3,#0x09
					BL		SPI1_Write_data
					
					mov		r3,#0x05
					BL		SPI1_Write_data
					
					mov		r3,#0x03
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x36, 0x49, 0x49, 0x49, 0x36
writeEight			mov		r3,#0x36
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x36
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR

;0x06, 0x49, 0x49, 0x29, 0x1e
writeNine			mov		r3,#0x06
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x49
					BL		SPI1_Write_data
					
					mov		r3,#0x29
					BL		SPI1_Write_data
					
					mov		r3,#0x1e
					BL		SPI1_Write_data
					ADD		R0,#0x01
					POP		{LR}
					BX 		LR