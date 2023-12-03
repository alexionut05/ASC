.data
	i:		.space 4
	j:		.space 4
	m:		.space 4	# lines
	n:		.space 4	# columns
	p:		.space 4	# alive cells
	k:		.space 4	# generations
	array:		.zero 6400
	newArray:	.zero 6400
	formatScanf:	.asciz "%ld"
	formatPrintf:	.asciz "%ld "
	newLine:	.asciz "\n"

.text
.global main
main:
	pushl	$m
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

	pushl	$n
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

	pushl	$p
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

_read_cells:
	xorl	%eax, %eax
	cmp	%eax, p
	je	_exit_read_cells
	decl	p

	pushl	$i
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

	pushl	$j
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

	# to refer to the point (i, j) in the ext. arr:
	# (n + 2) * (i + 1) + j + 1

	xorl	%edx, %edx
	movl	n, %eax		# n
	addl	$2, %eax	# (n+2)
	movl	i, %ebx		# (n+2), i
	incl	%ebx		# (n+2), (i+1)
	mull	%ebx		# (n+2) * (i+1)
	addl	j, %eax		# (n+2) * (i+1) + j

	lea	array, %edi
	movl	$1, 4(%edi, %eax, 4)

	jmp	_read_cells

_exit_read_cells:
	pushl	$k
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

_run_simulation:
	xorl	%eax, %eax
	cmp	%eax, k
	je	_exit_run_simulation
	decl	k

	movl	$0, i

	_simulate_col:
		movl	i, %eax
		cmp	%eax, m
		je	_exit_simulate_col

		movl	$0, j

		_simulate_line:
			movl	j, %eax
			cmp	%eax, n
			je	_exit_simulate_line
			xorl	%ecx, %ecx	# sum

			xorl	%edx, %edx
			movl	n, %eax		# n
			addl	$2, %eax	# (n+2)
			movl	i, %ebx		# (n+2), i
			mull	%ebx		# (n+2)*i
			addl	j, %eax		# (n+2)*i+j

			lea	array, %edi
			addl	(%edi, %eax, 4), %ecx
			addl	4(%edi, %eax, 4), %ecx
			addl	8(%edi, %eax, 4), %ecx

			addl	n, %eax
			addl	$2, %eax

			addl	(%edi, %eax, 4), %ecx
			movl	4(%edi, %eax, 4), %edx
			addl	8(%edi, %eax, 4), %ecx

			addl	n, %eax
			addl	$2, %eax

			addl	(%edi, %eax, 4), %ecx
			addl	4(%edi, %eax, 4), %ecx
			addl	8(%edi, %eax, 4), %ecx

			# now we reset the original (i, j)

			xorl    %edx, %edx
                        movl    n, %eax
                        addl    $2, %eax
                        movl    i, %ebx
                        incl    %ebx
                        mull    %ebx
                        addl    j, %eax
                        movl    %eax, %ebx

			_check_cell_status:
			xorl	%eax, %eax
			cmp	%eax, 4(%edi, %ebx, 4)
			jne	_cell_is_alive

			_cell_is_dead:
			movl	$3, %eax
			cmp	%eax, %ecx
			jne	_exit_check_cell_status

			jmp	_cell_lives

			_cell_is_alive:
			movl	$2, %eax
			cmp	%eax, %ecx
			jl	_cell_dies

			incl	%eax
			cmp	%eax, %ecx
			jg	_cell_dies

			jmp	_cell_lives

			_cell_lives:
			lea	newArray, %edi
			movl	$1, 4(%edi, %ebx, 4)
			jmp	_exit_check_cell_status

			_cell_dies:
			lea	newArray,%edi
			movl	$0, 4(%edi, %ebx, 4)
			jmp	_exit_check_cell_status

			_exit_check_cell_status:
			incl	j
			jmp	_simulate_line
		_exit_simulate_line:
		incl	i
		jmp	_simulate_col
	_exit_simulate_col:
	movl	$0, i

	_copy_array:
		movl	i, %eax
		cmp	%eax, m
		je	_exit_copy_array

		movl	$0, j

		_copy_line:
			movl	j, %eax
			cmp	%eax, n
			je	_exit_copy_line

			xorl	%edx, %edx
			movl	n, %eax		# n
			addl	$2, %eax	# (n+2)
			movl	i, %ebx		# (n+2), i
			incl	%ebx		# (n+2), (i+1)
			mull	%ebx		# (n+2)*(i+1)
			incl	j
			addl	j, %eax		# (n+2)*(i+1)+j+1

			lea	array, %edi
			lea	newArray, %esi
			movl	(%esi, %eax, 4), %ebx
			movl	%ebx, (%edi, %eax, 4)

			jmp	_copy_line
		_exit_copy_line:
		incl	i
		jmp	_copy_array
	_exit_copy_array:
	jmp	_run_simulation

_exit_run_simulation:
	movl	$0, i

_print_array:
	movl	i, %eax
	cmp	%eax, m
	je	_exit_print_array

	movl	$0, j

	_print_line:
		movl	j, %eax
		cmp	%eax, n
		je	_exit_print_line

		xorl	%edx, %edx
		movl	n, %eax		# n
		addl	$2, %eax	# (n+2)
		movl	i, %ebx		# (n+2), i
		incl	%ebx		# (n+2), (i+1)
		mull	%ebx		# (n+2)*(i+1)
		incl	j
		addl	j, %eax		# (n+2)*(i+1)+j+1

		lea	newArray, %edi
		pushl	(%edi, %eax, 4)
		pushl	$formatPrintf
		call	printf
		popl	%eax
		popl	%eax

		pushl	$0
		call	fflush
		popl	%ebx

		jmp	_print_line
	_exit_print_line:
	movl	$4, %eax
	movl	$1, %ebx
	movl	$newLine, %ecx
	movl	$2, %edx
	int	$0x80

	incl	i
	jmp	_print_array
_exit_print_array:
	jmp	exit

exit:
	movl	$1, %eax
	xorl	%ebx, %ebx
	int	$0x80
