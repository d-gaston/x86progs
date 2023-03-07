format ELF executable 3
entry start
segment readable executable

start:
	mov	eax,msg
	call	print
	
	mov	ecx,input
	mov	eax,3
	mov	ebx,0
	mov	edx,100
	int	80h
	
	mov	eax,input
	call	reverse
	
	mov	eax,input
	call	print
	
	call exit

strlen:
	push	ecx
	push	ebx
	mov	ecx,0
next:
	cmp	byte [eax],0
	jz	done
	inc	eax
	inc	ecx
	jmp	next
done:
	mov	eax, ecx
	pop	ebx
	pop	ecx
	ret

print:
	push	ecx
	push	ebx
	push	edx
	push	eax
	call	strlen
	mov	edx,eax
	pop	eax
	mov	ecx,eax
	mov	eax,4
	mov 	ebx,1
	int	80h
	pop	edx
	pop	ebx
	pop	ecx
	ret
	

reverse:
	push	ebx
	push	edx
	push	ecx
	push	eax
	call	strlen
	mov	ecx,eax
	pop	eax
	
	mov	ebx,eax
	dec	ecx
	dec	ecx
	add	eax,ecx
revloop:
	mov	cl,[eax]
	mov	dl,[ebx]
	mov	[eax],dl
	mov	[ebx],cl
	dec	eax
	inc	ebx
	cmp	ebx,eax
	jle	revloop
	pop	ecx
	pop	edx
	pop	ebx
	ret
	
exit:
	mov	eax,1
	mov	ebx,0
	int	80h
segment readable writeable
msg db 'Entry',0Ah,0h
input rb 100

