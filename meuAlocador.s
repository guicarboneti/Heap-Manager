.section .data
    strInicia: .string "Endereço inicial: %d\n"
    info: .string "################"
    livre: .string "-"
    ocupado: .string "+"
    brline: .string "\n"
    topoInicialHeap: .quad 0
    topoAtualHeap: .quad 0
    .equ OCUPADO, 0
    .equ LIVRE, 1

.section .text

.globl iniciaAlocador
.globl finalizaAlocador
.globl alocaMem
.globl liberaMem
.globl imprimeMapa
# .globl main

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax # código brk
    movq $0, %rdi # tamanho 0 no argumento
    syscall
    movq %rax, topoInicialHeap
    movq %rax, topoAtualHeap
    # movq $strInicia, %rdi # primeiro argumento printf (string)
    # movq %rax, %rsi # segundo argumento printf (endereço a ser impresso)
    # call printf
    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq topoInicialHeap, %rdi # rdi <- rbk inicial
    movq %rdi, topoAtualHeap
    movq $12, %rax
    syscall
    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq topoInicialHeap, %r10 # itera começando pelo início
    movq topoAtualHeap, %r11 # r11 guarda final da heap
    pushq %r12

    iteracao:
        cmpq %r10, %r11 # compara iterador com topo
        je aumentaHeap # se igual, aumenta heap
        
        movq 8(%r10), %r12
        cmpq $OCUPADO, (%r10) # verifica se bloco está ocupado
        je incrementaIterador

        cmpq %r12, %rdi # compara tamanhos de memória
        jle armazena # armazena no bloco se o tamanho é menor ou igual

    incrementaIterador:
        addq $8, %r10
        addq %r12, %r10
        jmp iteracao

    armazena:
        movq $OCUPADO, (%r10) # indica que bloco agora está ocupado
        addq $16, %r10 # r10 <- vetor[0]
        movq %r10, %rax
        popq %r12
        popq %rbp
        ret

    aumentaHeap:
        addq $8, %r11
        addq %rdi, %r11
        movq %r11, topoAtualHeap
        pushq %r13
        movq %rdi, %r13

        movq %r11, %rdi
        movq $12, %rax
        syscall

        movq $OCUPADO, (%r10) # indica que bloco está ocupado
        movq %r13, 8(%r10) # armazena tamanho do bloco
        movq %r10, %rax
        addq $16, %rax # %rax <- vetor[0]
        movq %r13, %rdi
        popq %r13

    popq %r12
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rdi
    movq $LIVRE, (%rdi)
    popq %rbp
    ret

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    movq topoInicialHeap, %rbx

    pushq %r12
    pushq %r13

    laco:
        cmpq topoAtualHeap, %rbx
        jge retorno
        jl imprime

    imprime:
        movq $info, %rdi
        call printf

        jmp imprime_bloco
    
    imprime_bloco:
        movq $1, %r13
        movq 8(%rbx), %r12      # indica tamanho do bloco
        cmpq $OCUPADO, (%rbx)   # verifica se o bloco esta ocupado
        je bloco_ocupado
        jmp bloco_disponivel
    
    bloco_ocupado:
        cmpq %r12, %r13
        jg proximo_bloco

        movq $ocupado, %rdi
        call printf

        addq $1, %r13

        jmp bloco_ocupado

    bloco_disponivel:
        cmpq %r12, %r13
        jg proximo_bloco
        
        movq $livre, %rdi
        call printf

        addq $1, %r13

        jmp bloco_disponivel

    proximo_bloco:
        addq $8, %rbx     # tamanho do espaço de informacoes
        addq %r12, %rbx   # tamanho do bloco

        jmp laco
    
    retorno:
        movq $brline, %rdi
        call printf
        popq %r13
        popq %r12
        popq %rbp
        ret

# main:
#     pushq %rbp
#     movq %rsp, %rbp
#     call iniciaAlocador
#     subq $8, %rsp
#     movq $100, %rdi
#     pushq %rdi
#     call alocaMem
#     popq %rdi
#     movq %rax, %rbx
#     movq $20, %rdi
#     pushq %rdi
#     call alocaMem
#     popq %rdi
#     movq %rbx, %rdi
#     call liberaMem
#     addq $8, %rsp
#     call imprimeMapa
#     movq $60, %rax
#     syscall
    