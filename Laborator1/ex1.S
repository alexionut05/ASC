.data
	x:	.long 12345
	y:	.long 94181
.text
.global main

main:
	movl	x, %eax
	movl	y, %ebx
	movl	%eax, y
	movl	%ebx, x

	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
