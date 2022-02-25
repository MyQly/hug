# hug
#
# Usage: .\hug.ps1 GameFolder zs
# Parameter : Game Folder (where main.lua lives, can be a directory outside of Love2D installation path)
# z - retain the generated .zip file
# s - silent (do *not* run the exe after packaging)
#
# Game.exe will remain in the love directory.

$argCount = $args.Count
if ($argCount -lt 1 -or $argCount -gt 2) {
    Write-Host "Game folder name expected: e.g. .\hug.ps1 GameName"
} else {
    $game=$args[0]
    if (Get-Item .\$game.zip -ErrorAction SilentlyContinue) {
        rm .\$game.zip
    }
    if (Get-Item .\$game.exe -ErrorAction SilentlyContinue) {
        rm .\$game.exe
    }
    Compress-Archive .\$game\* -DestinationPath .\$game.zip
    cmd /c copy /b .\love.exe+.\$game.zip .\$game.exe
    if ($argCount -eq 2) {
        Write-Host $args[1]
        $params=$args[1].ToLower()
        if (-not($params -like '*z*')) {
            rm .\$game.zip
        }
        if (-not($params -like '*s*')) {
            cmd /c "$game.exe"
        }
    }
}