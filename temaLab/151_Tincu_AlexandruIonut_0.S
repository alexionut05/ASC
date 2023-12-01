.data
	i:		.space 4	# line index
	j:		.space 4	# column index
	m:		.space 4	# lines
	n:		.space 4	# columns
	p:		.space 4	# alive cells
	k:		.space 4	# generations to simulate
	array:		.zero 6400
	newArray:	.zero 6400
	formatScanf:	.asciz "%ld"
	formatPrintf:	.asciz "%ld "
	newLine:	.asciz "\n"

.text
_read_cells:
	pushl	$i
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	pushl	$j
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	# to refer to the point (i,j) in the extended array
	# we use the formula: (2 + n) * (1 * i) + j + 1

	xorl	%edx, %edx
	movl	n, %eax
	addl	$2, %eax
	movl	i, %ebx
	incl	%ebx
	mull	%ebx
	addl	j, %eax

	lea	array, %edi
	movl	$1, 4(%edi, %eax, 4)

	decl	p
	xorl	%eax, %eax
	cmp	%eax, p
	jg	_read_cells
	ret


_print_array:
	movl	$0, j

	_print_line:
		xorl	%edx, %edx
		movl	n, %eax
		addl	$2, %eax
		movl	i, %ebx
		incl 	%ebx
		mull	%ebx
		addl	j, %eax

		lea	newArray, %edi
		pushl	4(%edi, %eax, 4)
		pushl	$formatPrintf
		call	printf
		popl	%ebx
		popl	%ebx

		pushl	$0
		call	fflush
		popl	%ebx

		incl	j
		movl	j, %eax
		cmp	%eax, n
		jne	_print_line

	_print_new_line:
		movl	$4, %eax
		movl	$1, %ebx
		movl	$newLine, %ecx
		movl	$2, %edx
		int	$0x80

	incl	i
	movl	i, %eax
	cmp	%eax, m
	jne	_print_array
	ret


_run_simulation:
	movl	$0, i

	_simulate_col:
		movl	$0, j

		_simulate_line:
			xorl	%ecx, %ecx	# %ecx will be used as sum

			xorl	%edx, %edx
			movl	n, %eax
			addl	$2, %eax
			movl	i, %ebx
			mull	%ebx
			addl	j, %eax

			lea	array, %edi
			addl	(%edi, %eax, 4), %ecx
			addl	4(%edi, %eax, 4), %ecx
			addl	8(%edi, %eax, 4), %ecx

			addl	n, %eax
			addl	$2, %eax

			addl	(%edi, %eax, 4), %ecx
			addl	8(%edi, %eax, 4), %ecx

			addl	n, %eax
			addl	$2, %eax

			addl	(%edi, %eax, 4), %ecx
			addl	4(%edi, %eax, 4), %ecx
			addl	8(%edi, %eax, 4), %ecx

			xorl	%edx, %edx
			movl	n, %eax
			addl	$2, %eax
			movl	i, %ebx
			incl	%ebx
			mull	%ebx
			addl	j, %eax
			movl	%eax, %ebx

			# Checking what to do next
			xorl	%eax, %eax
			cmp	%eax, 4(%edi, %ebx, 4)
			jne	_cell_is_alive

			_cell_is_dead:
				movl	$3, %eax
				cmp	%eax, %ecx
				jne	_do_nothing

				jmp	_cell_lives

			_cell_is_alive:
				# Check for underpop:
				movl	$2, %eax
				cmp	%eax, %ecx
				jl	_cell_dies

				# Check for overpop:
				incl	%eax
				cmp	%eax, %ecx
				jg	_cell_dies

				jmp	_cell_lives

			_cell_lives:
				lea	newArray, %edi
				movl	$1, 4(%edi, %ebx, 4)
				jmp	_do_nothing

			_cell_dies:
				lea	newArray, %edi
				movl	$0, 4(%edi, %ebx, 4)
				jmp	_do_nothing

			_do_nothing:

			incl	j
			movl	j, %eax
			cmp	%eax, n
			jne	_simulate_line

		incl	i
		movl	i, %eax
		cmp	%eax, m
		jne	_simulate_col

	movl	$0, i

	_copy_array:
		movl	$0, j

		_copy_line:
			xorl	%edx, %edx
			movl	n, %eax
			addl	$2, %eax
			movl	i, %ebx
			incl	%ebx
			mull	%ebx
			addl	j, %eax

			lea	array, %edi
			lea	newArray, %esi
			movl	4(%esi, %eax, 4), %ebx
			movl	%ebx, 4(%edi, %eax, 4)

			incl	j
			movl	j, %eax
			cmp	%eax, n
			jne	_copy_line

		incl	i
		movl	i, %eax
		cmp	%eax, m
		jne	_copy_array

	decl	k
	xorl	%eax, %eax
	cmp	%eax, k
	jne	_run_simulation
	ret


.global main
main:
	pushl	$m
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	pushl	$n
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	pushl	$p
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	call	_read_cells

	pushl	$k
	pushl	$formatScanf
	call	scanf
	popl	%ebx
	popl	%ebx

	call	_run_simulation

	movl	$0, i
	call	_print_array


exit:
	movl	$1, %eax
	xorl	%ebx, %ebx
	int	$0x80
