;LABEL      		DIRECTIVE   VALUE       COMMENT
					AREA        autoTexts , READONLY, CODE
					THUMB
					EXPORT 		autoText	  ; make this subroutine availible externally
					EXTERN		CNVRT
					EXTERN		SPI1_Write_data
					EXTERN		SPI1_Write_cmd

autoText			PROC
					PUSH		{R3,LR}
					;0x7f, 0x40, 0x40, 0x40, 0x40 FOR L
					;0x3f, 0x40, 0x40, 0x40, 0x3f FOR U
					;0x7f, 0x02, 0x0c, 0x02, 0x7f FOR M
					;------------------------------------------------LUM------------------------------------------------------
					mov		r3,#0x80     ;X to beginning     
					BL		SPI1_Write_cmd
					
					mov		r3,#0x40	;Y to 0. segment
					BL		SPI1_Write_cmd
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					
					mov		r3,#0x3f
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x3F
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x02
					BL		SPI1_Write_data
					
					mov		r3,#0x0C
					BL		SPI1_Write_data
					
					mov		r3,#0x02
					BL		SPI1_Write_data
					
					mov		r3,#0x7F
					BL		SPI1_Write_data
					
					
					
					mov		r3,#0x80     ;X to beginning     
					BL		SPI1_Write_cmd
					
					mov		r3,#0x42	;Y to 2. segment
					BL		SPI1_Write_cmd
					;--------------------------------------------LT---------------------------------------
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x40
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					;0x01, 0x01, 0x7f, 0x01, 0x01 for T
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					
					mov		r3,#0x80     ;X to beginning     
					BL		SPI1_Write_cmd
					
					mov		r3,#0x44	;Y to 4. segment
					BL		SPI1_Write_cmd
					;0x7f, 0x08, 0x08, 0x08, 0x7f FOR H
					;------------------------------------------------------HT------------------------------------
					mov		r3,#0x7F
					BL		SPI1_Write_data
					
					mov		r3,#0x08
					BL		SPI1_Write_data
					
					mov		r3,#0x08
					BL		SPI1_Write_data
					
					mov		r3,#0x08
					BL		SPI1_Write_data
					
					mov		r3,#0x7F
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x7f
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x01
					BL		SPI1_Write_data
					
					mov		r3,#0x00          ; space
					BL		SPI1_Write_data
					
					mov		r3,#0x00
					BL		SPI1_Write_data
					
					POP		{R3,LR}
					BX		LR