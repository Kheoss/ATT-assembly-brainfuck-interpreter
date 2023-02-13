.global brainfuck
.data 
JustRed: .quad 0
ProgramStackPointer: .quad 0
ProgramStack:.skip 240000               #reserving space for 30000 characters
format_str: .asciz "%c"
inputString: .asciz "%c"

# Input : a zero terminated string reprezenting the brainfuck code we have to interpret
.text
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

    movq $0, %rsi                               # starting index ( a secret tool that will help us later for looping)
    leaq ProgramStack, %rax
    movq %rax, ProgramStackPointer              # setup the program stack pointer

    call interpret                              # call the interpreter

    
    jmp endCoroutine                            # my job is done

interpret:
    pushq %rbp
    movq %rsp, %rbp
loop:
    movq %rdi, %rcx
    movq (%rdi), %rbx                           # get that character


    cmpb $0x00, %bl
    je endLoop                                  # end of line || string || file || whatever => end the loop
    cmpb $',', %bl
    je getCurrentFrame
    cmpb $'.', %bl
    je printCurrentFrame                        # print if it's the case
    cmpb $'+', %bl
    je addOneToFrame                            # add 1 to the current stack frame
    cmpb $'-', %bl
    je decrementOneToFrame                      # decrement 1 to the current stack frame
    cmpb $'>', %bl
    je incrementStackPointer
    cmpb $'<', %bl
    je decrementStackPointer                    # TO DO : ask for input
    cmpb $'[', %bl
    je interpretInsideLoop
    cmpb $']', %bl
    je endInsideLoop

    jmp loopContinue

interpretInsideLoop:
   movq ProgramStackPointer, %rbx
   movq $1, %rdx
   cmpq $0, (%rbx)                             # SKIP THE LOOP IF IT's not good
   je skipTheFoundingLoop
   pushq %rdi
   incq %rdi
   jmp loopContinue

skipTheFoundingLoop:
   incq %rdi
   movq (%rdi), %rax

   cmpb $'[', %al
   je skipFoundOpening
   cmpb $']', %al
   je skipFoundClosing

   jmp skipTheFoundingLoop

skipFoundOpening:
  incq %rdx
  jmp skipTheFoundingLoop

skipFoundClosing:
  decq %rdx
  cmpq $0, %rdx
  je endFound
  jmp skipTheFoundingLoop

endFound:
  movq %rdi, %rcx
  jmp loopContinue

endInsideLoop:
  movq ProgramStackPointer, %rbx
  cmpq $0, (%rbx)
  je skipTheLoop
  popq %rcx
  decq %rcx                                     # enforce the loop verification
  jmp loopContinue

skipTheLoop:
    popq %rbx
    #decq %rdi
    movq %rdi, %rcx
    jmp loopContinue

loopContinue:
    movq %rcx, %rdi
    addq $1, %rdi
    jmp loop

endLoop:
  jmp endCoroutine

incrementStackPointer:                          # here we can see how "inteligent" the interpretor is
  addq $8, ProgramStackPointer
  jmp loopContinue
decrementStackPointer:
  subq $8, ProgramStackPointer
  jmp loopContinue

addOneToFrame:
    movq ProgramStackPointer, %rax
    incq (%rax)
    jmp loopContinue

decrementOneToFrame:
    movq ProgramStackPointer, %rax
    decq (%rax)
    jmp loopContinue

getCurrentFrame:

    pushq %rdi
    pushq %rsi
    pushq %rcx
    pushq %rdx
    pushq %r8
    pushq %r9
    pushq %rax
    pushq %rbx

    #mov $0, %rax
    #mov $inputString, %rdi
    #mov $JustRed, %rsi
    #call scanf

    #mov JustRed, %rbx
    #mov (%rbx), %rbx

    call getchar
    movq %rax, %rbx

    #mov $'d', %rbx
    movq ProgramStackPointer, %rax
    movq %rbx, (%rax)

    popq %rbx
    popq %rax
    popq %r9
    popq %r8
    popq %rdx
    popq %rcx
    popq %rsi
    popq %rdi

    jmp loopContinue

printCurrentFrame:
    movq $0, %rax
    pushq %rdi
    pushq %rsi
    pushq %rcx
    pushq %rdx
    #movq $format_str, %rdi
    movq ProgramStackPointer, %rsi
    movq (%rsi), %rdi
    call putchar
    #movq $'c', %rsi
    #call printf
    popq %rdx
    popq %rcx
    popq %rsi
    popq %rdi
   jmp loopContinue

endCoroutine:
    movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret


printTemplate:
    pushq %rax
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    
    movq $0, %rax
    movq $format_str, %rdi
    movq (%rdx), %rsi
    call printf
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    popq %rax

