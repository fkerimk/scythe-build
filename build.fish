#!/usr/bin/env fish

function movexist; if test -e $argv[1]; command mv -f -- $argv[1] $argv[2]; end; end
function copexist; if test -e $argv[1]; command cp -f -- $argv[1] $argv[2]; end; end
function remexist; if test -e $argv[1]; command rm -rf -- $argv[1] $argv[2]; end; end

function checkdep; if not test -e "$argv[1]"; echo "$argv[2..-1]"; exit 1; end; end
function remkdir; remexist $argv[1]; mkdir -p $argv[1]; end;

# Initialize
cd (dirname (status --current-filename))

# Read config
set current_section ""

for line in (cat config.ini)
    # Skip '# '
    if test -z "$line"; continue; end
    if string match -rq '^#' -- "$line"; continue; end
    # Section check
    if string match -rq '^\[(.*)\]' -- "$line"
        set current_section (string replace -r '^\[(.*)\]' '$1' "$line")
    continue; end
    # Key/value pair
    set parts (string split -m1 '=' $line)
    set key (string trim $parts[1])
    set val (string trim $parts[2])
    if test -z "$key"; continue; end
    # Trim "'s
    set val (string trim --chars='"' $val)
    # Section vars
    if test -n "$current_section"
          set var_name (string replace -r '\s+' '' "$current_section")"_"(string replace -r '\s+' '' "$key")
    else; set var_name (string replace -r '\s+' '' "$key"); end
    set -gx $var_name $val
end

# Building
cd ..

# scythe-lib
if test $module_lib = true
    cd lib
    remexist bin
    echo Building (set_color cyan)scythe-lib (set_color normal)
    dotnet publish -v q -c Release
    movexist bin/Release/netstandard2.1/publish/scythe-lib.dll bin
    remexist bin/Release
    checkdep bin/scythe-lib.dll scythe-lib (set_color red)failed to build, aborting
    cd ..
    if test -e core/Assets/Scythe; copexist lib/bin/scythe-bin.dll core/Assets/Scythe; end
end

# scythe-util
if test $module_util = true
    cd util
    remexist bin
    echo Building (set_color cyan)scythe-util (set_color normal)
    dotnet publish -v q -c Release -r linux-x64
    movexist bin/Release/net10.0/linux-x64/publish/scythe-util bin
    checkdep bin/scythe-util scythe-util (set_color red)failed to build, aborting
    remexist bin/Release
    cd ..
end

# scythe-core
if test $module_core = true
    echo Building (set_color cyan)scythe-core (set_color normal)
    checkdep core scythe-core (set_color red)failed to build, aborting
    checkdep $deps_unity scythe-core (set_color red)failed to build, aborting
    remexist core_tmp
    rsync -a --exclude=Library --exclude=Temp --exclude=Builds core/ core_tmp
    $deps_unity -quit -noUpm -batchmode -nographics \
        -logFile build/unity.log \
        -projectPath core_tmp \
        -buildLinux $platform_linux \
        -buildWindows $platform_windows \
        -executeMethod BuildScript.Build >/dev/null 2>&1
    if test $platform_linux = true; checkdep core_tmp/Builds/linux-x64/scythe-core.x86_64 scythe-core (set_color red)failed to build, aborting; end
    if test $platform_windows = true; checkdep core_tmp/Builds/win-x64/scythe-core.exe scythe-core (set_color red)failed to build, aborting; end
    remkdir core/Builds
    mv -f core_tmp/Builds/* core/Builds
    rm -rf core_tmp
end

# scythe-run
if test $module_run = true
    cd run
    remexist bin
    echo Building (set_color cyan)scythe-run (set_color normal)
    if test $platform_linux = true;
        dotnet publish -v q -c Release -r linux-x64
        movexist bin/Release/net10.0/linux-x64/publish/scythe-run bin
        checkdep bin/scythe-run scythe-run (set_color red)failed to build, aborting
    end
    if test $platform_windows = true;
        dotnet publish -v q -c Release -r win-x64
        movexist bin/Release/net10.0/win-x64/publish/scythe-run.exe bin
        checkdep bin/scythe-run.exe scythe-run (set_color red)failed to build, aborting
    end
    remexist bin/Release
    cd ..
end

# mod
if test $mod_build = true
    echo Building (set_color cyan)$mod_name (set_color normal)
    checkdep mods/$mod_name $mod_name (set_color red)failed to build, aborting
    if test $platform_linux = true; checkdep core/Builds/linux-x64/scythe-core.x86_64 $mod_name 1 (set_color red)failed to build, aborting; end
    if test $platform_windows = true; checkdep core/Builds/win-x64/scythe-core.exe $mod_name 2 (set_color red)failed to build, aborting; end
    if test $platform_linux = true; checkdep run/bin/scythe-run $mod_name 3 (set_color red)failed to build, aborting; end
    if test $platform_windows = true; checkdep run/bin/scythe-run.exe $mod_name 4 (set_color red)failed to build, aborting; end
    remkdir build/$mod_name
    mkdir -p build/$mod_name/bin/scythe
    cd build/$mod_name
    echo "[Mod]" > runner.ini
    echo "name=template" >> runner.ini
    cd ../..
    cp -rf mods/$mod_name build/$mod_name/bin/$mod_name
    if test $platform_linux = true; cp -rf core/Builds/linux-x64/* build/$mod_name/bin/scythe; end
    if test $platform_windows = true; cp -rf core/Builds/win-x64/* build/$mod_name/bin/scythe; end
    if test $platform_linux = true; cp -f run/bin/scythe-run build/$mod_name; end
    if test $platform_windows = true; cp -f run/bin/scythe-run.exe "build/$mod_name"; end
    cd build/$mod_name
    if test $platform_linux = true; mv scythe-run $mod_name; end
    if test $platform_windows = true; mv scythe-run.exe $mod_name.exe; end
    cd bin/scythe
    remexist scythe-core_BurstDebugInformation_DoNotShip
    remexist scythe-core_BurstDebugInformation_DoNotShip
    remexist D3D12
    cd ../../../..
end