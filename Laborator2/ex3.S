.data
	a: .long 1
	b: .long 2
	c: .long 3
	min: .space 4
.text
.global main

main:
	movl	b, %eax
	cmp	a, %eax
	jbe	ba
	ja	ab

ba:
	movl	c, %eax
	cmp	b, %eax
	jbe	cmin

	movl	b, %eax
	mov	%eax, min
	jmp	exit
ab:
	movl	c, %eax
	cmp	a, %eax
	jbe	cmin

	mov	a, %eax
	mov	%eax, min
	jmp	exit

cmin:
	movl	c, %eax
	mov	%eax, min
	jmp	exit

exit:
	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
