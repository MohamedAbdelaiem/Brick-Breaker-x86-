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
    time_aux        DB 0
	ball_x          DW 160
	ball_y          DW 100
	ball_size       DW 5
	ball_velocity_x DW 02h
	ball_velocity_y DW 02h
    WINDOW_WIDTH    DW 320
	WINDOW_HEIGHT   DW 200
	WINDOW_BORDER   DW 5
