.data
	Idx01:		.space 4
	Idx02:		.space 4
	Lines:		.space 4
	Columns:	.space 4
	Temp:		.space 4
	FormatScanf:	.asciz "%ld"
	FormatPrintf:	.asciz "%ld "
	ArrCells:	.zero 400
	ArrNeighbrCnt:	.zero 400
	NewLine:	.asciz "\n"
	fp:		.space 4
	.LC0:		.asciz "r"
	.LC1:		.asciz "w"
	.LC2:		.asciz "in.txt"
	.LC3:		.asciz "out.txt"

.text

.globl main
main:			pushl	$.LC0
			pushl	$.LC2
			call	fopen
			movl	%eax, fp

			pushl	$Lines
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			pushl	$Columns
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			pushl	$Temp
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			movl	Temp, %ebx

read_cells.loop:	testl	%ebx, %ebx		# check exit condition
			jz	read_cells.exit		#
			decl	%ebx			#

			pushl	$Idx01
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			pushl	$Idx02
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			movl	Columns, %eax		# (n+2)*(i+1)+j+1
			addl	$2, %eax		#
			movl	Idx01, %ecx		#
			incl	%ecx			#
			mull	%ecx			#
			movl	Idx02, %ecx		#
			addl	%ecx, %eax		#

			leal	ArrCells, %edi
			movb	$1, 1(%edi, %eax, 1)

			jmp	read_cells.loop

read_cells.exit:	pushl	$Temp
			pushl	$FormatScanf
			pushl	fp
			call	fscanf

			pushl	fp
			call	fclose

			pushl	$.LC1
			pushl	$.LC3
			call	fopen
			movl	%eax, fp

			movl	Temp, %esi

simulate_gens.loop:	testl	%esi, %esi		# check exit condition
			jz	simulate_gens.exit	#
			decl	%esi			#

neighbr_cnt:		movb	Lines, %bl

	for_lin00.loop:	testb	%bl, %bl		# check exit condition
			jz	for_lin00.exit		#

			movb	Columns, %bh

	for_col00.loop:	testb	%bh, %bh		# check exit condition
			jz	for_col00.exit		#

			xorb	%dl, %dl		# in %dl we save the neighbours count

			movl	Columns, %eax
			addl	$2, %eax
			movl	%eax, %ebp		# in %ebp we save (n+2) for easier future access
			movl	Lines, %ecx
			subb	%bl, %cl
			mull	%ecx
			movl	Columns, %ecx
			subb	%bh, %cl
			addw	%cx, %ax
			leal	ArrCells, %edi

			addb	0(%edi, %eax, 1), %dl
			addb	1(%edi, %eax, 1), %dl
			addb	2(%edi, %eax, 1), %dl
			addl	%ebp, %eax
			addb	0(%edi, %eax, 1), %dl
			addb	2(%edi, %eax, 1), %dl
			addl	%ebp, %eax
			addb	0(%edi, %eax, 1), %dl
			addb	1(%edi, %eax, 1), %dl
			addb	2(%edi, %eax, 1), %dl

			subl	%ebp, %eax
			leal	ArrNeighbrCnt, %edi
			movb	%dl, 1(%edi, %eax, 1)

			decb	%bh
			jmp	for_col00.loop
	for_col00.exit:

			decb	%bl
			jmp	for_lin00.loop
	for_lin00.exit:

calculate_cells:	movb	Lines, %bl

	for_lin01.loop:	testb	%bl, %bl		# check exit condition
			jz	for_lin01.exit		#
			movb	Columns, %bh

	for_col01.loop:	testb	%bh, %bh		# check exit condition
			jz	for_col01.exit		#

			movl	Columns, %eax
			addl	$2, %eax
			movl	Lines, %ecx
			subb	%bl, %cl
			incb	%cl
			mull	%ecx
			movl	Columns, %ecx
			subb	%bh, %cl
			addl	%ecx, %eax
			movl	%eax, %ebp

			leal	ArrCells, %edi

			xorl	%ecx, %ecx
			movb	1(%edi, %ebp, 1), %ah
			testb	%ah, %ah
			setnz	%ah				# if (cell_is_alive) %ah = 1
			setz	%al				# else               %al = 1

			leal	ArrNeighbrCnt, %edi

			movb	$3, %dl
			movb	1(%edi, %ebp, 1), %dh
			cmpb	%dl, %dh			# if (neighbours == 3) %cl = 1
			sete	%cl

			movb	$2, %dl
			movb	1(%edi, %ebp, 1), %dh
			cmpb	%dl, %dh			# if (neighbours == 2) %ch = 1
			sete	%ch

			andb	%cl, %al			# %al = (cell_is_dead && neighbours == 3)
			orb	%ch, %cl			# %cl = (neigbhours == 3 || neigbhours == 2)
			andb	%cl, %ah			# %ah = (cell_is alive && (neighbours == 3 || neighbours == 2))
			orb	%ah, %al			# %al = %al || %ah

			leal	ArrCells, %edi
			movb	%al, 1(%edi, %ebp, 1)

			decb	%bh
			jmp	for_col01.loop
	for_col01.exit:

			decb	%bl
			jmp	for_lin01.loop
	for_lin01.exit:

			jmp	simulate_gens.loop
simulate_gens.exit:

print_array:		movb	Lines, %bl

	for_lin02.loop:	testb	%bl, %bl
			jz	for_lin02.exit
			movb	Columns, %bh

	for_col02.loop:	testb	%bh, %bh
			jz	for_col02.exit

			movl	Columns, %eax
			movl	Lines, %ecx
			addl	$2, %eax
			subb	%bl, %cl
			incl	%ecx
			mull	%ecx
			addl	Columns, %eax
			subb	%bh, %al
			leal	ArrCells, %edi

			movb	1(%edi, %eax, 1), %cl
			pushl	%ecx
			pushl	$FormatPrintf
			pushl	fp
			call	fprintf

			decb	%bh
			jmp	for_col02.loop
	for_col02.exit:
			pushl	$NewLine
			pushl	fp
			call	fprintf

			decb	%bl
			jmp	for_lin02.loop
	for_lin02.exit:

			pushl	fp
			call	fclose
exit:			movl	$1, %eax
			xorl	%ebx, %ebx
			int	$0x80
