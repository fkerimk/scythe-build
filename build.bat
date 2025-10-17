@echo off

echo DO NOT USE THIS

pause
exit

setlocal enabledelayedexpansion

:: Initialize
cd /d "%~dp0"
for /f "tokens=1,* delims== " %%a in ('findstr "=" config.ini') do set "%%~a=%%~b"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Building
cd ..

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Scythe Lib
if /i "%mod_lib%" == "true" (

    cd ./lib/
    if exist ".\bin\" rmdir /s /q ".\bin\"
    echo [BUILD] Building "scythe-lib"
    dotnet publish -v q -c Release
    if exist ".\bin\Release\%dotnet%\publish\scythe-lib.dll" move /y ".\bin\Release\%dotnet%\publish\scythe-lib.dll" ".\bin\"
    if exist ".\bin\Release\" rmdir /s /q ".\bin\Release\"
    if not exist ".\bin\scythe-lib.dll" echo "[BUILD] scythe-lib failed to build, aborting" && exit /b 1
    cd ..
    if exist ".\core\Assets\Scythe\" copy /y ".\lib\bin\scythe-lib.dll" ".\core\Assets\Scythe\"
    echo Please take the core build, return, and continue. & pause >nul
    
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Scythe Util
if /i "%mod_util%" == "true" (

    cd .\util\
    if exist ".\bin\" rmdir /s /q ".\bin\"

    :: Linux
    if /i "%plat_linux%" == "true" (
        echo [BUILD] Building scythe-util for linux-x64
        dotnet publish -v q -c Release -r "linux-x64"
        if exist ".\bin\Release\%dotnet%\linux-x64\publish\scythe-util" move /y ".\bin\Release\%dotnet%\linux-x64\publish\scythe-util" ".\bin\"
        if not exist ".\bin\scythe-util" echo [BUILD] scythe-util linux-x64 failed to build, aborting && exit /b 1
    )

    :: Windows
    if /i "%plat_win%" == "true" (
        echo [BUILD] Building scythe-util for win-x64
        dotnet publish -v q -c Release -r "win-x64"
        if exist ".\bin\Release\%dotnet%\win-x64\publish\scythe-util.exe" move /y ".\bin\Release\%dotnet%\win-x64\publish\scythe-util.exe" ".\bin\"
        if not exist ".\bin\scythe-util.exe" echo [BUILD] scythe-util win-x64 failed to build, aborting && exit /b 1
    )

    if exist ".\bin\Release\" rmdir /s /q ".\bin\Release\"
    cd ..

)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Scythe Run
if /i "%mod_run%" == "true" (

    cd .\run\
    if exist ".\bin\" rmdir /s /q ".\bin\"

    :: Linux
    if /i "%plat_linux%" == "true" (
        echo [BUILD] Building scythe-run for linux-x64
        dotnet publish -v q -c Release -r "linux-x64"
        if exist ".\bin\Release\%dotnet%\linux-x64\publish\scythe-run" move /y ".\bin\Release\%dotnet%\linux-x64\publish\scythe-run" ".\bin\"
        if not exist ".\bin\scythe-run" echo [BUILD] scythe-run linux-x64 failed to build, aborting && exit /b 1
    )

    :: Windows
    if /i "%plat_win%" == "true" (
        echo [BUILD] Building scythe-run for win-x64
        dotnet publish -v q -c Release -r "win-x64"
        if exist ".\bin\Release\%dotnet%\win-x64\publish\scythe-run.exe" move /y ".\bin\Release\%dotnet%\win-x64\publish\scythe-run.exe" ".\bin\"
        if not exist ".\bin\scythe-run.exe" echo [BUILD] scythe-run win-x64 failed to build, aborting && exit /b 1
    )

    if exist ".\bin\Release\" rmdir /s /q ".\bin\Release\"
    cd ..

)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Finishing
endlocal