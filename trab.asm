.data
prompt_rows: .asciiz "Digite o n?mero de linhas da matriz: "
prompt_cols: .asciiz "Digite o n?mero de colunas da matriz: "
prompt_value: .asciiz "Digite o valor: "
prompt_menu: .asciiz "Menu\n1-adicao\n2-subtracao\n3-multiplicacao\n4-divisao\n5-sair\nEscolha uma opcao: "
opcao_invalida: .asciiz "Op??o inv?lida. Digite novamente.\n"
newline: .asciiz "\n"
buffer: .space 16

.text
.globl main
main:

  # Exibir o menu
  li $v0, 4
  la $a0, prompt_menu
  syscall

  # Ler a op??o do usu?rio
  li $v0, 5
  syscall
  move $t0, $v0  # Armazenar a op??o em $t0

  # Verificar a op??o escolhida
  beq $t0, 1, soma_matriz
  # beq $t0, 2, input_matriz
  # beq $t0, 3, sair
  li $v0, 4          # Carrega o c?digo da chamada do sistema para imprimir string
  la $a0, opcao_invalida    # Carrega o endere?o da mensagem em $a0
  syscall            # Faz a chamada do sistema para imprimir a string

soma_matriz:
  jal input_matriz

input_matriz:
  # Solicitar n?mero de linhas
  li $v0, 4
  la $a0, prompt_rows
  syscall

  # Ler n?mero de linhas
  li $v0, 5
  syscall
  move $t0, $v0  # Armazenar n?mero de linhas em $t0

  # Solicitar n?mero de colunas
  li $v0, 4
  la $a0, prompt_cols
  syscall

  # Ler n?mero de colunas
  li $v0, 5
  syscall
  move $t1, $v0  # Armazenar n?mero de colunas em $t1

  # Alocar espa?o para a matriz
  mul $t2, $t0, $t1  # Calcular o tamanho total da matriz
  li $v0, 9
  mul $a0, $t2, 4  # Tamanho em bytes (cada elemento ? uma palavra de 4 bytes)
  syscall
  move $t3, $v0  # Endere?o da matriz alocada

  # Solicitar o conte?do da matriz
  li $t4, 0  # Contador de linhas

loop_rows:
  beq $t4, $t0, print_matrix  # Se todas as linhas foram preenchidas, imprimir matriz

  li $t5, 0  # Contador de colunas

loop_cols:
  beq $t5, $t1, next_row  # Se todas as colunas foram preenchidas, passar para a pr?xima linha

  # Solicitar valor para a posi??o [$t4][$t5]
  li $v0, 4
  la $a0, prompt_value
  syscall

  # Preencher o valor na matriz
  li $v0, 5
  syscall
  sw $v0, ($t3)  # Armazenar valor na matriz

  addiu $t3, $t3, 4  # Avan?ar para a pr?xima posi??o na matriz
  addiu $t5, $t5, 1  # Incrementar contador de colunas
  j loop_cols

next_row:
  addiu $t4, $t4, 1  # Incrementar contador de linhas
  j loop_rows

print_matrix:
  # Imprimir a matriz
  move $t3, $v0  # Restaurar endere?o da matriz

  li $t4, 0  # Reiniciar contador de linhas

print_loop_rows:
  beq $t4, $t0, exit_program  # Se todas as linhas foram impressas, sair do programa

  li $t5, 0  # Reiniciar contador de colunas

print_loop_cols:
  beq $t5, $t1, next_row_print  # Se todas as colunas foram impressas, passar para a pr?xima linha

  # Imprimir valor da posi??o [$t4][$t5]
  lw $a0, ($t3)
  li $v0, 1
  syscall

  addiu $t3, $t3, 4  # Avan?ar para a pr?xima posi??o na matriz
  addiu $t5, $t5, 1  # Incrementar contador de colunas
  j print_loop_cols

next_row_print:
  li $v0, 4
  la $a0, newline
  syscall

  addiu $t4, $t4, 1  # Incrementar contador de linhas
  j print_loop_rows

exit_program:
  # Terminar o programa
  li $v0, 10
  syscall
