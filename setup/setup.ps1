


$tmpPath = "$pwd\temp"
Remove-Item -Recurse -Force -Path $tmpPath
if (-Not $(Test-Path $tmpPath)) {
    New-Item $tmpPath -ItemType Directory
}


function Get-Folder {
    param ()
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    [System.Reflection.BindingFlags] $DialogFlags = [System.Reflection.BindingFlags]::Instance + [System.Reflection.BindingFlags]::Public + [System.Reflection.BindingFlags]::NonPublic;
    [string] $DialogFoldersFilter = "Folders|\n";
    [System.UInt32] $AdviseType = 0;
    [System.Reflection.Assembly] $AssemblyOfWinForm = [System.Windows.Forms.FileDialog].Assembly
    [System.Type] $FileDialogType = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialogNative+IFileDialog")
    [System.Reflection.MethodInfo] $SystemAdviseMethodInfo = $FileDialogType.GetMethod("Advise")
    [System.Reflection.MethodInfo] $SystemCeateVistaDialogMethodInfo = [System.Windows.Forms.OpenFileDialog].GetMethod("CreateVistaDialog", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemGetOptionsMethodInfo = [System.Windows.Forms.FileDialog].GetMethod("GetOptions", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemOnBeforeVistaDialogMethodInfo = [System.Windows.Forms.OpenFileDialog].GetMethod("OnBeforeVistaDialog", $DialogFlags)
    [System.Type] $SystemOsPickFolders = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialogNative+FOS")
    [System.UInt32] $SystemOsPickFoldersBitFlag = [System.UInt32]$SystemOsPickFolders.GetField("FOS_PICKFOLDERS").GetValue($null)
    [System.Reflection.MethodInfo] $SystemSetOptionsMethodInfo = $FileDialogType.GetMethod("SetOptions", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemShowMethodInfo = $FileDialogType.GetMethod("Show")
    [System.Reflection.MethodInfo] $SystemUnAdviseMethodInfo = $FileDialogType.GetMethod("Unadvise")
    [System.Type] $VistaDialogEvents = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialog+VistaDialogEvents")
    [System.Object[]] $parameters = , [System.Windows.Forms.FileDialog]
    [System.Reflection.ConstructorInfo] $VistaDialogEventsConstructorInfo = $VistaDialogEvents.GetConstructor($DialogFlags, $null, $parameters, $null)

    [System.Windows.Forms.OpenFileDialog] $openFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
    $openFileDialog.AddExtension = $false
    $openFileDialog.CheckFileExists = $false
    $openFileDialog.DereferenceLinks = $true
    $openFileDialog.Filter = $DialogFoldersFilter
    $openFileDialog.InitialDirectory = ""
    $openFileDialog.Multiselect = $false
    $openFileDialog.Title = "Select a location where to install yaul"

    [System.Object[]] $empty = @()
    [System.Object] $fileDialog = $SystemCeateVistaDialogMethodInfo.Invoke($openFileDialog, $empty)
    [System.Object[]] $fileDialogParam = , $fileDialog
    $SystemOnBeforeVistaDialogMethodInfo.Invoke($openFileDialog, $fileDialogParam) | Out-Null
    [System.UInt32] $flag = [System.UInt32]$SystemGetOptionsMethodInfo.Invoke($openFileDialog, $empty) + $SystemOsPickFoldersBitFlag;
    [System.Object[]] $flags = , $flag
    $SystemSetOptionsMethodInfo.Invoke($fileDialog, $flags) | Out-Null
    [System.Object[]] $advParam = , $openFileDialog
    [System.Object[]] $adviseParametersWithOutputConnectionToken = $VistaDialogEventsConstructorInfo.Invoke($advParam), $AdviseType
    $SystemAdviseMethodInfo.Invoke($fileDialog, $adviseParametersWithOutputConnectionToken) | Out-Null

    try {
        [System.Object[]] $handle = , [System.IntPtr].Zero
        [int] $dialogResult = [int]$SystemShowMethodInfo.Invoke($fileDialog, $handle);

        if ($dialogResult -eq 0) {
            $result = $openFileDialog.FileName.Trim()
        }
        else {
            exit
        }
    }
    finally {
        [System.Object[]] $advFinParam = , $adviseParametersWithOutputConnectionToken[1]
        $SystemUnAdviseMethodInfo.Invoke($fileDialog, $advFinParam) | Out-Null
    }

    return $result
}

Add-Type -AssemblyName System.Windows.Forms

function Get-Folder {
    param ()
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    [System.Reflection.BindingFlags] $DialogFlags = [System.Reflection.BindingFlags]::Instance + [System.Reflection.BindingFlags]::Public + [System.Reflection.BindingFlags]::NonPublic;
    [string] $DialogFoldersFilter = "Folders|\n";
    [System.UInt32] $AdviseType = 0;
    [System.Reflection.Assembly] $AssemblyOfWinForm = [System.Windows.Forms.FileDialog].Assembly
    [System.Type] $FileDialogType = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialogNative+IFileDialog")
    [System.Reflection.MethodInfo] $SystemAdviseMethodInfo = $FileDialogType.GetMethod("Advise")
    [System.Reflection.MethodInfo] $SystemCeateVistaDialogMethodInfo = [System.Windows.Forms.OpenFileDialog].GetMethod("CreateVistaDialog", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemGetOptionsMethodInfo = [System.Windows.Forms.FileDialog].GetMethod("GetOptions", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemOnBeforeVistaDialogMethodInfo = [System.Windows.Forms.OpenFileDialog].GetMethod("OnBeforeVistaDialog", $DialogFlags)
    [System.Type] $SystemOsPickFolders = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialogNative+FOS")
    [System.UInt32] $SystemOsPickFoldersBitFlag = [System.UInt32]$SystemOsPickFolders.GetField("FOS_PICKFOLDERS").GetValue($null)
    [System.Reflection.MethodInfo] $SystemSetOptionsMethodInfo = $FileDialogType.GetMethod("SetOptions", $DialogFlags)
    [System.Reflection.MethodInfo] $SystemShowMethodInfo = $FileDialogType.GetMethod("Show")
    [System.Reflection.MethodInfo] $SystemUnAdviseMethodInfo = $FileDialogType.GetMethod("Unadvise")
    [System.Type] $VistaDialogEvents = $AssemblyOfWinForm.GetType("System.Windows.Forms.FileDialog+VistaDialogEvents")
    [System.Object[]] $parameters = , [System.Windows.Forms.FileDialog]
    [System.Reflection.ConstructorInfo] $VistaDialogEventsConstructorInfo = $VistaDialogEvents.GetConstructor($DialogFlags, $null, $parameters, $null)

    [System.Windows.Forms.OpenFileDialog] $openFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
    $openFileDialog.AddExtension = $false
    $openFileDialog.CheckFileExists = $false
    $openFileDialog.DereferenceLinks = $true
    $openFileDialog.Filter = $DialogFoldersFilter
    $openFileDialog.InitialDirectory = ""
    $openFileDialog.Multiselect = $false
    $openFileDialog.Title = "Select a location where to install yaul"

    [System.Object[]] $empty = @()
    [System.Object] $fileDialog = $SystemCeateVistaDialogMethodInfo.Invoke($openFileDialog, $empty)
    [System.Object[]] $fileDialogParam = , $fileDialog
    $SystemOnBeforeVistaDialogMethodInfo.Invoke($openFileDialog, $fileDialogParam) | Out-Null
    [System.UInt32] $flag = [System.UInt32]$SystemGetOptionsMethodInfo.Invoke($openFileDialog, $empty) + $SystemOsPickFoldersBitFlag;
    [System.Object[]] $flags = , $flag
    $SystemSetOptionsMethodInfo.Invoke($fileDialog, $flags) | Out-Null
    [System.Object[]] $advParam = , $openFileDialog
    [System.Object[]] $adviseParametersWithOutputConnectionToken = $VistaDialogEventsConstructorInfo.Invoke($advParam), $AdviseType
    $SystemAdviseMethodInfo.Invoke($fileDialog, $adviseParametersWithOutputConnectionToken) | Out-Null

    try {
        [System.Object[]] $handle = , [System.IntPtr].Zero
        [int] $dialogResult = [int]$SystemShowMethodInfo.Invoke($fileDialog, $handle);

        if ($dialogResult -eq 0) {
            $result = $openFileDialog.FileName.Trim()
        }
        else {
            exit
        }
    }
    finally {
        [System.Object[]] $advFinParam = , $adviseParametersWithOutputConnectionToken[1]
        $SystemUnAdviseMethodInfo.Invoke($fileDialog, $advFinParam) | Out-Null
    }

    return $result
}

$installationPath = Get-Folder

$installationPath += "\yaul"

while ($(Test-Path $installationPath)) {
    [System.Windows.Forms.MessageBox]::Show('Chosen location already has a previous installation plase chose a different folder.', 'ERROR')
    $installationPath = Get-Folder
    $installationPath += "\yaul"
}

if (-Not $(Test-Path $installationPath)) {
    New-Item $installationPath -ItemType Directory
}

$settings = Get-Content -Raw -Path "settings.json" | ConvertFrom-Json

$installerDependencies = $settings | Select-Object -ExpandProperty InstallerDependencies

$7zipPackage = $installerDependencies | Select-Object -ExpandProperty 7zipPackage

if (-Not $(Test-Path "7za.exe")) {
    $7zipPath = "$tmpPath\7-Zip"
    if (-Not $(Test-Path $7zipPath)) {
        New-Item $7zipPath -ItemType Directory
    }
    $fileName = $7zipPackage.Substring($7zipPackage.LastIndexOf("/") + 1)
    $tempPackage = "$tmpPath\$fileName"
    Invoke-WebRequest -URI $7zipPackage -OutFile $tempPackage
    Expand-Archive -Force $tempPackage -DestinationPath $7zipPath
    $Env:PATH += ";$7zipPath"
}

$Packages = $settings | Select-Object -ExpandProperty Packages
$Packages
$Packages | Select-Object -Property Destination, Source | ForEach-Object {
    $Source = $_.Source
    

    if (-Not $(Test-Path $tmpPath)) {
        New-Item $tmpPath -ItemType Directory
    }
    if ($source.Contains("http")) { 
        $fileName = $source.Substring($source.LastIndexOf("/") + 1)
        $tempPackagePath = "$tmpPath\$fileName"
        Invoke-WebRequest -URI $source -OutFile $tempPackagePath
    }
    else {
        $fileName = $source.Substring($source.LastIndexOf("\") + 1)
        Copy-Item -Force -Path $source -Destination $tmpPath
        $tempPackagePath = "$tmpPath\$fileName"
    }

    if ($tempPackagePath.Contains(".tar")) {
        7za.exe x $tempPackagePath -aoa -o"$tmpPath"
        $tempPackagePath = $tempPackagePath.Substring(0, $tempPackagePath.IndexOf(".tar") + 4)
    }

    $tempExtractPath = $tempPackagePath + "_dir"
    Remove-Item -Recurse -Force -Path $tempExtractPath
    if (-Not $(Test-Path $tempExtractPath)) {
        New-Item $tempExtractPath -ItemType Directory
    }

    7za.exe x $tempPackagePath -aoa -o"$tempExtractPath"

    $DestinationDir = $InstallationPath + "\" + $_.Destination
    if (-Not $(Test-Path $DestinationDir)) {
        New-Item $DestinationDir -ItemType Directory
    }
    if ((Get-ChildItem $tempExtractPath | Measure-Object).Count -gt 1) {
        Copy-Item -Recurse -Path "$tempExtractPath/*" -Destination $DestinationDir
    }
    else {
        Copy-Item -Recurse -Path "$tempExtractPath/*/*" -Destination $DestinationDir
    }

    Remove-Item -Recurse -Force -Path $tempExtractPath

}

[System.Environment]::SetEnvironmentVariable('YAUL_ROOT', $InstallationPath, [System.EnvironmentVariableTarget]::User)

foreach ($example in $(Get-ChildItem -Directory -Path "$InstallationPath/libyaul-examples")) { 
    Copy-Item -Recurse -Path "project_template/*" -Destination $example.FullName
}

Copy-Item -Force -Recurse -Path "$currentPath/libyaul-patch/*" -Destination "$InstallationPath\libyaul"

$Env:PATH += ";$InstallationPath/msys64/usr/bin"
$Env:PATH += ";$InstallationPath/msys64/mingw64/bin"

To fix intelisense on vscode
Copy-Item -Force "$InstallationPath\msys64\mingw64\bin\libwinpthread-1.dll" -Destination "$InstallationPath\sh2eb-elf\bin"

$InstallationPath = $InstallationPath.Replace('\', '/')

$Env:YAUL_INSTALL_ROOT = "$InstallationPath/sh2eb-elf"
$Env:YAUL_ARCH_SH_PREFIX = "sh2eb-elf"
$Env:YAUL_ARCH_M68K_PREFIX = "m68keb-elf"
$Env:YAUL_BUILD_ROOT = "$InstallationPath/libyaul"
$Env:YAUL_BUILD = "build"
$Env:YAUL_CDB = "0"
$Env:YAUL_OPTION_DEV_CARTRIDGE = "0"
$Env:YAUL_OPTION_MALLOC_IMPL = "tlsf"
$Env:YAUL_OPTION_SPIN_ON_ABORT = "1"
$Env:YAUL_OPTION_BUILD_GDB = "0"
$Env:YAUL_OPTION_BUILD_ASSERT = "1"
$Env:SILENT = "1"
$Env:MAKE_ISO_XORRISO = "$InstallationPath/msys64/usr/bin/xorrisofs"

Set-Location "$InstallationPath\libyaul"

make install

Remove-Item -Recurse -Force -Path $tmpPath
