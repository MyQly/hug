# hug
#
# Usage: .\hug.ps1 GameFolder zs
# Required : Game Folder (where main.lua lives, can be a directory outside of Love2D installation path)
# Optional : z - retain the generated .zip file
# Optional : r - will execute the game after building
# Optional : i - will execute rcedit-x64 to update the exe icon 
#
# Game.exe will remain in the love directory.

$argCount = $args.Count

$options = @{
    deleteZip = $true;
    runGame = $false;
    updateIcon = $false;
}

if ($argCount -lt 1 -or $argCount -gt 2) {
    Write-Host "Argument count mismatch. Please use the following format: .\hug.ps1 GameName (zri)"
    Exit
}

$game=$args[0]

if (-not(Get-Item .\$game -ErrorAction SilentlyContinue)) {
    Write-Host "Game folder $game not found!"
    Exit
}



if (Get-Item .\$game.zip -ErrorAction SilentlyContinue) {
    Remove-Item .\$game.zip
}
if (Get-Item .\$game.exe -ErrorAction SilentlyContinue) {
    Remove-Item .\$game.exe
}

# Generate .zip archive of game content from folder
Compress-Archive .\$game\* -DestinationPath .\$game.zip
# Generate game executable
Add-Content -Path ".\$game.exe" -Value ((Get-Content -Path .\love.exe -Raw -AsByteStream) + (Get-Content -Path .\$game.zip -Raw -AsByteStream)) -AsByteStream


if ($argCount -eq 2) {
    $arg2=$args[1].ToLower()
    if (($arg2 -like '*z*')) {
        $options.deleteZip = $false
    }
    if ($arg2 -like '*r*') {
        $options.runGame = $true
    }
    if ($arg2 -like '*i*') {
        $options.updateIcon = $true
    }
}

# If an icon exists under gfx/icon.ico apply it to the generated exe.
# I don't like using this .exe to do this job and the results seem inconsistent for some reason.
if ((Get-Item .\$game\gfx\icon.ico -ErrorAction SilentlyContinue) -and $options.updateIcon) {
    Write-Host "Applying icon from gfx/icon.ico!"
    # Run rcedit-x64 and update the newly created exe with our icon.
    $p = Start-Process .\rcedit-x64.exe -ArgumentList " .\$game.exe --set-icon icon.ico" -wait -NoNewWindow -PassThru
    # Wait for this process to finish before going any further to prevent locking the exe.
    while (-not($p.HasExited)) {
        # This never actually renders from my tests but may if the system is slower.
        Write-Host "." -NoNewLine
    }
}


# If z option is not given or only 1 argument is found delete the .zip file.
if ($options.deleteZip) {
    Remove-Item ".\$game.zip"
}

# If s option is not given or only 1 argument is found run the game
if ($options.runGame) {
    Start-Process .\$game.exe
}