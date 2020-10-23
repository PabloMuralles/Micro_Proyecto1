.model small								;declaracion de model
.data									;inicia segmento de datos
 
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
	contUUI DB 01h
	random DB 00h
	TextoOpcion DB 'Seleccione opcion, 1 = Generar UUID , 2 = Validar UUID , 3 = Salir: ',13,10,'$'
	TextoIncial DB '--------------------------PROYECTO MICROPROGRAMACION----------------------------',13,10,'$'
	texto1 DB 13,10,'Ingrese un UUID:',13,10,'$'
    error DB 13,10,'Codigo invalido$'
	correcto DB 13,10,'Codigo valido$'
	TextoEnter DB 13,10,'$'
	TextoMenu DB 13,10,'Ingrese 4 para ver el menu:',13,10,'$'
	
.stack						
.code 

program: 
	MOV AX,@DATA							;obtenemos la direccion de inicio
	MOV DS,AX								; iniciliza el segmento de datos
	
	MOV AX, 600h
    MOV BH, 07h
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h							;Limpieza de consola
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 00h
    MOV DL, 00h
    INT 10h
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
	
	
	MOV DX, offset TextoIncial ; impresión de mensaje de ingreso
	MOV AH, 09h
	INT 21h
	
	MOV DX, offset TextoOpcion ; impresión de mensaje de ingreso
	MOV AH, 09h
	INT 21h
	
	;		Leer numero
	MOV AH,01h			;Se escribe la interrupciòn para escribir en teclado.
	INT 21H
	
	
	
	CMP AL,31h
	JE Creacion			;Etiqueta para crear UUID
	
	CMP AL,32h
	JE Validacion			;Etiqueta para crear UUID
	
	CMP AL,33h
	JE finalizar			;Genera el menu otra vez 

Creacion:
	
	CALL PARTE1				;creaciòn de UUID
	JMP finalizar
	
Validacion:
	
	CALL PARTE2				;validaciòn de UUID
	JMP finalizar
	
	;finalizar el programa
FinalizarPrograma proc near 
	
	MOV DX, offset TextoMenu ; impresión de mensaje de ingreso
	MOV AH, 09h
	INT 21h
	;		Leer numero
	MOV AH,01h			;Se escribe la interrupciòn para escribir en teclado.
	INT 21H
	CMP AL, 34h
	JE program
	JNE finalizar
	
	finalizar:
	MOV AH, 4ch
	INT 21h
	RET
	FinalizarPrograma ENDP

	
PARTE1 PROC	

	CALL CALCULAR							; se calcula el primer timestamp
	
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
	
	MOV AH,2CH    								; obtenemos la hora del sistema
	INT 21H
	
	MOV random, DH								;guardamos los segundos
	
	XOR CX,CX 		
	MOV CL, 24h		
	
	LEA SI, UUID
	
	MOV DX, offset TextoEnter ; impresión de mensaje de ingreso
	MOV AH, 09h
	INT 21h
	
	ciclo10:
		XOR AX,AX 								;limpiar registros
		XOR BX,BX				
		XOR DX,DX
		
		CMP CL,1Ch								;se compara si se esta en la posicion donde debe de ir un guion
        JE signo
        
        CMP CL,17h								;se compara si se esta en la posicion donde debe de ir un guion
        JE signo
        
        CMP CL,12h								;se compara si se esta en la posicion donde debe de ir un guion
        JE signo
        
        CMP CL,0Dh								;se compara si se esta en la posicion donde debe de ir un guion
        JE signo
		
		CMP CL,16h								;se compara si se esta en la posicion donde debe de ir un 1
		JE numero1
		
		CMP CL,11h								;se compara si se esta en la posicion donde puede ir 8,9,a,b
		JE numero2
		JMP procedimiento
		
       
        signo:
		MOV AH, 02h								; se imprimir el guion
		MOV DL, 02Dh		
		INT 21h
		JMP continuar
  
        numero1:
        MOV AH, 02h								; se imprimir el guion
		MOV DL, 31h		
		INT 21h
		JMP continuar
		
		numero2:
		CALL NUM2								;se llama a la funcion y se imprimir un numero del rango
		JMP continuar
	
        procedimiento:							; se imprimir un numero en base al timestamp para generar el uuid
        MOV AL,[SI]
		MOV BL,contUUI
		MUL BL
		
		XOR BX,BX
		MOV BL,10h
		
		DIV BX
		
		XOR BX,BX
		MOV BL,DL
		
		CALL IMPRIMIR2

        continuar:								; incrementar el contador y el si
		INC SI
		INC contUUI
	
	LOOP ciclo10
	
	CALL FinalizarPrograma								

	NUM2 PROC 
		; procedimiento que calcula el numero que puede ser 8,9,a,b
		
		MOV AL,[SI]
		ADD AL,random
		
		step:
		
		XOR BX,BX					;calcular el mood con restas
		MOV BL,04h
		SUB AX,BX
		CMP AX,00h
		JL guardar
		JMP step
		
		guardar:
		ADD AX,BX
		MOV BL,AL
		
		CALL IMPRIMIR3
		
		
	RET
	NUM2 ENDP
	
	
	IMPRIMIR3 PROC 
		; en base al mood de num2 se imprime alguno de las posibilidades 8,9,a,b
		CMP BL,01h
		JE result1
		
		CMP BL,02h
		JE result2
		
		CMP BL,03h
		JE result3
		JMP result4
		
		result1:
			MOV AH, 02h								
			MOV DL, 38h		
			INT 21h
			JMP retornars1
		
		result2:
			MOV AH, 02h								
			MOV DL, 39h
			INT 21h
			JMP retornars1
			
		result3:
			MOV AH, 02h								
			MOV DL, 61h	
			INT 21h
			JMP retornars1
			
		result4:
			MOV AH, 02h								
			MOV DL, 62h		
			INT 21h
			JMP retornars1
		
		retornars1:
		
		
	RET
	IMPRIMIR3 ENDP
	
	IMPRIMIR2 PROC 
		; procedimiento que imprime numeros del 0 al 9 y los numero del 10 al 15 en letras 
		CMP BL,09h
		JLE resultado1
		JMP resultado2
		
		resultado1:
			MOV AH, 02h								
			MOV DL, BL	
			ADD DL, 30h		
			INT 21h
			JMP retornars
		
		resultado2:
			MOV AH, 02h								
			MOV DL, BL	
			ADD DL, 57h		
			INT 21h
			JMP retornars
		
		retornars:
	RET
	IMPRIMIR2 ENDP
	
	
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
		ciclo5:
			XOR AX,AX						;limpiar registros
			MOV AL,[SI]
			CMP AL,24h
			JE final
			MOV AH,02h						; imprimir caracter
			MOV DL,[SI]
			ADD DL,30h
			INT 21h
			INC SI
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


RET
	PARTE1 ENDP
	
PARTE2 PROC	
	    
     ;imprimir la instruccion al usuario
    MOV DX, offset texto1
    MOV AH, 09h
    INT 21h
    
    
    XOR CX,CX
    MOV CL, 24h
    
    
    Evaluar:
        XOR AX,AX
        XOR BX,BX
        
        ;leer segundo digito
        MOV AH, 01h
        INT 21h
        
        MOV BL, AL                            ; se lo sumo a num1
        
        CMP CL,1Ch
        JE signoP2
        
        CMP CL,17h
        JE signoP2
        
        CMP CL,12h
        JE signoP2
        
        CMP CL,0Dh
        JE signoP2
        
        CMP CL,16h                              ;se compara si se esta en la posicion donde debe de ir un 1
        JE numeros1
        
        CMP CL,11h                              ;se compara si se esta en la posicion donde puede ir 8,9,a,b
        JE procedimiento2
        JMP procedimiento3
        
        signoP2:
        CMP BL,2Dh
        JZ continuarP2
        JNE Mostrar
        
        numeros1:
        CMP BL,31h
        JE continuarP2
        JNE Mostrar
        
        procedimiento2:
        CALL DISP2
        JMP continuarP2
        
        procedimiento3:
        CALL DISP
        
        continuarP2:
        
    LOOP Evaluar
	 
	JMP Bien
  Mostrar:
    ;imprimir error
    MOV DX, offset error
    MOV AH, 09h
    INT 21h
	CALL FinalizarPrograma
  Bien:
	 MOV DX, offset correcto
    MOV AH, 09h
    INT 21h
	CALL FinalizarPrograma
    
    DISP2 PROC
        CMP BL,38h
        JZ Repay2
        CMP BL,39h
        JZ Repay2
        CMP BL,61h
        JZ Repay2
        CMP BL,62h
        JNE Mostrar
        Repay2:
    
    RET
    DISP2 ENDP
    
    
    DISP PROC
        CMP BL,30h
        JZ Repay
        CMP BL,31h
        JZ Repay
        CMP BL,32h
        JZ Repay
        CMP BL,33h
        JZ Repay
        CMP BL,34h
        JZ Repay
        CMP BL,35h
        JZ Repay
        CMP BL,36h
        JZ Repay
        CMP BL,37h
        JZ Repay
        CMP BL,38h
        JZ Repay
        CMP BL,39h
        JZ Repay
        CMP BL,61h
        JZ Repay
        CMP BL,62h
        JZ Repay
        CMP BL,63h
        JZ Repay
        CMP BL,64h
        JZ Repay
        CMP BL,65h
        JZ Repay
        CMP BL,66h
        JZ Repay
        JNE Mostrar
        Repay:
    
    RET
    DISP ENDP
    
	 
    RET
    PARTE2 ENDP
    
end program