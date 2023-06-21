.data 0x10000100
Matrizes: .space 40 			# 100 bytes para cada matriz, up to 4 matrices


.data

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
NaoMult: .asciiz "Matrizes nao multiplicaveis.\n\n"
Multiplicado: .asciiz "Matrizes multiplicadas com sucesso.\n\n"

.text
.globl main

.globl InserirMatriz
.globl ListarMatrizes
.globl ApagarMatriz
.globl MultiplyMatrices
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
    beq $t0, 2, MenuListar
    beq $t0, 3, ApagarMatriz 
    beq $t0, 4, MultiplyMatrices 
    beq $t0, 5, exit 
    
    j main
    
    MenuListar:
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
 
  li $v0, 4    			# Solicitar o numero de colunas
  la $a0, colunas
  syscall

  
  li $v0, 5 			
  syscall
  move $t0, $v0 		# Guardar o numero de colunas -> $t0

  
  li $v0, 4   			# Solicitar o numero de linhas
  la $a0, linhas
  syscall

  li $v0, 5 			
  syscall
  move $t1, $v0 		# Guardar o numero de linhas -> $t1


  # Calcular o tamanho da matriz
  mul $t2, $t0, $t1 		# linhas x colunas = elementos -> $t2
  move $t4, $t2 		# guarda nｺ de elementos -> $t4
  move $t5, $t0 		# guarda colunas -> $t5
  move $t6, $t1 		# guarda linhas -> $t6
  addi $t2, $t2, 3		#######	# nｺ elementos + colunas + linhas -> $t2
  li $t3, 4			# $t3 = 4
  mul $t2, $t2, $t3   		# $t2 x 4 = bytes totais necess疵ios -> $t2
  

  # Alocar memoria para a matriz
  li $v0, 9
  li $a0, 0
  move $a0, $t2 		# Aloca nｺ de bytes de t2 para $a0
  syscall
  
  #  Guardar enderecos
  move $t8,$v0			# endereco da matriz -> $t8
  move $a1, $t8			# endereco da matriz -> $a1
  move $a0, $s0 		# Salva o endereco de Matrizes -> $a0
  
  #JAL Enderecamento de elementos
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal EnderecamentoElementos
  lw $ra, 0($sp)
  addi $sp, $sp, 4 
 
  #Posicionamento
  move $a0, $t2			# numero de bytes totais da matriz -> $a0
  sw $t4, 0($t8)		# numero de elementos -> Primeira
  sw $t6, 4($t8)		# numero de linhas -> Segunda
  sw $t5, 8($t8)		################## numero de colunas -> Terceira
  addi $t8, $t8, 12		################## $t8 salta 3 posicoes
  li $t1, 12			##################
  move $a1, $t8			# $t8 para endereco da matriz
  
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
  
  #Atribuir endereco aos elementos
  EnderecamentoElementos:
  li $t0, 0
  lw $t0, 0($a0) 		# Carrega 1ｪ posicao em $a0, depois ser� manipulada por addi 
  beq $t0, $0, FimEnderecos
  addi $a0, $a0, 4		# salta para a posicao seguinte
  j EnderecamentoElementos
  
  FimEnderecos:
  sw $a1, 0($a0)		# Guarda os enderecos em $a1
  jr $ra
  
  #############################################         FIM INSERIR          ################################
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
	mul $t5, $t9, $t6		# t5 = t9 x nｺ linhas 
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
	addi $t1, $t1, 1		# incrementar t1 (guarda a 
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

########################################################## Fim Lista ###############################################
ApagarMatriz:
   	
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal ListarMatrizes
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	beq $v1, $0 FimApagar
	
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
	mul $t0, $t0, $s2		# Circulo posicao
	sw $0, Matrizes($t0)		# 

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
	beq $t2, $0, ApagarUltimo 	#
	sw $t2, Matrizes($a0)		# S
	add $a0, $a0, 4			# 
	j Proximo
	
ApagarUltimo:
	sw $0, Matrizes($a0)		# Elimina Matriz se nao houver prima
	j FimApagar
	
	
	
IndexInvalido:
    li $v0, 4 
    la $a0, IndexInvalido_msg 
    syscall 
    j main
    

MultiplyMatrices:
    #listar matrizes
    addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal ListarMatrizes
	lw $ra, 0($sp)
	addi $sp, $sp, 4
    #Primeiro escolher matrizes
    li $v0, 4		
	la $a0, Matriz1
	syscall	

    li $v0, 5
    syscall
    move $a0, $v0   # Move o valor lido para $a0

    li $v0, 4
    la $a0, Matriz2
    syscall
    
    li $v0, 5
    syscall
    move $a1, $v0   # Move o valor lido para $a1

    #Saber se encontrou oque queria
    #3 atributos + numero elementos (EX: se for 1 é os 3 primeiros + numeros de elementos)
    #generalizando $a2 = a0*(3*4+indice1) e $a3 = a1*(3*4+indice1)
    #comeca no 0x10040012


    sll $t1, $t1, 2 
    add $t0, $t0, $t1 

    lw $t2, ($t0)








