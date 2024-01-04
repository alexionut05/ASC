.data
.LC0:		.asciz "r"
.LC1:		.asciz "w"
.LC2:		.asciz "%ld"
.LC3:		.asciz "%ld "
.LC4:		.asciz "input.txt"
.LC5:		.asciz "output.txt"
fp:		.space 4
a:		.space 4

.text
.globl main
main:		pushl	$.LC0
		pushl	$.LC4
		call	fopen
		movl	%eax, fp
		addl	$8, %esp
ok:
		pushl	$a
		pushl	$.LC2
		pushl	fp
		call	fscanf
		addl	$12, %esp
ok2:
		pushl	fp
		call	fclose
		addl	$4, %esp

		pushl	$.LC1
		pushl	$.LC5
		call	fopen
		movl	%eax, fp
		addl	$8, %esp

		pushl	a
		pushl	$.LC3
		pushl	fp
		call	fprintf
		addl	$12, %esp

		pushl	fp
		call	fclose
		addl	$4, %esp

exit:		movl	$1, %eax
		xorl	%ebx, %ebx
		int	$0x80
