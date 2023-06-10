.data
    matrix: .word 1, 2, 3, 4, 5, 6, 7, 8, 9   # Exemplo de matriz 3x3
    newline: .asciiz "\n"                     # Caractere de nova linha

.text
    main:
        la $s0, matrix              # Carrega o endere?o base da matriz em $s0
        la $s1, newline             # Carrega o endere?o da sequ?ncia de nova linha em $s1
        li $t0, 0                   # ?ndice do elemento atual
        li $t1, 3                   # N?mero de linhas
        li $t2, 3                   # N?mero de colunas
        mul $t3, $t1, $t2           # Calcula o n?mero total de elementos na matriz
        li $t4, 0                   # Contador para controlar as quebras de linha

    outer_loop:
        beq $t0, $t3, exit          # Verifica se todos os elementos foram exibidos

        lw $a0, 0($s0)              # Carrega o valor do elemento atual
        li $v0, 1                   # C?digo 1 para imprimir inteiro
        syscall

        addiu $t0, $t0, 1           # Incrementa o ?ndice do elemento atual
        addiu $s0, $s0, 4           # Incrementa o endere?o base da matriz

        addiu $t4, $t4, 1           # Incrementa o contador de quebras de linha
        beq $t4, $t2, print_newline # Verifica se ? necess?rio imprimir uma quebra de linha

        j outer_loop                # Volta para o in?cio do loop externo

    print_newline:
        li $v0, 4                   # C?digo 4 para imprimir string
        move $a0, $s1               # Move o endere?o da sequ?ncia de nova linha para $a0
        syscall

        li $t4, 0                   # Reinicia o contador de quebras de linha

        j outer_loop                # Volta para o in?cio do loop externo

    exit:
        li $v0, 10                  # C?digo 10 para encerrar o programa
        syscall

