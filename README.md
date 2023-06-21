# matrix-calculator

MultiplyMatrices:
  #Primeiro escolher matrizes
  li $v0, 4		
	la $a0, Matriz1
	syscall	

    li $v0, 5
    syscall
    move $a0, $v0   # Move o valor lido para $a0


    #Saber se encontrou oque queria
    #3 atributos + numero elementos (EX: se for 1 é os 3 primeiros + numeros de elementos)
    #generalizando $a2 = a0*(3*4+indice1) e $a3 = a1*(3*4+indice1)
    #comeca no 0x10040012


    Este é o primeiro indice do array(elementos) a partir daqui da para calcular os outros
    lui $t0, 0x1004    # Carrega os 16 bits mais significativos do endereço
    ori $t0, $t0, 0x0000   # Realiza uma operação OR com os 16 bits menos significativos do endereço
    sll $t1, $t1, 2 
    add $t0, $t0, $t1 

    multiplica se por 4 e vai andar uma casa para a frente inicialmente vai ter sempre +12 que é onde fica o primeiro indice da matriz em si depois fazes 4*valor do indice 0  e assim chegas a outra matriz a1 vai servir se quantas matrizes vai passar a frente
    mul $t1,$a1, 4
    add $t0 ,$t0, $t1
    lw $t2, ($t0)
