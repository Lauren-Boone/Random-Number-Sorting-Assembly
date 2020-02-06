TITLE Random Number Sorting

; Author: Lauren Boone
; Last Modified: 5/5/19
; OSU email address: boonela@oregonstate.edu

; Description: The program generates an array of randoms numbers in the range of (loo- 999)
;the length of which is determined by the user[10-200] (inclusive). The numbers are displayed 
;unsorted first then the array is sorted and displayed hi - low. Boths outputs are displayed 10 per line.
; The median value is calculated and dispayed. 

INCLUDE Irvine32.inc

MAX_DISPLAY = 200
MIN_DISPLAY = 10
MAX_VALUE = 1000
MIN_VALUE = 100


.data

; strings for introduction
progTitle		BYTE	"Random Number Generator and Sorter",0
programmer		BYTE	"Author: Lauren Boone",0
instruct1		BYTE	"I will generate an array of random numbers between 100 and 999.",0
instruct2		BYTE	"You will need to tell me how many numbers you want (range: 10-200) inclusive",0
instruct3		BYTE	"I will display the the original list, the median, and then the sorted list.",0
prompt			BYTE	"How many numbers shall I generate? [10-200] : ",0
invalidNum		BYTE	"Oops, that number is out of range. Try again",0
unsortStr		BYTE	"The unsorted random numbers:",0
sortedStr		BYTE	"The sorted list of random numbers: ",0
medianStr		BYTE	"The median is ",0
space			BYTE	"    ",0

;numerical values
input			DWORD ?
array			DWORD MAX_DISPLAY DUP(?)


; (insert variable definitions here)

.code
main PROC

	call Randomize
	
	call Introduction

	push OFFSET input
	call	getData
	


	push	OFFSET array ;pass array by reference
	push	input ;push input by value onto the stack
	call	fillArray
	
	
	push	OFFSET array
	push	input
	push	OFFSET unsortStr
	push	OFFSET space
	call	displayList

	push	OFFSET array
	push	input
	call	sortList

	push	OFFSET array
	push	input
	call	displayMedian

	push	OFFSET array
	push	input
	push	OFFSET sortedStr
	push	OFFSET space
	call	displayList

; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

;******************************************
;Introduction
;Display information and instructions
;Recieves: global variables
;REturns: none
;PReconditions: None
;Registers Changed: EDX
;********************************************
Introduction PROC

	push	EBP
	mov		EBP,ESP

	mov			EDX, OFFSET progTitle
	call	Writestring
	call	Crlf
	mov			EDX, OFFSET programmer
	call	WriteString
	call	Crlf
	mov			EDX, OFFSET instruct1
	call	WriteString
	call	Crlf
	mov			EDX, OFFSET instruct2
	call	WriteString
	call	Crlf
	mov			EDX, OFFSET instruct3
	call	WriteString
	call	Crlf
	
	;mov		ESP, EBP
	pop EBP
ret
Introduction ENDP


;*********************************************
;getData
;Gets input from user and validates number
;Recieves: global variables, input variable by reference
;Returns: valid input number
;Preconditions: None
;Regs: EAX, EDX
;**************************************************
getData PROC

	push		EBP
	mov		EBP,ESP
	mov		EBX, [EBP+8]
	

	;Get input from the user and validate it
	GET_USER_INPUT:
	mov			EDX, OFFSET prompt
	call	WriteString
	call	ReadDec
	cmp		EAX, MAX_DISPLAY
	ja		OUT_OF_RANGE
	cmp		EAX, MIN_DISPLAY
	jl		OUT_OF_RANGE
	mov			[EBX], EAX
	jmp		VALID

	;If input is out of range print a message and jump to get input
	OUT_OF_RANGE:
	mov			EDX, OFFSET invalidNum
	call	WriteString
	call	Crlf
	jmp		GET_USER_INPUT

	;returns if number is valid
	VALID:
	;mov		ESP, EBP
	pop		EBP
	ret		4

getData ENDP

;*****************************************
;fillArray
;fills array will random numbers
;Recieves: input(by value), array(by reference)
;Returns: filled array
;Preconditions: input value must be valid
;Regs: EBP, ESP, ECX, EAX
;*******************************************
fillArray	PROC

	;set the count 
	push		EBP
	mov			EBP, ESP
	mov			ECX, [EBP+ 8]
	mov			ESI, [EBP + 12]

	;This loop generates random numbers between 0-999. If the numbers are less than 100
	;them jump to too low.
	GET_RANDOM_NUMS:
		mov		EAX, MAX_VALUE
		call	RandomRange
		cmp		EAX, MIN_VALUE
		jl		TOO_LOW
		mov		[ESI],EAX
		add		ESI, 4
		loop	GET_RANDOM_NUMS
		jmp		ARRAY_FILLED

	;This prevents numbers less than 100 from being put in array
	;incriments ecx
	TOO_LOW:
	inc		ECX
	loop	GET_RANDOM_NUMS

	ARRAY_FILLED:
	mov		ESP,EBP
	pop		EBP
	ret 	
		
fillArray ENDP

;**************************************************
;sortList
;Sorts array using bubblesort in descending order 
;Recieves: array(reference), input(value)
;Returns: sorted array
;Preconditions: Input != 0
;Regs:
;*************************************************
sortList	PROC


	push	EBP
	mov		EBP,ESP
	

	mov		ESI, [EBP+12]
	mov		EAX, [esi]
	
	mov		ECX, [EBP+8]
	dec		ECX
	
	;continue looping untill array is sorted
	OUTER_LOOP:
	push	ECX
	mov		EAX, [ESI]

	mov		EDX, ESI ;to hold the address of first element to loop through multiple times
	;The this is incrimented after each loop of the entire array


	ASSIGN_COMPARE:
	mov		EBX, [ESI+4]
	mov		EAX, [EDX]
	cmp		EAX, EBX
	jge		CONTINUE
	jmp		SWAP



	;THis functions pushes the necessary values onto the stack and then calls EXCHANGE
	CONTINUE:
	add		ESI, 4
	loop	ASSIGN_COMPARE
	pop		ECX
	mov		ESI, EDX
	add		ESI, 4
	loop	OUTER_LOOP
	jmp		FINISHED

	SWAP:
	add		ESI, 4
	push	ESI
	push	EDX
	call	exchangeElements
	
	sub		ESI,4
	
	jmp		CONTINUE

	FINISHED:
	mov		ESP, EBP
	pop		EBP
	ret	 8

sortList ENDP




;******************************************
;exchangeElements
;Swaps two values in the array
;Recieves: two array values (reference)
;Returns:none
;Preconditions: None
;Regs:
;***********************************************
exchangeElements PROC
	
	push	EBP
	mov		EBP,ESP
	pushad

	mov		EAX, [EBP+12] ;move the higher number
	mov		ECX, [EAX]

	mov		EBX, [EBP+8] ;lower number
	mov		EDX,[EBX]

	mov		[EAX], EDX
	mov		[EBX],ECX
	popad
	;mov		ESP,EBP
	pop		EBP
	ret	8 
exchangeElements ENDP



;**********************************************
;displayMedia
;Finds the Median and prints the value
;Recieves: array(reference), input(value)
;Returns: nothing
;preconditions: none
;regs: 
;**************************************************
displayMedian PROC

	push	EBP
	mov		EBP, ESP
	mov		EAX, [EBP + 8]
	mov		ESI, [EBP+12]
	mov		EDX, 0
	;Determine if there is an odd or even number
	mov		EBX, 2
	cdq
	div		EBX
	cmp		EDX, 0
	jne		oddNum

	;If the number of ints are even then find the middle point between the two
	evenNum:
	dec		EAX
	mov		EBX, 4
	mul		EBX
	mov		EBX,2
	add		ESI, EAX
	mov		EAX, [ESI]
	sub		EAX, [ESI+4]
	cdq
	div		EBX
	mov		EBX, EAX
	mov		EAX, [ESI+4]
	add		EAX, EBX
	jmp		finish

	;If the the number of ints is odd then the middle number is printed.
	oddNum:
	inc		EAX
	mov		EBX, 4
	mul		EBX
	
	add		ESI, EAX
	mov		EAX, [ESI]

	finish:
	mov		EDX, OFFSET medianStr
	call	Crlf
	call	WriteString
	call	WriteDec
	call	Crlf
	Call	Crlf

	pop EBP
	ret	8

displayMedian ENDP


;*****************************************
;displayList
;Prints the list
;Recieves: array(reference), input(value), title(reference)
;returns; none
;preconditions; none
;regs: ECX, EDX
;***************************************************
displayList PROC

	push	EBP
	mov		EBP,ESP
	mov		EDX, [EBP+12]
	call	WriteString
	call	Crlf
	mov		ECX, [EBP+16]
	mov		ESI,[EBP+20]
	
	;This loop keeps track of the total number left to print
	
	outerLoop:
	push	ECX
	cmp		ECX,10
	jle		printLoop
	mov		ECX, 10

	;This loop prints ten numbers 
	printLoop:
	mov		EAX, [ESI]
	call	WriteDec
	add		ESI, 4
	mov		EDX, [EBP+8]
	call	WriteString
	loop	printLoop
	
	
	;AFter ten numbers are printed crlf then get the number count and decriment 10
	call	Crlf
	pop		ECX
	inc		ECX ;Must incriment to print all numbers
	cmp		ECX, 10
	jle		goodBye
	sub		ECX,10
	;push	ECX
	loop	outerLoop
	call	Crlf
	

	goodBye:
	mov		ESP, EBP
	pop		EBP

	ret	16
displayList ENDP

END main
