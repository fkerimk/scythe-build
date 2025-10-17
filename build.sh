#!/bin/sh
################################################################

## Initialize
cd "$(dirname "$0")"
while IFS='=' read -r k v || [[ -n $k ]]; do [[ -z "$k" || "$k" =~ ^#|^\[ ]] && continue; k=$(echo "$k" | tr -d '[:space:]'); v=$(echo "$v" | tr -d '"\r'); [ -n "$k" ] && export "$k=$v"; done < config.ini

################################################################

## Building
cd ..

################################################################

##  Scythe Lib
if [[ "$mod_lib" == "true" ]]; then

    cd ./lib/
    [ -d "./bin/" ] && rm -rf "./bin/"
    echo "[BUILD] Building scythe-lib" 
    dotnet publish -v q -c Release
    [ -f "./bin/Release/netstandard2.1/publish/scythe-lib.dll" ] && mv -f "./bin/Release/netstandard2.1/publish/scythe-lib.dll" "./bin/"
    [ -d "./bin/Release/" ] && rm -rf "./bin/Release/"
    [ ! -f "./bin/scythe-lib.dll" ] && echo "[BUILD] scythe-lib failed to build, aborting" && exit 1
    cd ..

fi

################################################################

if [[ "$mod_core" == "true" ]]; then

    [ ! -d "./core/Assets/Scythe/" ] && echo "[BUILD] scythe-core failed to build, aborting" && exit 1
    cp -f "./lib/bin/scythe-lib.dll" "./core/Assets/Scythe/"
    [ -d "./core/Builds/" ] && rm -rf "./core/Builds/"
    [[ "$plat_linux" == "true" ]] && mkdir -p "./core/Builds/linux-x64"
    [[ "$plat_win" == "true" ]] && mkdir -p "./core/Builds/win-x64"
    read -n1 -r -p "Please take the core build, return, and continue." _;

fi

################################################################

## Scythe Util
if [[ "$mod_util" == "true" ]]; then

    cd ./util/
    [ -d "./bin/" ] && rm -rf "./bin/"

    ## Linux
    if [[ "$plat_linux" == "true" ]]; then
        echo "[BUILD] Building scythe-util for linux-x64" 
        dotnet publish -v q -c Release -r "linux-x64"
        [ -f "./bin/Release/net10.0/linux-x64/publish/scythe-util" ] &&  mv -f "./bin/Release/net10.0/linux-x64/publish/scythe-util" "./bin/"
        [ ! -f  "./bin/scythe-util" ] && echo "[BUILD] scythe-util linux-x64 failed to build, aborting" && exit 1
    fi

    ## Windows
    if [[ "$plat_win" == "true" ]]; then
        echo "[BUILD] Building scythe-util for win-x64" 
        dotnet publish -v q -c Release -r "win-x64"
        [ -f "./bin/Release/net10.0/win-x64/publish/scythe-util.exe" ] &&  mv -f "./bin/Release/net10.0/win-x64/publish/scythe-util.exe" "./bin/"
        [ ! -f  "./bin/scythe-util.exe" ] && echo "[BUILD] scythe-util win-x64 failed to build, aborting" && exit 1
    fi

    [ -d "./bin/Release/" ] && rm -rf "./bin/Release/"
    cd ..

fi

################################################################

## Scythe Run
if [[ "$mod_run" == "true" ]]; then

    cd ./run/
    [ -d "./bin/" ] && rm -rf "./bin/"

    ## Linux
    if [[ "$plat_linux" == "true" ]]; then
        echo "[BUILD] Building scythe-run for linux-x64" 
        dotnet publish -v q -c Release -r "linux-x64"
        [ -f "./bin/Release/net10.0/linux-x64/publish/scythe-run" ] &&  mv -f "./bin/Release/net10.0/linux-x64/publish/scythe-run" "./bin/"
        [ ! -f  "./bin/scythe-run" ] && echo "[BUILD] scythe-run linux-x64 failed to build, aborting" && exit 1
    fi

    ## Windows
    if [[ "$plat_win" == "true" ]]; then
        echo "[BUILD] Building scythe-run for win-x64" 
        dotnet publish -v q -c Release -r "win-x64"
        [ -f "./bin/Release/net10.0/win-x64/publish/scythe-run.exe" ] &&  mv -f "./bin/Release/net10.0/win-x64/publish/scythe-run.exe" "./bin/"
        [ ! -f  "./bin/scythe-run.exe" ] && echo "[BUILD] scythe-run win-x64 failed to build, aborting" && exit 1
    fi

    [ -d "./bin/Release/" ] && rm -rf "./bin/Release/"
    cd ..

fi

################################################################

## Mod
if [[ "$build" == "true" ]]; then

    echo "[BUILD] Building $name" 
    [ ! -d "./mods/template/" ] && echo "[BUILD] $name failed to build, aborting" && exit 1
    [[ "$plat_linux" == "true" ]] && [ ! -d "./core/Builds/linux-x64/" ] && echo "[BUILD] $name failed to build, aborting" && exit 1
    [[ "$plat_linux" == "true" ]] && [ ! -f "./run/bin/scythe-run" ] && echo "[BUILD] $name failed to build, aborting" && exit 1
    [[ "$plat_win" == "true" ]] && [ ! -d "./core/Builds/win-x64/" ] && echo "[BUILD] $name failed to build, aborting" && exit 1
    [[ "$plat_win" == "true" ]] && [ ! -f "./run/bin/scythe-run.exe" ] && echo "[BUILD] $name failed to build, aborting" && exit 1
    cd ./build/
    [ -d "./$name/" ] && rm -rf "./$name/"
    mkdir -p "./$name/bin/scythe/"
    cd "$name"
    
    ## Config
    echo "[Mod]" > runner.ini
    echo "name=template" >> runner.ini

    ## Binary
    cd ../..
    cp -rf "./mods/template/" "./build/$name/"
    [[ "$plat_linux" == "true" ]] && cp -rf "./core/Builds/linux-x64/" "./build/$name/bin/scythe/"
    [[ "$plat_linux" == "true" ]] && cp -f "./run/bin/scythe-run" "./build/$name/"
    [[ "$plat_win" == "true" ]] && cp -rf "./core/Builds/win-x64/" "./build/$name/bin/scythe/"
    [[ "$plat_win" == "true" ]] && cp -f "./run/bin/scythe-run.exe" "./build/$name/"
    cd "./build/$name/"
    [ -d "./bin/scythe/linux-x64/scythe-core_BurstDebugInformation_DoNotShip" ] && rm -rf "./bin/scythe/linux-x64/scythe-core_BurstDebugInformation_DoNotShip"
    [ -d "./bin/scythe/win-x64/scythe-core_BurstDebugInformation_DoNotShip" ] && rm -rf "./bin/scythe/win-x64/scythe-core_BurstDebugInformation_DoNotShip"
    [ -d "./bin/scythe/win-x64/D3D12" ] && rm -rf "./bin/scythe/win-x64/D3D12"

    cd ../..

fi