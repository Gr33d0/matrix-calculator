.data
prompt_rows: .asciiz "Digite o número de linhas da matriz: "
prompt_cols: .asciiz "Digite o número de colunas da matriz: "
prompt_value: .asciiz "Digite o valor: "
prompt_menu: .asciiz "Menu\n1-adição\n2-subtração\n3-multiplicação\n4-divisão\n5-sair\nEscolha uma opção: "
opcao_invalida: .asciiz "Opção inválida. Digite novamente.\n"
newline: .asciiz "\n"
buffer: .space 16

.text
.globl main
main:

  # Exibir o menu
  li $v0, 4
  la $a0, prompt_menu
  syscall

  # Ler a opção do usuário
  li $v0, 5
  syscall
  move $t0, $v0  # Armazenar a opção em $t0

  # Verificar a opção escolhida
  beq $t0, 1, soma_matrizes
  # beq $t0, 2, subtrai_matrizes
  # beq $t0, 3, multiplica_matrizes
  # beq $t0, 4, divide_matrizes
  li $v0, 4          # Carrega o código da chamada do sistema para imprimir string
  la $a0, opcao_invalida    # Carrega o endereço da mensagem em $a0
  syscall            # Faz a chamada do sistema para imprimir a string

soma_matrizes:
  jal input_matriz

input_matriz:
  # Solicitar número de linhas
  li $v0, 4
  la $a0, prompt_rows
  syscall

  # Ler número de linhas
  li $v0, 5
  syscall
  move $t0, $v0  # Armazenar número de linhas em $t0

  # Solicitar número de colunas
  li $v0, 4
  la $a0, prompt_cols
  syscall

  # Ler número de colunas
  li $v0, 5
  syscall
  move $t1, $v0  # Armazenar número de colunas em $t1

  # Alocar espaço para a primeira matriz
  mul $t2, $t0, $t1  # Calcular o tamanho total da primeira matriz
  li $v0, 9
  mul $a0, $t2, 4  # Tamanho em bytes (cada elemento é uma palavra de 4 bytes)
  syscall
  move $t3, $v0  # Endereço da primeira matriz alocada

  # Solicitar o conteúdo da primeira matriz
  li $t4, 0  # Contador de linhas

loop_rows:
  beq $t4, $t0, input_second_matrix  # Se todas as linhas foram preenchidas, passar para a segunda matriz

  li $t5, 0  # Contador de colunas

loop_cols:
  beq $t5, $t1, next_row  # Se todas as colunas foram preenchidas, passar para a próxima linha

  # Solicitar valor para a posição [$t4][$t5]
  li $v0, 4
  la $a0, prompt_value
  syscall

  # Preencher o valor na primeira matriz
  li $v0, 5
  syscall
  sw $v0, ($t3)  # Armazenar valor na primeira matriz

  addiu $t3, $t3, 4  # Avançar para a próxima posição na primeira matriz
  addiu $t5, $t5, 1  # Incrementar contador de colunas
  j loop_cols

next_row:
  addiu $t4, $t4, 1  # Incrementar contador de linhas
  j loop_rows

input_second_matrix:
  # Solicitar número de linhas da segunda matriz
  li $v0, 4
  la $a0, prompt_rows
  syscall

  # Ler número de linhas da segunda matriz
  li $v0, 5
  syscall
  move $t4, $v0  # Armazenar número de linhas da segunda matriz em $t4

  # Solicitar número de colunas da segunda matriz
  li $v0, 4
  la $a0, prompt_cols
  syscall

  # Ler número de colunas da segunda matriz
  li $v0, 5
  syscall
  move $t5, $v0  # Armazenar número de colunas da segunda matriz em $t5

  # Alocar espaço para a segunda matriz
  mul $t6, $t4, $t5  # Calcular o tamanho total da segunda matriz
  li $v0, 9
  mul $a0, $t6, 4  # Tamanho em bytes (cada elemento é uma palavra de 4 bytes)
  syscall
  move $t7, $v0  # Endereço da segunda matriz alocada

  # Solicitar o conteúdo da segunda matriz
  li $t8, 0  # Contador de linhas

loop_rows_second:
  beq $t8, $t4, print_matrices  # Se todas as linhas foram preenchidas, imprimir matrizes

  li $t9, 0  # Contador de colunas

loop_cols_second:
  beq $t9, $t5, next_row_second  # Se todas as colunas foram preenchidas, passar para a próxima linha

  # Solicitar valor para a posição [$t8][$t9] da segunda matriz
  li $v0, 4
  la $a0, prompt_value
  syscall

  # Preencher o valor na segunda matriz
  li $v0, 5
  syscall
  sw $v0, ($t7)  # Armazenar valor na segunda matriz

  addiu $t7, $t7, 4  # Avançar para a próxima posição na segunda matriz
  addiu $t9, $t9, 1  # Incrementar contador de colunas
  j loop_cols_second

next_row_second:
  addiu $t8, $t8, 1  # Incrementar contador de linhas
  j loop_rows_second


print_matrices:
  # Imprimir as matrizes
  move $t3, $v0  # Restaurar endereço da primeira matriz
  move $t4, $t9  # Restaurar endereço da segunda matriz

  li $t5, 0  # Reiniciar contador de linhas

print_loop_rows:
  beq $t5, $t0, exit_program  # Se todas as linhas foram impressas, sair do programa

  li $t6, 0  # Reiniciar contador de colunas

print_loop_cols:
  beq $t6, $t1, next_row_print  # Se todas as colunas foram impressas, passar para a próxima linha

  # Imprimir valor da posição [$t5][$t6] da primeira matriz
  lw $a0, ($t3)
  li $v0, 1
  syscall

  # Imprimir espaço entre os valores das matrizes
  li $v0, 4
  la $a0, buffer
  syscall

  # Imprimir valor da posição [$t5][$t6] da segunda matriz
  lw $a0, ($t4)
  li $v0, 1
  syscall

  addiu $t3, $t3, 4  # Avançar para a próxima posição na primeira matriz
  addiu $t4, $t4, 4  # Avançar para a próxima posição na segunda matriz
  addiu $t6, $t6, 1  # Incrementar contador de colunas
  j print_loop_cols

next_row_print:
  li $v0, 4
  la $a0, newline
  syscall

  addiu $t5, $t5, 1  # Incrementar contador de linhas
  j print_loop_rows

exit_program:
  # Terminar o programa
  li $v0, 10
  syscall
