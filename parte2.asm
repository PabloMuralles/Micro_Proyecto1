.model small                                ;declaracion de modelo
.data                                        ;inicia segmento de datos
 
    texto1 DB 'hola$'
    error DB 'Error$'
    
.stack                        
.code 

 

program: 
    MOV AX,@DATA                            ;obtenemos la direccion de inicio
    MOV DS,AX                                ; iniciliza el segmento de datos
    
    
    ;imprimir la instruccion al usuario
    MOV DX, offset texto1
    MOV AH, 09h
    INT 21h
    
    ;imprimir salto de linea
    MOV DL, 0AH
    MOV AH, 02h
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
        JE signo
        
        CMP CL,17h
        JE signo
        
        CMP CL,12h
        JE signo
        
        CMP CL,0Dh
        JE signo
		
		CMP CL,16h								;se compara si se esta en la posicion donde debe de ir un 1
		JE numeros1
		
		CMP CL,11h								;se compara si se esta en la posicion donde puede ir 8,9,a,b
		JE procedimiento2
		JMP procedimiento
        
        signo:
        CMP BL,2Dh
        JZ continuar
        JNE Mostrar
		
		numeros1:
		CMP BL,31h
		JE continuar
		JNE Mostrar
        
        procedimiento2:
		CALL DISP2
		JMP continuar
		
        procedimiento:
        CALL DISP
        
        continuar:
        
    LOOP Evaluar

 

    Mostrar:
    ;imprimir salto de linea
    MOV DL, 0AH
    MOV AH, 02h
    INT 21h
    
    ;imprimir error
    MOV DX, offset error
    MOV AH, 09h
    INT 21h

 

    Finalizar:
    ;finalizar el programa
    MOV AH, 4ch
    INT 21h
    
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
    

 

end program