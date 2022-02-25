# hug
#
# Usage: .\hug.ps1 GameFolder zs
# Required : Game Folder (where main.lua lives, can be a directory outside of Love2D installation path)
# Optional : z - retain the generated .zip file
# Optional : r - will execute the game after building
# Optional : i - will execute rcedit-x64 to update the exe icon 
#
# Game.exe will remain in the love directory.

$deleteZip = $true
$runGame = $false
$updateIcon = $false

$argCount = $args.Count
if ($argCount -lt 1 -or $argCount -gt 2) {
    Write-Host "Game folder name expected: e.g. .\hug.ps1 GameName"
} else {
    $game=$args[0]
    
    if (Get-Item .\$game.zip -ErrorAction SilentlyContinue) {
        Remove-Item .\$game.zip
    }
    if (Get-Item .\$game.exe -ErrorAction SilentlyContinue) {
        Remove-Item .\$game.exe
    }
    
    Compress-Archive .\$game\* -DestinationPath .\$game.zip
    
    # TO-DO Find a PS equivalent to this call.
    cmd /c copy /b .\love.exe+.\$game.zip .\$game.exe

    # If an icon exists under gfx/icon.ico apply it to the generated exe.
    if (Get-Item .\$game\gfx\icon.ico -ErrorAction SilentlyContinue) {
        Write-Host "Applying icon from gfx/icon.ico!"
        # Run rcedit-x64 and update the newly created exe with our icon.
        $p = Start-Process .\rcedit-x64.exe -ArgumentList " .\$game.exe --set-icon .\$game\gfx\icon.ico" -wait -NoNewWindow -PassThru
        $p
        # Wait for this process to finish before going any further to prevent locking the exe.
        $p.HasExited
    }
    
    if ($argCount -eq 2) {
        $options=$args[1].ToLower()
        if (($options -like '*z*')) {
            $deleteZip = $false
        }
        if ($options -like '*r*') {
            $runGame = $true
        }
        if ($options -like '*i*') {
            $updateIcon = $true
        }
    }

    # If z option is not given or only 1 argument is found delete the .zip file.
    if ($deleteZip) {
        Remove-Item ".\$game.zip"
    }

    # If s option is not given or only 1 argument is found run the game
    if ($runGame) {
        Start-Process .\$game.exe
    }
}