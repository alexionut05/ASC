.data
	i:		.space 4
	j:		.space 4
	m:		.space 4	# lines
	n:		.space 4	# columns
	p:		.space 4	# alive cells
	k:		.space 4	# generations
	array:		.zero 400
	formatScanf:	.asciz "%ld"
	formatPrintf:	.asciz "%ld "
	newLine:	.asciz "\n"

.text
.global main
main:
	pushl	$m
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

	pushl	$n
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

	pushl	$p
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

_read_cells:
	xorl	%eax, %eax
	movl	p, %ebx
	cmp	%eax, %ebx
	je	_exit_read_cells
	decl	%ebx
	movl	%ebx, p

	pushl	$i
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

	pushl	$j
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

	movl	n, %eax
	addl	$2, %eax
	movl	i, %ebx
	incl	%ebx
	mull	%ebx
	addl	j, %eax

	lea	array, %edi
	movl	$1, 1(%edi, %eax, 1)

	jmp	_read_cells
_exit_read_cells:

	pushl	$k
	pushl	$formatScanf
	call	scanf
	addl	$8, %esp

_run_simulation:
	xorl	%eax, %eax
	movl	k, %ebx
	cmp	%eax, %ebx
	je	_exit_run_simulation
	decl	%ebx
	movl	%ebx, k

	movl	%eax, i

	_simulate_col:
		movl	i, %eax
		movl	m, %ebx
		cmp	%eax, %ebx
		je	_exit_simulate_col

		xorl	%eax, %eax
		movl	%eax, j

		_simulate_line:
			movl	j, %eax
			movl	n, %ebx
			cmp	%eax, %ebx
			je	_exit_simulate_line
			xorl	%ecx, %ecx

			movl	n, %eax
			addl	$2, %eax
			movl	i, %ebx
			mull	%ebx
			addl	j, %eax

			lea	array, %edi
			add	(%edi, %eax, 1), %ecx
			add	1(%edi, %eax, 1), %ecx
			add	2(%edi, %eax, 1), %ecx

			addl	n, %eax
			addl	$2, %eax
			add	(%edi, %eax, 1), %ecx
			movl	%eax, %edx
			add	2(%edi, %eax, 1), %ecx

			addl	n, %eax
			addl	$2, %eax
			add	(%edi, %eax, 1), %ecx
			add	1(%edi, %eax, 1), %ecx
			add	2(%edi, %eax, 1), %ecx

			
		_exit_simulate_line:

	_exit_simulate_col:

_exit_run_simulation:

_exit:
	movl	$1, %eax
	xorl	%ebx, %ebx
	int	$0x80
