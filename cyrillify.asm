

; syscall numbers: /usr/src/linux/include/asm-x86_64/unistd.h
; parameters order:
; r9    ; 6th param
; r8    ; 5th param
; r10   ; 4th param
; rdx   ; 3rd param
; rsi   ; 2nd param
; rdi   ; 1st param
; eax   ; syscall_number
; syscall

format ELF64 executable 3

segment readable executable

entry $
	pop	rcx		;number of args
	cmp	ecx,1
	je	file_err
	pop	rbx		;name of prog
	pop	rdi		;get filename
	push	rcx
	jl	.open
	;pop	rcx
	;mov	rax,[rcx]
	;mov	rcx,[switch]
 .open:
	mov	rax,2		
	mov	rsi,2
	mov	rdx,0777
	syscall			;open file
	cmp	rax,0
	jl	file_err
	mov	[fd_in],rax	;save filedescriptor
	call	createtemp
	pop	rcx
	cmp	rcx,3
	jl	.smloop
	pop	rcx
	cmp	[rcx],word '-s'
	je	.stloop
	jmp	switch_err
 .smloop:
	call	read
	push	rax		;save bytes read
	call	similar
	call	writetemp
	pop	rax
	cmp	rax,bufsize	;if the buffer was not filled, we've reached the last read
	je	.smloop
	jmp	.done	
 .stloop:
	call	read
	push	rax		;save bytes read
	call	stealth
	call	writetemp
	pop	rax
	cmp	rax,bufsize	;if the buffer was not filled, we've reached the last read
	je	.stloop
 .done:
	call	overwrite
	jmp	cleanup

read:
	mov	rdi,[fd_in]
	mov	rax,0
	mov	rsi,readbuf
	mov 	rdx,bufsize
	syscall	
	;sub	rax,1
	mov	[bytesread],rax
	ret
stealth:
	mov	rcx,0		;count for # of bytes processed
	mov	edx,readbuf	;in
	mov	ebx,writebuf	;out

	mov	[bufwritten],0 	;clear variable
 .loop:
	cmp	rcx,[bytesread]	
	je	.done
;***********comparisons***********
	cmp	[edx],byte 61h
	jge	.lowercase
		;the cyrillic is stored in edi
		;we compare the current byte with the test case
		;either go to replace or fall through

	mov	edi,'Т'
	cmp	[edx],byte 'T'
	je	.replace

	mov	edi,'М'
	cmp	[edx],byte 'M'
	je	.replace

	mov	edi,'Н'
	cmp	[edx],byte 'H'
	je	.replace

	mov	edi,'Р'
	cmp	[edx],byte 'P'
	je	.replace

	mov	edi,'А'
	cmp	[edx],byte 'A'
	je	.replace

	mov	edi,'В'
	cmp	[edx],byte 'B'
	je	.replace

	mov	edi,'С'
	cmp	[edx],byte 'C'
	je	.replace

	mov	edi,'Е'
	cmp	[edx],byte 'E'
	je	.replace

	mov	edi,'О'
	cmp	[edx],byte 'O'
	je	.replace

	mov	edi,'К'
	cmp	[edx],byte 'K'
	je	.replace

	mov	edi,'Х'
	cmp	[edx],byte 'X'
	je	.replace
 .lowercase:
	mov	edi,'е'
	cmp	[edx],byte 'e'
	je	.replace

	mov	edi,'а'
	cmp	[edx],byte 'a'
	je	.replace

	mov	edi,'о'
	cmp	[edx],byte 'o'
	je	.replace

	mov	edi,'с'
	cmp	[edx],byte 'c'
	je	.replace

	mov	edi,'у'
	cmp	[edx],byte 'y'
	je	.replace

	mov	edi,'р'
	cmp	[edx],byte 'p'
	je	.replace

	mov	edi,'х'
	cmp	[edx],byte 'x'
	je	.replace
;**********default case**********
	mov	ax, [edx]	;simply transfer the byte read into the write buffer
	mov	[ebx],ax
	inc	rcx
	inc	edx
	inc	ebx
	add	[bufwritten],1
	;pop	rax
	jmp 	.loop
 .replace:
	mov	[ebx],edi
	;mov	esi,[ebx]
	inc	ebx		;inc the write buffer twice, since unicode is two bytes long
	inc	ebx	
	inc	edx
	inc	rcx		;don't forget the counter
	;inc	rcx
	add	[bufwritten],2	;again, cyrillic takes up 2 bytes/char
	jmp	.loop
 .done:
	ret
	

similar:
	mov	rcx,0		;count for # of bytes processed
	mov	edx,readbuf	;in
	mov	ebx,writebuf	;out

	mov	[bufwritten],0 	;clear variable
 .loop:
	cmp	rcx,[bytesread]	
	je	.done
;***********comparisons***********
	cmp	[edx],byte 61h
	jl	.uppercase

	mov	edi,'т'
	cmp	[edx],byte 't'
	je	.replace

	mov	edi,'п'
	cmp	[edx],byte 'n'
	je	.replace

	mov	edi,'г'
	cmp	[edx],byte 'r'
	je	.replace

	mov	edi,'м'
	cmp	[edx],byte 'm'
	je	.replace

	mov	edi,'ш'
	cmp	[edx],byte 'w'
	je	.replace

	mov	edi,'Ь'
	cmp	[edx],byte 'b'
	je	.replace

	mov	edi,'к'
	cmp	[edx],byte 'k'
	je	.replace
 .uppercase:
	mov	edi,'Я'
	cmp	[edx],byte 'R'
	je	.replace

	mov	edi,'Ш'
	cmp	[edx],byte 'W'
	je	.replace

	mov	edi,'У'
	cmp	[edx],byte 'Y'
	je	.replace

	mov	edi,'б'
	cmp	[edx],byte '6'
	je	.replace

	mov	edi,'З'
	cmp	[edx],byte '3'
	je	.replace
;**********default case**********
	mov	ax, [edx]	;simply transfer the byte read into the write buffer
	mov	[ebx],ax
	inc	rcx
	inc	edx
	inc	ebx
	add	[bufwritten],1
	;pop	rax
	jmp 	.loop
 .replace:
	mov	[ebx],edi
	;mov	esi,[ebx]
	inc	ebx		;inc the write buffer twice, since unicode is two bytes long
	inc	ebx	
	inc	edx
	inc	rcx		;don't forget the counter
	;inc	rcx
	add	[bufwritten],2	;again, cyrillic takes up 2 bytes/char
	jmp	.loop
 .done:
	ret
	
createtemp:
	mov	rdi,tempfile	;this file is where we write the processed bytes to
	mov	eax,2
	mov	rsi,0102o
	mov	rdx,0700o
	syscall
	mov	[fd_temp],rax
	ret
writetemp:			;this sub is only for writing to the temp file
	mov	rdi,[fd_temp]
	mov	rdx,[bufwritten];bufsize*2
	mov	rsi,writebuf
	;mov	rcx,[rsi]
	mov	rax,1
	syscall
	ret
overwrite:
	mov	rdi,[fd_in]	;move the file pointers to the beginning of both files
	mov	rsi,0
	mov 	rdx,0
	call	lseek
	mov	rdi,[fd_temp]
	call	lseek

	mov	rdx,bufsize*2	;setting up for write syscall
	mov	rsi,writebuf
 .loop:
	mov	rdi,[fd_temp]	;the loop reads from the temp file into writebuf
	mov	eax,0		;then writes back to the input file
	syscall
	push	rax
	mov	rdx,rax
	mov	rdi,[fd_in]
	mov	eax,1
	syscall
	pop	rax
	cmp	rax,bufsize*2
	je	.loop
	ret
lseek:
	mov	eax,8
	syscall
	ret
close:
	mov	eax,3
	syscall
	ret
file_err:
	lea	rsi,[bad_file]
	mov	edx,16
	mov	edi,1
	mov	eax,1
	syscall
	jmp exit
switch_err:
	lea	rsi,[bad_switch]
	mov 	edx,25
	mov	edi,1
	mov	eax,1
	syscall
	jmp	exit
cleanup:
	mov	rdi,fd_in	;close the files before exiting
	mov	eax,3
	syscall	
	mov	rdi,fd_temp	;I don't know if it's necessary to close the temp file, since
	syscall			;it's deleted with syscall 87
	mov	rdi,tempfile
	mov	eax,87
	syscall
exit:
	xor	edi,edi 	; exit code 0
	mov	eax,60		; sys_exit
	syscall

segment readable writeable
bufsize=1500
tempfile db 'cyr.txt',0h
fd_in rq 1
fd_temp rq 1
readbuf rw bufsize
writebuf rw bufsize*2 ;worst case: every char is converted to cyrillic, so we need a write buffer that's twice the size
bufwritten dq 0
bytesread dq 0
switch	rq 1
bad_file db 'File not found',0Ah,0h
bad_switch db 'use -s for stealth mode',0Ah,0h
