.global read_file

# Taken from <stdio.h>
.equ SEEK_SET,  0
.equ SEEK_CUR,  1
.equ SEEK_END,  2
.equ EOF,      -1

file_mode: .asciz "r"

# TO DO : free the memory buffer
read_file:
	pushq %rbp
	movq %rsp, %rbp

	# internal stack usage:
	#  -8(%rbp) saved read_bytes pointer
	# -16(%rbp) FILE pointer
	# -24(%rbp) file size
	# -32(%rbp) address of allocated buffer
	subq $32, %rsp

	movq %rsi, -8(%rbp)

	movq $file_mode, %rsi
	call fopen
	testq %rax, %rax
	jz _read_file_open_failed
	movq %rax, -16(%rbp)

	movq %rax, %rdi
	movq $0, %rsi
	movq $SEEK_END, %rdx
	call fseek
	testq %rax, %rax
	jnz _read_file_seek_failed

	movq -16(%rbp), %rdi
	call ftell
	cmpq $EOF, %rax
	je _read_file_tell_failed
	movq %rax, -24(%rbp)

	movq -16(%rbp), %rdi
	movq $0, %rsi
	movq $SEEK_SET, %rdx
	call fseek
	testq %rax, %rax
	jnz _read_file_seek_failed

	movq -24(%rbp), %rdi
	incq %rdi
	call malloc
	test %rax, %rax
	jz _read_file_malloc_failed
	movq %rax, -32(%rbp)


	movq %rax, %rdi
	movq $1, %rsi
	movq -24(%rbp), %rdx
	movq -16(%rbp), %rcx
	call fread
	movq -8(%rbp), %rdi
	movq %rax, (%rdi)

	movq -32(%rbp), %rdi
	movb $0, (%rdi, %rax)

	movq -16(%rbp), %rdi
	call fclose

	movq -32(%rbp), %rax
	movq %rbp, %rsp
	popq %rbp
	ret

_read_file_malloc_failed:
_read_file_tell_failed:
_read_file_seek_failed:
	movq -16(%rbp), %rdi
	call fclose

_read_file_open_failed:
	movq -8(%rbp), %rax
	movq $0, (%rax)
	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
