@echo off
rem ----------------------------------------------------------------------------
set ROM="rom\bnw.sfc"
rem ----------------------------------------------------------------------------
set GFX="gfx"
rem ----------------------------------------------------------------------------
set DD="tools\dd.exe"
set FFVIDECOMP="tools\ffvi.exe"

rem ----------------------------------------------------------------------------

rem ----------------------------------------------------------------------------
if not exist "%GFX%" mkdir %GFX%
if not exist "%GFX%\de-compressed" mkdir "%GFX%\de-compressed"
if not exist "%GFX%\modified" mkdir ""%GFX%\modified"
if not exist "%GFX%\extracted" mkdir "%GFX%\extracted"
rem ----------------------------------------------------------------------------

rem ----------------------------------------------------------------------------
echo Extracting Uncompressed Graphics...
%DD% skip=57632 count=512 if=%ROM% of=%GFX%\extracted\00E120_battle_data.bin bs=1 2>NUL
%DD% skip=294848 count=9472 if=%ROM% of=%GFX%\extracted\047FC0_menu_font.bin bs=1 2>NUL
%DD% skip=2223552 count=1024 if=%ROM% of=%GFX%\extracted\21EDC0_INN.bin bs=1 2>NUL
%DD% skip=2712320 count=1536 if=%ROM% of=%GFX%\extracted\296300_The_End.bin bs=1 2>NUL

rem ----------------------------------------------------------------------------
echo Extracting Compressed Graphics...
%FFVIDECOMP% -m d -s 0x02686C %ROM% > %GFX%\de-compressed\02686C_Title_Program.bin
%FFVIDECOMP% -m d -s 0x04BA00 %ROM% > %GFX%\de-compressed\04BA00_End_Font_GFX.bin
%FFVIDECOMP% -m d -s 0x12E000 %ROM% > %GFX%\de-compressed\12E000_Battle_GFX.bin
%FFVIDECOMP% -m d -s 0x18F000 %ROM% > %GFX%\de-compressed\18F000_Title_GFX.bin
%FFVIDECOMP% -m d -s 0x19568f %ROM% > %GFX%\de-compressed\19568f_Ending_Cinematic_GFX_1.bin
%FFVIDECOMP% -m d -s 0x199d4b %ROM% > %GFX%\de-compressed\199d4b_Ending_Cinematic_GFX_2.bin
%FFVIDECOMP% -m d -s 0x19a4e5 %ROM% > %GFX%\de-compressed\19a4e5_Ending_Cinematic_GFX_3.bin
%FFVIDECOMP% -m d -s 0x19a800 %ROM% > %GFX%\de-compressed\19a800_Map_Tile_Properties.bin
%FFVIDECOMP% -m d -s 0x19cd10 %ROM% > %GFX%\de-compressed\19cd10_Map_Tile_Properties_Pointers.bin