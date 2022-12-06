Clear-Host

Set-alias -Name c -Value Clear-Host
Remove-Item alias:\ls
function ls { Clear-Host ; lsd --icon never --group-dirs first $args}
function l { Clear-Host ; lsd --icon never -a -h --group-dirs first $args}
function ll { Clear-Host ; lsd --icon never -ahl --group-dirs first $args}
function lt { Clear-Host ; lsd --icon never -ahltr }

function b { Clear-Host ; set-location "C:\Program Files\" ; ls --icon never -ah }
function b2 { Clear-Host ; set-location "C:\Program Files (x86)\" ; ls --icon never -ah }
Set-alias -Name env -Value Get-Variable
Set-alias -Name comando -Value Get-Command
#Set-alias -Name cl -Value choco list --local-only
function cl { choco list --local-only }
function cs { choco search $args }
function home { set-location $home ; lsd --group-dirs first -a --icon never }
function cnf { set-location $home\ ; lsd --group-dirs first -a --icon never }
Set-alias -Name n -Value notepad
function d { Clear-Host ; set-location $home\Downloads\ ; lsd --group-dirs first -a --icon never}
function p { notepad C:\Users\exp\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 ; Get-ChildItem }
function v { Clear-Host ; set-location $home\Videos\ ; lsd --group-dirs first -a --icon never }
function .. { Clear-Host ; set-location .. ; lsd --group-dirs first -a --icon never }
function s { Clear-Host ; set-location $home\software ; lsd --group-dirs first -a --icon never }
function / { Clear-Host ; set-location / ; Get-ChildItem }
function path { echo $env:path }
function ipp { Invoke-RestMethod icanhazip.com }
function ipl { ipconfig }
function cron {  Start-Process taskschd.msc -Verb runAs }
function ex { 7z e $args }
#function sudo {  Start-Process powershell -Verb runAs }
#function su {  Start-Process powershell -Verb runAs }
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
function politica {  Get-ExecutionPolicy -List }
function doc { Clear-Host ; set-location C:\Users\exp\Desktop\doc ; lsd --group-dirs first -a --icon never }
#function scan { Start-Process "C:\ProgramData\Microsoft\Windows Defender\platform\4.18.2008.9-0\MpCmdRun.exe" -Scan -Scantype 3 $args }
function scan { Start-Process "C:\program files\windows defender\mpcmdrun.exe" -ArgumentList "-Scan -ScanType 3 -File $($args[0])" }
function luna { Invoke-RestMethod wttr.in/Moon }
function tiempo { Invoke-RestMethod wttr.in/$args }
function tareas { Clear-Host ; Get-scheduledTask }
function service { Clear-Host ; Get-service $args }
#function grep { select-string $args }
Set-alias -Name grep -Value select-string
Set-alias -Name wc -Value measure-object
Set-alias -Name less -Value more
Set-alias -Name q -Value exit
function ex {  Start-Process C:\Users\exp\Documents\WindowsPowerShell\ex.ps1 } 

function hello{
    param(
            $path
         )
    if(Test-Path $path){
        $path = Resolve-Path $path
	Clear-Host
        Set-Location $path
	lsd -a --icon never --group-dirs first $path
    }else{
        "Could not find path $path"
    }
}
Set-Alias cdd hello -Force

Remove-Item alias:\cd
New-Alias cd hello
