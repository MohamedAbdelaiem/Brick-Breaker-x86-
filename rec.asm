.MODEL small
.STACK 100h
.data
value db ?, "$"
messsage DB 'reciever on , press esc to end session', 0AH, 0DH, "$"
messsage2 DB 'Enter your string', 0AH, 0DH, "$"
messsage3 DB 'good by then', 0AH, 0DH, "$"


InDATA db 30,?,30 dup('$') 
emptystr db 10,13,'$'
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


    ;Check that Data Ready from UART
    CHK:    mov dx , 3FDH		; Line Status Register
    	    in al , dx 
            AND al , 1
            JZ CHKINCHAR     ; if there is not char in uart go check for key pressed

    ;If Ready read the VALUE in Receive data register
            mov dx , 03F8H
            in al , dx 
            mov VALUE , al

            mov ah, 09 
            mov dx, offset value
            int 21h

    CHKINCHAR:
            mov ah,01h     ; check if key is pressed
            mov al,0
            Int 16h
            cmp al,0h
            jz CHK        ; if no key is pressed go check for uart again


            mov ah,0h     ;read the char to see if it is esc
            Int 16h
            cmp al,1Bh
            jz exit

            mov ah, 09 
            mov dx, offset messsage2
            int 21h

            mov ah,0AH   ; read the string      
            mov dx,offset InDATA                  
            int 21h 

            mov ah, 9         ;display the string
            mov dx, offset InDATA+2
            int 21h  
            mov ah, 9         ;get to the next line
            mov dx, offset emptystr
            int 21h 

       
                    
                

exit:

    mov ah, 4ch
    int 21h 

Main endp
end