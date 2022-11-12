@echo off

echo "rendering assembly image.."

openscad.com ^
-D "$fn=128" ^
-D "mode=\"assembly\"" ^
--autocenter ^
--viewall ^
--colorscheme="Tomorrow Night" ^
--imgsize="800,800" ^
-o assembly.png ^
filament-roller.scad
