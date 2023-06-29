.data 0x10000100
Matrizes: .space 40 			# 100 bytes para cada matriz, up to 4 matrices


.data
MultInvalid: .asciiz "Nao e possivel multiplicar essas matrizes"

menu: .asciiz "Menu:\n1 - Inserir\n2 - Listar\n3 - Apagar\n4 - Multiplicar\n5 - Sair\n\nInsira a opcao: "

Matriz: .asciiz "Matriz: "
Vazio: .asciiz "Sem matrizes guardadas.\n\n"

espaco: .asciiz " "
paragrafo: .asciiz "\n"
colunas: .asciiz "Numero de colunas: "
linhas: .asciiz "Numero de Linhas: "
elemento: .asciiz "Introduza um elemento: "
successo: .asciiz "\nMatriz salva com sucesso.\n\n\n."

ApagarMatriz_msg: .asciiz "Indique o index da matriz a apagar: "
MatrizApagada_msg: .asciiz "Matriz apagada com sucesso.\n\n"
IndexInvalido_msg: .asciiz "Index invalido.\n\n"

Matriz1: .asciiz "Index da primeira matriz: "
Matriz2: .asciiz "Index da segunda matriz: "
NaoMult_msg: .asciiz "Matrizes nao multiplicaveis.\n\n"
Multiplicado_msg: .asciiz "Matrizes multiplicadas com sucesso.\n\n"

.text
.globl main

.globl InserirMatriz
.globl ListarMatrizes
.globl ApagarMatriz
.globl MultiplicarMatrizes
.globl PrintMatriz

main:
    li $s2, 4
    la $s0, Matrizes
    li $v0, 4 
    la $a0, menu 
    syscall 
    li $v0, 5 
    syscall 

    move $t0, $v0

    beq $t0, 1, InserirMatriz 
    beq $t0, 2, Listar
    beq $t0, 3, ApagarMatriz 
    beq $t0, 4, MultiplicarMatrizes 
    beq $t0, 5, exit 
    
    j main
    
Listar:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal ListarMatrizes
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    j main 
   
  ### INSERIR MATRIZ ###

InserirMatriz:

 #Limpar registradores
  li $t0, 0
  li $t1, 0
  li $t2, 0
 
  li $v0, 4 # Pedir o numero de colunas
  la $a0, colunas
  syscall

  
  li $v0, 5 			
  syscall
  move $t0, $v0 # Guardar o numero de colunas -> $t0

  
  li $v0, 4 # Pedir o numero de linhas
  la $a0, linhas
  syscall

  li $v0, 5 			
  syscall
  move $t1, $v0 		# Guardar o numero de linhas -> $t1


  # Calcular o tamanho da matriz
  mul $t2, $t0, $t1 # linhas x colunas = elementos -> $t2
  move $t4, $t2 		# guarda numero de elementos -> $t4
  move $t5, $t0 		# guarda colunas -> $t5
  move $t6, $t1 		# guarda linhas -> $t6
  addi $t2, $t2, 3	# numero elementos + colunas + linhas -> $t2
  li $t3, 4         # $t3 = 4
  mul $t2, $t2, $t3 # $t2 x 4 = bytes totais necess?ios -> $t2
  

  # Alocar memoria para a matriz
  li $v0, 9
  li $a0, 0
  move $a0, $t2 # Aloca numero de bytes de t2 para $a0
  syscall
  
  #  Guardar enderecos
  move $t8,$v0			# endereco da matriz -> $t8
  move $a1, $t8			# endereco da matriz -> $a1
  move $a0, $s0 		# Salva o endereco de Matrizes -> $a0
  
  #JAL Enderecamento da matriz
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal EnderecamentoMatriz 
  lw $ra, 0($sp)
  addi $sp, $sp, 4
 
  #Posicionamento
  move $a0, $t2			# numero de bytes totais da matriz -> $a0
  sw $t4, 0($t8)		# numero de elementos -> Primeira
  sw $t6, 4($t8)		# numero de linhas -> Segunda
  sw $t5, 8($t8)		# numero de colunas -> Terceira
  addi $t8, $t8, 12	# $t8 salta 3 posicoes
  li $t1, 12
  move $a1, $t8			 # $t8 para endereco da matriz
  
  # procedimento para inserir elementos
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal LoopElementos
  lw $ra, 0($sp)
  addi $sp, $sp, 4	
  j main
 
 
LoopElementos:
  beq $t1, $a0, FimElementos
  li $v0, 4        		# Imprimir prompt para o elemento atual
  la $a0, elemento
  syscall
  
  move $a0, $t2
  
  li $v0, 5        		# Ler o elemento atual
  syscall
  
  sw $v0, 0($a1)
  addi $a1, $a1, 4
  addi $t1, $t1, 4
  j LoopElementos
  
FimElementos:
  li $v0, 4            		# Imprimir mensagem de sucesso
  la $a0, successo
  syscall
  jr $ra
  
  # Atribuir endereco das matriz
  EnderecamentoMatriz :
  li $t0, 0
  lw $t0, 0($a0)
  beq $t0, $0, EnderecosFinal
  addi $a0, $a0, 4
  j EnderecamentoMatriz 
  
  EnderecosFinal:
  sw $a1, 0($a0)		# Guarda os enderecos em $a1
  jr $ra
  
ListarMatrizes:
  lw $t0, 0($s0)
  beq $t0, $0, SemMatrizes
  move $v1, $t0
  li $t0, 0
  li $t1, 0
  li $t2, 0		
  li $t8, 1
  li $a0, 40			# bytes do array de enderecos -> $a0
  
ListarEnderecos:
  li $a0, 40
  li $t1, 0
  beq $t0, $a0, FimMatrizes 	#Se array cheio e lista terminar
  lw $t2, Matrizes($t0)
  beq $t2, $0, FimMatrizes	#Se array nao cheio e nao houver mais enderecos
  move $a1, $t2
  
  #JAL para imprimir matriz
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal PrintMatriz
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  addi $t0, $t0, 4
  j ListarEnderecos
  
SemMatrizes:
  li $v0, 4 
  la $a0, Vazio 
  syscall 
  j main
    
 FimMatrizes:
 jr $ra

PrintMatriz:
 #Reset dos registradores
	li $t1, 0
	li $t6, 0			
	li $t5, 0			
	li $t6, 0			
	li $t7, 0					
	li $t9, 0
	lw $t6, 4($a1)			# $t6 adquire o numero de linhas da matriz
	lw $t3, 8($a1)			# t3 adquire colunas
	
	addi $a1, $a1, 12		# saltar para inicio de elementos

	li $v0, 4
	la $a0, Matriz
	syscall

	li $v0, 1
	move $a0, $t8
	syscall

	li $v0, 4
	la $a0, paragrafo
	syscall
	
PrintElementos:
	

	
	beq $t9, $t3, AumentaColuna 	# t9 compara com numero de col
	mul $t5, $t9, $t6		# t5 = t9 x numero linhas 
	mul $t5, $t5, $s2		# t5 x 4 -> Guarda em bytes a posicao da linha
	mul $t7, $t1, $s2		# t7 = t1 (cont aumenta colunas) x 4 - Guarda em bytes o salto da prox linha
	add $t5, $t5, $t7		# t5 (bytes linhas) + t7 (bytes colunas) -> offset para chegar ao endereco
	add $t5, $t5, $a1		# t5 (bytes total) + a1 (inicio da matriz) ->  andar na matriz para buscar valores
	lw $a0, 0($t5)			# guarda t5 valor do elemento

	li $v0, 1
	syscall			

	li $v0, 4
	la $a0, espaco
	syscall	

	addi $t9, $t9, 1		# incrementa t9 para depois comparar
	j PrintElementos
	
	
AumentaColuna:
	#beq $t3, 
	li $v0, 4
	la $a0, paragrafo
	syscall
	addi $t1, $t1, 1		# Acumulador
	beq $t1, $t6, EndLoop
	li $t9, 0
	li $t5, 0
	move $a1, $t2
	addi $a1, $a1, 12
	j PrintElementos

EndLoop:
	
	addi $t8, $t8, 1

	li $v0, 4
	la $a0, paragrafo
	syscall

	jr $ra

exit:
    li $v0, 10 # Load syscall code for program exit
    syscall # Exit the program

ApagarMatriz:
   	
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal ListarMatrizes
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	beq $v1, $0 FimApagar
	#Reset das variaveis
	li $t0, 0
	li $t1, 0		
	li $t2, 0		
	li $t3, 0		
	li $t4, 0		
	li $t5, 0		
	li $t6, 0		
	li $t7, 0		
	li $t8, 0		
	li $t9, 0		

	li $v0, 4		
	la $a0, ApagarMatriz_msg
	syscall	

	li $v0, 5
   	syscall
	move $t0, $v0

	li $v0, 4
	la $a0, paragrafo
	syscall

	addi $t0, $t0, -1		# indice 1, posicao 0
	mul $t0, $t0, $s2		
	sw $0, Matrizes($t0)	

	move $a0, $t0			# Move a posicao actual
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal VerificaProximo
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
			
FimApagar:	
	j main

VerificaProximo:
	move $t1, $a0
	
Proximo:

	addi $t1, $t1, 4 		# posicao da Matrizseguinte
	lw $t2, Matrizes($t1) 		# Carrega Matriz em $t2
	beq $t2, $0, ApagarUltimo 	
	sw $t2, Matrizes($a0)		
	add $a0, $a0, 4			
	j Proximo
	
ApagarUltimo:
	sw $0, Matrizes($a0)
	j FimApagar
	
	
	
IndexInvalido:
    li $v0, 4 
    la $a0, IndexInvalido_msg 
    syscall 
    j main
    

MultiplicarMatrizes:
    #Mostra as matrizes 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal ListarMatrizes
    lw $ra, 0($sp)
    addi $sp, $sp, 4
   #Reseta os registradores
    li $t0, 0
    li $t1, 0		
    li $t2, 0		
    li $t3, 0		
    li $t4, 0		
    li $t5, 0		
    li $t6, 0		
    li $t7, 0		
    li $t8, 0		
    li $t9, 0		

ProcurarPrimeiraMatriz:
  # Matriz 1
  li $v0, 4
  la $a0, Matriz1
  syscall
  li $v0, 5
  syscall
  move $t0, $v0 # Matriz 1 -> $t0
  li $v0, 4
  la $a0, paragrafo
  syscall

  #Primeira matriz(referencia)
  la $s0,0x10040000 # Endereco inicial
  la $s1,0x1004000c # Endereco modificavel
  lw $t2,0($s0) # Numero de elementos
  lw $t3,4($s0) # Numero de linhas
  lw $s6, 8($s0) # Numero COLUNAS - VAI SER O numero DE COLUNAS DE M3
  la $s3,12($s0) # Guardar Endereco
  addi $t9,$t9,1
  bne $t0,$t9,LoopProcuraPrimeiraMatriz# Se for diferente 
  j ProcurarSegundaMatriz

LoopProcuraPrimeiraMatriz:
    addi $t9,$t9,1 # Numero de colunas
    mul $t5,$t2,$s2 # elementos * 4
    add $s1,$s1,$t5 # adiciona ao enderco
    lw $t2,0($s1) # Numero de elementos
    lw $t3,4($s1) # Numero de linhas
    lw $s6, 8($s1) # numero COLUNAS - VAI SER O numero DE COLUNAS DE M3
    la $s3,12($s1) # Guardar Endereco

    bne $t0,$t9,LoopProcuraPrimeiraMatriz# Enquanto $t9 diferente de $t0->escolha da matriz passa para a proxima matriz
    j ProcurarSegundaMatriz
ProcurarSegundaMatriz: 
    li $t9, 0	 # Reset t9
    # Matriz 2
    li $v0, 4
    la $a0, Matriz2
    syscall
    li $v0, 5
    syscall
    move $t1, $v0 # Matriz 2 -> $t1
    li $v0, 4
    la $a0, paragrafo
    syscall
  # Primeira matriz(referencia)
  la $s0,0x10040000 # Endereco inicial
 
  la $s1,0x1004000c # Endereco modificavel
  lw $t6,0($s0) # Numero de elementos (segunda)
  lw $t7, 4($s0) # numero LINHAS - VAI SER O numero DE LINHAS DE M3
  lw $t8,8($s0) # Numero de colunas (segunda)
  la $s4,12($s0) # Guardar Endereco
  addi $t9,$t9,1
  bne $t1,$t9,LoopProcuraSegundaMatriz# Enquanto $t9 diferente de $t0->escolha da matriz passa para a proxima matriz
  j CompararLinhaColuna
LoopProcuraSegundaMatriz:
    addi $t9,$t9,1 # Numero de colunas
    mul $t6,$t6,$s2 # elementos * 4
    add $s1,$s1,$t6 # adiciona ao enderco 
    lw $t6, 0($s1) # Numero de elementos (segunda)
    lw $t7, 4($s1)  ### numero LINHAS - VAI SER O numero DE LINHAS DE M3
    lw $t8, 8($s1) # Numero de colunas (segunda)
    la $s4, 12($s1) # Guardar Endereco

    bne $t1,$t9,LoopProcuraSegundaMatriz# Enquanto $t9 diferente de $t0->escolha da matriz passa para a proxima matriz
    j CompararLinhaColuna
CompararLinhaColuna:
  li $t9,0
  beq $t3,$t8,Multiplicacao # N de linhas M1 com n colunas M2
  li $v0, 4           
  la $a0, MultInvalid # Print da mensagem de erro
  syscall             # Executa

  li $v0, 10       
  syscall           

  j main 

Multiplicacao:

  # Calcular o tamanho e bytes da nova matriz
  mul $t1, $t3, $t8		# linhas M1 X COLUNAS M2 = ELEMENTOS M3
  move $t9, $t1			# transfere numero elementos para $t9
  addi $t9, $t9, 3		# adicionar 3 para ajustar tamanho com as variaveis (numero elementos + linhas + colunas)
  mul $t9, $t9, $s2		# calcula bytes de M3 que vao ficar em t9
  
  

  # Alocar memia para a nova matriz
  li $v0, 9
  li $a0, 0
  move $a0, $t9 		#($t9 registo com numero de bytes)  Aloca numero de bytes da matriz nova para $a0
  syscall
  
  # Guardar Endereco de M3
   
   move $t5, $v0		# Endereco da matriz para $t5
   move $a1, $t5		# Endereco da matriz para $a1
   li $a0, 0x10000100
   
  
   ### Encontrar espaco vazio e Guardar Endereco da matriz nova
  #JAL Enderecamento da matriz
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal EnderecamentoMatriz 
  lw $ra, 0($sp)
  addi $sp, $sp, 4
   
   ### Posicionamento e gUARDAR VARIAVEIS   
  move $a0, $t9		# numero de bytes totais da matriz -> $a0
    sw $t1, 0($t5)		# guarda numero de elementos de M3
  sw $t7, 4($t5)		# guarda numero de linhas de M3
  sw $t8, 8($t5)		# guarda numero de colunas de M3
  addi $t5, $t5, 12		# offset para inicio de elementos de M3
  move $a1, $t5		   
 
  
  ###########
GuardaMultiplicacao:
 
 la $s0, Matrizes
 li $s1, 0

  # Calcular o tamanho da matriz
  mul $t0, $t3, $t8		# linhas 2 x colunas 1 = elementos -> $t0
  move $t4, $t0 		# guarda numero de elementos -> $t4
  addi $t0, $t0, 3		# numero elementos + colunas + linhas -> $t2
  mul $t0, $t0, $s2   		# $t2 x 4 = bytes totais necess?ios -> $t2
  

  # Alocar memoria para a matriz
  li $v0, 9
  li $a0, 0
  move $a0, $t0 		# Aloca numero de bytes de t2 para $a0
  syscall
  
  #  Guardar enderecos
  move $t7,$v0			# endereco da matriz -> $t7
  move $a1, $t7			# endereco da matriz -> $a1
  move $a0, $s0 		# Salva o endereco de Matrizes -> $a0
  
  #JAL Enderecamento da matriz
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal EnderecamentoMatriz 
  lw $ra, 0($sp)
  addi $sp, $sp, 4
 
  #Posicionamento
  move $a0, $t0			# numero de bytes totais da matriz -> $a0
  sw $t4, 0($t7)		# numero de elementos -> Primeira
  sw $t3, 4($t7)		# numero de linhas -> Segunda
  sw $t8, 8($t7)		# numero de colunas -> Terceira
  addi $t7, $t7, 12		# $t7 salta 3 posicoes
  li $t1, 12			
  move $a1, $t7			# $t7 para endereco da matriz

MultiMatriz:
    
    lw $t1, 0($s3) # Inicia na posicao anterior da primeiro indice M1
    lw $t7, 0($s4) # Inicia na posicao anterior da primeiro indice M2
    lw $s5 , -8($s3) # Numero de linhas M1
    li $t2,0 # Incia o contador colunas M2
    la $t4,0($s3)# Endereço M1
    la $s7, 0($s4) # Endereco M2
    li $t8,0 # Reset t8
    li $t9,0 # Reset t9


    Linha1:
        addi $t9,$t9,1
        #Linha 2
        mul $t3,$s2,$s5 # linhas x 4
        lw $t1, 0($t4)
        add $t4,$t4,$t3 # endereço da posicao anterior + t3
        # coluna 2 
        lw $t5,0($s7) # proximo elemento da M2
        addi $s7,$s7,4 # adiciona 4 ao endereço

        mul $t2,$t1,$t5 # linha 1
        add $t8,$t8,$t2 # soma das multiplicacoes da linha
        bne $s5,$t9,Linha1
        sw  $t8,0($a1)
        addi $a1,$a1,4
    Reset1:
        lw $t1, 0($s3) # Inicia na posicao anterior da primeiro indice M1
        lw $s6, -8($s4) # Numero de linhas M2
        li $t2,0 # Incia o contador colunas M2
        la $t4,0($s3)# Endereço M1
        la $s7, 0($s4) # Endereco M2
        li $t8,0 # Reset t8
        li $t9,0 # Reset t9
    MudaLinha:
      addi $t4,$t4,4  # Avanca 4 bytes
      j Linha2
    Linha2:
        addi $t9,$t9,1
        #Linha 2
        mul $t3,$s2,$s5 # linhas x 4
        lw $t1, 0($t4)
        add $t4,$t4,$t3 # endereço da posicao anterior + t3
        # coluna 2 
        lw $t5,0($s7) # proximo elemento da M2
        addi $s7,$s7,4 # adiciona 4 ao endereço

        mul $t2,$t1,$t5 # linha 1
        add $t8,$t8,$t2 # soma das multiplicacoes da linha
        bne $s5,$t9,Linha2
        sw  $t8,0($a1) 
        addi $a1,$a1,4
        
  
