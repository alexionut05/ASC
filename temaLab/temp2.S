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
_read_cells:
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

	# to refer to the point (i,j) in the ext. arr.
	# we use: (2 + n) * (1 + i) + j + 1

	xorl	%edx, %edx
	movl	n, %eax		# (n)
	addl	$2, %eax	# (2 + n)
	movl	i, %ebx		# (i)
	incl	%ebx		# (1 + i)
	mull	%ebx		# (2 + n) * (1 + i)
	addl	j, %eax		# (2 + n) * (1 + i) + j

	lea	array, %edi
	movl	$1, 4(%edi, %eax, 4)

	decl	p
	xorl	%eax, %eax
	cmp	%eax, p
	jne	_read_cells

	ret


_run_simulation:
	xorl	%ebp, %ebp

	simulateCol:
		xorl	%esp, %esp

		simulateLine:
			# we will use %ecx as sum of cells
			xorl	%ecx, %ecx

			xorl	%edx, %edx
			movl	n, %eax
			addl	$2, %eax
			movl	%ebp, %ebx
			mull	%ebx
			addl	%esp, %eax

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
			movl	%ebp, %ebx
			incl	%ebx
			mull	%ebx
			addl	%esp, %eax
			movl	%eax, %ebx

			# Checking what to do next
			xorl	%eax, %eax
			cmp	%eax, 4(%edi, %ebx, 4)
			jne	cellIsAlive

			cellIsDead:
				movl	$3, %eax
				cmp	%eax, %ecx
				jne	cellSkip

				jmp	cellLives

			cellIsAlive:
				# Check for underpop:
				movl	$2, %eax
				cmp	%eax, %ecx
				jl	cellDies

				# Check for overpop:
				incl	%eax
				cmp	%eax, %ecx
				jg	cellDies

				jmp	cellLives

			cellLives:
				lea	newArray, %edi
				movl	$1, 4(%edi, %ebx, 4)
				jmp	cellSkip

			cellDies:
				lea	newArray, %edi
				movl	$0, 4(%edi, %ebx, 4)
				jmp	cellSkip

			cellSkip:

			incl	%esp
			cmp	%esp, n
			jne	simulateLine

		incl	%ebp
		cmp	%ebp, m
		jne	simulateCol

	xorl	%ebp, %ebp

	copyArray:
		xorl	%esp, %esp

		copyLine:
			xorl	%edx, %edx
			movl	n, %eax
			addl	$2, %eax
			movl	%ebp, %ebx
			incl	%ebx
			mull	%ebx
			addl	%esp, %eax

			lea	array, %edi
			lea	newArray, %esi
			movl	4(%esi, %eax, 4), %ebx
			movl	%ebx, 4(%edi, %eax, 4)

			incl	%esp
			cmp	%esp, n
			jne	copyLine

		incl	%ebp
		cmp	%ebp, m
		jne	copyArray

	decl	k
	xorl	%eax, %eax
	cmp	%eax, k
	jne	_run_simulation

	ret


_print_array:
	xorl	%esp, %esp

	printLine:
		xorl	%edx, %edx
		movl	n, %eax
		addl	$2, %eax
		movl	%ebp, %ebx
		incl 	%ebx
		mull	%ebx
		addl	%esp, %eax

		lea	newArray, %edi
		pushl	4(%edi, %eax, 4)
		pushl	$formatPrintf
		call	printf
		popl	%ebx
		popl	%ebx

		pushl	$0
		call	fflush
		popl	%ebx

		incl	%esp
		cmp	%esp, n
		jne	printLine

	printNewLine:
		movl	$4, %eax
		xorl	%ebx, %ebx
		movl	$newLine, %ecx
		movl	$2, %edx
		int	$0x80

	incl	%ebp
	cmp	%ebp, m
	jne	_print_array

	ret


_exit:
	movl	$1, %eax
	xorl	%ebx, %ebx
	int	$0x80


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

	xorl	%eax, %eax
	cmp	%eax, p
	je	noCellsToRead

	call	_read_cells

noCellsToRead:
	pushl	$k
	pushl	$formatScanf
	call	scanf
	popl	%eax
	popl	%eax

	# we will use %ebp as i
	# we will use %esp as j
	call	_run_simulation

	xorl	%ebp, %ebp
	call	_print_array

	call	_exit
