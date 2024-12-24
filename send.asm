.MODEL small
.STACK 100h
.data
messsage DB 'serial communication Send one byte', 0AH, 0DH, "$"
.code


Main proc
    mov ax, @data
    mov ds, ax
    mov ah, 09 
    mov dx, offset messsage
    int 21h

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

    ;Check that Transmitter Holding Register is Empty
            mov dx , 3FDH		; Line Status Register
    AGAIN:  
            In al , dx 			;Read Line Status
            AND al , 00100000b
            JZ AGAIN

    SEND_CHARS:
        mov dx , 3F8H		; Transmit data register
        mov ah, 0h        ; Get key press
        int 16h
        mov ah, 2
        mov dl, al
        int 21h
    ;If empty put the VALUE in Transmit data register
        ;     mov al,"A"
            out dx , al 
        JMP SEND_CHARS


exit:
    mov ah, 4ch
    int 21h 

Main endp
end
