.model small
.stack 100h
.data

X_Ruler_Start dw 130
X_Ruler_End dw 190
Y_Ruler_Start dw 185
Y_Ruler_End dw 190

X_Start dw 0
X_End dw 0
Y_Start dw 0
Y_End dw 0

X_Range dw 0
Y_Range dw 0

color db 0fh

.code

SET_VIDEO_MODE MACRO
    mov ah, 0
    mov al, 13h
    int 10h
ENDM

DrawPixel MACRO x, y, color
    mov ah, 0ch
    mov al, color
    mov cx, x
    mov dx, y
    int 10h
ENDM

DRAW_HORIZONTAL_LINE PROC

push ax
push cx
push dx
push bx

mov dx, X_Start
Horizontal_Line_Loop:

    push dx
    DrawPixel dx, Y_Start, color
    pop dx
    INC dx
    CMP dx, X_End
    JNE Horizontal_Line_Loop

pop bx
pop dx
pop cx
pop ax

ret

DRAW_HORIZONTAL_LINE ENDP

DRAW_VERTICAL_LINE PROC
    push ax
    push cx
    push dx
    push bx
    mov dx, Y_Start
    Vertical_Line_Loop:
        push dx
        DrawPixel X_Start, dx, color
        pop dx
        INC dx
        CMP dx, Y_End
        JNE Vertical_Line_Loop
    pop bx
    pop dx
    pop cx
    pop ax
    ret
DRAW_VERTICAL_LINE ENDP

DRAW_BRICK PROC
    
    push cx
    mov cx, X_End
    brick_loop:
        CALL DRAW_VERTICAL_LINE
        INC X_Start
        CMP X_Start, cx
        JNE brick_loop
    pop cx

    ret

DRAW_BRICK ENDP

DRAW_BRICK_ROW PROC
    
    mov X_Start, 20
    mov X_End, 60
    CALL DRAW_BRICK

    mov X_Start, 80
    mov X_End, 120
    CALL DRAW_BRICK

    mov X_Start, 140
    mov X_End, 180
    CALL DRAW_BRICK

    mov X_Start, 200
    mov X_End, 240
    CALL DRAW_BRICK

    mov X_Start, 260
    mov X_End, 300
    CALL DRAW_BRICK

    ret
DRAW_BRICK_ROW ENDP

INIT_BRICKS PROC
    mov Y_Start, 30
    mov Y_End, 40
    mov color, 0bh
    CALL DRAW_BRICK_ROW
    
    mov Y_Start, 50
    mov Y_End, 60
    mov color, 0eh
    CALL DRAW_BRICK_ROW

    mov Y_Start, 70
    mov Y_End, 80
    mov color, 0ch
    CALL DRAW_BRICK_ROW

    ret
INIT_BRICKS ENDP


DRAW_RULER PROC
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax
    
    mov Y_Start, 185
    mov Y_End, 190

    CALL DRAW_BRICK
    ret
DRAW_RULER ENDP
;description
MOVE_RULER_RIHGT PROC
    MOV color, 0
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax
    CALL DRAW_RULER

    mov color, 0dh
    CMP X_Ruler_End, 320
    JE RIGHT_RULER_EXIT

    ADD X_Ruler_Start, 20
    ADD X_Ruler_End, 20
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax

    CALL DRAW_RULER

    RIGHT_RULER_EXIT:
    ret
MOVE_RULER_RIHGT ENDP


; Draw Game Frame
DRAW_FRAME PROC
    mov color, 6
    mov X_Start, 5
    mov X_End, 312
    mov Y_Start, 5
    mov Y_End, 7
    CALL DRAW_BRICK

    mov X_Start, 5
    mov X_End, 7
    mov Y_Start, 5
    mov Y_End, 200
    CALL DRAW_BRICK

    mov X_Start, 310
    mov X_End, 312
    mov Y_Start, 5
    mov Y_End, 200
    CALL DRAW_BRICK
    ret
DRAW_FRAME ENDP
INIT_GAME PROC
    SET_VIDEO_MODE
    CALL INIT_BRICKS
    mov color, 0dh
    CALL DRAW_RULER
    CALL DRAW_FRAME
    ret
INIT_GAME ENDP


MAIN PROC
    mov ax, @data
    mov ds, ax

    mov ah, 0

    CALL INIT_GAME

    ; mov ax, 0FFFFh
    int 16h
    CMP ah, 4Dh
    JE MOVE_RIGHT
    jnz MAIN_EXIT

    MOVE_RIGHT:
        CALL MOVE_RULER_RIHGT

    JMP MAIN_EXIT

    MAIN_EXIT:

    mov ah,4ch
    int 21h

MAIN ENDP
END MAIN