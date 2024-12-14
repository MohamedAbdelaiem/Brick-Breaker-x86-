ClearUpperScreen MACRO
    mov ax,060Dh
    mov bh,09h
    mov cx,0       
    mov dh, 12
    mov dl, 79
    int 10h 
    
ENDM ClearUpperScreen

ClearLowerScreen MACRO
    mov ax,060Ch
    mov bh,30h
    mov ch,13
    mov cl, 0       
    mov dh,24
    mov dl, 79
    int 10h 
    
ENDM ClearLowerScreen


SaveCursorS MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov XposS, DL
    mov YposS, DH
ENDM SaveCursorS

SaveCursorR MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov XposR, DL
    mov YposR, DH
ENDM SaveCursorR

SetCursor MACRO x, y
    mov ah, 2
    mov bh, 0
    mov dl, x
    mov dh, y
    int 10h
ENDM SetCursor


.MODEL small
.STACK 100h
.data
VALUE DB ?
XposS DB 0
YposS DB 0
XposR DB 0
YposR DB 0Dh

.code

Main proc
    mov ax, @data
    mov ds, ax

   

    ; initinalize COM
    ;Set Divisor Latch Access Bit
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f8h			
    mov al,0ch			
    out dx,al

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f9h
    mov al,00h
    out dx,al

    ;Set port configuration
    mov dx,3fbh
    mov al,00011011b
    out dx,al


     CLEARSCREEN:   

        ; Make sure it is Text-Mode

      ClearUpperScreen
      ClearLowerScreen
      SetCursor 0, 0

    call detect

    detect proc

    START:

    ;Check that Transmitter Holding Register is Empty
        mov ah,01h     ; check if key is pressed
        Int 16h
        jz dummy2        ; if no key is pressed go check for uart again
        jnz send

    send:
        mov ah,0h     ;read the char to see if it is esc
        Int 16h

        mov VALUE, AL
        cmp al, 0Dh
        jz ENTERKEY
        jnz CONT

        dummy2:jmp recieve

    ENTERKEY:
        cmp YposS, 11
        jz OverFlow
        jnz INCREMENT
        
        OverFlow:
        ClearUpperScreen
        mov XposS, 0
        mov YposS, 0
        SetCursor XposS, YposS
        jmp PRINT

        INCREMENT:
        inc YposS
        MOV XposS, 0

        CONT:
        SetCursor XposS, YposS
        cmp XposS, 79
        jz CHECKY
        jnz PRINT

        CHECKY:
        cmp YposS, 11
        jnz PRINT
        ClearUpperScreen
        mov XposS, 0
        mov YposS, 0
        SetCursor XposS, YposS

    PRINT:
        mov ah, 2
        mov dl, VALUE
        int 21h


    SENDSTATUS:
        mov dx , 3FDH		; Line Status Register
    AGAIN:  
        In al , dx 			;Read Line Status
        AND al , 00100000b
        JZ recieve


        ;If empty put the VALUE in Transmit data register
        mov dx , 3F8H		; Transmit data register
        mov al, VALUE
        out dx , al 

    ESCAPEKEY:
        cmp al, 1Bh
        JZ dummy
        SaveCursorS
        jmp START

    dummy: jmp exit
    dummy3: jmp send

    recieve:
    mov ah, 1
    int 16h
    jnz dummy3

        ;Check that Data Ready from UART
    READSTATUS:
        mov dx , 3FDH		; Line Status Register
        in al , dx 
        AND al , 1
        JZ recieve     ; if there is not char in uart go check for key pressed

    READ:
        mov dx , 03F8H
        in al , dx 
        mov VALUE , al
        cmp VALUE, 1Bh
        jz dummy

        cmp VALUE, 0Dh
        jnz contR
        jz newlineR

        newlineR:
        cmp yposR, 24
        jz XR
        jnz YR

        XR:
        ClearLowerScreen
        mov XposR, 0
        mov YposR, 12
        SetCursor XposR, YposR
        jmp PRINTR


        YR:
        inc YposR
        mov XposR, 0

        contR:
        SetCursor XposR, YposR
        cmp XposR, 79
        jz CHECKYR
        jnz PRINTR

        CHECKYR:
        cmp YposR, 24
        jnz PRINTR
        ClearLowerScreen
        mov XposR, 0
        mov YposR, 12
        SetCursor XposR, yposR

        PRINTR:
        mov ah, 2
        mov dl, VALUE
        int 21h

        SaveCursorR

        jmp START
   
   detect endp

exit:
    mov ah, 4ch
    int 21h 

Main endp
end

