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

git clone https://github.com/ijacquez/libyaul-examples.git
cd libyaul-examples
git checkout %YAUL_EXAMPLES_COMMIT%

FOR /d %%i IN (*) DO (
  xcopy /s/e/y "%ROOT_DIR%vscode_template" "%%i"
)

SET PATCH_DIR=%ROOT_DIR%patches/libyaul-examples/%YAUL_EXAMPLES_COMMIT%
IF EXIST %PATCH_DIR% (
    cp -rf %PATCH_DIR%/* .
)

pacman -Syy
pacman -S --noconfirm yaul-tool-chain-git
pacman -S --noconfirm yaul-emulator-yabause
pacman -S --noconfirm yaul-emulator-mednafen

cp -rf %ROOT_DIR%msys_trimmed/opt/* .

@REM Copy libwinpthread-1.dll so that intellisense works on vscode
cp %ROOT_DIR%msys_trimmed/usr/bin/libwinpthread-1.dll tool-chains/sh2eb-elf/bin/

pacman -R --noconfirm yaul-tool-chain-git
pacman -R --noconfirm yaul-emulator-yabause
pacman -R --noconfirm yaul-emulator-mednafen

set YAUL_COMMIT=47e2d38f22ada0de55ae8e1ffedfd572ec9090c9

git clone https://github.com/ijacquez/libyaul.git
cd libyaul
git checkout %YAUL_COMMIT%

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