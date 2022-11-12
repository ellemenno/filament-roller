@echo off
setlocal enabledelayedexpansion

echo rendering STL part files..

set p[0]=empty
set p[1]=roller
set p[2]=arm
set p[3]=washer
set p[4]=spacer
set p[5]=nut
set p[6]=test

for /L %%i in (1,1,6) do call :render %%i %%p[%%i]%%
goto :eof


:render
echo:
echo part: %2
@echo on
openscad.com ^
-D "$fn=128" ^
-D "mode=\"print\"" ^
-D "part=%1" ^
-o stl\%2.stl ^
--export-format "binstl" ^
filament-roller.scad
@echo off
goto :eof
