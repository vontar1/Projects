IDEAL
MODEL small
STACK 100h
DATASEG

; ---Patch Notes---
; Added castling.
; Added a 50% chance to play as white.
; Fixed all the known bugs.
; -----------------

MACRO ADD_MOVE ; adds a move to a move list
	push ax
	push bx
	push dx
	mov ax, [legalMovesAmountP1]
	mov bx, 2
	
	inc [legalMovesAmountP1]
	
	xor dx, dx
	mul bx
	
	mov bx, ax
		
	mov dl, square
	mov [legalMovesP1 + bx], dl
	mov dl, endPoint
	inc bx
	mov [legalMovesP1 + bx], dl
	
	pop dx
	pop bx
	pop ax
endm ADD_MOVE

; --------------------------
	GameOverPress db "Game Over! Press Any Key To Continue$"

	whiteWon db "GOOD GAME! White Won!$"
	
	blackWon db "GOOD GAME! Black Won!$"
	
	stalemateSTR db "How Did You Mess This Up?"
	
	chooseOption db "Choose The Desired Option:$"
	
	playAgain db "Press 'A': AGAIN!!!$"
	
	imDone db "Press 'B': I'm Salty Cause I Lost$"
	
	Line db 320 dup(0)


	rook1Move db 0 ; 66 0
	rook2Move db 0 ; 67 7
	rook3Move db 0 ; 68 56
	rook4Move db 0 ; 69 63
	
	rook1LastPos dw 0
	rook2LastPos dw 7
	rook3LastPos dw 56
	rook4LastPos dw 63
	
	blackKingMoved db 0
	whiteKingMoved db 0

	turnCounter db 0

	legalMovesP1 db 512 dup (0)
	legalMoves db 512 dup (0)
	legalMovesAmountP1 dw 0
	legalMovesAmount dw ?
	
	pieceSave dw ?
	from dw ?
	to dw ?
	
	toRefill db 64 dup(0)
	toRefillCounter dw 0
	
	legalSecondPos db 64 dup(0)
	legalSecondPosCount dw 0

	firstPos dw ?
	secondPos dw ?
	
	bestFrom db ?
	bestTo db ?
	
	depthCounter db 0

	matrix dw ?

	playerColor dw 0
	playerColorAscii dw 0

	king db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	     db 0,0,0,0,0,0,0,0,0,0,0,187,187,0,0,0,0,0,0,0,0,0,0,0
	     db 0,0,0,0,0,0,0,0,0,0,187,1,1,187,0,0,0,0,0,0,0,0,0,0
	     db 0,0,0,0,0,187,187,187,0,0,187,1,1,187,0,0,187,187,187,0,0,0,0,0
	     db 0,0,0,0,187,1,1,1,187,0,0,187,187,0,0,187,1,1,1,187,0,0,0,0
	     db 0,0,0,0,187,1,1,1,1,187,187,1,1,187,187,1,1,1,1,187,0,0,0,0
	     db 0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0
	     db 0,0,0,187,1,187,187,1,1,1,1,1,1,1,1,1,1,187,187,1,187,0,0,0
	     db 0,0,187,1,187,0,0,187,1,1,1,1,1,1,1,1,187,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,187,187,1,1,1,1,1,1,187,187,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,0,0,187,1,1,1,1,187,0,0,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,0,0,187,1,1,1,1,187,0,0,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,0,0,187,1,1,1,1,187,0,0,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,0,0,187,1,1,1,1,187,0,0,0,0,187,1,187,0,0
	     db 0,0,187,1,187,0,0,0,0,187,1,1,1,1,187,0,0,0,0,187,1,187,0,0
	     db 0,0,0,187,1,187,0,0,0,187,1,1,1,1,187,0,0,0,187,1,187,0,0,0
	     db 0,0,0,187,1,187,0,0,0,187,1,1,1,1,187,0,0,0,187,1,187,0,0,0
	     db 0,0,0,187,1,1,187,187,0,187,1,1,1,1,187,0,187,187,1,1,187,0,0,0
	     db 0,0,0,0,187,1,1,1,187,1,1,1,1,1,1,187,1,1,1,187,0,0,0,0
	     db 0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0
	     db 0,0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0
	     db 0,0,0,0,187,187,1,1,1,1,1,1,1,1,1,1,1,1,187,187,0,0,0,0
	     db 0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0
	     db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
	queen db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,187,187,187,0,0,187,187,187,0,0,0,0,187,187,187,0,0,187,187,187,0,0
		  db 0,0,187,1,187,0,0,187,1,187,0,0,0,0,187,1,187,0,0,187,1,187,0,0
		  db 0,0,0,187,0,0,0,0,187,0,0,0,0,0,0,187,0,0,0,0,187,0,0,0
		  db 0,0,187,1,187,0,0,187,1,187,0,0,0,0,187,1,187,0,0,187,1,187,0,0
		  db 0,0,187,1,187,0,0,187,1,187,0,0,0,0,187,1,187,0,0,187,1,187,0,0
		  db 0,0,187,1,187,0,0,187,1,187,0,0,0,0,187,1,187,0,0,187,1,187,0,0
		  db 0,0,187,1,187,0,0,187,1,1,187,0,0,187,1,1,187,0,0,187,1,187,0,0
		  db 0,0,187,1,187,0,0,187,1,1,187,0,0,187,1,1,187,0,0,187,1,187,0,0
		  db 0,0,0,187,1,187,0,187,1,1,187,0,0,187,1,1,187,0,187,1,187,0,0,0
		  db 0,0,0,187,1,187,0,187,1,1,187,0,0,187,1,1,187,0,187,1,187,0,0,0
		  db 0,0,0,187,1,187,0,187,1,1,1,187,187,1,1,1,187,0,187,1,187,0,0,0
		  db 0,0,0,187,1,187,0,187,1,1,1,1,1,1,1,1,187,0,187,1,187,0,0,0
		  db 0,0,0,0,187,1,187,187,1,1,1,1,1,1,1,1,187,187,1,187,0,0,0,0
		  db 0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0
		  db 0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0
		  db 0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0
		  db 0,0,0,0,0,187,1,187,187,187,187,187,187,187,187,187,187,1,187,0,0,0,0,0
		  db 0,0,0,0,187,187,187,1,1,1,1,1,1,1,1,1,1,187,187,187,0,0,0,0
		  db 0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0
		  db 0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0
		  db 0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
	knight db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,187,0,0,0,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,187,187,187,187,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,1,1,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,187,1,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,187,187,1,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,1,1,187,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,1,187,0,187,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,187,1,1,187,0,0,187,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,1,1,187,0,0,187,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,1,1,187,0,187,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,187,187,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,0,187,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0
		   
	
	rook db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		 db 0,0,0,0,187,187,0,0,0,0,187,187,187,187,0,0,0,0,187,187,0,0,0,0
		 db 0,0,0,187,1,1,187,0,0,187,1,1,1,1,187,0,0,187,1,1,187,0,0,0
		 db 0,0,0,187,1,1,187,0,0,187,1,1,1,1,187,0,0,187,1,1,187,0,0,0
		 db 0,0,0,187,1,1,187,0,0,187,1,1,1,1,187,0,0,187,1,1,187,0,0,0
		 db 0,0,0,187,1,1,1,187,187,1,1,1,1,1,1,187,187,1,1,1,187,0,0,0
		 db 0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0
		 db 0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0
		 db 0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0
		 db 0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0
		 db 0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0
		 db 0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0
		 db 0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0
		 db 0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0
		 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
	bishop db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           db 0,0,0,0,0,0,0,0,0,0,0,187,187,0,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,0,187,1,1,187,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,1,1,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,187,187,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,187,0,0,187,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,187,0,0,0,0,187,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,187,0,0,0,0,187,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,187,0,0,187,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,1,1,187,187,1,1,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,0,187,1,1,187,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,0,187,1,1,187,0,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,0,187,1,1,1,1,187,0,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,1,1,1,1,1,1,1,1,1,1,187,0,0,0,0,0,0
		   db 0,0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0
		   
		   
		   
		   
	pawn db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 187, 187, 187, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 187, 187, 1, 1, 1, 1, 187, 187, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 187, 1, 1, 1, 1, 1, 1, 187, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 187, 187, 1, 1, 1, 1, 187, 187, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 187, 187, 187, 187, 187, 187, 187, 187, 187, 187, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 187, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 187, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 187, 187, 187, 187, 187, 187, 187, 187, 187, 187, 187, 187, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		 
		 
	board db "WR" , "WN" , "WB" , "WK" , "WQ" , "WB" , "WN" , "WR"
		  db "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP"
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP"
		  db "BR" , "BN" , "BB" , "BK" , "BQ" , "BB" , "BN" , "BR"
	
	boardSave db "WR" , "WN" , "WB" , "WK" , "WQ" , "WB" , "WN" , "WR"
		  db "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP"
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP"
		  db "BR" , "BN" , "BB" , "BK" , "BQ" , "BB" , "BN" , "BR"
		  
	board1 db "WR" , "WN" , 00,00 , "WK" , 00,00 , 00,00 , 00,00 , "WR"
		  db "WP" , "WP" , 00,00 , 00,00 , 00,00 , "WP" , "WP" , "WP"
		  db 00,00 , 00,00 , "WQ" , 00,00 , 00,00 , "WN" , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , "WP" , 00,00 , "BP" , 00,00
		  db 00,00 , "WB" , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , "BP"
		  db 00,00 , "BP" , "BN" , 00,00 , 00,00 , 00,00 , "BQ" , 00,00
		  db "BP" , 00,00 , "BP" , "BP" , 00,00 , 00,00 , 00,00 , 00,00
		  db "BR" , 00,00 , "BB" , "BK" , 00,00 , "BB" , "BN" , "BR"
		  
	board0 db 00,00 , 00,00 , 00,00 , "WR" , "WK" , 00,00 , 00,00 , "WR"
		  db "WP" , "BQ" , 00,00 , 00,00 , 00,00 , "WP" , 00,00 , "WP"
		  db 00,00 , 00,00 , 00,00 , 00,00 , "WN" , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , "BN" , 00,00 , "WP" , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , "BP" , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db "BP" , "BP" , "BP" , 00,00 , 00,00 , 00,00 , 00,00 , "BP"
		  db 00,00 , 00,00 , 00,00 , "BK" , 00,00 , 00,00 , 00,00 , "BR"
		  
	board3 db "WR" , "WN" , "WB" , "WK" , "WQ" , "WB" , "WN" , "WR"
		  db "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP" , "WP"
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP" , "BP"
		  db "BR" , 00,00 , "BB" , "BK" , 00,00 , 00,00 , 00,00 , "BR"
	
	board6 db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , "BP" , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db "WK" , 00,00 , "BK" , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
		  db 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00 , 00,00
	
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
	mov ax, 13h
	int 10h
	
	call ChooseStartingPlayer
	
	cmp [playerColor], 0
	je playerStarts
	jmp startGame
	
playerStarts:
	mov [turnCounter], 1
	
startGame:
	call DrawBoard

InfLoop:
	mov ax, 3
	int 33h
	cmp bx, 1
	je outLoop
	cmp bx, 2
	je exit1
	call LoopDelay50MilSec
	jmp InfLoop
	
cont:
	call IsGameOver
	jz GameOver1
	call LoopDelay50MilSec
	jmp InfLoop

exit1:
	jmp exit
	
GameOver1:
	jmp GameOver
	
outLoop:
	push dx
	push cx
	call GetSquare
	shl bx, 1
	
	cmp [turnCounter], 0
	je computer
	
	mov ax, [playerColorAscii]
	cmp [byte board + bx], al
	jne resetRefill
	jmp afterTurn

computer:
	;push ax
	;mov al, [blackKingMoved]
	;xor ah, ah
	;call ShowAxDecimal
	;pop ax
	;push ax
	;mov al, [blackKingMoved]
	;xor ah, ah
	;call ShowAxDecimal
	;pop ax

	xor [playerColor], 1

	push 7FFFh 
	push 8000h
	push [playerColor]
	push 2
	call Minimax
	
	xor [playerColor], 1
	
	xor bh, bh
	mov bl, [bestFrom]
	mov [firstPos], bx
	mov bl, [bestTo]
	jmp makeMoveLabel
	;
	;cmp [byte board + bx], 'W'
	;jne resetRefill
;	je checkForMove

afterTurn:
	shr bx, 1
	mov [firstPos], bx
	push bx
	call ShowLegalMoves

	jmp cont
	
resetRefill:
	call Refill
	mov [toRefillCounter], 0
	shr bx, 1
	push bx
	call CheckIfLegal
	jz makeMoveLabel
	jmp cont
	
makeMoveLabel:
	mov [secondPos], bx
	call MakeMoveGraphic
	mov [legalSecondPosCount], 0
	xor [turnCounter], 1
	jmp cont
	
GameOver:
	mov ah, 02h
	mov bh, 0
	mov dh, 12  ; Row 
	mov dl, 2 ; Column 
	int 10h

	mov ah, 9
	lea dx, [GameOverPress]
	int 21h
	
	mov ah, 1
	int 21h

	mov ax, 2
	int 33h
	call ClearScreen
	mov ah, 02h
	mov bh, 0
	mov dh, 12  ; Row 
	mov dl, 47 ; Column 
	int 10h
	
	mov ah, 9
	lea dx, [chooseOption]
	int 21h
	
	push 1 
	call CheckForCheck
	jz blackLost
	
	push 0
	call CheckForCheck
	jz whiteLost
	
	jmp stalemate
	
blackLost:
	mov ah, 02h
	mov bh, 0
	mov dh, 7  ; Row 
	mov dl, 49 ; Column 
	int 10h

	mov ah, 9
	lea dx, [whiteWon]
	int 21h
	
	mov cx, 24
	mov dx, 24
	mov di, 14640
	mov [matrix], offset king
	
	push 15
	
	call PutMatrixOnScreen
	
	jmp showOptions
	
whiteLost:
	mov ah, 02h
	mov bh, 0
	mov dh, 7  ; Row 
	mov dl, 49 ; Column 
	int 10h

	mov ah, 9
	lea dx, [blackWon]
	int 21h
	
	mov cx, 24
	mov dx, 24
	mov di, 14640
	mov [matrix], offset king
	
	push 21
	
	call PutMatrixOnScreen
	jmp @@showOptions
	
stalemate:
	mov ah, 02h
	mov bh, 0
	mov dh, 7  ; Row 
	mov dl, 49 ; Column 
	int 10h
	
	mov ah, 9
	lea dx, [stalemateSTR]
	int 21h
	
showOptions:
	mov ah, 02h
	mov bh, 0
	mov dh, 15  ; Row 
	mov dl, 1 ; Column 
	int 10h
	
	mov ah, 9
	lea dx, [playAgain]
	int 21h
	
	mov ah, 02h
	mov bh, 0
	mov dh, 17  ; Row 
	mov dl, 1 ; Column 
	int 10h
	
	mov ah, 9
	lea dx, [imDone]
	int 21h
	
	mov ax, 1
	int 33h
	
	mov ah, 1
	int 21h
	
	cmp dl, 'A'
	je again
	
	jmp exit
	
again:
	call RestartGame
	jmp start
	
; --------------------------

exit:
	mov ax, 2
	int 10h

	mov ax, 4c00h
	int 21h

	depth equ [word bp + 4]
	maximizingPlayer equ [word bp + 6]
	alpha equ [word bp + 8]
	beta equ [word bp + 10]
	fromMinimax equ [word bp - 2]
	toMinimax equ [word bp - 4]
	pieceSaveMinimax equ [word bp - 6]
	maxEval equ [word bp - 8]
	minEval equ [word bp - 10]
	eval equ [word bp - 12]
proc Minimax 	
	push bp
	mov bp, sp
	sub sp, 12
	
	push cx
	push dx
	
; First exit conditions, if depth is 0 - means the algorithm reached the bottom of the tree
; Or the game is over	
	call IsGameOver
	jz @@retEvaluation1
	
	cmp depth, 0
	je @@retEvaluation1
	

	
; distinguish between the colors
	cmp maximizingPlayer, 0
	je @@whiteTurn
	
	jmp @@blackTurn
	
@@retEvaluation1:
	jmp @@retEvaluation
	
@@whiteTurn:
; Set the max eval to lowest possible
	mov maxEval, 8000h
	
;extract the position's legal moves according to White
	push 0
	call ExtractLegalMoves
	
;call minimax on every possible move of the position
	mov cx, [legalMovesAmount]
	mov dx, cx
	;mov ax, dx
	;call ShowAxDecimal
	
@@ForEachChildWhite:
;Restore the legal moves array
	push 0
	call ExtractLegalMoves
	
;Make a move
	mov si, dx
	sub si, cx
	
	shl si, 1
	
	xor bh, bh
	mov bl, [legalMoves + si]
	mov fromMinimax, bx
	mov [from], bx
;	mov ax, bx
;	call ShowAxDecimal

;	push dx
;	mov ah, 2
;	mov dl, ';'
;	int 21h
;	pop dx
	
	mov bl, [legalMoves + si + 1]
	mov toMinimax, bx
	mov [to], bx


	call MakeMove
	
	mov ax, [pieceSave]
	mov pieceSaveMinimax, ax 

;Calling minimax
	inc [depthCounter]
	mov ax, depth
	dec ax
	
	push beta
	push alpha
	push 1
	push ax
	call Minimax
	
	jmp @@nextWhite

@@LoopForEachChildWhite:
	loop @@ForEachChildWhite
	jmp @@retMaxEval
	
@@nextWhite:	
	mov eval, ax ; minimax returns the evaluation in ax
	
	push ax
	push maxEval
	call Max ; returns the greater* number inside ax
	cmp [depthCounter], 0
	mov maxEval, ax ; updating maxEval
	jne @@PruningWhite
	jmp @@UpdateMaxEval
	
@@PruningWhite:
	mov bx, ax
	
	push alpha
	push eval
	call max
	mov alpha, ax
	
	mov ax, beta
	cmp ax, alpha
	jle @@retUndoMove1
	
	mov ax, bx
	
@@UpdateMaxEval:
	
	cmp [depthCounter], 0
	je @@secondCheckSaveMoveWhite
	jmp @@NextRoundWhite

@@retUndoMove1:
	jmp @@retUndoMove

@@secondCheckSaveMoveWhite:
	cmp ax, eval
	je @@saveMoveWhite
	
@@NextRoundWhite:
	
	mov ax, fromMinimax
	mov [from], ax
	
	mov ax, toMinimax
	mov [to], ax
	
	mov ax, pieceSaveMinimax
	mov [pieceSave], ax
	
	call UndoMove
	jmp @@LoopForEachChildWhite
	
	jmp @@retMaxEval
	
@@saveMoveWhite:
	;mov ax, [depthCounter]
	;call ShowAxDecimal
	push bx
	mov bx, fromMinimax
	mov [bestFrom], bl
	;mov ax, bx
	;call ShowAxDecimal
	
	mov bx, toMinimax
	mov [bestTo], bl
	;mov ax, bx
	;call ShowAxDecimal
	
	pop bx
	jmp @@NextRoundWhite

@@blackTurn:
; Set the min eval to highest possible 
	mov minEval, 7FFFh
	
; extract the position's legal moves according to Black
	push 1
	call ExtractLegalMoves
	
;call minimax on every possible move of the position
	mov cx, [legalMovesAmount]
	mov dx, cx

@@ForEachChildBlack:
;Restore the legal moves array
	push 1
	call ExtractLegalMoves

;Make a move
	mov si, dx
	sub si, cx
	
	shl si, 1
	
	xor bh, bh
	mov bl, [legalMoves + si]
	mov fromMinimax, bx
	mov [from], bx
	;mov ax, bx
	;call ShowAxDecimal
	
	mov bl, [legalMoves + si + 1]
	mov toMinimax, bx
	mov [to], bx
	;mov ax, bx
	;call ShowAxDecimal

	call MakeMove
	
	mov ax, [pieceSave]
	mov pieceSaveMinimax, ax 

;Calling minimax
	inc [depthCounter]
	mov ax, depth
	dec ax
	push beta
	push alpha
	push 0
	push ax
	call Minimax
	
	jmp @@nextBlack

@@LoopForEachChildBlack:
	loop @@ForEachChildBlack
	jmp @@retMinEval
	
@@nextBlack:
	mov eval, ax ; minimax returns the evaluation in ax
	
	push ax
	push minEval
	call Min ;returns the lower* number inside ax
	cmp [depthCounter], 0
	mov minEval, ax ; updating minEval
	jne @@PruningBlack
	jmp @@UpdateMinEval
	
@@PruningBlack:
	mov bx, ax
	
	push beta
	push eval
	call Min
	mov beta, ax
	
	mov ax, alpha
	cmp beta, ax
	jle @@retUndoMove2
	mov ax, bx

@@UpdateMinEval:

	cmp [depthCounter], 0
	je @@secondCheckSaveMoveBlack	
	jmp @@NextRoundBlack

@@retUndoMove2:
	jmp @@retUndoMove

@@secondCheckSaveMoveBlack:
	cmp ax, eval
	je @@saveMoveBlack
	
@@NextRoundBlack:
	mov ax, fromMinimax
	mov [from], ax
	
	mov ax, toMinimax
	mov [to], ax
	
	mov ax, pieceSaveMinimax
	mov [pieceSave], ax
	
	call UndoMove
	
	jmp @@LoopForEachChildBlack
	
	jmp @@retMinEval

@@saveMoveBlack:
	;mov ax, [depthCounter]
	;call ShowAxDecimal
	push bx
	mov bx, fromMinimax
	mov [bestFrom], bl
	;mov ax, bx
	;call ShowAxDecimal
	
	mov bx, toMinimax
	mov [bestTo], bl
	;mov ax, bx
	;call ShowAxDecimal
	
	pop bx
	
	jmp @@NextRoundBlack

@@retEvaluation:
	call EvaluatePosition
	jmp @@ret
	
@@retMinEval:
	mov ax, minEval
	
	jmp @@ret
	
@@retMaxEval:
	mov ax, maxEval

	jmp @@ret

@@retUndoMove:
	mov ax, fromMinimax
	mov [from], ax
	
	mov ax, toMinimax
	mov [to], ax
	
	mov ax, pieceSaveMinimax
	mov [pieceSave], ax
	
	call UndoMove
	
	cmp maximizingPlayer, 0
	je @@retMaxEval
	jmp @@retMinEval

@@ret:

	pop dx
	pop cx
	add sp, 12
	pop bp
	cmp [depthCounter], 0
	jne @@decCount
	jmp @@retNext
	
@@decCount:
	dec [depthCounter]
	
@@retNext:
	ret 8
	
endp Minimax

;------------------
;INPUT: none
;OUTPUT: zf - zf = 1 => game over, ax = whos out of moves, 0 - white, 1 - black
;PURPOSE: check if the game is over
;EXTRA INFO: only checks if game is over. doesnt specify how.	
;------------------
proc IsGameOver	
	mov [word legalMoves], 0

	push 0
	call ExtractLegalMoves
	
	cmp [word legalMoves], 0
	je @@retGameOverWhite
	
	mov [word legalMoves], 0
	
	push 1
	call ExtractLegalMoves
	
	cmp [word legalMoves], 0
	je @@retGameOverBlack	
	
	jmp @@retGameNotOver
	
@@retGameOverWhite:
	push ax
	mov ax, 1
	sub ax, 1
	pop ax
	mov ax, 0
	ret
	
@@retGameOverBlack:
	push ax
	mov ax, 1
	sub ax, 1
	pop ax
	mov ax, 1
	ret
	
@@retGameNotOver:
	push ax
	add ax, 1
	pop ax
	ret

endp IsGameOver

proc RestartGame
	
	mov cx, 128
	
@@restartBoard:
	mov bx, 128
	sub bx, cx
	mov al, [byte boardSave + bx]
	mov [byte board + bx], al
	loop @@restartBoard
	
	mov [rook1Move], 0
	mov [rook2Move], 0
	mov [rook3Move], 0
	mov [rook4Move], 0
	
	mov [rook1LastPos], 0
	mov [rook2LastPos], 7
	mov [rook3LastPos], 56
	mov [rook4LastPos], 63
	
	mov [blackKingMoved], 0
	mov [whiteKingMoved], 0
	
	mov [turnCounter], 0
	
	mov [legalMovesAmountP1], 0
	mov [legalMovesAmount], 0
	
	mov [toRefillCounter], 0
	
	mov [legalSecondPosCount], 0
	
	mov [depthCounter], 0

	mov [playerColor], 0
	mov [playerColorAscii], 0	

	ret
endp RestartGame
proc ChooseStartingPlayer
	push ax
	push bx
	push dx
	push es	
	
	xor dx, dx
	
	mov ax, 0040h
	mov es, ax
	
	mov ax, [es:006Ch]
	mov bx, 2
	div bx

	cmp dx, 0
	je @@playerWhite
	
	mov [playerColor], 1
	mov [playerColorAscii], 'B'
	jmp @@ret
	
@@playerWhite:
	mov [playerColor], 0
	mov [playerColorAscii], 'W'

@@ret:
	pop es
	pop dx
	pop bx
	pop ax
	ret
endp ChooseStartingPlayer

	color equ [word bp + 4]
proc CheckForCastle
	push bp
	mov bp, sp
	xor ax, ax
	
	push color
	call CheckForCheck
	jz @@ret2
	
	cmp color, 1
	je @@blackCastle1

	cmp [whiteKingMoved], 0
	jne @@ret2

	cmp [rook1Move], 0
	jne @@secondOptionWhite
	
	cmp [word board + 2], 0
	jne @@secondOptionWhite
	
	cmp [word board + 4], 0
	jne @@secondOptionWhite
	
	cmp [word board], "RW"
	jne @@secondOptionWhite
	
	mov [from], 3
	mov [to], 2
	call MakeMove
	push color
	call CheckForCheck
	jz @@secondOptionWhiteUndoMove
	call UndoMove
	
	mov [from], 3
	mov [to], 1
	call MakeMove
	push color
	call CheckForCheck
	jz @@secondOptionWhiteUndoMove
	call UndoMove
	
	inc ax
	jmp @@secondOptionWhite
	
@@ret2:
	jmp @@ret
	
@@blackCastle1:
	jmp @@blackCastle
	
@@secondOptionWhiteUndoMove:
	call UndoMove

@@secondOptionWhite:
	cmp [rook2Move], 0
	jne @@ret1
	
	cmp [word board + 8], 0
	jne @@ret1
	
	cmp [word board + 10], 0
	jne @@ret1
	
	cmp [word board + 12], 0
	jne @@ret1
	
	cmp [word board + 14], "RW"
	jne @@ret1
	
	mov [from], 3
	mov [to], 4
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove1
	call UndoMove
	
	mov [from], 3
	mov [to], 5
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove1
	call UndoMove
	
	mov [from], 3
	mov [to], 6
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove1
	call UndoMove
	
	cmp ax, 1
	je @@both
	
	mov ax, 2

@@ret1:
	jmp @@ret

@@retUndoMove1:
	jmp @@retUndoMove
	
@@both:
	mov ax, 3
	jmp @@ret1

@@blackCastle:
	cmp [blackKingMoved], 0
	jne @@ret1
	
	cmp [rook3Move], 0
	jne @@secondOptionBlack
	
	cmp [word board + 114], 0
	jne @@secondOptionBlack
	
	cmp [word board + 116], 0
	jne @@secondOptionBlack
	
	cmp [word board + 112], "RB"
	jne @@secondOptionBlack
	
	mov [from], 59
	mov [to], 58
	call MakeMove
	push color
	call CheckForCheck
	jz @@secondOptionBlackUndoMove
	call UndoMove
	
	mov [from], 59
	mov [to], 57
	call MakeMove
	push color
	call CheckForCheck
	jz @@secondOptionBlackUndoMove
	call UndoMove
	
	inc ax
	jmp @@secondOptionWhite
	
@@secondOptionBlackUndoMove:
	call UndoMove

@@secondOptionBlack:
	cmp [rook4Move], 0
	jne @@ret
	
	cmp [word board + 124], 0
	jne @@ret
	
	cmp [word board + 122], 0
	jne @@ret
	
	cmp [word board + 120], 0
	jne @@ret
	
	cmp [word board + 126], "RB"
	jne @@ret
	
	mov [from], 59
	mov [to], 60
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove
	call UndoMove
	
	mov [from], 59
	mov [to], 61
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove
	call UndoMove
	
	mov [from], 59
	mov [to], 62
	call MakeMove
	push color
	call CheckForCheck
	jz @@retUndoMove
	call UndoMove
	
	cmp ax, 1
	je @@both2
	
	mov ax, 2
	jmp @@ret
	
@@both2:
	mov ax, 3
	jmp @@ret

@@retUndoMove:
	call UndoMove

@@ret:
	pop bp
	ret 2
endp CheckForCastle

proc DrawBoard
	push ax
	push bx
	push cx
	push dx

	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx


	mov cx, 64
	
@@DrawBoard:
	mov bx, 64
	sub bx, cx
	xor bh, bh
	
	push [playerColor]
	push 0
	push bx
	call DrawSquare
	loop @@DrawBoard
	
	mov ax, 1
	int 33h
	xor bx, bx
	
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

endp DrawBoard

;------------------
;INPUT: none
;OUTPUT: ax - changes according to the position's evaluation. 
;PURPOSE: evaluate the position
;EXTRA INFO: the 3 parts combined	
;------------------
proc EvaluatePosition
	call IsGameOver
	jz @@gameOver
	xor ax, ax
	
	call EvaluateCenterControl
	
	call EvaluateKingSafety
	
	call EvaluateMaterial

	jmp @@ret
	
@@gameOver:
	cmp ax, 1
	je @@CheckForCheckWhite

	push 0
	call CheckForCheck
	jz @@checkmateBlack
	jmp @@stalemate
	
@@CheckForCheckWhite:
	push 1
	call CheckForCheck
	jz @@checkmateWhite
	
@@stalemate:
	mov ax, 0
	jmp @@ret
	
@@checkmateWhite:
	mov ax, 7FFFh
	jmp @@ret
	
@@checkmateBlack:
	mov ax, 8000h
	
@@ret:
	ret
endp EvaluatePosition

;------------------
;INPUT: none
;OUTPUT: ax - changes according to the piece's center control.
;PURPOSE: evaluate the position
;EXTRA INFO: 1 of 3 parts	
;------------------
	x equ [byte bp - 2]
	y equ [byte bp - 4]
proc EvaluateCenterControl
	push bp
	mov bp, sp
	sub sp, 4
	push bx
	push cx
	
	mov cx, 64
	
@@lookForPiece:
	mov bx, 64
	sub bx, cx
	
	shl bx, 1
	cmp [board + bx], 0
	jne @@CheckIfKing
	jmp @@NextRound	
	
@@CheckIfKing:
	cmp [byte board + bx + 1], 'K'
	jne @@FindSection

@@NextRound:	
	loop @@lookForPiece
	jmp @@ret


@@FindSection:
; move to an (x,y) representation
	push bx
	shr bx, 1
	push ax
	mov ax, bx
	mov bx, 8
	div bl
	mov y, al
	mov x, ah
	pop ax
	pop bx
	
; locate section
	
	cmp x, 3
	jae @@xCheckInnerSection
	jmp @@ringCheck
	
@@xCheckInnerSection:
	cmp x, 4
	jbe @@yCheck1InnerSection
	jmp @@ringCheck
	
@@yCheck1InnerSection:
	cmp y, 3
	jae @@yCheck2InnerSection
	jmp @@ringCheck
	
@@yCheck2InnerSection:
	cmp y, 4
	jbe @@innerSection
	jmp @@ringCheck

@@innerSection:
	cmp [byte board + bx], 'W'
	je @@AddInner
	
	cmp [byte board + bx + 1], 'P'
	je @@PawnInner
	sub ax, 30
	jmp @@NextRound
	
@@PawnInner:
	sub ax, 35
	jmp @@NextRound
	
@@AddInner:
	cmp [byte board + bx + 1], 'P'
	je @@AddPawnInner
	add ax, 30
	jmp @@NextRound

@@AddPawnInner:
	add ax, 35
	jmp @@NextRound

@@ringCheck:
	cmp x, 2
	jae @@xCheckRingSection
	jmp @@outerSection
	
@@xCheckRingSection:
	cmp x, 5
	jbe @@yCheck1RingSection
	jmp @@outerSection
	
@@yCheck1RingSection:
	cmp y, 2
	jae @@yCheck2RingSection
	jmp @@outerSection

@@yCheck2RingSection:
	cmp y, 5
	jbe @@ringSection
	jmp @@outerSection

@@ringSection:
	cmp [byte board + bx], 'W'
	je @@AddRing
	
	cmp [byte board + bx], 'P'
	je @@ringPawn
	
	sub ax, 30
	jmp @@NextRound
	
@@ringPawn:
	sub ax, 5
	jmp @@NextRound
	
@@AddRing:
	cmp [byte board + bx + 1], 'P'
	je @@addRingPawn
	add ax, 30
	jmp @@NextRound
	
@@addRingPawn:
	add ax, 5
	jmp @@NextRound
	
@@outerSection:
	jmp @@NextRound ; No advantage added
	
@@ret:
	pop cx
	pop bx
	add sp, 4
	pop bp
	ret
endp EvaluateCenterControl
	
;------------------
;INPUT: none
;OUTPUT: ax - changes according to the piece count on each side.
;PURPOSE: evaluate the position
;EXTRA INFO: 1 of 3 parts	
;------------------
proc EvaluateMaterial
	push bx
	push cx
	
;Material Evaulation
	mov cx, 64
	
@@FindPieces:
	mov bx, 64
	sub bx, cx
	shl bx, 1
	cmp [byte board + bx], 0
	je @@middle
	cmp [byte board + bx + 1], 'P'
	jne @@knight
	cmp [byte board + bx], 'W'
	je @@addPawn
	sub ax, 100
	jmp @@NextRound
@@addPawn:
	add ax, 100
	jmp @@NextRound
	
	
@@knight:
	cmp [byte board + bx + 1], 'N'
	jne @@bishop
	cmp [byte board + bx], 'W'
	je @@addKnight
	sub ax, 300
	jmp @@NextRound
@@addKnight:
	add ax, 300
	jmp @@NextRound
	
@@middle:
	loop @@FindPieces
	jmp @@Continue
	
@@bishop:
	cmp [byte board + bx + 1], 'B'
	jne @@rook
	cmp [byte board + bx], 'W'
	je @@addBishop
	sub ax, 300
	jmp @@NextRound
@@addBishop:
	add ax, 300
	jmp @@NextRound
	
	
@@rook:
	cmp [byte board + bx + 1], 'R'
	jne @@queen
	cmp [byte board + bx], 'W'
	je @@addRook
	sub ax, 500
	jmp @@NextRound
@@addRook:
	add ax, 500
	jmp @@NextRound
	
@@queen:
	cmp [byte board + bx + 1], 'Q'
	jne @@NextRound
	cmp [byte board + bx], 'W'
	je @@addQueen
	sub ax, 900
	jmp @@NextRound
@@addQueen:
	add ax, 900
	jmp @@NextRound
	
@@NextRound:
	jmp @@middle

@@Continue:

@@ret:	
	pop cx
	pop bx
	ret
endp EvaluateMaterial

;------------------
;INPUT: none
;OUTPUT: ax - changes according to the kings' safety.
;PURPOSE: evaluate the position
;EXTRA INFO: 1 of 3 parts
;------------------

	
	blackKingPos equ [word bp - 4]
	whiteKingPos equ [word bp - 2]
proc EvaluateKingSafety
	push bp
	mov bp, sp
	sub sp, 4
	
	push di
	push cx
	push bx

	xor di, di
	mov cx, 64

@@FindKings:
	;push ax 
	;mov ax, di
	;call ShowAxDecimal
	;pop ax	
	cmp di, 2
	je @@Continue
	
	mov bx, 64
	sub bx, cx
	shl bx, 1
	
	cmp [byte board + bx + 1], 'K'
	je @@IdentifyColor

@@NextRound:
	loop @@FindKings
	jmp @@Continue
	
@@IdentifyColor:
	cmp [byte board + bx], 'W'
	je @@whiteKingFound
	
	shr bx, 1
	mov blackKingPos, bx
	inc di
	jmp @@NextRound
	
@@whiteKingFound:
	shr bx, 1
	mov whiteKingPos, bx
	inc di
	jmp @@NextRound
	
@@Continue:

;Black King's safety Evalution
	mov bx, blackKingPos
	cmp bx, 47
	jbe @@worstBlack
	cmp bx, 55
	jbe @@secondWorstBlack
	
	cmp bx, 59
	je @@thirdBestBlackKing
	cmp bx, 60
	je @@thirdBestBlackKing
	cmp bx, 58
	je @@secondBestBlackKing
	cmp bx, 61
	je @@secondBestBlackKing
	
	sub ax, 45
	jmp @@WhiteKingEva
	
@@thirdBestBlackKing:
	sub bx, 20
	jmp @@ret
	
@@secondBestBlackKing:
	sub ax, 35
	jmp @@WhiteKingEva
	
@@worstBlack:
	add ax, 35
	jmp @@WhiteKingEva
	
@@secondWorstBlack:
	add ax, 25
	
;White King's safety Evalution
@@WhiteKingEva:
	mov bx, whiteKingPos
	cmp bx, 16
	jae @@worstWhite
	cmp bx, 8
	jae @@secondWorstWhite
	
	cmp bx, 3
	je @@thirdBestWhiteKing
	cmp bx, 4
	je @@thirdBestWhiteKing
	cmp bx, 2
	je @@secondBestWhiteKing
	cmp bx, 5
	je @@secondBestWhiteKing
	
	add ax, 45
	
@@thirdBestWhiteKing:
	add bx, 20
	jmp @@ret
	
@@secondBestWhiteKing:
	add ax, 35
	jmp @@ret
	
@@worstWhite:
	sub ax, 35
	jmp @@ret
	
@@secondWorstWhite:	
	sub ax, 25
	
@@ret:
	pop bx
	pop cx
	pop di
	add sp, 4
	pop bp
	ret
endp EvaluateKingSafety

	color equ [word bp - 2]
proc MakeMoveGraphic
	push bp
	mov bp, sp
	sub sp, 2
	push ax
	
	mov ax, 2
	int 33h

	push bx
	push dx

	mov bx, [firstPos]
	mov [from], bx

	mov dx, [secondPos]
	cmp dx, 64
	je @@promotion1
	jmp @@secondPromCheck

@@promotion1:
	cmp bx, 47
	jae @@whitePromotion
	mov dx, bx
	sub dx, 8
	jmp @@next
	
@@whitePromotion:
	mov dx, bx
	add dx, 8
	jmp @@next

@@secondPromCheck:	
	shl bx, 1
	cmp [byte board + bx + 1], "P"
	je @@CheckPromotion
	jmp @@CheckMaybeCastle
	
@@CheckPromotion:
	cmp [secondPos], 7
	jbe @@Promotion2a
	cmp [secondPos], 56
	jae @@Promotion2a
	jmp @@next
	
@@Promotion2a:
	jmp @@Promotion2
	
@@CheckMaybeCastle:
	cmp [byte board + bx], "W"
	je @@IsCastleWhite
	
	mov color, 1

	jmp @@CheckCastle
	
@@IsCastleWhite:
	mov color, 0
	
@@CheckCastle:
	push color
	call CheckForCastle
	cmp ax, 0
	je @@next
	
	cmp [from], 3
	je @@CheckSecondPos
	
	cmp [from], 59
	je @@CheckSecondPos
	
	jmp @@next
	
@@CheckSecondPos:
	cmp [secondPos], 1
	je @@topLeft
	
	cmp [secondPos], 5
	je @@topRight
	
	cmp [secondPos], 57
	je @@bottomLeft
	
	cmp [secondPos], 61
	je @@bottomRight
	
	jmp @@next
	
@@topLeft:
	mov [secondPos], 66
	jmp @@next
	
@@topRight:
	mov [secondPos], 67
	jmp @@next
	
@@bottomLeft:
	mov [secondPos], 68
	jmp @@next
	
@@bottomRight:
	mov [secondPos], 69
	jmp @@next
	
@@Promotion2:
	mov [secondPos], 64
	
@@next:
	mov bx, [secondPos]
	mov [to], bx
	
	call MakeMove
	
	;push 0
	;push [firstPos]
	;call DrawSquare
	;
	;mov [secondPos], dx
	;push 0
	;push [secondPos]
	;call DrawSquare
	call DrawBoard
	
	mov ax, 1
	int 33h
	
	pop dx
	pop bx
	pop ax
	
@@ret:
	add sp, 2
	pop bp
	ret

endp MakeMoveGraphic

	square equ [byte bp + 4]
proc CheckIfLegal
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	
 	mov cx, [legalSecondPosCount]
	cmp cx, 0
	je @@retIllegal
	mov bl, square

@@Check:
	mov si, [legalSecondPosCount]
	sub si, cx
	cmp [legalSecondPos + si], bl
	je @@retLegal
	loop @@Check
	
	jmp @@retIllegal

@@retLegal:
	xor ah, ah
	jmp @@ret

@@retIllegal:
	mov ax, 1
	add ax, 1

@@ret:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp CheckIfLegal

proc LoopDelay50MilSec
	push cx
	mov cx, 85
@@Self1:
	push cx
	mov cx,3000   
@@Self2:	
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret
endp LoopDelay50MilSec

proc Refill
	push ax
	push cx
	push bx
	push dx
	
	mov ax, 2
	int 33h

	mov cx, [toRefillCounter]
	cmp cx, 0
	je @@noRefill

@@Refill:
	mov bx, [toRefillCounter]
	sub bx, cx
	mov dl, [toRefill + bx] 
	xor dh, dh
	push [playerColor]
	push 0
	push dx
	call DrawSquare
	loop @@Refill

@@noRefill:
	mov ax, 1
	int 33h
	pop dx
	pop bx
	pop cx
	pop ax
	ret
endp Refill

	square equ [word bp + 4]
proc ShowLegalMoves
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov ax, 2
	int 33h

	call Refill
	
	mov [legalSecondPosCount], 0
	mov bx, square
	
	shl bx, 1
	cmp [byte board + bx], 'W'
	je @@ExtractWhite
	
	push 1
	call ExtractLegalMoves
	
	mov cx, [LegalMovesAmount]
	jmp @@LookForMovesLoop

@@ExtractWhite:
	push 0
	call ExtractLegalMoves

 	mov cx, [LegalMovesAmount]

@@LookForMovesLoop:
	mov bx, [LegalMovesAmount]
	sub bx, cx
	shl bx, 1
	mov dx, square
	cmp [byte legalMoves + bx], dl
	je @@HighlightLegalSquares

@@NextRound:
	loop @@LookForMovesLoop
	jmp @@ret

@@HighlightLegalSquares:
	mov al, [byte legalMoves + bx + 1]
	cmp al, 64
	je @@SpecialMove
	
	cmp al, 65
	ja @@Castle
	
@@next:
	mov si, [toRefillCounter]
	mov [toRefill + si], al
	inc [toRefillCounter]
	mov si, [legalSecondPosCount]
	mov [legalSecondPos + si], al
	inc [legalSecondPosCount]
	push [playerColor]
	push 1
	xor ah, ah
	push ax
	call DrawSquare
	jmp @@NextRound

@@SpecialMove:
	mov al, [byte legalMoves + bx]
	cmp [byte legalMoves + bx], 47
	ja @@blackPromotion
	
	sub al, 8
	jmp @@next

@@blackPromotion:
	add al, 8
	jmp @@next

@@Castle:
	cmp al, 66
	je @@topLeft
	
	cmp al, 67
	je @@topRight
	
	cmp al, 68
	je @@bottomLeft
	
	cmp al, 69
	je @@bottomRight
	
@@topLeft:
	mov al, dl
	sub al, 2
	jmp @@next
	
@@topRight:
	mov al, dl
	add al, 2
	jmp @@next
	
@@bottomLeft:
	mov al, dl
	sub al, 2
	jmp @@next
	
@@bottomRight:
	mov al, dl
	add al, 2
	jmp @@next

@@ret:
	mov ax, 1
	int 33h
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp ShowLegalMoves

	x equ [word bp + 4]
	y equ [word bp + 6]
proc GetSquare
	push bp
	mov bp, sp
	push ax
	push cx
	push dx
	
	xor dx, dx
	
	shr x, 1
	mov ax, x
	sub ax, 64
	mov bx, 24
	div bx ; ax = x
	;call ShowAxDecimal
	
	mov cl, al ; cl = x
	
	xor dx, dx
	mov ax, y
	sub ax, 4
	div bx ; ax = y
	
	xor dx, dx
	mov bl, 8
	mul bx
	
	add al, cl ; al = square
	xor ah, ah
	
	mov bx, ax

	cmp [playerColor], 0
	je @@PlayerWhite
	jmp @@ret
	
@@playerWhite:
	mov ax, 63
	sub ax, bx
	mov bx, ax
	
@@ret:
	pop dx
	pop cx
	pop ax
	pop bp
	ret 4
endp GetSquare

	square equ [byte bp + 4]
	mode equ [byte bp + 6]
	color equ [byte bp + 8]
	y equ [byte bp - 2]
	x equ [byte bp - 4]
proc DrawSquare
	push bp
	mov bp, sp
	sub sp, 4
	push ax
	push bx
	push cx
	push dx
	push di
	push si

	mov bl, 8
	mov al, square
	
	cmp color, 1
	je @@playerBlack
	
@@playerWhite:
	mov ah, 63
	sub ah, al
	mov al, ah
	xor ah, ah
	
@@playerBlack:
	div bl ; ah = x al = y
	mov y, al
	mov x, ah
	mov dl, al
	mov dh, ah
	mov bl, 24
	xor ah, ah	
	mul bl
	mov cx, ax
	mov al, dh
	xor ah, ah
	mul bl
	mov dx, ax
	
	push 24
	push 24

	test x, 00000001b
	jz @@testYEven
	
@@testYOdd:
	test y, 00000001b
	jz @@brownish
	jmp @@yellowish
	
@@testYEven:
	test y, 00000001b
	jz @@yellowish
	jmp @@brownish

@@brownish:
	cmp mode, 1
	je @@darkRedish
	push 139
	jmp @@next
	
@@yellowish:
	cmp mode, 1
	je @@redish
	push 92
	jmp @@next
	
@@darkRedish:
	push 4
	jmp @@next

@@redish:
	push 40
	
@@next:
	add cx, 4
	push cx
	
	add dx, 63
	push dx
	
	call DrawFullRect

	mov bl, square
	xor bh, bh
	shl bx, 1
	cmp [byte board + bx], 0
	je @@ret1

	push dx
	xor dx, dx
	mov bx, cx
	mov ax, 320
	mul bx
	pop dx
	add ax, dx
	mov di, ax
	inc di

@@CheckPiece:
	mov cx, 24
	mov dx, 24
	mov bl, square
	xor bh, bh
	shl bx, 1
	cmp [byte board + bx + 1], "P"
	je @@drawPawn
	
	cmp [byte board + bx + 1], "B"
	je @@drawBishop
	
	cmp [byte board + bx + 1], "R"
	je @@drawRook
	
	cmp [byte board + bx + 1], "N"
	je @@drawKnight
	
	cmp [byte board + bx + 1], "Q"
	je @@drawQueen
	
	cmp [byte board + bx + 1], "K"
	je @@drawKing
	
@@ret1:
	jmp @@ret

@@drawPawn:
	mov si, offset pawn
	mov [matrix], si
	jmp @@checkColor
	
@@drawBishop:
	mov si, offset bishop
	mov [matrix], si
	jmp @@checkColor
	
@@drawRook:
	mov si, offset rook
	mov [matrix], si
	jmp @@checkColor
	
@@drawKnight:
	mov si, offset knight
	mov [matrix], si
	jmp @@checkColor
	
@@drawQueen:
	mov si, offset queen
	mov [matrix], si
	jmp @@checkColor
	
@@drawKing:
	mov si, offset king
	mov [matrix], si
	
@@checkColor:
	cmp [byte board + bx], 'W'
	je @@white
	jmp @@black

@@white:
	push 15
	jmp @@drawPiece
	
@@black:
	push 22

@@drawPiece:
	call PutMatrixOnScreen
	
	
@@ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	add sp, 4
	pop bp
	ret 6
endp DrawSquare

	x equ [bp + 4]
	y equ [bp + 6]
	color equ [bp + 8]
	len equ [bp + 10]
proc DrawHorizontalLine
	push bp
	mov bp, sp	
	push cx
	
	mov dx, y
	mov al, color
	mov ah, 0ch
	mov cx, len
	
@@DrawLoop:
	push cx
	mov bx, x
	add bx, cx
	mov cx, bx
	mov bh, 0
	int 10h
	pop cx
	loop @@DrawLoop

@@ret:
	pop cx
	pop bp
	ret	8
endp DrawHorizontalLine


	x equ [bp + 4]
	y equ [bp + 6]
	color equ [bp + 8]
	len equ [bp + 10]
proc DrawVerticalLine
	push bp 
	mov bp, sp
	push cx
	
	mov dx, y
	mov al, color
	mov ah, 0ch
	mov cx, len
	
@@DrawLoop:
	mov bx, y
	add bx, cx
	push cx
	mov cx, x
	mov dx, bx
	mov bh, 0
	int 10h
	pop cx
	loop @@DrawLoop
	


@@ret:
	pop cx
	pop bp
	ret 8
endp DrawVerticalLine
	
	
	x equ [bp + 4]
	y equ [bp + 6]
	color equ [bp + 8]
	len equ [bp + 10]
	wid equ [bp + 12]
proc DrawRect	
	push bp
	mov bp, sp

	mov dx, y
	mov cx, x
	mov al, color
	mov ah, 0ch
	mov bh, 0
	int 10h

	push wid
	push color
	push y
	push x
	call DrawHorizontalLine
	push wid
	push color
	push y
	push x
	call DrawHorizontalLine
	
	push len
	push color
	push y
	push x
	call DrawVerticalLine
	
	mov ax, x
	add ax, wid
	
	push len
	push color
	push y
	push ax
	call DrawVerticalLine
	
	mov ax, y
	add ax, len
	
	push wid
	push color
	push ax
	push x
	call DrawHorizontalLine

@@ret:
	pop bp
	ret 10
endp DrawRect


	x equ [bp + 4]
	y equ [word bp + 6]
	color equ [bp + 8]
	len equ [bp + 10]
	wid equ [bp + 12]
proc DrawFullRect

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	mov cx, len

@@Drawloop:
	push wid
	push color
	push y
	push x
	call DrawHorizontalLine
	inc y
	loop @@DrawLoop

@@ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
endp DrawFullRect

	color equ [byte bp + 4]
proc PutMatrixOnScreen
	push bp
	mov bp, sp
	push cx
	push di
	push dx
	push bx
	
	mov ax, 0a000h
	mov es, ax
	
	cld ;sets direction of movsb to copy forward
    mov si, [matrix] ; puts offset of the Matrix to si (Source)
	
@@NextRow:	; loop of cx lines according to matrix height (num of Lines)
	push cx ;saves cx of loop
	mov cx, dx ;sets cx for movsb according to matrix length
	
@@NoBlack:
	cmp [byte ptr ds:si], 0
	je @@NextRound
	cmp [byte ptr ds:si], 187
	jne @@color
	jmp @@draw

@@color:
	mov bl, color
	mov [byte ptr ds:si], bl
	
@@draw:
	movsb
	jmp @@Loop
	
@@NextRound:
	inc si
	inc di
	
@@Loop:
	loop @@NoBlack
	
	sub di,dx ; returns back to the beginning of the line 
	add di, 320 ;go down one line in “screen” by adding 320
	pop cx  ;restores cx of loop
	loop @@NextRow

@@ret:
	;call ShowAxDecimal
	pop bx
	pop dx
	pop di
	pop cx
	pop bp
	ret 2
endp PutMatrixOnScreen

proc ShowAxDecimal
	push ax
	push bx
	push cx
	push dx

	 
	; check if negative
	test ax,08000h
	jz PositiveAx
		
	;  put '-' on the screen
	push ax
	mov dl,'-'
	mov ah,2
	int 21h
	pop ax

	neg ax ; make it positive
PositiveAx:
	mov cx,0   ; will count how many time we did push 
	mov bx,10  ; the divider

put_mode_to_stack:
	xor dx,dx
	div bx
	add dl,30h
	; dl is the current LSB digit 
	; we cant push only dl so we push all dx
	push dx    
	inc cx
	cmp ax,9   ; check if it is the last time to div
	jg put_mode_to_stack

	cmp ax,0
	jz pop_next  ; jump if ax was totally 0
	add al,30h  
	mov dl, al    
	mov ah, 2h
	int 21h        ; show first digit MSB
	   
pop_next: 
	pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	mov dl, al
	mov ah, 2h
	int 21h        ; show all rest digits
	loop pop_next

	pop dx
	pop cx
	pop bx
	pop ax

	ret
endp ShowAxDecimal

	color equ [word bp + 4]
proc ExtractLegalMoves
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	
	mov [legalMovesAmount], 0
	mov [legalMovesAmountP1], 0

	mov cx, 64
	
 @@ExtractLegalMovesP1:
 	mov bx, 64
 	sub bx, cx
	mov ax, color
	push ax
 	push bx
 	call ExtractLegalMovesSquare
 	
 	;mov ax, bx
 	;call ShowAxDecimal
 	;mov ah, 2
 	;mov dl, ';'
 	;int 21h
 	loop @@ExtractLegalMovesP1

	mov cx, [legalMovesAmountP1]
	cmp cx, 0
	je @@ret
	mov dx, cx
	jmp @@ExtractLegalMovesP2
	
@@ExtractLegalMovesP2:
	xor ah, ah
	mov bx, dx
	sub bx, cx
	shl bx, 1
	mov di, bx
	mov al, [legalMovesP1 + bx]
	mov [from], ax
	mov al, [legalMovesP1 + bx + 1]
	mov [to], ax
	call MakeMove
	
	push color
	
	call CheckForCheck
	jz @@NextRound
	
	mov al, [legalMovesP1 + bx]
	mov ah, [legalMovesP1 + bx + 1]
	mov bx, [legalMovesAmount]
	
	shl bx, 1
	
	mov [legalMoves + bx], al
	mov [legalMoves + bx + 1], ah
	
	inc [legalMovesAmount]
	jmp @@NextRound
	
@@NextRound:

	call UndoMove
;	cmp color, 1
;	jne @@a
;	
;	push ax 
;	mov al, [blackKingMoved]
;	xor ah, ah
;	call ShowAxDecimal
;	pop ax
;	
;	
;@@a:	
	loop @@ExtractLegalMovesP2

	
@@ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp ExtractLegalMoves

;------------------
;INPUT: from, and to variables
;OUTPUT: none
;PURPOSE: makes a move on the board, used for evaluations etc.
;EXTRA INFO: none
;------------------

	promotion equ [byte bp - 2]
proc MakeMove 
	push bp
	mov bp, sp
	sub sp, 2
	push si
	push di
	push bx
	push ax
	push [from]
	push [to]
	
; Special moves
	mov promotion, 0

	cmp [to], 64
	je @@promotionA
	
	cmp [to], 66
	je @@castleTopLeft
	
	cmp [to], 67
	je @@castleTopRight
	
	cmp [to], 68
	je @@castleBottomLeft
	
	cmp [to], 69
	je @@castleBottomRight1
	
	jmp @@normalMove

@@promotionA:
	jmp @@promotion
	
@@castleBottomRight1:
	jmp @@castleBottomRight
	
@@castleTopLeft:
	mov [from], 0
	mov [to], 2
	call MakeMove
	dec [rook1Move]
	
	mov [from], 3
	mov [to], 1
	call MakeMove
	dec [whiteKingMoved]
	
	
	jmp @@ret
	
@@castleTopRight:
	mov [from], 7
	mov [to], 4
	call MakeMove
	dec [rook2Move]
	
	mov [from], 3
	mov [to], 5
	call MakeMove
	dec [whiteKingMoved]
	
	jmp @@ret
	
@@castleBottomLeft:
	mov [from], 56
	mov [to], 58
	call MakeMove
	dec [rook3Move]
	
	
	mov [from], 59
	mov [to], 57
	call MakeMove
	dec [blackKingMoved]
	
	jmp @@ret
	
@@castleBottomRight:
	mov [from], 63
	mov [to], 60
	call MakeMove
	dec [rook4Move]

	mov [from], 59
	mov [to], 61
	call MakeMove
	dec [blackKingMoved]
	
	jmp @@ret
	
@@promotion:
	mov promotion, 1
	mov bx, [from]
	cmp bx, 47
	ja @@blackPromotion
	sub bx, 8
	mov [to], bx
	jmp @@normalMove
	
@@blackPromotion:
	add bx, 8
	mov [to], bx
	
@@normalMove:
	mov si, [from]
	shl si, 1
	mov bx, [word board + si]
	
	mov di, [to]
	shl di, 1
	mov ax, [word board + di]
	mov [pieceSave], ax
	mov [word board + di], bx
	mov [word board + si], 0
	
; Rook Moves
	
	cmp [byte board + di + 1], "R"
	je @@UPDRookMove
	
; King Move

	cmp [byte board + di + 1], "K"
	je @@UPDKingMove
	
	cmp promotion, 1
	je @@Promote
	
	jmp @@ret

@@UPDKingMove:
	cmp [byte board + di], "B"
	je @@blackKing
	inc [whiteKingMoved]
	jmp @@ret
	
@@blackKing:
	inc [blackKingMoved]
	jmp @@ret

@@UPDRookMove:
	shr si, 1
	shr di, 1
	
	cmp si, [rook1LastPos]
	je @@rook1
	
	cmp si, [rook2LastPos]
	je @@rook2
	
	cmp si, [rook3LastPos]
	je @@rook3
	
	cmp si, [rook4LastPos]
	je @@rook4
	
@@rook1:
	mov [rook1LastPos], di
	inc [rook1Move]

	jmp @@ret
	
@@rook2:
	mov [rook2LastPos], di
	inc [rook2Move]
	
	jmp @@ret
	
@@rook3:
	mov [rook3LastPos], di
	inc [rook3Move]

	jmp @@ret
	
@@rook4:
	mov [rook4LastPos], di
	inc [rook4Move]
	
	jmp @@ret

@@Promote:
	mov [byte board + di + 1], "Q"
	mov [to], 64
@@ret:
	pop [to]
	pop [from]
	pop ax
	pop bx
	pop di
	pop si
	add sp, 2
	pop bp
	ret 
endp MakeMove


;------------------
;INPUT: None
;OUTPUT: None
;PURPOSE: Undos the last move, used for evaluations etc.
;EXTRA INFO: Cant rewind more than one move
;------------------
	promotion equ [byte bp - 2]
proc UndoMove
	push bp
	mov bp, sp
	sub sp, 2
	push bx
	push ax
	push si
	push [from]
	push [to]
	

; Special moves
	mov promotion, 0
	
	cmp [to], 64
	je @@promotionA
	
	cmp [to], 66
	je @@castleTopLeft
	
	cmp [to], 67
	je @@castleTopRight
	
	cmp [to], 68
	je @@castleBottomLeft
	
	cmp [to], 69
	je @@castleBottomRight1
	
	jmp @@normalMove
	
@@castleBottomRight1:
	jmp @@castleBottomRight
	
@@promotionA:
	jmp @@promotion
	
@@castleTopLeft:
	push [pieceSave]
	mov [from], 2
	mov [to], 0
	call MakeMove
	dec [rook1Move]
	
	dec [whiteKingMoved]
	mov [from], 1
	mov [to], 3
	call MakeMove
	pop [pieceSave]
	
	jmp @@ret
	
@@castleTopRight:
	push [pieceSave]
	mov [from], 4
	mov [to], 7
	call MakeMove
	dec [rook2Move]
	
	dec [whiteKingMoved]
	mov [from], 5
	mov [to], 3
	call MakeMove
	pop [pieceSave]
	
	jmp @@ret
	
@@castleBottomLeft:
	push [pieceSave]
	mov [from], 58
	mov [to], 56
	call MakeMove
	dec [rook3Move]
	
	dec [blackKingMoved] 
	mov [from], 57
	mov [to], 59
	call MakeMove
	pop [pieceSave]

	jmp @@ret
	
@@castleBottomRight:
	push [pieceSave]
	mov [from], 60
	mov [to], 63
	call MakeMove
	dec [rook4Move]

	dec [blackKingMoved]
	mov [from], 61
	mov [to], 59
	call MakeMove
	pop [pieceSave]

	
	jmp @@ret

@@promotion:
	;call ShowAxDecimal
	mov promotion, 1
	mov bx, [from]
	cmp bx, 47
	ja @@blackPromotion
	sub bx, 8
	mov [to], bx
	jmp @@normalMove
	
@@blackPromotion:
	add bx, 8
	mov [to], bx

@@normalMove:
	mov bx, [to]
	shl bx, 1
	mov bx, [word board + bx]
	
	mov si, [from]
	shl si, 1
	mov [word board + si], bx
	
	mov bx, [to]
	mov ax, [pieceSave]
	shl bx, 1
	mov [word board + bx], ax
	
	cmp promotion, 1
	je @@Unpromote
	
;RookMoves
	cmp [byte board + si + 1], "R"
	je @@undoRookMove
	
;KingMove
	cmp [byte board + si + 1], "K"
	je @@undoKingMove
	
	jmp @@ret
	
@@undoKingMove:
	cmp [byte board + si], "W"
	je @@whiteMoved
	dec [blackKingMoved]
	jmp @@ret
	
@@whiteMoved:
	dec [whiteKingMoved]
	jmp @@ret
	
@@undoRookMove:
	shr bx, 1
	shr si, 1
	
	cmp bx, [rook1LastPos]
	je @@rook1
	
	cmp bx, [rook2LastPos]
	je @@rook2
	
	cmp bx, [rook3LastPos]
	je @@rook3
	
	cmp bx, [rook4LastPos]
	je @@rook4
	
@@rook1:
	dec [rook1Move]
	mov [rook1LastPos], si
	jmp @@ret
	
@@rook2:
	dec [rook2Move]
	mov [rook2LastPos], si
	jmp @@ret
	
@@rook3:
	dec [rook3Move]
	mov [rook3LastPos], si
	jmp @@ret
	
@@rook4:
	dec [rook4Move]
	mov [rook4LastPos], si
	jmp @@ret
	
@@Unpromote:
	mov [byte board + si + 1], "P"
	
@@ret:
	pop [to]
	pop [from]
	pop si
	pop ax
	pop bx
	add sp, 2
	pop bp
	ret
endp UndoMove


;------------------
;INPUT: square - which square u wanna extract the moves from
;		color - what color the piece is
;OUTPUT: uses the MACRO "ADD_MOVE" in order to save the legal moves
;PURPOSE: the first phase of extracting the legal moves, gets the legal move depending on the piece and its location.
;EXTRA INFO: allows certain illegal moves - move while in check
;------------------
	square equ [byte bp + 4]
	color equ [byte bp + 6]
	endPoint equ [byte bp - 2]
	oppColor equ [word bp - 4]
	Option1Bool equ [byte bp - 6]
	Option2Bool equ [byte bp - 7]
	Option3Bool equ [byte bp - 8]
	Option4Bool equ [byte bp - 9]
	QueenBool equ [byte bp - 10]
	PawnBool equ [byte bp - 11]
proc ExtractLegalMovesSquare
	push bp
	mov bp, sp
	sub sp, 12
	
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	
;Set Dead Ends
	mov cx, 4
	
@@True:
	mov bx, 4
	sub bx, cx
	sub bx, 9
	add bp, bx
	mov [byte bp], 1
	sub bp, bx
	loop @@True

;Set Bools
	mov QueenBool, 0
	mov PawnBool, 1
	
;SetColor
	cmp color, 1
	je @@black
	mov dx, 'W'
	mov oppColor, 'B'
	jmp @@Continue
	
@@black:
	mov dx, 'B'
	mov oppColor, 'W'

;
@@Continue:
	mov bl, square
	xor bh, bh	
	mov di, bx
	shl bx, 1
	
	cmp [byte board + bx], dl
	jne @@retNotValid
	
	cmp [byte board + bx + 1], 0
	je @@retNotValid
	
	cmp [byte board + bx + 1], 'P'
	je @@pawn
	
	cmp [byte board + bx + 1], 'N'
	je @@knight1
	
	cmp [byte board + bx + 1], 'B'
	je @@bishop1
	jmp @@nextPiece3
	
@@retNotValid:
	jmp @@ret
	
@@bishop1:
	jmp @@bishop

@@nextPiece3:
	cmp [byte board + bx + 1], 'R'
	je @@rook1
	jmp @@nextPiece2
	
@@rook1:
	jmp @@rook

@@nextPiece2:
	cmp [byte board + bx + 1], 'Q'
	jne @@nextPiece
	mov QueenBool, 1
	jmp @@rook
	
@@nextPiece:
	cmp [byte board + bx + 1], 'K'
	je @@king1
	jmp @@ret3
	
@@king1:
	jmp @@king

@@ret3:
	jmp @@ret

@@knight1:
	jmp @@knight

;START PAWN

@@pawn:
	cmp [byte board + bx], 'W'
	je @@WhitePawns1
	shr bx, 1
	jmp @@BlackPawns

@@WhitePawns1:
	shr bx, 1
	jmp @@WhitePawns

@@BlackPawns:
	mov dx, oppColor

	sub bx, 8
	shl bx, 1
	cmp [board + bx], 0
	jne @@SetNoOp4
	shr bx, 1
	mov endPoint, bl
	add bx, 8
	cmp endPoint, 63
	ja @@BPawnOption2
	
	cmp endPoint, 7
	jbe @@PromoteBlack
	jmp @@addMoveBlack
	
@@PromoteBlack:
	mov endPoint, 64
	
@@addMoveBlack:
	ADD_MOVE
	jmp @@BPawnOption2

@@SetNoOp4:
	mov PawnBool, 0
	
@@BPawnOption2:
	mov bx, di
	sub bx, 7
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@BPawnOption3
	shr bx, 1
	
	mov endPoint, bl
	mov al, square
	cmp endPoint, 63
	ja @@BPawnOption3
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@BPawnOption3
	ADD_MOVE
	
@@BPawnOption3:
	mov bx, di
	sub bx, 9
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@BPawnOption4
	shr bx, 1
	mov endPoint, bl
	mov al, square
	cmp endPoint, 63
	ja @@BPawnOption4
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@BPawnOption4
	ADD_MOVE

@@BPawnOption4:
	cmp PawnBool, 0
	je @@ret2
	
	mov bx, di
	cmp bx, 48
	jae @@SecondCheck
	jmp @@ret2
	
@@SecondCheck:
	cmp bx, 55
	jbe @@CheckIfValid
	jmp @@ret2

@@CheckIfValid:
	sub bx, 16
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@ret2
	shr bx, 1
	mov endPoint, bl
	add bx, 16
	cmp endPoint, 63
	ja @@ret2
	ADD_MOVE
	jmp @@ret2

@@ret2:
	jmp @@ret1

@@WhitePawns:
	mov dx, 'B'
	
	add bx, 8
	shl bx, 1
	cmp [board + bx], 0
	jne @@SetNoOp4W
	shr bx, 1
	mov endPoint, bl
	sub bx, 8
	cmp endPoint, 63
	ja @@WPawnOption2
	
	cmp endPoint, 56
	jae @@PromoteWhite
	jmp @@addMoveWhite
	
@@PromoteWhite:
	mov endPoint, 64
	
@@addMoveWhite:
	ADD_MOVE
	jmp @@WPawnOption2
	
@@SetNoOp4W:
	mov PawnBool, 0
	
@@WPawnOption2:
	mov bx, di

	add bx, 7
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@WPawnOption3
	shr bx, 1
	mov endPoint, bl
	mov al, square
	cmp endPoint, 63
	ja @@WPawnOption3
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@WPawnOption3
	ADD_MOVE
	
@@WPawnOption3:
	mov bx, di

	add bx, 9
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@WPawnOption4
	shr bx, 1
	mov endPoint, bl
	mov al, square
	cmp endPoint, 63
	ja @@WPawnOption4
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@WPawnOption4
	ADD_MOVE

@@WPawnOption4:
	cmp PawnBool, 0
	je @@ret1
	
	mov bx, di
	cmp bx, 8
	jae @@SecondCheckW
	jmp @@ret1
	
@@SecondCheckW:
	cmp bx, 17
	jbe @@CheckIfValidW
	jmp @@ret1
	
@@ret1:
	jmp @@ret

@@CheckIfValidW:
	add bx, 16
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@ret1
	shr bx, 1
	mov endPoint, bl
	sub bx, 16
	cmp endPoint, 63
	ja @@ret1
	ADD_MOVE
	jmp @@ret1

;END PAWN



;START KNIGHT

@@knight:
	mov bx, di
	shl bx, 1
	cmp [byte board + bx + 34], dl
	je @@knightOption2
	shr bx, 1
	add bx, 17
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption2
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption2
	
	ADD_MOVE
	
@@knightOption2:
	mov bx, di
	shl bx, 1
	cmp [byte board + bx + 30], dl
	je @@knightOption3
	shr bx, 1
	add bx, 15
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption3
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption3
	
	ADD_MOVE
	
@@knightOption3:
	mov bx, di
	shl bx, 1
	cmp [byte board + bx + 20], dl
	je @@knightOption4
	shr bx, 1
	add bx, 10
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption4
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption4
	
	ADD_MOVE
	
@@knightOption4:
	mov bx, di
	shl bx, 1
	cmp [byte board + bx + 12], dl
	je @@knightOption5
	shr bx, 1
	add bx, 6
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption5
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption5
	
	ADD_MOVE
	
@@knightOption5:
	mov bx, di
	shl bx, 1
	sub bx, 34
	cmp [byte board + bx], dl
	je @@knightOption6
	shr bx, 1
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption6
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption6
	
	ADD_MOVE
	
@@knightOption6:
	mov bx, di
	shl bx, 1
	sub bx, 30
	cmp [byte board + bx], dl
	je @@knightOption7
	shr bx, 1
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption7
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption7
	
	ADD_MOVE
	
@@knightOption7:
	mov bx, di
	shl bx, 1
	sub bx, 20
	cmp [byte board + bx], dl
	je @@knightOption8
	shr bx, 1
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@knightOption8
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption8
	
	ADD_MOVE
	
@@knightOption8:
	mov bx, di
	shl bx, 1
	sub bx, 12
	cmp [byte board + bx], dl
	je @@retKnight
	shr bx, 1
	mov endPoint, bl
	
	cmp endPoint, 63
	ja @@retKnight
	mov al, square
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@retKnight
	
	ADD_MOVE
	
	jmp @@ret
;END KNIGHT
@@retKnight:
	jmp @@retRook

;START ROOK && QUEEN
@@rook:	
	mov cx, 7
	
@@Check4Directions:
	
@@rookOption1:
	cmp Option1Bool, 0
	je @@9
	mov bx, 8
	sub bx , cx
	shl bx, 3
	add bx, di
	
	cmp bx, 63
	ja @@DeadEnd1
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece1
	shr bx, 1

	mov endPoint, bl
	ADD_MOVE
	jmp @@rookOption2
	
@@9:
	jmp @@rookOption2

@@middleR01:
	loop @@Check4Directions
	jmp @@CheckQueen
	
@@OppColorPiece1:
	shr bx, 1
	cmp bl, square
	je @@rookOption2
	shl bx, 1
	
	cmp [byte board + bx], dl
	je @@DeadEnd1
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE
	jmp @@DeadEnd1

@@middleR12:
	jmp @@middleR01

@@DeadEnd1:
	mov Option1Bool, 0

@@rookOption2:
	cmp Option2Bool, 0
	je @@3
	mov bx, 8
	sub bx , cx
	mov al, 8
	mul bl
	mov bx, di
	sub bx, ax
	
	cmp bx, 63
	ja @@DeadEnd2
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece2
	shr bx, 1

	mov endPoint, bl
	ADD_MOVE
	jmp @@rookOption3
	
@@3:
	jmp @@rookOption3
	
@@OppColorPiece2:
	shr bx, 1
	cmp bl, square
	je @@rookOption3
	shl bx, 1
	
	cmp [byte board + bx], dl
	je @@DeadEnd2
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

	
@@DeadEnd2:
	mov Option2Bool, 0
	jmp @@rookOption3
	
@@middleR23:
	jmp @@middleR12



@@rookOption3:
	cmp Option3Bool, 0
	je @@4
	mov bx, 8
	sub bx , cx
	add bx, di
	
	cmp bx, 63
	ja @@4
	
	mov al, bl
	dec al
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 1
	ja @@DeadEnd3
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece3
	shr bx, 1

	mov endPoint, bl
	ADD_MOVE
	jmp @@rookOption4
	
@@4:
	jmp @@rookOption4

@@OppColorPiece3:
	shr bx, 1
	cmp bl, square
	je @@rookOption4
	shl bx, 1
	
	cmp [byte board + bx], dl
	je @@DeadEnd3
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

	
@@DeadEnd3:
	mov Option3Bool, 0

@@rookOption4:
	cmp Option4Bool, 0
	je @@5
	mov bx, -8
	add bx , cx
	add bx, di
	
	cmp bx, 63
	ja @@5
	
	mov al, bl
	inc al
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 1
	ja @@DeadEnd4
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece4
	shr bx, 1
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@NextRoundRook
@@5:
	jmp @@DeadEnd4
	
@@OppColorPiece4:
	shr bx, 1
	cmp bl, square
	je @@NextRoundRook
	shl bx, 1
	
	cmp [byte board + bx], dl
	je @@DeadEnd4
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

	
@@DeadEnd4:
	mov Option4Bool, 0

@@NextRoundRook:
	jmp @@middleR23

;END ROOK

@@CheckQueen:
	cmp QueenBool, 0
	je @@retRook
	jmp @@queen

@@retRook:
	jmp @@retBishop
	
@@queen:
;Set Dead Ends
	mov cx, 4
	
@@True2:
	mov bx, 4
	sub bx, cx
	sub bx, 9
	add bp, bx
	mov [byte bp], 1
	sub bp, bx
	loop @@True2
	
;START BISHOP
@@bishop:
	mov cx, 7
	
@@Check4Diagonals:	
	
	
@@bishopOption1:
	cmp Option1Bool, 0
	je @@2
	
	mov bx, 8
	sub bx, cx
	mov al, 9
	mul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@2
	
	mov al, bl
	sub al, 9
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd1b
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece1b
	shr bx, 1
	jmp @@1

@@middleB01:
	loop @@Check4Diagonals
	jmp @@ret

@@1:
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@bishopOption2
@@2:
	jmp @@DeadEnd1b
	
@@OppColorPiece1b:
	shr bx, 1
	cmp bl, square
	je @@bishopOption2
	shl bx, 1

	cmp [byte board + bx], dl
	je @@DeadEnd1b
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE


@@DeadEnd1b:
	mov Option1Bool, 0
	jmp @@bishopOption2
	
@@middleB12:
	jmp @@middleB01
	
@@bishopOption2:
	cmp Option2Bool, 0
	je @@6
	
	mov bx, 8
	sub bx, cx
	mov al, 7
	mul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@6
	
	mov al, bl
	sub al, 7
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd2b
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece2b
	shr bx, 1
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@bishopOption3

@@6:
	jmp @@DeadEnd2b

@@OppColorPiece2b:
	shr bx, 1
	cmp bl, square
	je @@bishopOption3
	shl bx, 1

	cmp [byte board + bx], dl
	je @@DeadEnd2b
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

@@DeadEnd2b:
	mov Option2Bool, 0
	jmp @@bishopOption3

@@middleB23:
	jmp @@middleB12
	
@@bishopOption3:
	cmp Option3Bool, 0
	je @@7
	
	mov bx, 8
	sub bx, cx
	mov al, -9
	imul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@7
	
	mov al, bl
	add al, 9
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd3b
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece3b
	shr bx, 1
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@bishopOption4
	
@@7:
	jmp @@DeadEnd3b
	
@@OppColorPiece3b:	
	shr bx, 1
	cmp bl, square
	je @@bishopOption4
	shl bx, 1

	cmp [byte board + bx], dl
	je @@DeadEnd3b
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

@@DeadEnd3b:
	mov Option3Bool, 0
	
@@bishopOption4:
	cmp Option4Bool, 0
	je @@8
	
	mov bx, 8
	sub bx, cx
	mov al, -7
	imul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@8
	
	mov al, bl
	add al, 7
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd4b
	
	shl bx, 1
	cmp [byte board + bx], 0
	jne @@OppColorPiece4b
	shr bx, 1
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@BishopNextRound
	
@@8:
	jmp @@DeadEnd4b
	
@@OppColorPiece4b:
	shr bx, 1
	cmp bl, square
	je @@BishopNextRound
	shl bx, 1

	cmp [byte board + bx], dl
	je @@DeadEnd4b
	shr bx, 1
	mov endPoint, bl
	ADD_MOVE

@@DeadEnd4b:
	mov Option4Bool, 0
	
@@BishopNextRound:
	jmp @@middleB23
	
;END BISHOP && QUEEN
@@retBishop:
	jmp @@ret
	
;START KING
@@king:
	mov cx, 3
	mov bx, di
	sub bx, 9

@@KingLoopVert:
	push cx
	push bx
	mov cx, 3
	
@@KingLoopHor:
	cmp bx, 63
	ja @@NextRoundKingHor
	
	shl bx, 1
	cmp [byte board + bx], dl 
	je @@CheckIfSquare
	jmp @@nextKing
	
@@CheckIfSquare:
	cmp [byte board + bx + 1], 'K'
	je @@KingOnKing
	shr bx, 1
	jmp @@NextRoundKingHor
	
@@nextKing:
	shr bx, 1

	mov al, square
	xor ah, ah
	push bx
	push ax
	call Distance2Square
	cmp ax, 2
	ja @@NextRoundKingHor
	
	mov endPoint, bl
	ADD_MOVE
	jmp @@NextRoundKingHor

@@KingOnKing:
	shr bx, 1

@@NextRoundKingHor:
	add bx, 1
	loop @@KingLoopHor

@@NextRoundKingVert:
	pop bx
	add bx, 8
	pop cx
	loop @@KingLoopVert

	mov al, color
	xor ah, ah
	push ax
	call CheckForCastle
	cmp ax, 0
	je @@retA
	
	cmp ax, 1
	je @@option1
	
	cmp ax, 2
	je @@option2
	
	cmp ax, 3
	je @@both1
	
@@option1:
	cmp color, 0
	je @@topLeftRook
	
	mov endPoint, 68
	ADD_MOVE
	jmp @@ret
	
@@both1:
	jmp @@both

@@retA:
	jmp @@ret
	
@@topLeftRook:
	mov endPoint, 66
	ADD_MOVE
	jmp @@ret
	
@@option2:
	cmp color, 0
	je @@topRightRook
	
	mov endPoint, 69
	ADD_MOVE
	jmp @@ret
	
@@topRightRook:
	mov endPoint, 67
	ADD_MOVE
	jmp @@ret
	
@@both:
	cmp color, 0
	je @@whiteCastle
	
	mov endPoint, 69
	ADD_MOVE
	
	mov endPoint, 68
	ADD_MOVE
	jmp @@ret
	
@@whiteCastle:
	mov endPoint, 67
	ADD_MOVE
	
	mov endPoint, 66
	ADD_MOVE
	jmp @@ret

;END KING
@@ret:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	add sp, 12
	pop bp
	ret 4
	
endp ExtractLegalMovesSquare

;------------------
;INPUT: the color of the king you want to check if checked
;OUTPUT: ZF - zf = 1 => checked
;PURPOSE: Find if a certain position is in a state of check, used for filtering illegal moves
;EXTRA INFO: none
;------------------
	color equ [byte bp + 4]
	check equ [byte bp - 2]
	oppColor equ [byte bp - 4]
	Option1Bool equ [byte bp - 6]
	Option2Bool equ [byte bp - 7]
	Option3Bool equ [byte bp - 8]
	Option4Bool equ [byte bp - 9]
proc CheckForCheck
	push bp
	mov bp, sp
	sub sp, 10
	
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	
	mov cx, 4
	
@@True:
	mov bx, 4
	sub bx, cx
	sub bx, 9
	add bp, bx
	mov [byte bp], 1
	sub bp, bx
	loop @@True
	
@@setColor:
	cmp color, 1
	je @@black
	mov dx, 'B'
	mov oppColor, 'W'
	jmp @@Continue
	
@@black:
	mov dx, 'W'
	mov oppColor, 'B'

@@Continue:
	mov cx, 64

;FIND KING START
	mov al, oppColor
	
@@FindKing:
	mov bx, 64
	sub bx, cx
	shl bx, 1
	cmp [byte board + bx], al
	je @@KingCheck
	
@@NextRoundFindKing:
	loop @@FindKing
	jmp @@retNoCheck

@@KingCheck:
	cmp [byte board + bx + 1], 'K'
	je @@KingFound
	jmp @@NextRoundFindKing

@@KingFound:
	shr bx, 1
	mov di, bx
	
;FIND KING END

;KING THREAT START
	mov cx, 3
	mov bx, di
	sub bx, 9

@@KingLoopVert:
	push cx
	push bx
	mov cx, 3
	
@@KingLoopHor:
	cmp bx, 63
	ja @@NextRoundKingHor1
	
	mov ax, di
	push bx
	push ax
	call Distance2Square
	cmp ax, 2
	ja @@NextRoundKingHor1
	shl bx, 1
	cmp [byte board + bx], dl 
	je @@CheckIfKing
	jmp @@NextRoundKingHor
	
@@CheckIfKing:
	cmp [byte board + bx + 1], 'K'
	je @@CheckFound
	jmp @@NextRoundKingHor

@@SetZf:
	jmp @@retCheck

@@CheckFound:	
	mov check, 1

@@NextRoundKingHor:
	shr bx, 1
@@NextRoundKingHor1:
	add bx, 1
	loop @@KingLoopHor

@@NextRoundKingVert:
	pop bx
	add bx, 8
	pop cx
	cmp check, 1
	je @@SetZf
	loop @@KingLoopVert
	
;KING THREAT END

;KNIGHT THREAT START
@@knight:
	mov bx, di
	add bx, 17
	cmp bl, 63
	ja @@knightOption2
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption2
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption2
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck6
	
@@knightOption2:
	mov bx, di
	add bx, 15
	cmp bl, 63
	ja @@knightOption3
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption3
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption3
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck6
	jmp @@knightOption3
	
@@retCheck6:
	jmp @@retCheck
	
@@knightOption3:
	mov bx, di
	add bx, 10
	cmp bl, 63
	ja @@knightOption4
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption4
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption4
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1
	
@@knightOption4:
	mov bx, di
	add bx, 6
	cmp bl, 63
	ja @@knightOption5
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption5
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption5
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1
	
@@knightOption5:
	mov bx, di
	sub bx, 6
	cmp bl, 63
	ja @@knightOption6
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption6
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption6
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1
	jmp @@knightOption6
	
@@retCheck1:
	jmp @@retCheck
	
@@knightOption6:
	mov bx, di
	sub bx, 10
	cmp bl, 63
	ja @@knightOption7
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption7
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption7
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1
	
@@knightOption7:
	mov bx, di
	sub bx, 15
	cmp bl, 63
	ja @@knightOption8
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@knightOption8
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@knightOption8
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1
	
@@knightOption8:
	mov bx, di
	sub bx, 17
	cmp bl, 63
	ja @@rook
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 3
	ja @@rook
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@rook
	
	cmp [byte board + bx + 1], 'N'
	je @@retCheck1

;KNIGHT THREAT END

;ROOK THREAT START
@@rook:
	mov cx, 7
	
@@Check4Directions:
	
@@rookOption1:
	cmp Option1Bool, 0
	je @@9
	mov bx, 8
	sub bx , cx
	shl bx, 3
	add bx, di
	
	cmp bx, 63
	ja @@DeadEnd1
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece1
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd1

	jmp @@rookOption2
	
@@9:
	jmp @@rookOption2

@@middleR01:
	loop @@Check4Directions
	jmp @@bishop
@@retNoCheck1:
	jmp @@retNoCheck
	
@@OppColorPiece1:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck2
	cmp [byte board + bx + 1], 'R'
	je @@retCheck2
	
	jmp @@DeadEnd1

@@middleR12:
	jmp @@middleR01
@@retCheck2:
	jmp @@retCheck


@@DeadEnd1:
	mov Option1Bool, 0

@@rookOption2:
	cmp Option2Bool, 0
	je @@3
	mov bx, 8
	sub bx , cx
	mov al, 8
	mul bl
	mov bx, di
	sub bx, ax
	
	cmp bx, 63
	ja @@DeadEnd2
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece2
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd2
	shr bx, 1

	
	
@@3:
	jmp @@rookOption3
	
@@OppColorPiece2:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck2
	cmp [byte board + bx + 1], 'R'
	je @@retCheck2
	
@@DeadEnd2:
	mov Option2Bool, 0
	jmp @@rookOption3
	
@@middleR23:
	jmp @@middleR12



@@rookOption3:
	cmp Option3Bool, 0
	je @@4
	mov bx, 8
	sub bx , cx
	add bx, di
	
	cmp bx, 63
	ja @@4
	mov al, bl
	dec al
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 1
	ja @@DeadEnd3
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece3
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd3
	shr bx, 1
	
	

	jmp @@rookOption4
	
@@4:
	jmp @@rookOption4

@@OppColorPiece3:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck4
	cmp [byte board + bx + 1], 'R'
	je @@retCheck4
	
@@DeadEnd3:
	mov Option3Bool, 0

@@rookOption4:
	cmp Option4Bool, 0
	je @@5
	mov bx, -8
	add bx , cx
	add bx, di
	
	cmp bx, 63
	ja @@5
	mov al, bl
	inc al
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 1
	ja @@DeadEnd4
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece4
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd4
	shr bx, 1

	jmp @@NextRoundRook
@@5:
	jmp @@DeadEnd4
	
@@retCheck4:
	jmp @@retCheck
	
@@OppColorPiece4:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck4
	cmp [byte board + bx + 1], 'R'
	je @@retCheck4
	
@@DeadEnd4:
	mov Option4Bool, 0

@@NextRoundRook:
	jmp @@middleR23

;ROOK THREAT END

;BISHOP THREAT START
@@bishop:
	mov cx, 4
	
@@True2:
	mov bx, 4
	sub bx, cx
	sub bx, 9
	add bp, bx
	mov [byte bp], 1
	sub bp, bx
	loop @@True2

	mov cx, 7
	
@@Check4Diagonals:		
	
@@bishopOption1:
	cmp Option1Bool, 0
	je @@2
	
	mov bx, 8
	sub bx, cx
	mov al, 9
	mul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@2
	
	mov al, bl
	sub al, 9
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd1b
	
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece1b
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd1b
	shr bx, 1
	jmp @@bishopOption2

@@middleB01:
	loop @@Check4Diagonals
	jmp @@pawn

@@2:
	jmp @@DeadEnd1b
	
@@OppColorPiece1b:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck3
	cmp [byte board + bx + 1], 'B'
	je @@retCheck3


@@DeadEnd1b:
	mov Option1Bool, 0
	jmp @@bishopOption2
	
@@middleB12:
	jmp @@middleB01
	
@@bishopOption2:
	cmp Option2Bool, 0
	je @@6
	
	mov bx, 8
	sub bx, cx
	mov al, 7
	mul bl
	mov bx, ax
	add bx, di
	
	
	cmp bx, 63
	ja @@6
	mov al, bl
	sub al, 7
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd2b
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece2b
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd2b
	shr bx, 1

	jmp @@bishopOption3

@@6:
	jmp @@DeadEnd2b
@@retCheck3:
	jmp @@retCheck

@@OppColorPiece2b:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck3
	cmp [byte board + bx + 1], 'B'
	je @@retCheck3

@@DeadEnd2b:
	mov Option2Bool, 0
	jmp @@bishopOption3

@@middleB23:
	jmp @@middleB12
	
@@bishopOption3:
	cmp Option3Bool, 0
	je @@7
	
	mov bx, 8
	sub bx, cx
	mov al, -9
	imul bl
	mov bx, ax
	add bx, di
	
	
	
	cmp bx, 63
	ja @@7
	mov al, bl
	add al, 9
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd3b
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece3b
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd3b
	shr bx, 1

	jmp @@bishopOption4
	
@@7:
	jmp @@DeadEnd3b
	
@@OppColorPiece3b:	
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck3
	cmp [byte board + bx + 1], 'B'
	je @@retCheck3
	
@@DeadEnd3b:
	mov Option3Bool, 0
	
@@bishopOption4:
	cmp Option4Bool, 0
	je @@8
	
	mov bx, 8
	sub bx, cx
	mov al, -7
	imul bl
	mov bx, ax
	add bx, di
	
	cmp bx, 63
	ja @@8
	
	mov al, bl
	add al, 7
	xor ah, ah
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@DeadEnd4b
	
	shl bx, 1
	cmp [byte board + bx], dl
	je @@OppColorPiece4b
	mov al, oppColor
	cmp [byte board + bx], al
	je @@DeadEnd4b
	shr bx, 1

	jmp @@BishopNextRound
	
@@8:
	jmp @@DeadEnd4b

@@retCheck5:
	jmp @@retCheck
	
@@OppColorPiece4b:
	cmp [byte board + bx + 1], 'Q'
	je @@retCheck5
	cmp [byte board + bx + 1], 'B'
	je @@retCheck5

@@DeadEnd4b:
	mov Option4Bool, 0
	
@@BishopNextRound:
	jmp @@middleB23
;BISHOP THREAT END 

;PAWN THREAT START
@@pawn:
	mov bx, di
	cmp dl, 'W'
	je @@WhitePawns1
	jmp @@BlackPawns

@@WhitePawns1:
	jmp @@WhitePawns

@@BlackPawns:

@@BPawnOption2:
	mov bx, di
	add bx, 7
	cmp bx, 63
	ja @@BPawnOption3
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@BPawnOption3
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@BPawnOption3
	
	cmp [byte board + bx + 1], 'P'
	je @@retCheck
	
@@BPawnOption3:
	mov bx, di
	add bx, 9
	cmp bx, 63
	ja @@retNoCheck
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@retNoCheck
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@retNoCheck
	
	cmp [byte board + bx + 1], 'P'
	je @@retCheck

@@WhitePawns:

@@WPawnOption2:
	mov bx, di

	sub bx, 7
	cmp bx, 63
	ja @@WPawnOption3
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@WPawnOption3
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@WPawnOption3
	
	cmp [byte board + bx + 1], 'P'
	je @@retCheck

	
@@WPawnOption3:
	mov bx, di

	sub bx, 9
	cmp bx, 63
	ja @@retNoCheck
	
	mov ax, di
	push ax
	push bx
	call Distance2Square
	cmp ax, 2
	ja @@retNoCheck
	
	shl bx, 1
	cmp [byte board + bx], dl
	jne @@retNoCheck
	
	cmp [byte board + bx + 1], 'P'
	je @@retCheck

	jmp @@retNoCheck

;PAWN THREAT END

@@retCheck:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	add sp, 10
	pop bp	
	
	push ax
	sub ax, ax
	pop ax
	ret 2

@@retNoCheck:	
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	add sp, 10
	pop bp
	
	push ax
	mov ax, 1
	add ax, ax
	pop ax
	
	ret 2
endp CheckForCheck

;------------------
;INPUT: 2 squares (numbers)
;OUTPUT: ax - whats the distance between them in squares e.g 1 and 9 return 2
;PURPOSE: filtering illegal moves
;EXTRA INFO: none
;------------------
proc PutMatrixOnScreen2
	push cx
	push di
	push dx
	
	mov ax, 0a000h
	mov es, ax
	
	cld ;sets direction of movsb to copy forward
    mov si,[matrix] ; puts offset of the Matrix to si (Source)
	
NextRow:	; loop of cx lines according to matrix height (num of Lines)
	push cx ;saves cx of loop
	mov cx, dx ;sets cx for movsb according to matrix length
	rep movsb ; Copy whole line to the screen, si and di increases
	sub di,dx ; returns back to the beginning of the line 
	add di, 320 ;go down one line in “screen” by adding 320
	pop cx  ;restores cx of loop
	loop NextRow

@@ret:
	pop dx
	pop di
	pop cx
	ret
endp PutMatrixOnScreen2
proc ClearScreen

	mov cx, 320
@@setLine:
	mov bx, 320
	sub bx, cx
	mov [Line + bx], 0
	loop @@setLine
	
	xor di, di
	
	mov cx, 200
	
@@Clear:	
	push cx
	mov [matrix], offset Line
	mov cx, 1
	mov dx, 320
	add di, 320
	call PutMatrixOnScreen2
	pop cx
	loop @@Clear

	ret
endp ClearScreen
	startSquare equ [byte bp + 4]
	endSquare equ [byte bp + 6]
proc Distance2Square
	push bp
	mov bp, sp
	
	push bx
	push cx
	push dx
	
	xor ah, ah
	mov al, startSquare
	mov bl, 8
	div bl
	
	mov dl, al ; y1
	mov dh, ah ; x1
	
	xor ah, ah
	mov al, endSquare
	mov bl, 8
	div bl
	
	mov cl, al ; y2
	mov ch, ah ; x2
	
	cmp cl, dl
	ja @@y1
	sub dl, cl
	mov al, dl
	jmp @@xCheck
	
@@y1: 
	sub cl, dl
	mov al, cl
	
@@xCheck:
	cmp ch, dh
	ja @@x1
	sub dh, ch
	mov ah, dh
	jmp @@ret

@@x1:	
	sub ch, dh
	mov ah, ch

@@ret:
	add al, ah
	xor ah, ah
	pop dx
	pop cx
	pop bx
	pop bp
	ret 4
endp Distance2Square

	num1 equ [word bp + 4]
	num2 equ [word bp + 6]
proc Min
	push bp
	mov bp, sp
	
	mov ax, num1
	
	cmp ax, num2
	jl @@ret
	mov ax, num2
	
@@ret:
	pop bp
	ret 4
endp Min

	num3 equ [word bp + 4]
	num4 equ [word bp + 6]
proc Max

	push bp
	mov bp, sp
	
	mov ax, num3
	
	cmp ax, num4
	jg @@ret
	mov ax, num4
	
@@ret:
	pop bp
	ret 4
endp Max
END start


