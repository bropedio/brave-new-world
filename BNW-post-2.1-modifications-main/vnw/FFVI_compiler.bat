@echo off
rem ----------------------------------------------------------------------------
set ORIGINAL_ROM="bnw.sfc"
set EDITED_ROM="vnw.sfc"

rem ----------------------------------------------------------------------------
set ASAR="asar.exe"

rem ----------------------------------------------------------------------------
copy %ORIGINAL_ROM% %EDITED_ROM% /y
rem ----------------------------------------------------------------------------

echo.
echo Applying hacks...
%ASAR% --pause-mode=on-error scripts.asm %EDITED_ROM%
%ASAR% --pause-mode=on-error names.asm %EDITED_ROM%
%ASAR% --pause-mode=on-error descriptions.asm %EDITED_ROM%
%ASAR% --pause-mode=on-error locations.asm %EDITED_ROM%
