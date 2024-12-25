public tryagainDashboard
extrn MAINGAMEDASH:FAR
.model small
.stack 100h
.data
TryAgain db "Try Again (Enter)$"
exit db "Exit (Esc)$"

.code

SetCursor MACRO x, y
                           PUSH      ax
                           PUSH      dx
    

                           mov        ah,2
                           mov        dl, x
                           mov        dh, y
                           int        10h

                           POP        dx
                           POP        ax
ENDM

CLEAR_SCREEN Proc NEAR
    ; Open graphical mode 13h (320x200, 256 colors)
                 push      ax
                 push      bx
                 mov       al, 13h
                 mov       ah, 0
                 int       10h

                 MOV       AH,0bh
                 mov       bx,00
                 int       10h

                 mov       al, 03h
                 mov       ah, 0
                 int       10h

                 pop       bx
                 pop       AX

                 ret
CLEAR_SCREEN endp

tryagainDashboard PROC FAR
                 mov       ax, @data
                 mov       ds, ax


                 CALL      CLEAR_SCREEN

                 SetCursor 13, 5

                 mov       ah, 9
                 LEA       dx, TryAgain
                 int       21h          

                 SetCursor 13, 10

                 mov       ah, 9
                 LEA       dx, exit
                 int       21h     

    tDashLoop:    
                 mov       ah, 0
                 int       16h

                 CMP       al, 0Dh             ;Enter
                 JE        tBEGIN_GAME

                 CMP       al, 1BH             ;Esc
                 JE        tDashExit

    tBEGIN_GAME:
    CALL MAINGAMEDASH
    tDashExit:    

                 mov       ah,4ch
                 int       21h

tryagainDashboard ENDP
END tryagainDashboard