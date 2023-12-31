.data
	x:	.long 2147483647
        textP: 	.asciz "PRIM\n"
	textF:	.asciz "NON-PRIM\n"

.text
.global main

main:
	movl	x, %eax
	mov	$2, %ebx
	cmp	%eax, %ebx
	jg	fail
	je	pass

	mov	$0, %edx
	idivl	%ebx
	mov	$0, %eax
	cmp	%eax, %edx
	je	fail

	mov	$3, %ebx
	jmp	check


check:
	mov	$0, %edx
	movl	x, %eax
	idivl	%ebx
	mov	$0, %eax
	cmp	%eax, %edx
	je	fail

	cmp	%ebx, %ecx
	jl	pass

	addl	$2, %ebx
	jmp	check


pass:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$textP, %ecx
	mov	$6, %edx
	int	$0x80

	jmp	exit


fail:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$textF, %ecx
	mov	$10, %edx
	int	$0x80

	jmp	exit


exit:
	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
