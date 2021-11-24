.data
Sol: .word 0,1,2,3,4,5,6,120,121
.space 28
Ec:.word 0,0,0,0,0
.space 12
Ec1:.word 0,0,0,0,0
.space 12
Vector: .word 3,0

VectorA: .word 0,0,0,0,0,0

VectorX: .word 0,2
.space 4
VectorY: .word 0,1
.space 16
Palabra: .asciiz "2x+y=1"
.space 4
Palabra1: .asciiz "4x+2y=2"
.align 2

VAItoa:.word 0,0,0,0
VAStr:.ascii
.space 160
StrSol: .asciiz ""
.space 160
.text
Main:
#mirar error linea 474
la $a0,Palabra
la $a1,Palabra1
la $a2,StrSol
jal ResuelveSistema
li $v0,10
syscall

ResuelveSistema:
	


	add $s0,$a0,$zero # String con la ecuacion 1 -> $s0
	add $s1,$a1,$zero # String con la ecuacion 2 -> $s1
	add $s2,$a2,$zero # Direccion de memoria donde guardaremos la solucion en String
	
	add $a0,$s0,$zero
	la $a1,Ec #Ec = vector ecuacion
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal String2Ecuacion
	lw $ra,($sp)
	addi $sp,$sp,4
	
	bne $v0,0,SalErr
	
	add $s0,$a1,$zero #Ec ecuacion 1 -> $s0 (el String con la ecuacion no lo vamos a volver a usar, por eso reutilizamos su registro)
	
	add $a0,$s1,$zero
	la $a1,Ec1
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal String2Ecuacion
	lw $ra,($sp)
	addi $sp,$sp,4
	
	bne $v0,0,SalErr

	add $s1,$a1,$zero #Ec ecuacion 2 -> $s1 (el string con la ecuacion no lo vamos a volver a usar, por eso reutilizamos su registro)
	#$s0 ->Ec ecuacion1
	#$s1 ->Ec ecuacion2
	#$a2 ->Direccion de Sol solucion
	
	add $a0,$s0,$zero
	add $a1,$s1,$zero
	la $a2,Sol
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal Cramer
	lw $ra,($sp)
	addi $sp,$sp,4
	
	add $a0,$a2,$zero
	add $a1,$s2,$zero
	addi $sp,$sp,-4
	sw $ra,($sp)
	#$a0<-Solucion solucion
	#$a1<-String solucion
	jal Solucion2String
	lw $ra,($sp)
	addi $sp,$sp,4
	
	SalErr: jr $ra
String2Ecuacion:
	addi $sp,$sp,-32
	sw $s0,28($sp)
	sw $s1,24($sp)
	sw $s2,20($sp)
	sw $s3,16($sp)
	sw $s4,12($sp)		
	sw $s5,8($sp)
	sw $s6,4($sp)
	sw $s7,0($sp)
	
	li $s3,0#variable donde guardamos el dato anterior para comprobar 2 letras seguidas o letra seguida de numero
	li $v0,0#en este registro se guarda el codigo de error
	li $s2,0 #variable global para si hay = o nó
	li $t9,0 #variable usada para multiplicar los numeros que nos van llegando 
	li $t3,0 #variable donde se almacenla la direccion de palabra despues de haber encontrado un =
	li $t4,0
	add $t4,$t4,$a0
	Recorre:
	 	li $t5,0 #variable donde guardamos el valor de $a0 antes de pasar a CompruebaDato
	 	li $t6,0#variable donde guardamos el dato siguiente por si hay error
	 	li $s6,0 #se pone a -1 si hemos tenido que restar 1 al numero porque se sale de rango pero es valido (IsNeg L3)
 		li $s5,1 # 1-> no hay un - // -1 -> hay un -
		li $t9,10#cargamos un 10 para usarlo en la multiplicacion
		li $s1,0 #variable global para si hay un numero o letra
		li $s4,0#variable global para si ha habido um signo
		la $s0,Vector
		sw $zero,($s0)#cargamos en la primera posicion de Vector un 0
		add $a2,$a0,$zero#copiamos en a2 la direccion de a0 (palabra)
		B:
			
			lb $t1,($a0)#cargamos en t1 cada caracter de palabra
			add $t5,$a0,$zero
			add $a0,$t1,$zero
			addi $sp,$sp,-4
			sw $ra($sp)
			jal CompruebaDato
			lw $ra,($sp)
			addi $sp,$sp,4
			add $a0,$t5,$zero
			
			
			beq $v1,1,Zero
			beq $v1,2,Space
			beq $v1,3,Plus
			beq $v1,4,Minus
			beq $v1,5,Equal
			beq $v1,6,CP
			beq $v1,7,Error
			# blt $t1,48,Men
			# bgt $t1,57,May
			beq $t4,$a0,Pasa
			bgt $s3,61,Error
			add $s3,$t1,$zero
		Pasa:
			
			li $s1,1 #cargamos un 1 en sq porque hemos metido un numero
			addi $a0,$a0,1 #nos movemos una posicion en la cadena
			addi $t1,$t1,-48 #conversion de ASCII a int
			lw $t0,($s0) #cargamos el valor del Vector (usado para acumular el numero en caso de tener más de una cifra)
			beq $t0,214748364,Maxim #comparacion de igualdad con el maximo/10
			bgt $t0,214748364,ErrorTam #comparacion de superioridad con el maximo/10
			Conti:	
				mult $t0,$t9 #acumulador*10
				mflo $t0
				add $t0,$t0,$t1 #acumulador + nuevo numero
				sw $t0,($s0) #guardamos en vector
				j B
			
			IsNeg:
				
				add $t5,$a0,$zero
				lb $a0,($t5)
				addi $sp,$sp,-4
				sw $ra,($sp)
				jal CompruebaDato
				lw $ra,($sp)
				addi $sp,$sp,4
				add $a0,$t5,$zero
				beq $v1,6,SiL
				beq $s2,0,W1
				beq $s5,1,ErrorTam
				li $s6,-1
				addi $t1,$t1,-1
				j Conti
			
				W1:
					beq $s5,-1,ErrorTam
					li $s6,-1
					addi $t1,$t1,-1
					j Conti
				SiL:
					beq $s2,0,W2
					beq $s5,-1,ErrorTam
					li $s6,-1
					addi $t1,$t1,-1
					j Conti
			
					W2:
						beq $s5,1,ErrorTam
						li $s6,-1
						addi $t1,$t1,-1
						j Conti
			Maxim:
				blt $t1,8,Conti
				beq $t1,8,IsNeg
				j ErrorTam
		
			#el caracter en $t0 es menor de 48
			#Men:
			#	beq $t1,0,Zero
			#	beq $t1,32,Space
			#	beq $t1,43,Plus
			#	beq $t1,45,Minus
			#	j Error
			
			#el caracter en $t0 es 0 (fin de cadena)	
			Zero:
				bne $s2,1,Error #si no hemos encontrado un =, error
				
				beq $a0,$t3,Error  #si la direccion de memoria a0 apunta a t3 significa que hay un 0 en la posicion siguiente del =
				
				j FinC
			
			

			Space:
				add $s3,$t1,$zero
				# bne $s1,0,Error -> no funciona porque al volver a recorre $s1 se inicializa a 0 y por tanto puede haber espacios no detectados entre los bloques
				bne $t4,$a0,Error
				addi $t4,$t4,1
				addi $a0,$a0,1
				j B
			
			Plus:
				add $s3,$t1,$zero
				#$s4 = 1 si ha habido algun signo antes, vamos a Mira
				beq $s4,1,Mira
				SiguePlus:
					beq $s1,1,MiraSigno #$s1 = 1 si hemos metido un numero o letra antes del signo en este bloque
					addi $a0,$a0,1
					li $s4,1
					j B
				
			Mira: #si s1 = 0, son 2 signos seguidos (error)// si no, en el bloque tenemios +c+ || +c- || -c+ || -c-
				beq $s1,0,Error
				j SiguePlus
			
			Minus:
				add $s3,$t1,$zero
			#igual que Plus
				beq $s4,1,MiraM
				SigueMinus:	
					beq $s1,1,MiraSigno
					addi $a0,$a0,1
					li $s4,1
					li $s5,-1#al ser el numero negativo, se carga -1 para posteriormente hacer la multiplicacion
					j B
				MiraM:
					beq $s1,0,Error
					j SigueMinus		
			
			Error: 
				li $v0,1
				j Final
			ErrorTam: 
				li $v0,2
				j Final
			ErrorOverflow:
				li $v0,3
				j Final
			ErrorNumIncognitas:
				li $v0,4
				j Final
			May:#si pasa las instrucciones de control, es una letra mayuscula
				beq $t1,61,Equal
				blt $t1,65,Error
				bgt $t1,90,May1 
			
		
		
			#cp solo funciona para cuando el dato que hemos detectado en t1 es una letra, por tanto fin de bloque y actualizacion de ecuacion (a1)	
			CP:	
				beq $t4,$a0,Pasa1
				bgt $s3,61,Error
				
			Pasa1:
				add $s3,$t1,$zero
				#beq $s3,1,Error
				#li $s3,1 #hemos encontrado un caracter
				#s2=0 -> a la izquierda de = -> s7=1
				#s2=1 -> a la derecha de = -> s7 = -1
				beq $s2,1,Menos
				li $s7,1
				j Sig
				Menos:
					li $s7,-1	
					Sig:
						#acceso a ecuacion en la posicion x
						addi $a1,$a1,12
						lw $t2,($a1)
						addi $a1,$a1,-12
			
						#si ecuacion(x) == 0 ->celda vacia -> IsX
						beq $t2,0,IsX
						#si la incognita ya está en la ecuacion -> IsX
						beq $t1,$t2,IsX

						#acceso a ecuacion en la posicion y
						addi $a1,$a1,16
						lw $t2,($a1)
						addi $a1,$a1,-16
			
						#si ecuacion(y) == 0 ->celda vacia -> IsY
						beq $t2,0,IsY
						#si la incognita ya está en la ecuacion -> IsY
						beq $t1,$t2,IsY
			
						#hay mas de 2 incognitas detectadas -> error
			
						j ErrorNumIncognitas
			
			May1:#si pasa las instrucciones de control, es una letra minuscula
				blt $t1,97,Error
				bgt $t1,122,Error
				j CP
			
		
			Equal:
				add $s3,$t1,$zero
				beq $s2,1,Error
				li $s2,1 #detectamos que existe un =
				addi $a0,$a0,1 
				add $t3,$a0,$zero #copia la direccion de a0 en la posicion siguiente al espacio en t3
				lw $t0,($s0) #si el dato s0 (vector acumulador) != 0, TIE
				bne $t0,0,TIE
				j B
			
			IsX:
				addi $a1,$a1,12
				sw $t1,($a1)
				addi $a1,$a1,-12
				#si vector(0)==0, el bloque es de la forma "x", es decir, "1*x" -> t0 = 1 aunque esté omitido en palabra
				lw $t0,($s0)
				bne $t0,0,SigX
				li $t0,1
				SigX:
			
					lw $t2,($a1)
					#*1 si no hemos detectado -
					#*-1 si hemos detectado -
					mult $t0,$s5
					mflo $t0
					#*-1 si hemos pasado el =
					#*1 si no hemos pasado el =
					mult $t0,$s7
					mflo $t0
					#- 1 si num = min && hemos pasado el =
					add $t0,$t0,$s6
			
					addi $sp $sp,-4
					sw $ra,($sp)
					jal CompruebaSuma
					lw $ra($sp)
					addi $sp,$sp,4
					beq $v1,1,ErrorOverflow
					
					sw $t0,($a1)
					addi $a0,$a0,1
					j Recorre
			
			IsY:
				addi $a1,$a1,16
				sw $t1,($a1)
				addi $a1,$a1,-16
				#si vector(0)==0, el bloque es de la forma "y", es decir, "1*y" -> t0 = 1 aunque esté omitido en palabra
				lw $t0,($s0)
				bne $t0,0,SigY
				li $t0,1
				SigY:
					addi $a1,$a1,4
					lw $t2,($a1)
			
					#*1 si no hemos detectado -
					#*-1 si hemos detectado -
					mult $t0,$s5
					mflo $t0
					#*-1 si hemos pasado el =
					#*1 si no hemos pasado el =
					mult $t0,$s7
					mflo $t0
					#- 1 si num = min && hemos pasado el =
					add $t0,$t0,$s6
			
					addi $sp $sp,-4
					sw $ra,($sp)
					jal CompruebaSuma
					lw $ra($sp)
					addi $sp,$sp,4
					beq $v1,1,ErrorOverflow
					sw $t0,($a1)
					addi $a0,$a0,1
					addi $a1,$a1,-4
					j Recorre
		
		
			FinC:
				#cargammos en $t0 el numero que tenemos en el vector
				lw $t0,($s0)
				addi $a1,$a1,8
				#si el numero es negativo (tiene un - delante en la cadena) $s5 = -1 y por tanto $t0 * -1
				mult $t0,$s5
				mflo $t0
				#cargamos en $t2 el numero que tenemos en la posicion c de la ecuacion
				lw $t2,($a1)
			
				#si num = min *-1, se le habrá restado 1 para que no se salga de rango. En ese caso $s6 = -1 y por tanto $t0 =min
				add $t0,$t0,$s6
				#guardamos ra en la pila para la llamada a funcion
				addi $sp $sp,-4
				sw $ra,($sp)
				jal CompruebaSuma
				lw $ra($sp)
				addi $sp,$sp,4
				beq $v1,1,ErrorOverflow
				#guardamos el resultado de la suma en la posicion c de la ecuacion y finalizamos el programa
				sw $t0,($a1)
				addi $a1,$a1,-8
				j Final
			

		
					
			MiraSigno:
				#$s2 = 0 si no hay '=' y por tanto c tiene que ser negativo
				beq $s2,0,Neg
				li $s7,1
				j TI
				Neg:
					li $s7,-1
				TI:
					lw $t0,($s0)
					addi $a1,$a1,8
					lw $t2,($a1)
					#num * 1 si num>0 || num * -1 si num<0
					mult $t0,$s7
					mflo $t0
					
					mult $t0,$s5
					mflo $t0
					
					#num + -1 si num = min || num + 0 si num != min
					add $t0,$t0,$s6
			
					addi $sp,$sp,-4
					sw $ra($sp)
					jal CompruebaSuma
					lw $ra($sp)
					addi $sp,$sp,4
					beq $v1,1,ErrorOverflow
					sw $t0,($a1)
					addi $a1,$a1,-8
					j Recorre
			
			TIE:	#s7 == -1 porque el dato al que afecta no ha pasado el igual
				li $s7,-1
				lw $t0,($s0)
				addi $a1,$a1,8
				#si num<0, s7=-1 ->t0 *-1 = num
				mult $t0,$s7
				mflo $t0
				
				mult $t0,$s5
				mflo $t0
				
				#si num=min -> s6 = -1 && t0 = num -1 -> t0 -1 = num 
				add $t0,$t0,$s6
				#t2 = valor de ecuacion en la posicion c
				lw $t2,($a1)
			
				addi $sp,$sp,-4
				sw $ra($sp)
				jal CompruebaSuma
				lw $ra($sp)
				addi $sp,$sp,4
				beq $v1,1,ErrorOverflow
				sw $t0,($a1)
				addi $a1,$a1,-8
				j Recorre
			
			#comprobamos si hay overflow en la suma: pos+pos = pos // neg + neg = neg
			#si no se cumple -> error 
			CompruebaSuma:
				bne $t2,0,NoZero
				add $t0,$t0,$t2
				#esta linea da error, mirar por q
				li $v1,0
				jr $ra
				NoZero:
					slt $t7,$t0,$zero
					slt $t8,$t2,$zero
					addu $t0,$t0,$t2
					bne $t7,$t8,Sal
					slt $t9,$t0,$zero
					mult $t7,$t8
					mflo $t8
					bne $t8,$t9,ErrorSuma
					Sal:
						li $v1,0
						jr $ra
					ErrorSuma:
						li $v1,1
						jr $ra
			Final:
				lw $s7,0($sp)
				lw $s6,4($sp)
				lw $s5,8($sp)
				lw $s4,12($sp)
				lw $s3,16($sp)
				lw $s2,20($sp)
				lw $s1,24($sp)
				lw $s0,28($sp)
				addi $sp,$sp,32
				jr $ra
				
			CompruebaDato:	#$a0 ->Dato	$v1->codigo de error
				blt $a0,48,MenNum
				bgt $a0,57,MayNum
				li $v1,0
				jr $ra
				
				Err:
					li $v1,7
					jr $ra
				MenNum:
					beq $a0,0,ZeroNum
					beq $a0,32,SpaceNum
					beq $a0,43,PlusNum
					beq $a0,45,NegNum
					j Err
					
					ZeroNum:
						li $v1,1
						jr $ra
					SpaceNum:
						li $v1,2
						jr $ra
					PlusNum:
						li $v1,3
						jr $ra
					NegNum:
						li $v1,4
						jr $ra
				MayNum:
					beq $a0,61,EqNum
					blt $a0,65,Err
					bgt $a0,90,MayNum1
					li $v1,6
					jr $ra
					
					EqNum:
						li $v1,5
						jr $ra
					MayNum1:
						blt $a0,97,Err
						bgt $a0,122,Err
						li $v1,6
						jr $ra


Cramer: #$a0<-Ec1//$a1<-Ec2//$a2<-Sol solucion = output
	#Ecuacion: |a|b|c|x|y|
	#VectorA |a|b|c|a'|b'|c'|
	addi $sp,$sp,-4
	sw $s0,0($sp)
	
	lw $t1,12($a0)
	lw $t2,16($a0)
	lw $t3,12($a1)
	lw $t4,16($a1)
	beq $t1,$t3,EqX
	bne $t1,$t4,SCI
	bne $t2,$t3,SCI
	li $t0,1
	j SigCramer
	EqX:
		bne $t2,$t4,SCI
		li $t0,0
	SigCramer:
		lw $t1,0($a0) #a
		lw $t2,0($a1) #a'
		lw $t3,4($a0) #b
		lw $t4,4($a1) #b'
		lw $t5,8($a0) #c
		lw $t6,8($a1) #c'
		la $s0,VectorA
		sw $t1,0($s0)
		sw $t3,4($s0)
		sw $t5,8($s0)
		sw $t6,20($s0)
		beq $t0,1,Rotar
		sw $t2,12($s0)
		sw $t4,16($s0)		
		
		PreDet:
			la $a0,VectorX
			la $a1,VectorY
			
			lw $t0,0($s0)
			lw $t1,4($s0)
			sw $t0,0($a0)
			sw $t1,4($a0)
			
			lw $t0,12($s0)
			lw $t1,16($s0)
			sw $t0,0($a1)
			sw $t1,4($a1)
			
			addi $sp,$sp,-4
			sw $ra,0($sp)
			jal Det
			lw $ra,0($sp)
			addi $sp,$sp,4
			
			beq $v1,2,SCD
			lw $t0,8($s0)
			lw $t1,20,($s0)
			sw $t0,4($a0)
			sw $t1,4($a1)
			
			addi $sp,$sp,-4
			sw $ra,0($sp)
			jal Det
			lw $ra,($sp)
			addi $sp,$sp,4
			
			beq $v1,1,SCD
			j SI
		Rotar:
			sw $t2,12($s0)
			sw $t2,16($s0)
			j PreDet
		SCI:
			li $t0,1
			sw $t0,0($a2)
			j FinCramer
			SI:
				li $t0,2
				sw $t0,0($a2)
				j FinCramer
			SCD:
				li $t0,0
				sw $t0,0,($a2)
				j FinCramer
		FinCramer:
			lw $s0,0($sp)
			addi $sp,$sp,4
			jr $ra
	Det:
		
		lw $t0,0($a0)
		lw $t1,4($a1)
		mult $t0,$t1
		mfhi $t2
		mflo $t3
		lw $t0,0($a1)
		lw $t1,4($a0)
		mult $t0,$t1
		mfhi $t0
		mflo $t1
		beq $t0,$t2,Low
		Rg2:
			li $v1,2
			jr $ra
		Low:
			bne $t1,$t3,Rg2
			li $v1,1
			jr $ra
			
Solucion2String:#$a0 <-Solucion solucion // $a1 <- Str resultado
	addi $sp,$sp,-8
	sw $s0,0($sp)
	sw $s1,4($sp)
	
	lw $t0,0($a0)
	bne $t0,0,NSCD
	add $s0,$a0,$zero
	add $s1,$a1,$zero
	la $a0,VAItoa
	lw $t0,28($s0)
	lw $t1,4($s0)
	lw $t2,8($s0)
	lw $t3,12($s0)
	sw $t0,0($a0)
	sw $t1,4($a0)
	sw $t2,8($a0)
	sw $t3,12($a0)
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal PreItoa
	lw $ra($sp)
	addi $sp,$sp,4
	
	li $t0,32
	lb $t0,($a1)
	addi $a1,$a1,1
	
	lw $t0,32($s0)
	lw $t1,16($s0)
	lw $t2,20($s0)
	lw $t3,24($s0)
	sw $t0,0($a0)
	sw $t1,4($a0)
	sw $t2,8($a0)
	sw $t3,12($s0)
	
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal PreItoa
	lw $ra($sp)
	addi $sp,$sp,4
	
	lw $s1,4($sp)
	lw $s0,0($sp)
	addi $sp,$sp,8
	jr $ra

NSCD:
	li $t9,56
	lw $s1,4($sp)
	lw $s0,0($sp)
	addi $sp,$sp,8
	jr $ra
	
PreItoa:#$a0<-VAItoa // $a1 <- String resultado 
	lw $t0,0($a0)
	sb $t0,($a1)
	addi $a1,$a1,1
	li $t0,61
	sb $t0,($a1)
	addi $a1,$a1,1
	
	lw $a2,4($a0)
	addi $sp,$sp,-4
	sw $ra,($sp)
	jal Itoa2.0
	lw $ra($sp)
	addi $sp,$sp,4
	
	li $t0,46
	sb $t0,($a1)
	addi $a1,$a1,1
	
	li $t0,48
	lw $t1,8($a0)
	BucleZero:
		lb $t0,($a1)
		addi $t1,$t1,-1
		bne $t1,0,BucleZero
	 lw $a2,12($a0)
	 addi $sp,$sp,-4
	 sw $ra,($sp)
	 jal Itoa2.0
	 lw $ra,($sp)
	 addi $sp,$sp,4
	  
	 jr $ra
	
Itoa2.0:#$a2 <- numero a convertir a String // $a1<-String resultado
	addi $sp,$sp,-8
	sw $s0,0($sp)
	sw $s1,4($sp)
	
	la $s0,VAStr
	li $t0,10
	li $s1,0 #contador
	B1:
		div $a2,$t0
		mflo $a2
		mfhi $t1
		addi $t1,$t1,48
		sb $t1,($s0)
		addi $s0,$s0,1
		addi $s1,$s1,1
		beq $a2,0,B2
		j B1
		
		B2:
			addi $s0,$s0,-1
			lb $t0,($s0)
			sb $t0,($a1)
			addi $s1,$s1,-1
			addi $a1,$a1,1
			beq $s1,0,Fin
			j B2
			Fin:
				lw $s1,4($sp)
				lw $s0,0($sp)
				addi $sp,$sp,8
				jr $ra 
