.data
	Idx01:		.space 4
	Idx02:		.space 4
	Lines:		.space 4
	Columns:	.space 4
	Temp:		.space 4
	ArrCells:	.zero 400
	ArrNeighbrCnt:	.zero 400
	HexPref:	.asciz "0x"
	NewLine:	.asciz "\n"
	FormatScanf:	.asciz "%ld"
	FormatPrintf:	.asciz "%ld "
	FormatScanfStr:	.asciz "%s"
	FormatPrintfCh:	.asciz "%c"
	Text:		.space 23

.text
.globl main
main:			pushl	$Lines
			pushl	$FormatScanf
			call	scanf

			pushl	$Columns
			pushl	$FormatScanf
			call	scanf

			pushl	$Temp
			pushl	$FormatScanf
			call	scanf

			movl	Temp, %ebx

read_cells.loop:	testl	%ebx, %ebx		# check exit condition
			jz	read_cells.exit		#
			decl	%ebx			#

			pushl	$Idx01
			pushl	$FormatScanf
			call	scanf

			pushl	$Idx02
			pushl	$FormatScanf
			call	scanf

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
			call	scanf

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

			pushl	$Temp
			pushl	$FormatScanf
			call	scanf

			pushl	$Text
			pushl	$FormatScanfStr
			call	scanf

			movl	Temp, %eax
			testl	%eax, %eax
			jnz	decrypt

encrypt:		leal	Text, %edi
			xorl	%ebx, %ebx
	strlen00.loop:	movb	(%edi, %ebx, 1), %al
			testb	%al, %al
			jz	strlen00.exit
			incb	%bl
			jmp	strlen00.loop
	strlen00.exit:	movl	%ebx, Temp
			shlb	$3, %bl
			movl	Lines, %eax
			addl	$2, %eax
			movl	Columns, %esi
			addl	$2, %esi
			mull	%esi
			movl	%eax, %esi
			movl	%eax, %ebp

			leal	ArrCells, %edi
	extend00.loop:	cmp	%ebx, %ebp
			jg	extend00.exit
			xorl	%ecx, %ecx
			movl	%ebp, %edx
	cpy00.loop:	cmp	%ecx, %esi
			je	cpy00.exit
			movb	(%edi, %ecx, 1), %al
			movb	%al, (%edi, %edx, 1)
			incl	%ecx
			incl	%edx
			jmp	cpy00.loop
	cpy00.exit:
			addl	%esi, %ebp
			jmp	extend00.loop
	extend00.exit:
			movl	$4, %eax
			movl	$1, %ebx
			movl	$HexPref, %ecx
			movl	$3, %edx
			int	$0x80

			xorl	%esi, %esi
	print00.loop:	movl	Temp, %eax
			cmpl	%esi, %eax
			je	print00.exit

			xorb	%bl, %bl
			leal	ArrCells, %edi
	make_mask00:	addb	0(%edi, %esi, 8), %bl
			shlb	%bl
			addb	1(%edi, %esi, 8), %bl
			shlb	%bl
			addb	2(%edi, %esi, 8), %bl
			shlb	%bl
			addb	3(%edi, %esi, 8), %bl
			shlb	%bl
			addb	4(%edi, %esi, 8), %bl
			shlb	%bl
			addb	5(%edi, %esi, 8), %bl
			shlb	%bl
			addb	6(%edi, %esi, 8), %bl
			shlb	%bl
			addb	7(%edi, %esi, 8), %bl

			leal	Text, %edi
			movb	(%edi, %esi, 1), %ah
			xorb	%bl, %ah
			movb	%ah, %al
			shrb	$4, %ah
			shlb	$4, %al
			shrb	$4, %al

			movb	$48, %bh
			movb	$48, %bl
			addb	%ah, %bh
			addb	%al, %bl

			xorl	%ecx, %ecx
			movl	$58, %eax
			cmpb	%bh, %al
			setle	%cl
			movl	$7, %eax
			mull	%ecx
			addb	%al, %bh

			xorl	%ecx, %ecx
			movl	$58, %eax
			cmpb	%bl, %al
			setle	%cl
			movl	$7, %eax
			mull	%ecx
			addb	%al, %bl

			movb	%bh, %al
			pushl	%eax
			pushl	$FormatPrintfCh
			call	printf

			movb	%bl, %al
			pushl	%eax
			pushl	$FormatPrintfCh
			call	printf

			pushl	$0
			call	fflush
			incl	%esi
			jmp	print00.loop
	print00.exit:
			movl	$4, %eax
			movl	$1, %ebx
			movl	$NewLine, %ecx
			movl	$2, %edx
			int	$0x80
			jmp	exit

decrypt:		leal	Text, %edi
			xorl	%ebx, %ebx
	strlen01.loop:	movb	(%edi, %ebx, 1), %al
			testb	%al, %al
			jz	strlen01.exit
			incb	%bl
			jmp	strlen01.loop
	strlen01.exit:	movl	%ebx, Temp
			shlb	$2, %bl
			movl	Lines, %eax
			addl	$2, %eax
			movl	Columns, %esi
			addl	$2, %esi
			mull	%esi
			movl	%eax, %esi
			movl	%eax, %ebp

			leal	ArrCells, %edi
	extend01.loop:	cmpl	%ebx, %ebp
			jg	extend01.exit
			xorl	%ecx, %ecx
			movl	%ebp, %edx
	cpy01.loop:	cmpl	%ecx, %esi
			je	cpy01.exit
			movb	(%edi, %ecx, 1), %al
			movb	%al, (%edi, %edx, 1)
			incl	%ecx
			incl	%edx
			jmp	cpy01.loop
	cpy01.exit:
			addl	%esi, %ebp
			jmp	extend01.loop
	extend01.exit:
			xorl	%esi, %esi
			addl	$2, %esi
	print01.loop:	movl	Temp, %eax
			cmpl	%esi, %eax
			jle	print01.exit

			xorl	%ebx, %ebx
			leal	ArrCells, %edi
	make_mask01:	addb	-8(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-7(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-6(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-5(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-4(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-3(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-2(%edi, %esi, 4), %bl
			shlb	%bl
			addb	-1(%edi, %esi, 4), %bl

			leal	Text, %edi
			movb	0(%edi, %esi, 1), %al
			subb	$48, %al
			movb	%al, %bh
			movb	$10, %al
			cmpb	%bh, %al
			setle	%cl
			movl	$7, %eax
			mull	%ecx
			subb	%al, %bh
			shlb	$4, %bh

			movb	1(%edi, %esi, 1), %al
			subb	$48, %al
			addb	%al, %bh
			movb	%al, %cl
			movb	$10, %al
			cmpb	%cl, %al
			setle	%cl
			movl	$7, %eax
			mull	%ecx
			subb	%al, %bh
			addl	%esi, %ebp
			xorb	%bl, %bh
			shrl	$8, %ebx

			pushl	%ebx
			pushl	$FormatPrintfCh
			call	printf

			pushl	$0
			call	fflush
			addl	$2, %esi
			jmp	print01.loop
	print01.exit:
			movl	$4, %eax
			movl	$1, %ebx
			movl	$NewLine, %ecx
			movl	$2, %edx
			int	$0x80
			jmp	exit

exit:			movl	$1, %eax
			xorl	%ebx, %ebx
			int	$0x80
