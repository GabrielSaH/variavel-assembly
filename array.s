# .data é uma diretriz para instruir ao ld (linker) que será a seção de
# dados do programa. Inclusive, o comportamento das seções podem ser 
# diferentes dependendo do processador ou do código linkeditado a ser
# gerado.

# para esse programa use o ld com os seguintes flags:
# ld --Ttext 0x7c00 --Tdata 0x7d00 --oformat=binary $(SOURCE).o -o $(SOURCE).bin 

# --Ttext atribui o endereço 0x7c00 para seção de código
# --Tdata atribui o endereço 0x7d00 para a seção de dados

# isso implica que só existem 0x100 bytes para código

# repare em . = 0x100

# no manual do gas: The special symbol `.' refers to the current address 
# that as is assembling into. 

# . = 0x100 é uma maneira de alterar o endereço atual da instrução ou dado

# assim, para esse código é considerado que

# [0x0, 0x100-1] será de instruções 
# [0x100, 0x200] será de dados
# [x,y] é um intervalo com início x e fim em y

# depois o linkeditor irá realocar os endereços relativos a 0x7c00

# Para quem não entendeu:

# compile o programa sem as diretrizes --Tdata e procure com o hexdump
# no arquivo .o gerado pelos dados do array 
# depois olhe no arquivo .bin pelos dados do array
# depois olhe no arquivo floppy.img pelos dados do array
# sem o flag Tdata e o controle correto do arquivo os dados poderão estar 
# em alguma posição que TALVEZ não será copiada para a imagem final.

# Considere que o programa começa em 0x7c00

.code16 			    # generate 16-bit code
.globl _start

# seção do código
.text 		

# ponto de entrada
_start:				    

    # imprimir o primeiro dado do array
    movb array(,1), %al
    movb $0x0e, %ah     # bios service code to print
    int  $0x10		# bios service (interrupt) 

    lea mensagem, %bx   # carrega o endereço de mensagem em bx

mensagem_loop:
   
    cmpb $0, (%bx)      # é o fim da string?
    je mensagem_fim     # é, então pula

    movb (%bx), %al     # não é, então carrega o valor que está
                        # no endereço apontado por bx
    movb $0x0e, %ah     # bios service code to print
    int  $0x10		# bios service (interrupt) 
    incw %bx            # proximo byte
    jmp mensagem_loop   

mensagem_fim:

    lea array, %bx      # carrega o endereço de array em bx
    movw $4, %cx        # configurar cx com o valor 4 que é
                        # o tamanho do array

loop_start:
    movb (%bx), %al
    movb $0x0e, %ah     # bios service code to print
    int  $0x10		# bios service (interrupt) 
    incw %bx            # proximo byte

    decw %cx            # decrementa cx
    jne loop_start      # loop

halt:                   # loop para halt
    hlt
    jmp halt


# colocar a seção de dados na posição 0x100 relativa ao 
# começo do programa, ou seja, 0x7d00

# colocar a seção de dados em 0x100 
. = 0x100 
.data

array:
    .ascii "1234"
mensagem:
    .ascii "o valor do array eh = \0"

# escrever a assinatura no local correto 
. = 0x100 - 2
bios_signature:
    .byte 0x55, 0xaa    # MBR boot signature 


