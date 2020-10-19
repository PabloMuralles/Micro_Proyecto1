 model small								;declaracion de modelo
.data										;inicia segmento de datos
 
	UUID DB 500 DUP('$') 
	timeStamp1 DB 500 DUP('$') 
	timeStamp2 DB 500 DUP('$') 
	timeStamp3 DB 500 DUP('$') 
	years DB 500 DUP('$') 
	months DB 500 DUP('$') 
	days DB 500 DUP('$') 
	horas DB 500 DUP('$') 
	minutos DB 500 DUP('$') 
	segundos DB 500 DUP('$') 
	contadorC DB 00h
	contadorD DB 00h
	contadorU DB 00h
	mes DB 00h
	dia DB 00h
	minuto DB 00h
	segundo DB 00h
	carry DW 00h
	i DW 00h
	x DW 00h
	largo DW 01h
	contSuma DB 00h
	
.stack						
.code 

program: 
	MOV AX,@DATA							;obtenemos la direccion de inicio
	MOV DS,AX								; iniciliza el segmento de datos
	
	CALL CALCULAR							; se calcula el primer timestamp
	
	LEA SI, years
	CALL IMPRIMIR
	
	;imprimir salto de linea
	MOV DL, 0AH
	MOV AH, 02h
	INT 21h
	
	LEA SI, UUID							;se copia el timestamp en el uuid por primera vez
	LEA DI, years
	CALL COPIAR
	
	LEA SI, UUID							; se busca donde termna la cadena uuid
	CALL ENCONTRAR
	LEA DI, years							;se copia el timestamp en el uuid por segunda vez
	CALL COPIAR
	
	LEA SI, UUID							; se busca donde termna la cadena uuid
	CALL ENCONTRAR
	LEA DI, years							;se copia el timestamp en el uuid por tercera vez
	CALL COPIAR
	
	LEA SI, UUID							; se busca donde termna la cadena uuid
	CALL ENCONTRAR
	LEA DI, years							;se copia el timestamp en el uuid por cuarta vez
	CALL COPIAR
	
	LEA SI, UUID
	CALL IMPRIMIR
	


	
	JMP finalizar
	
	
	COPIAR PROC 
		; SI es la cadena donde se va guardar el timestamp
		ciclo8:
		XOR AX,AX							;limpiar registros
		XOR BX,BX
		
		MOV AL, [DI]
		MOV [SI], AL						;almcenar el time timestamp en UUID
		
		INC SI
		INC DI
		
		MOV BL, [DI]						; verificar si se llego al final de la cadena
		CMP BL, 24h
		JNE ciclo8
		
	RET
	COPIAR ENDP
	
	ENCONTRAR PROC 
		; SI es la cadena donde se encuentra el uuid
		ciclo9:
			XOR AX,AX							;limpiar registros
			
			MOV AL, [SI]
			CMP AL, 24h
			JE retornar
			
			INC SI
			INC DI
			JMP ciclo9
			
		retornar:
		
	RET
	ENCONTRAR ENDP


	
	CALCULAR PROC 
	
		MOV AH,2AH   							; se obtiene la fecha del sistema
		INT 21H
		
		MOV mes, DH								;guardar el mes
		MOV dia, DL								;guardar el dia

	;----------------------------------------------calcular la diferencia de años y pasarla a segundos ------------------------------------------------------------------------

		SUB CX,7B2h								; restar a los años los años de la fecha base
		
		XOR BX, BX								;limpiar registros
		
		MOV BL,CL								;mover la diferencia para poder guardarla en la cadena
		CALL SEPARAR							; la diferencia pasarla a digitos por medio de los contadores
		
		LEA SI,years							;instanciar
		
		CALL ASIGNAR
		
		MOV x,16Dh								; el numero por el que se va multiplicar 
		MOV largo, 03h							; el largo del resultado
		LEA SI, years							
		CALL MULTIPLICAR
		
		MOV x,18h
		LEA SI, years							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, years							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, years							
		CALL MULTIPLICAR
		
	;----------------------------------------------calcular la diferencia de meses y pasarla a segundos ------------------------------------------------------------------------

		SUB mes,01h
		
		XOR BX,BX									;limpiar registros
		;falta validar si es 0
		MOV BL,mes
		CALL SEPARAR
		
		LEA SI,months							;instanciar
		CALL ASIGNAR
		
		MOV x,01Eh								; el numero por el que se va multiplicar, de dias a minutos 1 min es 86400 segundos
		MOV largo, 03h							; el largo del resultado
		LEA SI, months							
		CALL MULTIPLICAR
		
		MOV x,18h
		LEA SI, months							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, months							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, months							
		CALL MULTIPLICAR
		
	;----------------------------------------------calcular la diferencia de dias y pasarla a segundos ------------------------------------------------------------------------
		
		SUB dia,01h
		
		XOR BX,BX									;limpiar registros
		;falta validar si es 0
		MOV BL,dia
		CALL SEPARAR
		
		LEA SI,days								;instanciar
		CALL ASIGNAR
		
		MOV BL, contadorC						; pasar las centenas al resultado de los años
		MOV [SI], BL
		
		MOV x,18h								; el numero por el que se va multiplicar, de dias a minutos 1 min es 86400 segundos
		MOV largo, 03h							; el largo del resultado
		LEA SI, days							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, days							
		CALL MULTIPLICAR
		
		MOV x,03Ch
		LEA SI, days							
		CALL MULTIPLICAR
		
	;---------------------------------------------- tomar captura de la hora de la computadora------------------------------------------------------------------------	
		
		MOV AH,2CH    								; obtenemos la hora del sistema
		INT 21H
		
		MOV minuto, CL								;se guardar los tiempor en variables
		MOV segundo, DH
		
	;---------------------------------------------- calcular la diferencia en hora a segundos------------------------------------------------------------------------	

		XOR BX,BX									;limpiar registros
		;falta validar si es 0
		MOV BL,CH
		CALL SEPARAR
		
		LEA SI,horas								;instanciar
		CALL ASIGNAR
		
		MOV x,0E10h									; el numero por el que se va multiplicar 
		MOV largo, 03h								; el largo del resultado
		LEA SI, horas							
		CALL MULTIPLICAR
		
	;---------------------------------------------- calcular la diferencia en minutos a segundos------------------------------------------------------------------------

		XOR BX,BX									;limpiar registros
		;falta validar si es 0
		MOV BL,minuto
		CALL SEPARAR
		
		LEA SI,minutos								;instanciar
		CALL ASIGNAR
		
		MOV x,03Ch									; el numero por el que se va multiplicar 
		MOV largo, 03h								; el largo del resultado
		LEA SI, minutos							
		CALL MULTIPLICAR
		
	;---------------------------------------------- pasar los segundos a la cadena ---------------------------------------------------------------------------------

		XOR BX,BX									;limpiar registros
		;falta validar si es 0
		MOV BL,segundo
		CALL SEPARAR
		
		LEA SI,segundos								;instanciar
		CALL ASIGNAR
		
	;----------------------------------------------sumar cadenas ----------------------------------------------------------------------------------------------------

		LEA SI, years
		LEA DI, months
		CALL SUMAR
		
		LEA SI, years
		LEA DI, days
		CALL SUMAR
		
		LEA SI, years
		LEA DI, horas
		CALL SUMAR
		
		LEA SI, years
		LEA DI, minutos
		CALL SUMAR
		
		LEA SI, years
		LEA DI, segundos
		CALL SUMAR
		
	RET
	CALCULAR ENDP
	

	MULTIPLICAR PROC NEAR
		MOV i, 00h						; inicializar variables
		MOV carry, 00h
	
		ciclo2:
			XOR AX,AX					;limpiar registros
			XOR BX,BX
			
			MOV AX,x					;multiplicar el contador con el resultado que se lleva
			MOV BL,[SI]
			MUL BX
			ADD AX,carry				; sumarle el carry 	
			
			XOR DX,DX					; limpiar registros
			XOR BX,BX			
			
			MOV BX, 0Ah					; dividir entre 10 para poder calcular cual se pone en el resutlado y cual se almacena en carry
			DIV BX		
			
			MOV carry, AX				; el mood se le coloca a el resultado y el div al carry 
			MOV [SI], DL	
			
			INC i	
			
			XOR BX,BX					;limpiar registros
			XOR AX,AX	
			
			MOV BX, i
			MOV AX, largo			
			CMP AX, BX		
			JNE aumentar
			JMP ciclo3		
		aumentar:
			INC SI
		JMP ciclo2	
		ciclo3:
			XOR AX,AX
			
			MOV AX, carry					;verificar que el carry sea distinto a 0

			CMP AL, 00h
			JE terminar		
			
			INC SI							; incrementar el si para poder poner el carry
			
			XOR BX,BX						; limpiar registro
			XOR DX,DX 	
			
			MOV BX, 0Ah						;por si el carry es mayor a 10 ir poniendo solo los digitos con el mood y div
			DIV BX		
			
			MOV carry, AX					; el mood se pone al si y el div se pone al carry
			MOV [SI], DL
			INC largo						; se incrementa el largo del resultado
			
		JMP	ciclo3 
		terminar:
	RET
	MULTIPLICAR ENDP

	SEPARAR PROC NEAR
		MOV contadorC,00h
		MOV contadorD,00h
		MOV contadorU,00h

	
		SepararCentecima:
			CMP BL,63h							;comparar si si el numero es menor a 99
			JLE	SepararDecimas					;si es menor o igual ir a separar decimas 
			SUB BL, 64h							;se le resta 100 al numero 
			INC contadorC						;se cuenta cuantas veces se le resta el numero
			CMP BL, 63h							;se compara el numero con 99
			JLE SepararDecimas					;si es menor a 99 se va ir a separar decimas 
			JMP SepararCentecima				;si no es menor se va a repetir la etiqueta	
		
		SepararDecimas:
			CMP BL, 09h							;comparar el numero en b		
			JLE Terminar2						; si el numero es menor a 9 se va ir a imprimir 
			SUB BL, 0AH							;si es mayor a 9 se le resta 10 
			INC contadorD						; se cuenta cuantas veces se le resta 10
			CMP BL, 09h							;se compara con 9 el numero en bx
			JLE Terminar2						;si el numero es menor a 9 se va a imprimir 
			JMP SepararDecimas					;si el numero no es menor se vuelve a llamar a separr decimas 
			
		Terminar2:
			
			MOV contadorU,BL					; se pasan las unidadees al contador de unidades

	RET
	SEPARAR ENDP
	
	IMPRIMIR PROC 
		MOV x,00h							;inicializar variables
		ciclo4:
			XOR AX,AX						;limpiar registros
			MOV AL,[SI]						; mover a al si 
			CMP AL,24h						; comparar que no sea $
			JE decrementar					; se va a imprimir
			INC SI							;incrementar registros
			INC x
		JMP ciclo4
		decrementar:						;decrementar
			DEC SI	
		ciclo5:
			XOR AX,AX						;limpiar registros
			MOV AX, x						; mover contador a al
			CMP AL,00h						; comparar que no se 0
			JE final 						; salirser del ciclo
			MOV AH,02h						; imprimir caracter
			MOV DL,[SI]
			ADD DL,30h
			INT 21h
			DEC x							;decrementar variables
			DEC SI
		JMP ciclo5
		final:
	RET
	IMPRIMIR ENDP
	
 
	
	SUMAR PROC 
		;SI va ser el numero mas grande
		MOV carry, 00h
		MOV contSuma,00h
		ciclo6:
			XOR AX,AX					;limpiar registros
			XOR BX,BX
			XOR DX,DX
			
			MOV DL,[SI]					; mover lo que contenga SI  a DL
			CMP DL,24h					; verficar si lo que tenga SI es igual a dolar, si es igual a dolar se va incrementar un contador de suma sino se va a la opcion 2
			JE incrementar1				
			JMP opcion2
			
			incrementar1:
				INC contSuma
			
			opcion2:					; mover lo que contenga DI  a DH			
			MOV DH,[DI]					; verficar si lo que tenga SI es igual a dolar, si es igual a dolar se va incrementar un contador de suma sino se va a la opcion 2
			CMP DH,24h
			JE incrementar2
			JMP verificar
			
			incrementar2:
				INC contSuma
			
			
			verificar:
				MOV BL,contSuma
				CMP BL, 00h
				JE sumar2
				CMP BL, 01h
				JE sumar1
				JMP ciclo7
				
			sumar1:
				MOV AL,[SI]
				ADD AX,carry				; sumarle el carry 	
				
				XOR DX,DX					; limpiar registros
				XOR BX,BX	
				
				XOR DX,DX					; limpiar registros
				XOR BX,BX			
			
				MOV BX, 0Ah					; dividir entre 10 para poder calcular cual se pone en el resutlado y cual se almacena en carry
				DIV BX		
				
				MOV carry, AX				; el mood se le coloca a el resultado y el div al carry 
				MOV [SI], DL	
				
				INC DI
				INC SI
			
				JMP Fin
				
			sumar2:
				MOV AL,[DI]					;multiplicar el contador con el resultado que se lleva
				MOV BL,[SI]
				ADD AL,BL
				ADD AX,carry				; sumarle el carry 	
				
				XOR DX,DX					; limpiar registros
				XOR BX,BX			
				
				MOV BX, 0Ah					; dividir entre 10 para poder calcular cual se pone en el resutlado y cual se almacena en carry
				DIV BX		
				
				MOV carry, AX				; el mood se le coloca a el resultado y el div al carry 
				MOV [SI], DL	
				
				INC DI
				INC SI
				
				JMP Fin
			Salir:
				JMP ciclo7
			Fin:
	
		JMP ciclo6	
		ciclo7:
			XOR AX,AX
			
			MOV AX, carry					;verificar que el carry sea distinto a 0

			CMP AL, 00h
			JE terminar1		
			
			INC SI							; incrementar el si para poder poner el carry
			
			XOR BX,BX						; limpiar registro
			XOR DX,DX 	
			
			MOV BX, 0Ah						;por si el carry es mayor a 10 ir poniendo solo los digitos con el mood y div
			DIV BX		
			
			MOV carry, AX					; el mood se pone al si y el div se pone al carry
			MOV [SI], DL
	
		JMP	ciclo7 
		terminar1:
	RET
	SUMAR ENDP
	
	ASIGNAR PROC 
		MOV BL, contadorU						;pasar las unidades al resultado de los años
		MOV [SI], BL
		INC SI
		
		MOV BL, contadorD						;pasar las decenas al resultado de los años
		MOV [SI], BL
		INC SI
		
		MOV BL, contadorC						; pasar las centenas al resultado de los años
		MOV [SI], BL
	RET
	ASIGNAR ENDP


	;finalizar el programa
	finalizar:
	MOV AH, 4ch
	INT 21h
	
end program