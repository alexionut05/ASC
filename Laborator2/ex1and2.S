.data
	x:	.long 512
	y:	.long 2
	sum:	.long 0
	textP:	.asciz "PASS\n"
	textF:	.asciz "FAIL\n"

.text
.global main

main:
	mov	$0, %edx
	movl	x, %eax
	mov	$16, %ebx
	idivl	%ebx
	movl	%eax, sum
	movl	%eax, %ecx

	movl	y, %eax
	imull	%ebx
	addl	%eax, sum

	cmp	%eax, %ecx
	je	pass
	jmp	fail


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
	mov	$6, %edx
	int	$0x80

	jmp	exit


exit:
	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
