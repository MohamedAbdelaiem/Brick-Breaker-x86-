.model large
.stack 100h
.data

X_Ruler_Start dw 130
X_Ruler_End dw 190
Y_Ruler_Start dw 185
Y_Ruler_End dw 190

X_Start_Bricks dw 20, 80, 140, 200, 260
X_End_Bricks dw 60, 120, 180, 240, 300

Y_Start_Bricks dw 30, 50, 70
Y_End_Bricks dw 40, 60, 80

X_Start dw 0
X_End dw 0
Y_Start dw 0
Y_End dw 0

X_Range dw 0
Y_Range dw 0

X_Start_Destroyed_Brick dw 0
X_End_Destroyed_Brick dw 0

Y_Start_Destroyed_Brick dw 0
Y_End_Destroyed_Brick dw 0

color_palette db 0bh, 0eh, 0ch
color db 0fh

x db 0
y db 0

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
    push SI
    push DI

    LEA SI, X_Start_Bricks
    LEA DI, X_End_Bricks

    push cx
    push ax
    mov cx, 5
    Draw_Row_Bricks:
        mov ax, [SI]
        mov X_Start, ax
        mov ax, [DI]
        mov X_End, ax
        CALL DRAW_BRICK
        ADD SI, 2
        ADD DI, 2
        Loop Draw_Row_Bricks
    pop ax
    pop cx

    POP DI
    POP SI

    ret
DRAW_BRICK_ROW ENDP

INIT_BRICKS PROC
    PUSH SI
    PUSH DI

    PUSH BX

    LEA SI, Y_Start_Bricks
    LEA DI, Y_End_Bricks
    LEA BX, color_palette

    push cx
    push ax

    mov cx, 3
    Draw_Col_Bricks:
        mov al, [BX]
        mov color, al
        mov ax, [SI]
        mov Y_Start, ax
        mov ax, [DI]
        mov Y_End, ax
        CALL DRAW_BRICK_ROW
        ADD SI, 2
        ADD DI, 2
        INC BX
        Loop Draw_Col_Bricks

    pop ax
    pop cx

    POP BX

    POP DI
    POP SI

    ; mov Y_Start, 30
    ; mov Y_End, 40
    ; mov color, 0bh
    ; CALL DRAW_BRICK_ROW
    
    ; mov Y_Start, 50
    ; mov Y_End, 60
    ; mov color, 0eh
    ; CALL DRAW_BRICK_ROW

    ; mov Y_Start, 70
    ; mov Y_End, 80
    ; mov color, 0ch
    ; CALL DRAW_BRICK_ROW

    ret
INIT_BRICKS ENDP


;description
Draw_DestroyBrick PROC
    PUSH ax
    mov color, 0
    mov ax, X_Start_Destroyed_Brick
    mov X_Start, ax
    mov ax, X_End_Destroyed_Brick
    mov X_End, ax

    mov ax, Y_Start_Destroyed_Brick
    mov Y_Start, ax
    mov ax, Y_End_Destroyed_Brick
    mov Y_End, ax

    CALL DRAW_BRICK

    POP ax
    ret
Draw_DestroyBrick ENDP

GET_BRICK_Y PROC
    PUSH SI
    PUSH DI

    PUSH CX

    ; get X_Start and X_End
    LEA SI, Y_Start_Bricks
    LEA DI, Y_End_Bricks

    mov ah, y
    mov cx, 3
    Find_Y:
        CMP ah, [SI]
        JGE Check_Y_End
        JL GET_BRICK_Y_Destroy_Exit

    Check_Y_End:
        CMP ah, [DI]
        JLE GET_BRICK_Y_Answer
        ADD SI, 2
        ADD DI, 2
        LOOP Find_Y
    
    JMP GET_BRICK_Y_Destroy_Exit

    GET_BRICK_Y_Answer:
        mov ax, [SI]
        mov Y_Start_Destroyed_Brick, ax
        mov bx, [DI]
        mov Y_End_Destroyed_Brick, bx
        CALL Draw_DestroyBrick

    GET_BRICK_Y_Destroy_Exit:

    POP CX

    POP SI
    POP DI

    ret
GET_BRICK_Y ENDP

;description
GET_BRICK_X_Y PROC
    PUSH SI
    PUSH DI

    PUSH CX

    ; get X_Start and X_End
    LEA SI, X_Start_Bricks
    LEA DI, X_End_Bricks

    mov ah, x
    mov cx, 5
    Find_X:
        CMP ah, [SI]
        JGE Check_X_End
        JL GET_BRICK_X_Answer_Destroy_Exit

    Check_X_End:
        CMP ah, [DI]
        JLE GET_BRICK_X_Answer
        ADD SI, 2
        ADD DI, 2
        LOOP Find_X

    JMP GET_BRICK_X_Answer_Destroy_Exit
    
    GET_BRICK_X_Answer:
        mov ax, [SI]
        mov X_Start_Destroyed_Brick, ax
        mov bx, [DI]
        mov X_End_Destroyed_Brick, bx
        CALL GET_BRICK_Y


    GET_BRICK_X_Answer_Destroy_Exit:

    POP CX

    POP SI
    POP DI

    ret
GET_BRICK_X_Y ENDP

;description
Destroy_Brick PROC
    CALL GET_BRICK_X_Y
    ret
Destroy_Brick ENDP

;description
DRAW_RULER PROC
    PUSH AX
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax
    
    mov Y_Start, 185
    mov Y_End, 190

    CALL DRAW_BRICK
    POP AX
    ret
DRAW_RULER ENDP
;description

MOVE_RULER_RIHGT PROC
    CMP X_Ruler_End, 315
    JGE RIGHT_RULER_EXIT

    MOV color, 0
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax
    CALL DRAW_RULER

    mov color, 0dh


    ADD X_Ruler_Start, 5
    ADD X_Ruler_End, 5
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax

    CALL DRAW_RULER

    RIGHT_RULER_EXIT:
    ret
MOVE_RULER_RIHGT ENDP






MOVE_RULER_LEFT PROC

    CMP X_Ruler_Start, 10
    JLE LEFT_RULER_EXIT

    MOV color, 0
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax
    CALL DRAW_RULER

    mov color, 0dh

    SUB X_Ruler_Start, 5
    SUB X_Ruler_End, 5
    mov ax, X_Ruler_Start
    mov X_Start, ax

    mov ax, X_Ruler_End
    mov X_End, ax

    CALL DRAW_RULER

    LEFT_RULER_EXIT:
    ret
MOVE_RULER_LEFT ENDP


; Draw Game Frame
DRAW_FRAME PROC
    ; upper frame
    mov color, 6
    mov X_Start, 5
    mov X_End, 315
    mov Y_Start, 5
    mov Y_End, 7
    CALL DRAW_BRICK

    ; left frame
    mov X_Start, 5
    mov X_End, 10
    mov Y_Start, 5
    mov Y_End, 200
    CALL DRAW_BRICK

    ; right frame

    mov X_Start, 315
    mov X_End, 320
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
    ; int 16h
    ; CMP ah, 4Dh
    ; JE MOVE_RIGHT

    mov x, 20
    mov y, 35

    CALL Destroy_Brick

    Rulerloop:
    int 16h
    CMP ah, 4Bh
    JE MOVE_LEFT
    CMP ah,4Dh
    JE MOVE_RIGHT

    jmp Rulerloop

    MOVE_RIGHT:
        CALL MOVE_RULER_RIHGT
        mov ah,0
        jmp Rulerloop

    MOVE_LEFT:
    CALL MOVE_RULER_LEFT
    mov ah,0
    jmp Rulerloop
     

    JMP MAIN_EXIT

    MAIN_EXIT:

    mov ah,4ch
    int 21h

MAIN ENDP
END MAIN