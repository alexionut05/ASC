.data
	x: .long 256
	y: .long 1
	prod: .long 0
	cat: .long 0
	sum: .long 0
	testPass: .asciz "PASS\n"
	testFail: .asciz "FAIL\n"
.text
.global main

main:
	mov	$0, %edx
	mov	x, %eax
	mov	$16, %ebx
	idiv	%ebx
	mov	%eax, cat

	mov	y, %eax
	mov	$16, %ebx
	imul	%ebx
	mov	%eax, prod

	movl	$0, cat
	movl	$0, prod

	mov	x, %eax
	sar	$4, %eax
	mov	%eax, cat

	mov	y, %eax
	sal	$4, %eax
	mov	%eax, prod

	mov	cat, %eax
	mov	prod, %ebx
	add	%ebx, %eax
	mov	%eax, sum

	mov	cat, %eax
	mov	prod, %ebx
	cmp	%eax, %ebx
	je	pass
	jne	fail

pass:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$testPass, %ecx
	mov	$6, %edx
	int	$0x80

	jmp	exit

fail:
	mov	$4, %eax
	mov	$1, %ebx
	mov	$testFail, %ecx
	mov	$6, %edx
	int	$0x80

	jmp	exit

exit:
	mov	$1, %eax
	mov	$0, %ebx
	int	$0x80
