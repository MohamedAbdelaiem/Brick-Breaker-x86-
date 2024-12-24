extrn tryagainDashboard:FAR
public MAIN

.model large
.stack 100h
.data

X_Ruler_Start dw 130
X_Ruler_End dw 190
Y_Ruler_Start dw 185
Y_Ruler_End dw 190

X_Start_Bricks dw 20, 80, 140, 200, 260
X_End_Bricks dw 60, 120, 180, 240, 300

; X_START_EACH_BRICK dw 20, 80, 140, 200, 260, 20, 80, 140, 200, 260, 20, 80, 140, 200, 260
; X_END_EACH_BRICK dw 60, 120, 180, 240, 300, 60, 120, 180, 240, 300, 60, 120, 180, 240, 300

; Y_START_EACH_BRICK dw 30, 30, 30, 30, 30, 50, 50, 50, 50, 50, 70, 70, 70, 70, 70
; Y_END_EACH_BRICK DW 40, 40, 40, 40, 40, 60, 60, 60, 60, 60, 80, 80, 80, 80, 80

MARK_DESTROYED_BRICKS DB "000000000000000"

y_number dw 0
x_number dw 0

Y_Start_Bricks dw 30, 50, 70
Y_End_Bricks dw   40, 60, 80

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

x dw 0
y dw 0
DESTROYED_BRICKS DW 0

    time_aux        DB 0
	ball_x          DW 160
	ball_y          DW 170
	ball_size       DW 5
	ball_velocity_x DW 01h
	ball_velocity_y DW 01h
    WINDOW_WIDTH    DW 320
	WINDOW_HEIGHT   DW 200
	WINDOW_BORDER   DW 5

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
    push si
    PUSH BX
        MOV BX, y_number
        mov ax, bx
        mov bx, 5
        MUL bx
        ADD AX, x_number

        LEA SI, MARK_DESTROYED_BRICKS
        ADD SI,AX
        mov bx, 0
        CMP BYTE PTR [SI], '0'

        JZ destroy_this
        JNZ EXIT_DESTROY

    destroy_this:
        mov color, 0
        mov ax, X_Start_Destroyed_Brick
        mov X_Start, ax
        mov ax, X_End_Destroyed_Brick
        mov X_End, ax

        mov ax, Y_Start_Destroyed_Brick
        mov Y_Start, ax
        mov ax, Y_End_Destroyed_Brick
        mov Y_End, ax

        MOV BYTE PTR [SI], '1'

        NEG ball_velocity_y

        INC DESTROYED_BRICKS

        CALL DRAW_BRICK
        CMP DESTROYED_BRICKS, 15
        JNE EXIT_DESTROY
        ;MOV AH,4ch
        ;INT 21h
        call tryagainDashboard

    EXIT_DESTROY:   

    POP BX    
    POP SI    
    POP ax
    ret
Draw_DestroyBrick ENDP

GET_BRICK_Y PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX
    PUSH AX

    mov y_number, 0


        ; get X_Start and X_End
        LEA SI, Y_Start_Bricks
        LEA DI, Y_End_Bricks    


        mov ax, y
        mov cx, 3
        Find_Y:
            CMP ax, [SI]
            JGE Check_Y_End
            JL GET_BRICK_Y_Destroy_Exit

        Check_Y_End:
            CMP ax, [DI]
            JLE GET_BRICK_Y_Answer
            ADD SI, 2
            ADD DI, 2
            inc y_number
            LOOP Find_Y
        
        JMP GET_BRICK_Y_Destroy_Exit

        GET_BRICK_Y_Answer:
            mov ax, [SI]
            ; mov [si],0
            mov Y_Start_Destroyed_Brick, ax
            mov bx, [DI]
            ; mov [di],0
            mov Y_End_Destroyed_Brick, bx
            CALL Draw_DestroyBrick

    GET_BRICK_Y_Destroy_Exit:
    POP ax
    POP BX
    POP CX
    POP DI
    POP SI
    
    mov y_number, 0

    ret
GET_BRICK_Y ENDP

;description
GET_BRICK_X_Y PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX
    PUSH AX

    mov x_number, 0

    ; get X_Start and X_End
    LEA SI, X_Start_Bricks
    LEA DI, X_End_Bricks

    mov ax, x
    mov cx, 5
    Find_X:
        CMP ax, [SI]
        JGE Check_X_End
        JL GET_BRICK_X_Answer_Destroy_Exit

    Check_X_End:
        CMP ax, [DI]
        JLE GET_BRICK_X_Answer
        ADD SI, 2
        ADD DI, 2
        inc x_number
        LOOP Find_X

    JMP GET_BRICK_X_Answer_Destroy_Exit
    
    GET_BRICK_X_Answer:
        mov ax, [SI]
        ; mov [si],0
        mov X_Start_Destroyed_Brick, ax
        mov bx, [DI]
        ; mov [di],0
        mov X_End_Destroyed_Brick, bx
        CALL GET_BRICK_Y


    GET_BRICK_X_Answer_Destroy_Exit:

    POP AX
    POP BX
    POP CX
    POP SI
    POP DI
    mov x_number, 0
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
    push ax

        mov ax ,WINDOW_WIDTH
        sub ax , WINDOW_BORDER
        CMP X_Ruler_End, ax
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

    pop ax
    ret
MOVE_RULER_RIHGT ENDP






MOVE_RULER_LEFT PROC
    push ax

        mov ax , WINDOW_BORDER
        CMP X_Ruler_Start, ax
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
    pop ax
    ret
MOVE_RULER_LEFT ENDP


; Draw Game Frame
DRAW_FRAME PROC
    push ax
        ; upper frame
        mov color, 6
        mov X_Start, 0
        mov ax,WINDOW_WIDTH
        mov X_End, ax
        mov Y_Start, 0
        mov ax,WINDOW_BORDER
        mov Y_End, ax
        CALL DRAW_BRICK

        ; left frame
        mov X_Start, 0
        mov ax,WINDOW_BORDER
        mov X_End, ax
        mov Y_Start, 5
        mov ax , WINDOW_HEIGHT
        mov Y_End, ax
        CALL DRAW_BRICK

        ; right frame
        mov ax , WINDOW_WIDTH
        mov X_End,ax
        sub ax ,WINDOW_BORDER
        mov X_Start, ax
        mov Y_Start, 0
        mov ax,WINDOW_HEIGHT
        mov Y_End, ax
        CALL DRAW_BRICK

    pop ax
    ret
DRAW_FRAME ENDP

Draw_Ball PROC
    push ax
    push bx
    push cx
    push dx
	
	                     mov  cx, ball_x          	; X coordinate
	                     mov  dx, ball_y          	; Y coordinate
	
	
	Draw_Ball_Horziontal:
	                     mov  ah, 0Ch             	; Function to plot pixel
	                     mov  al, 0Ah             	; White color (0Fh)
	                     mov  bh, 0               	; Page number 0
	                     int  10h
	                     inc  cx
	                     mov  ax,cx
	                     sub  ax,ball_x
	                     cmp  ax,ball_size
	                     JNG  Draw_Ball_Horziontal
	                     mov  cx,ball_x
	                     inc  dx
	                     mov  ax,dx
	                     sub  ax,ball_y
	                     cmp  ax,ball_size
	                     JNG  Draw_Ball_Horziontal
	pop dx
    pop cx
    pop bx
    pop ax
	                     ret
Draw_Ball endp

MOVE_BALL PROC 
    PUSH ax
	                     mov  ax,ball_velocity_x
	                     add  ball_x,ax

                         MOV AX,ball_x
                         ADD AX,ball_size
                         MOV X,AX
                         MOV AX,ball_y
                         ADD AX,ball_size
                         MOV Y,AX

                         CALL Destroy_Brick

                         MOV AX,ball_x
                         MOV X,AX
                         MOV AX,ball_y
                         MOV Y,AX

                         CALL Destroy_Brick

                        ;  CMP DESTROYED_BRICKS, 15
                        ;  JGE CLOSE_BALL


                         MOV AX,ball_y
                         ADD AX,ball_size
                         CMP AX,WINDOW_HEIGHT
                         JGE  CLOSE_BALL
                         CMP AX,Y_Ruler_Start
                         JGE CHECK_x_START_Ruler
                         
                         
	                     
	                cmp_border:     
                         MOV  ax,WINDOW_BORDER
	                     CMP  ball_x,ax
	                     JLE   NEG_X
	                     
	                     MOV  ax,WINDOW_WIDTH
	                     SUB  ax,WINDOW_BORDER
	                     CMP  ball_x,ax
	                     JGE   NEG_X

	                     mov  ax,ball_velocity_y
	                     add  ball_y,ax
	                     
	                     MOV  ax,WINDOW_BORDER
	                     CMP  ball_y,ax
	                     JLE   NEG_Y
	                     
	                     MOV  ax,WINDOW_HEIGHT
	                     SUB  ax,WINDOW_BORDER
	                     CMP  ball_y,ax
	                     JGE   NEG_Y
    pop ax
	                     ret

	NEG_X:               
	                     NEG  ball_velocity_x
                         pop ax
	                     ret
	NEG_Y:               
	                     NEG  ball_velocity_y
                         pop ax
	                     ret
    CHECK_x_START_Ruler:
                       MOV AX,ball_x
                       CMP AX,X_Ruler_Start
                       JGE CHECK_x_end_Ruler
                       JMP cmp_border
    CHECK_x_end_Ruler:
                       MOV AX,ball_x
                       CMP AX,X_Ruler_End
                       JLE NEG_X_Y 
                       JMP cmp_border 

    NEG_X_Y:
                ; NEG ball_velocity_x
                NEG ball_velocity_y
                ; Move the ball slightly away from the ruler's edge
                MOV AX, ball_velocity_x
                ADD ball_x, AX
                MOV AX, ball_velocity_y
                ADD ball_y, AX
                pop ax
                ret
    CLOSE_BALL:
               ; mov ah,4ch
                ;int 21h
                call tryagainDashboard
                pop ax
                ret                                             
MOVE_BALL endp

DELETE_BALL PROC 
    push ax
    push bx
    push cx
    push dx
	
	                     mov  cx, ball_x          	; X coordinate
	                     mov  dx, ball_y          	; Y coordinate
	
	
	Draw_Ball_HorziontalFORDELETE:
	                     mov  ah, 0Ch             	; Function to plot pixel
	                     mov  al, 0             	; White color (0Fh)
	                     mov  bh, 0               	; Page number 0
	                     int  10h
	                     inc  cx
	                     mov  ax,cx
	                     sub  ax,ball_x
	                     cmp  ax,ball_size
	                     JNG  Draw_Ball_HorziontalFORDELETE
	                     mov  cx,ball_x
	                     inc  dx
	                     mov  ax,dx
	                     sub  ax,ball_y
	                     cmp  ax,ball_size
	                     JNG  Draw_Ball_HorziontalFORDELETE
	pop dx
    pop cx
    pop bx
    pop ax
ret
DELETE_BALL endp



Main_Ball_loop PROC 
    push ax
    push bx
    push cx
    push dx

        CALL DELETE_BALL
        CALL MOVE_BALL
        CALL Draw_Ball
        CALL DRAW_FRAME
        mov color, 0dh
        CALL DRAW_RULER

    pop dx
    pop cx
    pop bx
    pop ax
ret
Main_Ball_loop ENDP


INIT_GAME PROC
    SET_VIDEO_MODE
     ;NEG ball_velocity_x
    CALL INIT_BRICKS
    mov color, 0dh
    CALL DRAW_RULER
    CALL DRAW_FRAME
    CALL MOVE_BALL
	call Draw_Ball
    ret
INIT_GAME ENDP

CLEAR_SCREEN PROC NEAR
	; Open graphical mode 13h (320x200, 256 colors)
    push ax
    push bx
	                     mov  al, 13h
	                     mov  ah, 0
	                     int  10h

	                     MOV  AH,0bh
	                     mov  bx,00
	                     int  10h
    pop bx
    pop AX
	                     ret
CLEAR_SCREEN endp



MAIN PROC
    mov ax, @data
    mov ds, ax

    mov ah, 0
    CALL INIT_GAME


    ; mov ax, 0FFFFh
    ; int 16h
    ; CMP ah, 4Dh
    ; JE MOVE_RIGHT

    ; mov x, 20
    ; mov y, 35

    ; CALL Destroy_Brick
    
    ; mov ah,1

    startLoop:
        mov ah, 00h        ; Get key press
        int 16h

        ; Check if the key pressed is Spacebar (ASCII code 0x20)
        cmp al, 20h        ; Compare with 0x20 (Spacebar), use al for ASCII value
        je Rulerloop       ; Jump to Rulerloop if Spacebar is pressed

skipKeyPressStartLOOP:
        jmp startLoop      ; If no key pressed, continue checking for key presses


    


    Rulerloop:
        
        CALL Main_Ball_loop
        mov ah, 01h        ; Check if a key is available
        int 16h
        jz SkipKeyPress    ; If no key pressed, skip key handling

        mov ah, 00h        ; Get key press
        int 16h
        cmp ah, 4Bh        ; Check if left arrow key
        je MOVE_LEFT
        cmp ah, 4Dh        ; Check if right arrow key
        je MOVE_RIGHT

        SkipKeyPress:
            jmp Rulerloop

        MOVE_RIGHT:
            CALL MOVE_RULER_RIHGT
            mov ah,1
            jmp Rulerloop

        MOVE_LEFT:
        CALL MOVE_RULER_LEFT
        mov ah,1
        jmp Rulerloop
     

    JMP MAIN_EXIT

    MAIN_EXIT:

    ;mov ah,4ch
    ;int 21h
    call tryagainDashboard

MAIN ENDP
END MAIN