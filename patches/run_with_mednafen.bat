@ECHO Off

if not exist *.cue (
    echo "ISO missing, please build first."
) else (
    @REM Finding first cue file and running it on mednafen
    FOR %%F IN (*.cue) DO (
        "..\..\mednafen\mednafen.exe" %%F
        exit /b
    )
)
