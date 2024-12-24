import os
import subprocess
from time import sleep

filedata = r"""
[cpu]
cycles = max
[sdl]
fullresolution=640x400
windowresolution=640x400
output=openglpp
[autoexec]
mount C C:\8086\ParaParaPara_x86
C:
tasm /m2 *.asm
link Menu.obj main.obj Ball2.obj Ball.obj Bricks.obj Bricks2.obj Paddle.obj Paddle2.obj Multi.obj send.obj ;
"""

filedata += "\nMenu.exe"

filedata1 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM1
    """
)

filedata2 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM2
    """
)

with open("dosbox-x-generated1.conf", "w") as file:
    file.write(filedata1)

with open("dosbox-x-generated2.conf", "w") as file:
    file.write(filedata2)

prog1 = ["C:\8086\DOSBox-COM1\DOSBox.exe", "-conf", "dosbox-x-generated1.conf"]
prog2 = ["C:\8086\DOSBox-COM1\DOSBox.exe", "-conf", "dosbox-x-generated2.conf"]

subprocess.Popen(prog1)
sleep(2)
subprocess.Popen(prog2)