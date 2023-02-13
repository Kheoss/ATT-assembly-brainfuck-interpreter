.global main

usage_format: .asciz "usage: %s <filename>\n"

main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp

	cmp $2, %rdi
	jne wrong_argc

	movq 8(%rsi), %rdi
	leaq -8(%rbp), %rsi
	call read_file
	test %rax, %rax
	jz failed
	movq %rax, -16(%rbp)

	movq %rax, %rdi
	call brainfuck

	movq -16(%rbp), %rdi
	call free

	mov $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret

wrong_argc:
	movq $usage_format, %rdi
	movq (%rsi), %rsi # %rsi still hold argv up to this point
	call printf

failed:
	movq $1, %rax

	movq %rbp, %rsp
	popq %rbp
	ret
