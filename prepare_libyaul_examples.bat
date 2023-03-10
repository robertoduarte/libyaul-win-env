@ECHO Off
SET ROOT_DIR=%~dp0
SET "ROOT_DIR=%ROOT_DIR:\=/%"

SET MSYS_BIN=%ROOT_DIR%msys_trimmed/usr/bin
SET PATH=%MSYS_BIN%;%PATH%

SET YAUL_EXAMPLES_COMMIT=fa0cf46d7ea77d1d40246c0465e26f89e3bd0851

SET BACKUP_DIR=%ROOT_DIR%libyaul-examples_backup_%date:/=-%%time::=-%
SET BACKUP_DIR=%BACKUP_DIR: =_%
IF EXIST libyaul-examples (
    mv %ROOT_DIR%libyaul-examples %BACKUP_DIR%
    IF NOT EXIST %BACKUP_DIR% (
        echo "Failed to backup existing libyaul-examples, check if folder is in use by another process."
        exit
    )
)

powershell -command "Invoke-WebRequest -URI https://github.com/ijacquez/libyaul-examples/archive/%YAUL_EXAMPLES_COMMIT%.zip -OutFile %YAUL_EXAMPLES_COMMIT%.zip"
powershell -command "Expand-Archive %YAUL_EXAMPLES_COMMIT%.zip -DestinationPath ."
rm -f %YAUL_EXAMPLES_COMMIT%.zip
powershell -command "mv libyaul-examples-%YAUL_EXAMPLES_COMMIT% libyaul-examples"
cd libyaul-examples

FOR /d %%i IN (*) DO (
    cp -r %ROOT_DIR%project_template/.vscode "%%i"
    cp -r %ROOT_DIR%project_template/. "%%i"
)

SET PATCH_DIR=%ROOT_DIR%patches/libyaul-examples/%YAUL_EXAMPLES_COMMIT%
IF EXIST %PATCH_DIR% (
    cp -rf %PATCH_DIR%/* .
)

powershell -command "Invoke-WebRequest -URI http://packages.yaul.org/mingw-w64/x86_64/yaul-tool-chain-git-r132.00b3688-1-x86_64.pkg.tar.zst -OutFile yaul-tool-chain.tar.zst"
zstd -d yaul-tool-chain.tar.zst
tar --strip-components=1 -xf yaul-tool-chain.tar
powershell -command "Invoke-WebRequest -URI http://packages.yaul.org/mingw-w64/x86_64/yaul-emulator-mednafen-1.26.1-1-x86_64.pkg.tar.zst -OutFile yaul-emulator-mednafen.tar.zst"
zstd -d yaul-emulator-mednafen.tar.zst
tar --strip-components=1 -xf yaul-emulator-mednafen.tar
powershell -command "Invoke-WebRequest -URI http://packages.yaul.org/mingw-w64/x86_64/yaul-emulator-yabause-0.9.15-1-x86_64.pkg.tar.zst -OutFile yaul-emulator-yabause.tar.zst"
zstd -d yaul-emulator-yabause.tar.zst
tar --strip-components=1 -xf yaul-emulator-yabause.tar
rm -f *.tar

@REM Copy libwinpthread-1.dll so that intellisense works on vscode
cp %ROOT_DIR%msys_trimmed/usr/bin/libwinpthread-1.dll tool-chains/sh2eb-elf/bin/

set YAUL_COMMIT=47e2d38f22ada0de55ae8e1ffedfd572ec9090c9


powershell -command "Invoke-WebRequest -URI https://github.com/ijacquez/libyaul/archive/%YAUL_COMMIT%.zip -OutFile %YAUL_COMMIT%.zip"
powershell -command "Expand-Archive %YAUL_COMMIT%.zip -DestinationPath ."
rm -f %YAUL_COMMIT%.zip
powershell -command "mv libyaul-%YAUL_COMMIT% libyaul"
cd libyaul

SET PATCH_DIR=%ROOT_DIR%patches/libyaul/%YAUL_COMMIT%
IF EXIST %PATCH_DIR% (
    cp -rf %PATCH_DIR%/* .
)

SET YAUL_INSTALL_ROOT=%ROOT_DIR%libyaul-examples/tool-chains/sh2eb-elf
SET YAUL_PROG_SH_PREFIX=
SET YAUL_ARCH_SH_PREFIX=sh2eb-elf
SET YAUL_ARCH_M68K_PREFIX=m68keb-elf
SET YAUL_BUILD_ROOT=%ROOT_DIR%libyaul-examples/libyaul
SET YAUL_BUILD=build
SET YAUL_CDB=0
SET YAUL_OPTION_DEV_CARTRIDGE=0
SET YAUL_OPTION_MALLOC_IMPL=tlsf
SET YAUL_OPTION_SPIN_ON_ABORT=1
SET YAUL_OPTION_BUILD_GDB=0
SET YAUL_OPTION_BUILD_ASSERT=1
SET SILENT=1
SET MAKE_ISO_XORRISO=%MSYS_BIN%/xorrisofs

cmd /c make install