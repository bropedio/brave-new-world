@echo off
rem ----------------------------------------------------------------------------
set ORIGINAL_ROM="rom\bnw2.2.sfc"
set EDITED_ROM="bnw2.2.sfc"
set PATCHES="other"

rem ----------------------------------------------------------------------------
set ASAR="tools\asar.exe"
set FFVIDECOMP="tools\ffvi.exe"
set GFX="gfx"
set flips="tools\flips"

rem ----------------------------------------------------------------------------
copy %ORIGINAL_ROM% %EDITED_ROM% /y
rem ----------------------------------------------------------------------------

echo.
echo Applying hacks...
%ASAR% --pause-mode=on-error %PATCHES%\main.asm %EDITED_ROM%

rem echo Applying ips...
rem %flips% --apply "minimap[n].ips" %EDITED_ROM%
