@echo off

echo about to run frs
echo.

cd systems
cd frs
quarto render
cd ..
cd ..  

echo frs completed
echo.

pause