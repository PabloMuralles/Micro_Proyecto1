model small								;declaracion de modelo
.data										;inicia segmento de datos
 
	timeStamp DB 500 DUP('$') 
	years DB 500 DUP('$') 
	moths DB 500 DUP('$') 
	days DB 500 DUP('$') 
	horas DB 500 DUP('$') 
	minutos DB 500 DUP('$') 
	segundos DB 500 DUP('$') 
	contadorC DB 00h
	contadorD DB 00h
	contadorU DB 00h
	;mes DB 00h
	;dia DB 00h
	carry DW 00h
	i DW 00h
	x DB 00h
	largo DW 01h
	
.stack						
.code 

program: 
	MOV AX,@DATA							;obtenemos la direccion de inicio
	MOV DS,AX								; iniciliza el segmento de datos
 

	MOV AH,2AH   							; se obtiene la fecha del sistema
	INT 21H
	
	SUB CX,7B2h
	
	
	XOR BX, BX								;limpiar registros
	
	MOV BL,CL								;mover la diferencia para poder guardarla en la cadena
	CALL SEPARAR							; la diferencia pasarla a digitos por medio de los contadores
	
	LEA SI,years							;instanciar
	MOV BL, contadorU						;pasar las unidades al resultado de los años
	MOV [SI], BL
	INC SI
	
	MOV BL, contadorD
	MOV [SI], BL
	INC SI
	
	MOV BL, contadorC
	MOV [SI], BL
	
	LEA SI, years
	MOV AH,02h              
	MOV DL, [SI]
	ADD DL, 30h	
	INT 21h
	INC SI
	
	MOV AH,02h              
	MOV DL, [SI]
	ADD DL, 30h	
	INT 21h
	INC SI
	
	MOV AH,02h              
	MOV DL, [SI]
	ADD DL, 30h	
	INT 21h
	
	

	

	JMP finalizar
	
	
	

	MULTIPLICAR PROC NEAR
		MOV i, 00h						; inicializar variables
		MOV carry, 00h
		;LEA SI, resultadoTemp
		ciclo2:
			XOR AX,AX					;limpiar registros
			XOR BX,BX
			
			MOV AL,x					;multiplicar el contador con el resultado que se lleva
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



	;finalizar el programa
	finalizar:
	MOV AH, 4ch
	INT 21h
	
end program