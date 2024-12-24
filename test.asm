extrn MAIN:FAR
extrn CHAT_MAIN:FAR
extrn MULTI_MAIN:FAR


.model large
.stack 100h
.data

SinglePlayer DB "Single Player (enter)$"
MultiPlayer DB "Multi Player (m)$"
Chat db "Chat (c)$"
Exit db "Exit (esc)$"
TryAgain db "Try Again (t)$"

.code

SetCursor MACRO x, y
    PUSH ax
    PUSH dx
    

    mov ah,2
    mov dl, x
    mov dh, y
    int 10h

    POP dx
    POP ax
ENDM

CLEAR_SCREEN Proc NEAR
	; Open graphical mode 13h (320x200, 256 colors)
    push ax
    push bx
	    mov  al, 13h
	    mov  ah, 0
	    int  10h

	    MOV  AH,0bh
	    mov  bx,00
	    int  10h

    mov al, 03h
    mov ah, 0
    int 10h

    pop bx
    pop AX

    ret
CLEAR_SCREEN endp

ab3z PROC
    mov ax, @data
    mov ds, ax


    CALL CLEAR_SCREEN

        SetCursor 13, 5

        mov ah, 9
        LEA dx, SinglePlayer
        int 21h

        SetCursor 13, 7

        mov ah, 9
        LEA dx, MultiPlayer
        int 21h

        SetCursor 13, 9

        mov ah, 9
        LEA dx, Chat
        int 21h

        SetCursor 13, 11

        mov ah, 9
        LEA dx, Exit
        int 21h

        SetCursor 13, 13

        mov ah, 9
        LEA dx, TryAgain
        int 21h

    DashLoop:
        mov ah, 0
        int 16h

        CMP al, 0Dh ;Enter
        JE BEGIN_GAME

        CMP al, 63h ;Esc
        JE BEGIN_CHAT

        cmp al, 'm'
        JE BEGIN_MULTI

        CMP al, 1Bh ;Esc
        JE DashExit

        JMP DashLoop

    BEGIN_GAME:
        CALL MAIN

    JMP DashLoop

    BEGIN_CHAT:
        CALL CHAT_MAIN

    JMP DashLoop

    BEGIN_MULTI:
        CALL MULTI_MAIN

    JMP DashLoop

    DashExit:

    mov ah,4ch
    int 21h

ab3z ENDP
END ab3z