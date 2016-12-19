@echo off
echo Generating the resource file...
windres -O res -o mc4.res -i mc4.rc
echo Done!
pause