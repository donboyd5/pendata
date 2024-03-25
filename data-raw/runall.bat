@echo off

echo run quarto projects in the pendata package
echo.

echo To force all data manipulations to be executed, edit EACH _quarto.yml file
echo to set the execute: freeze: value to false. This will
echo force execution of each qumd file, even if it hasn't changed. 
echo.
echo This step is required for the "standard" project that gets SOA tables
echo   data-raw/standard/_quarto.yml
echo to make the downloading step below work.
echo.

echo In addition, to force re-downloading (or initial downloading) of SOA
echo mortality tables and mortality improvement tables, change the line
echo below from:
echo.
echo    set DOWNLOAD=false
echo       to:
echo    set DOWNLOAD=true

set DOWNLOAD=false

echo.
echo After initial setup, change the execute: freeze: value to auto
echo and change the line above to set DOWNLOAD=false so that the
echo programs don't spend time doing unnecessary calculations.
echo.

echo about to run standard, for SOA and similar tables
echo.
cd standard
quarto render -P download:%DOWNLOAD%
cd ..
echo standard completed
echo.

cd systems
cd frs
echo about to run frs
echo.
quarto render
cd ..
echo frs completed

cd ..  

echo.
echo All quarto projects rendered successfully.

pause