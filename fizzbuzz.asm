format ELF executable 3
entry start
segment readable executable

start:
	mov	ecx,1		;count kept in ecx
 .main:
	mov	eax,ecx
	call	checkfizz	;start by checking mod3
	inc	ecx		
	mov	eax,newline	;whatever gets printed followed by \n
	call	print
	cmp	ecx,100
	jne	.main	
	
	
	
	call 	exit
checkfizz:
		
	push	ebx
	push	edx
	push	eax
	mov	edx,0
	mov	ebx,3		;
	idiv	ebx		;current number %3
	cmp	edx,0		;
	je	.printfizz	;if rem==0 
	jmp	.continue	
 .printfizz:
	mov	eax,fizz
	call	print
	pop	eax
	call	checkfizzbuzz	;if mod3, check for mod15
	pop	edx
	pop	ebx
	ret
 .continue:
	pop	eax
	call	checkbuzz	;if !mod3, check mod 5
	pop	edx
	pop	ebx
	ret
	
checkbuzz:

	push	ebx
	push	edx
	push	eax
	mov	edx,0
	mov	ebx,5
	idiv	ebx
	cmp	edx,0
	jne	.printnum	;if !mod5
	mov	eax,buzz
	call	print
	pop	eax
	pop	edx
	pop	ebx
	ret
	.printnum:
	pop	eax
	call	printint	;done checking mods, so print int
	pop	edx
	pop	ebx
	ret
checkfizzbuzz:
	
	push	ebx
	push	edx
	push	eax
	mov	edx,0
	mov	ebx,5
	idiv	ebx
	cmp	edx,0
	jne	.done
	mov	eax,buzz	;if mod15, print buzz after fizz
	call	print
	pop	eax
	pop	edx
	pop	ebx
	ret
	.done:
	pop	eax		;else clean up and return
	pop	edx
	pop	ebx
	ret
strlen:
	push	ecx
	push	ebx
	mov	ecx,0
 .next:
	cmp	byte [eax],0	;0 terminated string, end if true
	jz	.done
	inc	eax		;move string pointer
	inc	ecx		;inc counter
	jmp	.next
 .done:
	mov	eax, ecx	;return result in eax
	pop	ebx
	pop	ecx
	ret

print:
	push	ecx
	push	ebx
	push	edx
	push	eax
	call	strlen
	mov	edx,eax		;move length to edx
	pop	eax		;get string address
	mov	ecx,eax		; mov string address to ecx
	mov	eax,4
	mov 	ebx,1
	int	80h
	pop	edx
	pop	ebx
	pop	ecx
	ret
	
printint:
	push	eax
	push	esi
	push 	ecx
	push	edx

	mov	ecx,0		;number of digits in ecx
 .divloop:
	mov	edx,0
	mov	esi,10
	idiv	esi
	inc 	ecx		;how many 10's?
	add	edx,48		;convert to ascii
	push	edx		;push the remainder
	cmp	eax,0		;continue loop if eax!=0
	jnz	.divloop
 .printloop:
	mov	eax,esp		;move address of next numbers
	call	print
	dec	ecx
	pop	eax		;pop each of the remainders to eax
	cmp	ecx,0		;while there are numbers left
	jnz	.printloop
	pop	edx
	pop	ecx
	pop	esi
	pop	eax
	ret	
	
exit:
	mov	eax,1
	mov	ebx,0
	int	80h
segment readable writeable
fizz db 'fizz',0h
buzz  db 'buzz',0h
newline db 0Ah,0h

