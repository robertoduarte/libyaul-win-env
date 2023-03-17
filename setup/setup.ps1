$Env:PATH += ";$pwd/msys64/usr/bin"

$currentPath= "$pwd"
$currentPath= $currentPath.Replace('\','/') 

$tmpPath = "$pwd\temp\"
if (-Not $(Test-Path $tmpPath)) {
    New-Item $tmpPath -ItemType Directory
}

Function Get-Component($src, $destPath) {
    if (-Not $(Test-Path $destPath)) {
        New-Item $destPath -ItemType Directory
    }
    if ($src.Contains("http")) { 
        $fileName = $src.Substring($src.LastIndexOf("/") + 1)
        $tmpFilePath = "$tmpPath$fileName"
        Invoke-WebRequest -URI $src -OutFile $tmpFilePath
        Expand-Archive -Force $tmpFilePath -DestinationPath $destPath
    }
    else {
        Expand-Archive -Force $src -DestinationPath $destPath
    }
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
    [System.Object[]] $parameters = ,[System.Windows.Forms.FileDialog]
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
    [System.Object[]] $fileDialogParam = ,$fileDialog
    $SystemOnBeforeVistaDialogMethodInfo.Invoke($openFileDialog, $fileDialogParam) | Out-Null
    [System.UInt32] $flag = [System.UInt32]$SystemGetOptionsMethodInfo.Invoke($openFileDialog, $empty) + $SystemOsPickFoldersBitFlag;
    [System.Object[]] $flags = ,$flag
    $SystemSetOptionsMethodInfo.Invoke($fileDialog, $flags) | Out-Null
    [System.Object[]] $advParam = ,$openFileDialog
    [System.Object[]] $adviseParametersWithOutputConnectionToken = $VistaDialogEventsConstructorInfo.Invoke($advParam), $AdviseType
    $SystemAdviseMethodInfo.Invoke($fileDialog, $adviseParametersWithOutputConnectionToken) | Out-Null

    try {
        [System.Object[]] $handle = ,[System.IntPtr].Zero
        [int] $dialogResult = [int]$SystemShowMethodInfo.Invoke($fileDialog, $handle);

        if ($dialogResult -eq 0) {
            $result = $openFileDialog.FileName.Trim()
        } else {
            exit
        }
    } finally {
        [System.Object[]] $advFinParam = ,$adviseParametersWithOutputConnectionToken[1]
        $SystemUnAdviseMethodInfo.Invoke($fileDialog, $advFinParam) | Out-Null
    }

    return $result
}

$destinationFolder = Get-Folder

$destinationFolder+="\yaul"

while ($(Test-Path $destinationFolder)){
    [System.Windows.Forms.MessageBox]::Show('Chosen location already has a previous installation plase chose a different folder.','ERROR')
    $destinationFolder = Get-Folder
    $destinationFolder+="\yaul"
}

if (-Not $(Test-Path $destinationFolder)) {
    New-Item $destinationFolder -ItemType Directory
}

Get-Component "base_installation.zip" "$destinationFolder"

Get-Component "https://github.com/ijacquez/libyaul/archive/47e2d38f22ada0de55ae8e1ffedfd572ec9090c9.zip" "$destinationFolder"

Get-ChildItem -Filter "libyaul-*" -Path $destinationFolder  | Rename-Item -NewName "libyaul"

Get-Component "https://github.com/ijacquez/libyaul-examples/archive/fa0cf46d7ea77d1d40246c0465e26f89e3bd0851.zip" "$destinationFolder"

Get-ChildItem -Filter "libyaul-examples-*" -Path $destinationFolder  | Rename-Item -NewName "libyaul-examples"

foreach ($example in $(Get-ChildItem -Directory -Path "$destinationFolder/libyaul-examples")) { 
    Copy-Item -Recurse -Path "project_template/*" -Destination $example.FullName
}

Copy-Item -Recurse -Path "$currentPath/msys64" -Destination $destinationFolder

Copy-Item -Force -Recurse -Path "$currentPath/libyaul-patch/*" -Destination "$destinationFolder\libyaul"

Remove-Item -Recurse -Force -Path $tmpPath

$destinationFolder = $destinationFolder.Replace('\','/')

$Env:YAUL_INSTALL_ROOT= "$destinationFolder/sh2eb-elf"
$Env:YAUL_ARCH_SH_PREFIX="sh2eb-elf"
$Env:YAUL_ARCH_M68K_PREFIX="m68keb-elf"
$Env:YAUL_BUILD_ROOT="$destinationFolder/libyaul"
$Env:YAUL_BUILD="build"
$Env:YAUL_CDB="0"
$Env:YAUL_OPTION_DEV_CARTRIDGE="0"
$Env:YAUL_OPTION_MALLOC_IMPL="tlsf"
$Env:YAUL_OPTION_SPIN_ON_ABORT="1"
$Env:YAUL_OPTION_BUILD_GDB="0"
$Env:YAUL_OPTION_BUILD_ASSERT="1"
$Env:SILENT="1"
$Env:MAKE_ISO_XORRISO="$destinationFolder/msys64/usr/bin/xorrisofs"

Set-Location "$destinationFolder\libyaul"
make install