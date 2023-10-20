.data
	x: .long 17
	d: .long 1
	dd: .long 0
	textPass: .asciz "PRIM\n"
	textFail: .asciz "NON-PRIM\n"
.text
.global main

main:
	mov	$1, %ebx
	movl	x, %eax
	cmp	%eax, %ebx
	jge	fail

	mov	$2, %ebx
	cmp	%eax, %ebx
	je	pass

	jmp	check

check:
	addl	$1, d
	movl	d, %eax
	movl	%eax, dd
	imull	dd, %eax
	cmp	%eax, x
	jl	pass

	movl	%eax, dd
	mov	$0, %edx
	movl	x, %eax
	movl	d, %ebx
	idivl	%ebx

	mov	$0, %eax
	cmp	%edx, %eax
	je	fail

	jmp	check

pass:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$textPass, %ecx
	mov	$6, %edx
	int	$0x80

	jmp	exit

fail:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$textFail, %ecx
	mov	$10, %edx
	int	$0x80

	jmp	exit

exit:
	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
