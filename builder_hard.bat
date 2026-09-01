@echo off
setlocal

set MOD_NAME=zm_xoia
set GAME_FOLDER=C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops II
set OAT_BASE=C:\OAT
set MOD_BASE=%cd%
set WINRAR=C:\Program Files\WinRAR\WinRAR.exe
set MOD_DEST=%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%

"%OAT_BASE%\linker.exe" ^
-v ^
--load "%GAME_FOLDER%\zone\all\zm_transit.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_prison.ff" ^
--load "%GAME_FOLDER%\zone\all\so_zclassic_zm_prison.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_buried.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_tomb.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_highrise.ff" ^
--load "%GAME_FOLDER%\zone\all\so_zclassic_zm_transit.ff" ^
--load "%GAME_FOLDER%\zone\all\so_zsurvival_zm_transit.ff" ^
--load "%GAME_FOLDER%\zone\all\common_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\ui_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\ui_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_nuked.ff" ^
--load "%GAME_FOLDER%\zone\all\patch_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc4_load_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\code_post_gfx_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\code_post_gfx_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\code_pre_gfx_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\code_pre_gfx_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\common_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\common_patch_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc0_load_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc1_load_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc1_load_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc2_load_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc2_load_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc3_load_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc3_load_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\dlc4_load_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\dlczm0_load_zm.ff" ^
--load "%GAME_FOLDER%\zone\all\patch_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_transit_patch.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_prison_patch.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_buried_patch.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_tomb_patch.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_nuked_patch.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_highrise_patch.ff" ^
--base-folder "%OAT_BASE%" ^
--add-asset-search-path "%MOD_BASE%" ^
--source-search-path "%MOD_BASE%\zone_source" ^
--output-folder "%MOD_BASE%\zone" mod

set err=%ERRORLEVEL%

if %err% EQU 0 (

    if not exist "%MOD_DEST%" mkdir "%MOD_DEST%"

    if exist "%MOD_BASE%\mod.iwd" del /Q "%MOD_BASE%\mod.iwd"

    if not exist "%WINRAR%" (
        echo ERROR: No se encuentra WinRAR:
        echo %WINRAR%
        pause
        exit /b 1
    )

    pushd "%MOD_BASE%"
    "%WINRAR%" a -afzip -r "mod.iwd" "ui\*"
    set RAR_ERR=%ERRORLEVEL%
    popd

    if not %RAR_ERR% EQU 0 (
        COLOR C
        echo ERROR: No se pudo crear mod.iwd
        pause
        exit /b 1
    )

    if exist "%MOD_BASE%\zone\mod.ff" (
        XCOPY "%MOD_BASE%\zone\mod.ff" "%MOD_DEST%\mod.ff" /Y
    ) else (
        COLOR C
        echo ERROR: No se encontro zone\mod.ff
        pause
        exit /b 1
    )

    if exist "%MOD_BASE%\mod.json" (
        XCOPY "%MOD_BASE%\mod.json" "%MOD_DEST%\mod.json" /Y
    ) else (
        COLOR C
        echo ERROR: No se encontro mod.json
        pause
        exit /b 1
    )

    if exist "%MOD_BASE%\mod.iwd" (
        XCOPY "%MOD_BASE%\mod.iwd" "%MOD_DEST%\mod.iwd" /Y
    ) else (
        COLOR C
        echo ERROR: No se encontro mod.iwd
        pause
        exit /b 1
    )

    del /Q "%MOD_BASE%\mod.iwd"

    echo.
    echo ==========================
    echo       XOIA BUILD OK
    echo ==========================
    echo.
    echo Mod instalado en:
    echo %MOD_DEST%
    echo.
pause

) ELSE (
    COLOR C
    echo.
    echo ==========================
    echo       LINKER FAILED
    echo ==========================
    echo.
    echo ERROR: El linker no pudo cargar una o mas zones.
    echo Comprueba GAME_FOLDER:
    echo %GAME_FOLDER%
    echo.
    pause
)
pause

endlocal

pause