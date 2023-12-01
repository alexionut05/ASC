.data
	str:		.space 13
	len:		.space 4
	idx:		.space 4
	formatPrintf:	.asciz "%d "
	ch:		.space	1
.text
_strlen:
	lea	str, %edi
	movl	(%edi, %ebp, 1), %ebx
	xorl	%eax, %eax
	incl	%ebp

	cmp	%eax, %ebx
	jne	_strlen

	decl	%ebp
	decl	%ebp

	movl	%ebp, len
	ret

_print_chars:
	lea	str, %edi
	xorl	%ebx, %ebx
	movb	(%edi, %ebp, 1), %bl

	pushl	%ebx
	pushl	$formatPrintf
	call	printf
	popl	%eax
	popl	%eax

	pushl	$0
	call	fflush
	popl	%eax

	incl	%ebp

	cmp	%ebp, len
	jne	_print_chars

	ret

_exit:
	movl	$1, %eax
	xorl	%ebx, %ebx
	int	$0x80

.global main
main:
	movl	$3, %eax
	xorl	%ebx, %ebx
	movl	$str, %ecx
	movl	$13, %edx
	int	$0x80

	xorl	%ebp, %ebp
	call	_strlen

ok:
	xorl	%ebp, %ebp
	call	_print_chars

	call	_exit
