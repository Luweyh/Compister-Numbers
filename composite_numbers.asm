TITLE Composite Numbers    (composite_numbers.asm)

; Author: Luwey Hon
; Description: This program can calculates up to 10,000 composites.
;	The program first starts with an introduction and then ask the
;	user to insert a number in 1 - 10000, so they can see that many
;	composite numbers. The program will validate the range and tell the
;	user if it is in an incorrect range. Once passed validation, it will
;	show the composite number in equally spaced column. It will print
;	the numbers a page at a time. After it will show prime numbers in color
;  and in even spacing columns. It finally concludes with a farewell.

;	Implementation Notes: This program uses procedures.
;	Did 9 numbers per line instead of 10 to equally fill one page for extra credit


INCLUDE Irvine32.inc

;upper limit defined as constant
UPPER_LIMIT = 10000

.data

; introduction variables
	author_name		BYTE	"by Luwey Hon",0
	prog_title		BYTE	"    Composite Number           ",0
	instructions_1	BYTE	"Enter the number of composite numbers you would like to see.",0
	instructions_2	BYTE	"Please choose a number in [1 ... 10,000]. ",0
	ec_columns		BYTE	"**EC: Align the output columns",0
	ec_pages		BYTE	"**EC: Display more composites at one page at a time",0
	ec_prime_divisors	BYTE	"**EC: Enhanced efficiency using array of primes",0
	ec_view_prime	BYTE	"**EC: OTHER: View prime numbers that has: ",0
	ec_prime_page	BYTE	"  color; equal columns; pages at a time; and has a title every page",0

; variables for displaying strings
	enter_number	BYTE	"Enter a number: ",0
	invalid_range	BYTE	"Out of range. Please enter number in [1 ... 10,000]",0
	add_space		BYTE	" ",0	; adds 1 single space 
	prime_string	BYTE	"!!!!  Will now view prime numbers   !!!!",0
	view_prime		BYTE	"            -------- PRIME NUMBERS ------------",0

; variables that hold important value 
	user_num		DWORD	?		; will hold user's number / input
	ok_validation	DWORD	?			; will use this to determine if validation passes
	divisor_num		DWORD	?		; test a divisor num to find composite
test_composite_num	DWORD	2			; number that is being tested to be composite
	is_composite	DWORD	?			; 0 = fail, 1 = passed composite
	length_num		DWORD	?		; the length of number (how many digits)
	counter			DWORD	?		; counts how many composite number been printed
	prime_array		DWORD	5000 DUP(?)	; an array of prime numbers
	array_size		DWORD	?
	array_index		DWORD	?		; finds the indexy for the arra
	not_prime		DWORD	?		; to test if it is not prime
	prime_counter	DWORD	1			; using for an ecx loop counter
	largest_prime	DWORD	?			; finds the largest prime number
	array_pointer	DWORD	?			; points to a certain positon in array
	prime_counters	DWORD	?			; the counter for prime numbers
	
;farewell variable
	goodbye			BYTE	"Results certified by Luwey. Goodbye.",0

.code
main PROC

call	introduction
call	getUserData
	; sub-procedure: validate
call	showComposites
	; sub-procedure: check_prime_divisors
		;sub-sub-procedure: array_position
	; sub-procedure: isComposite
	; sub-procedure: store_prime_numbers
	; sub-procedure: length_of_num 
	; sub-procedure: even_spacing 
	; sub-procedure: new_line
	; sub-procedure: new_page
call	view_prime_numbers
	;sub-procedure: prime_new_line
	;sub-procedure: prime_new_page
call	farewell

	exit	; exit to operating system
main ENDP


; Procedure to introduce the program.
; recieves: none
; returns: none
; preconditions: none
; registers changed: edx
introduction PROC
	mov		edx, OFFSET prog_title
	call	WriteString
	mov		edx, OFFSET author_name
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_columns
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_pages
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_prime_divisors
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_view_prime
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_prime_page
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET instructions_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions_2
	call	WriteString
	call	CrLf
	call	CrLf
	ret

introduction ENDP


; Procedure to get the data.
; recieves: none
; returns: The user's number that is correctly validated.
; preconditions: none
; registers changed: edx, eax
getUserData PROC

get_number_again:				
	mov		edx, OFFSET enter_number
	call	WriteString
	call	ReadInt
	mov		user_num, eax		; store's user's num to a variable
	call	validate			; check if numbers are valid
	cmp		ok_validation, 0	; 0 = fail, 1 = pass validation
	je		get_number_again	; if = 0, then get numbers again

	ret

getUserData ENDP


; Procedure to validate the number
; recieves: user's number
; returns: error message or gives back the validated number
; preconditions: user's input a number
; registers changed: eax, edx
validate PROC
	cmp		user_num, 1
	jl		error_range				; less than 1
	mov		eax, user_num
	cmp		eax, UPPER_LIMIT			; upper_limit = 10,0000
	jg		error_range				; greater than 10,000
	mov		ok_validation, 1			; 1 = passed validation
	ret
	
	; user input invalid range. Not in [1, 100,000]
	error_range:
		mov		edx, OFFSET invalid_range
		call	WriteString
		mov		ok_validation, 0	; 0 = failed validation
		call	CrLf
		call	CrLf
		ret

validate ENDP


; Procedure to show composites

; IMPLEMENT NOTE: How this loops work is that the outter loops check every
; single number up to requested number. It first checks with prime divisors in
; outter loop. Then in the inner loop, each number is iterated
; through every possible divisor to see if it is composite. It adds
; the prime number that failed the composite test.
; The inner loop's counter is how big is the composite number being tested
; and the outer loop's counter is the upper limit. There is a conditional
; to jump out of the loop once it reached the user's desired composite number.

; recieves: not_prime (when prime divisor is checked in outtler loop)
	; edx (when inner loops calls a sub-procedure to check composite)
; returns: all the composite numbers
; preconditions: Must successfully passed validation
; regisers changed: esi, ebx, ecx
showComposites PROC

	; adding 2 to the prime divisor list since this the first prime
	; number to be checked
	mov esi, OFFSET prime_array
	mov ebx, 2
	mov [esi], ebx
	add array_index, 4		; points to next array index

	; initializing the outer loop (check_number)
	mov		ecx, UPPER_LIMIT
	
	; beginning of outter loop
	check_number:
		push	ecx						; save outter loop count
	
	; intializing inner loop that's in outter loop
		inc		test_composite_num			; so that it test a new number 
		mov		divisor_num, 2				; intialize initial divisor at 2
		call	check_prime_divisors				; checks if composite with prime divisors
		cmp		not_prime, 1				
		je		print_composite				; printing number out since its composite
		
		;inner loop counter
		mov		ecx, test_composite_num
		dec		ecx							
		dec		ecx						

	; beginning of inner loop. 
	check_composite:
		call	isComposite				; sub-procedure to check for composite
								; True = 1 , False = 0
		cmp		is_composite, 1
		je		print_composite			; if it is composite, print it out

		inc		divisor_num
		loop	check_composite				; loops until composite is found or if number is prime
								; end of inner loop

	; will store the prime numbers in an array since it's not composite
		call store_prime_numbers
	
	; jumps to to get the next number when no composite is found
		jmp		next_number

	; prints the composite number in equal columns, pages at a time
	print_composite:
		mov		eax, test_composite_num
		call	new_page				; prints a page at a time
		call	WriteDec
		inc		counter
		call	length_of_num				; finds the length of number
		call	even_spacing				; prints even spacing
		call	new_line				; test to see if it needs a new line
		mov		eax, counter
		cmp		eax, user_num			; if the counter = the amount of composite
		je		no_more_loop			; stops loop once reached the desired amount
		inc		divisor_num
	
	next_number:
		pop		ecx				; restore ecx so outter loop can work
		loop	check_number				; checks a new number. end of outer loop
	

	
		ret						; this ret happen when they chose the max edge case	
								; e.g. user_num chose 10000

	no_more_loop:			

		pop ecx					; to allign stack since I pushed ecx in inner loop
		ret					; this ret happens when they didn't choose max edge case
							; i.e in [1 .. 10000) non inclusive

showComposites ENDP


; procedure to check if the number is composite with prime divisors
; recieves: test_composite_num
; returns: whether or not the number is prime
; preconditions: none
; registers changed: ecx ebp eax ebx edx
check_prime_divisors PROC

;loop counter is how many element in the prime numbers array
	mov		ecx, prime_counter			

	mov		ebp, 0				; this will change the position 

check_composites:

	call	array_value				; finds the array value at a certain position
							; and will store it in ebx

; loops and checks every prime number divisibility
	mov		not_prime, 0			; initialze not prime = false
	mov		eax, test_composite_num
	cdq
	div		ebx				; value of the specifc array
	add		ebp, 4				; used to increase the position of the array every loop
	cmp		edx, 0				; if the remainder is 0, it means not prime
	je		notPrime			; jumps out of loop if not prime
	loop	check_composites

; finished looping by here so must be a prime number
	jmp prime
	
	; change not_prime = true (1 = true)
	notPrime:
		mov		eax, 1
		mov		not_prime, eax

	prime:

	ret

check_prime_divisors ENDP


; Procedure to get the array value at a specific position
; recieves: ebp
; returns: the value in the array which is stored in ebx
; preconditions: none
; registers changed: ebp esp ebx
array_value PROC
	push	ebp
	mov		esi, OFFSET prime_array
	add		esi, ebp
	mov		ebx, [esi]		; push the value of the array onto the stack
	pop		ebp			; stores the value in ebp
					
	ret
array_value ENDP


; Procedure to check if number is composite and store non composite in an array
; recieves: the composite number that is being tested (test_composite_num)
; returns: the remainder to see if it is a composite number. (edx = 0, means composite)
; preconditions: must have a number to be tested
; register changed: eax ebx edx
isComposite PROC
	
	mov		is_composite, 0				; intialzie to make it not composite for future loops
	mov		eax, test_composite_num			; number being tested
	cdq
	mov		ebx, divisor_num			; a divisor number
	div		ebx
	cmp		edx, 0					; if the remainder is 0, then it's a composite number
	jne		not_composite				; since these means two integers multiplies to it
	
	; makes the current number composite
	composite:
	mov is_composite, 1

	not_composite:

	ret

isComposite ENDP

	
; Procedure to store the prime numbers in an array
; recieves: the tested composite number
; returns: nothing, just stores into an array
; preconditions: the tested number is a prime number
; registers changed: esi, ebx, edx
store_prime_numbers PROC
	
	mov		esi, OFFSET prime_array
	mov		ebx, array_index
	mov		edx, test_composite_num
	mov		[esi + ebx], edx	; adding the prime numbers to the array

	add		array_index, 4		; increase the array index for next time
	inc		prime_counter
	mov		array_size, ebp		; save the size of the array


	ret

store_prime_numbers ENDP


; Procedure to check the length of the number
; recieves: the value of eax which is the number being tested to find length
; returns: the length of the number
; preconditions: the number must be a composite number
; register changed: none (eax is only compared)
length_of_num PROC
	
	mov  length_num, 0	; initialize at 0 for future loops
		push eax

		cmp eax, 9					; comparing the fib number to actual sizes of numbers
		jle one_digit					; this has 1 digit
		cmp eax, 99
		jle two_digit					; this has 2 digits 
		cmp eax, 999
		jle three_digit					; this has 3 digit and the pattern continues
		cmp eax, 9999
		jle four_digit
		cmp eax, 99999
		jle five_digit
		cmp eax, 999999
		jle six_digit
		cmp eax, 9999999
		jle seven_digit
		cmp eax, 99999999
		jle eight_digit
		cmp eax, 999999999
		jle nine_digit
		cmp eax, 4294967294				;  the maximum size of DWORD 
		jle ten_digit

		
		; increases the length for every digit
		ten_digit:					; 10 digits adds 1 ten times
			inc length_num			
		nine_digit:
			inc length_num
		eight_digit:
			inc length_num
		seven_digit:
			inc length_num
		six_digit:
			inc length_num
		five_digit:
			inc length_num
		four_digit:
			inc length_num
		three_digit:
			inc length_num
		two_digit:
			inc length_num
		one_digit:						; 1 digit only adds one 1
			inc length_num			
	
		pop eax							; restore eax
		ret
length_of_num ENDP


; Procedure to print even spacing
; recieves: the length of the number
; returns: spacing depending on the length of the number
; preconditions: none
; registers changed: ecx, edx
even_spacing PROC uses ecx edx
		
	;initialize the loop
		mov		ecx, 13					; total spacing between integer
		sub		ecx, length_num				; decrease total spacing depending on length of integer

	;loops and prints 1 space a time
	print_spacing:
		mov		edx, OFFSET add_space
		call	WriteString				; prints 1 space
		loop	print_spacing				; continues looping
																				
		ret

even_spacing ENDP


; Procedure to print a new line every 10 digits
; recieves: must recieve a number
; returns: A new line or no new line, depending if the condition is met
; preconditions: the number is a composite number
; register changed: eax, ebx, edx
new_line PROC uses eax ebx edx
	
	mov		eax, counter		; how many composite numbers
	cdq
	mov		ebx, 9			; 9 digits for line (for extra credit so it fits in one page a time)
	div		ebx
	cmp		edx, 0			; comparing the remainder to 0
	je		print_line		; if it divisible by 9, print new line
	jmp		no_new_line


	print_line:
		call	CrLf

	no_new_line:
	
	ret
new_line ENDP


; Procedure to print a new page of number at a time
; recieves: recieves the counter for how many composite number
; returns: a wait message and a new screen, or nothing
; preconditions: must recieve a composite number
; register changed: eax ebx edx
new_page PROC uses eax ebx

; to print first page of numbers evenly 
	cmp		counter, 0		
	je		next_page		

; to print pages 2 and up evenly
	mov		eax, counter
	cdq
	mov		ebx, 243		; 9 digits each line. to fill up whole page
	div		ebx
	cmp		edx, 0			; if the remainder is 0, which means divisible by 300
	je		next_page
	jmp		no_next_page

; prints a new page of number, after pressing a key
	next_page:
		call	WaitMsg
		call	ClrScr

	no_next_page:

	ret
new_page ENDP


; Procedure to view prime numbers
; recieves: the array of prime numbers
; returns: the prime number in color
; preconditions: none
; registers changed: eax, edx, ebx, ecx, esi
view_prime_numbers PROC
	call	CrLf
	call	CrLf

; tells user they're going to view prime numbers
	mov		eax, red + (black * 16)
	call	SetTextColor				; make it the text red
	mov		edx, OFFSET prime_string
	call	 writestring
	call	CrLf
	mov eax, lightBlue + (black * 16)
	call SetTextColor					; make text light blue
	

; finds the array length
	mov eax, array_size
	cdq
	mov ebx, 4				; divide by 4 since DWORD uses 4 sizes each
	idiv ebx
	add eax, 1				; adjusting array size since I added 2 manually
							; to my prime list
	
	mov array_size, eax			; storing array size

; initializing the loop to print the prime
	mov esi, OFFSET prime_array
	mov ebx, 0						
	mov ecx, array_size

	print_primes:
		mov		eax, [esi + ebx]	
		call	prime_new_page			; prints a page at a time
		call	writedec
		inc		prime_counters
		call	length_of_num			; finds length of number
		call	even_spacing			; prints even spacing
		call	prime_new_line			; test to see if it needs a new line
		
		add ebx, 4				; to point next position in array
		loop print_primes
	
	call	crlf
	call	CrLf

	mov eax, white + (black * 16)
	call SetTextColor

ret
view_prime_numbers ENDP


; Procedure to print a new page of prime number at a time
; recieves: recieves the prime counter (how many prime numbers)
; returns: a wait message and a new screen with a title
; preconditions: must recieve the prime numbers
; register changed: eax ebx edx
prime_new_page PROC uses eax ebx

; to print first page of numbers evenly 
	cmp		prime_counters, 0		
	je		next_page		

; to print pages 2 and up evenly
	mov		eax, prime_counters
	cdq
	mov		ebx, 225			; 9 digits each line. to fill up whole page
							; i left extra buffer because it will later inform
							; to see prime numbers
							
	div		ebx
	cmp		edx, 0				; if the remainder is 0, which means divisible by 300
	je		next_page
	jmp		no_next_page

; prints a new page of number, after pressing a key
	next_page:
		call	WaitMsg
		call	ClrScr
		
		; prints a title page each time a new page beings
		mov		eax, red + (black * 16)
		call	SetTextColor
		mov		edx, OFFSET view_prime
		call	 writestring
		mov		eax, lightBlue + (black * 16)
		call	SetTextColor
		call	CrLf

	no_next_page:

	ret

prime_new_page ENDP


; Procedure to print on new line for prime numbers
; recieves: the prime counter (how many prime numbers)
; returns: CrLf
; preconditions: only prints CrLf when counter is 9
; registers changed: eax, ebx, edx
prime_new_line PROC uses eax ebx edx
	
	mov		eax, prime_counters		; the counter for prime number
	cdq
	mov		ebx, 9		; 9 digits for line (for extra credit so it fits in one page a time)
	div		ebx
	cmp		edx, 0			; comparing the remainder to 0
	je		print_line_		; if it divisible by 9, print new line
	jmp		no_new_line_

	
	print_line_:
		call	CrLf

	no_new_line_:
	
	ret

prime_new_line ENDP


; Procedure to say goodbye
; recieves: none
; returns: none
; preconditions: none
; registers changed: edx
farewell PROC
	
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	ret

farewell ENDP

END main
