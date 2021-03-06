$dir1 = Split-Path -Path $myInvocation.MyCommand.Path -Parent
$profit = "$dir1\profit"
$backup = "$profit\backup"
$out = "$dir1\out"
$email = @("tmn-goe@tmn.apkbank.ru")

function ClearUI{
	$bckgrnd = "DarkBlue"
	$Host.UI.RawUI.BackgroundColor = $bckgrnd
	$Host.UI.RawUI.ForegroundColor = 'White'
	$Host.PrivateData.ErrorForegroundColor = 'Red'
	$Host.PrivateData.ErrorBackgroundColor = $bckgrnd
	$Host.PrivateData.WarningForegroundColor = 'Magenta'
	$Host.PrivateData.WarningBackgroundColor = $bckgrnd
	$Host.PrivateData.DebugForegroundColor = 'Yellow'
	$Host.PrivateData.DebugBackgroundColor = $bckgrnd
	$Host.PrivateData.VerboseForegroundColor = 'Green'
	$Host.PrivateData.VerboseBackgroundColor = $bckgrnd
	$Host.PrivateData.ProgressForegroundColor = 'Cyan'
	$Host.PrivateData.ProgressBackgroundColor = $bckgrnd
	Clear-Host
}

function Test_dir($dirs1){	
	foreach ($d1 in $dirs1){
		#проверка существования путей
		if (!(Test-Path -Path $d1)){
			Write-Host "Путь $d1 не найден!" -ForegroundColor Red
			Write-Host "Нажмите любую клавишу для продолжения" 
			Read-Host "Нажмите Enter"			
			Exit
		}
	}
}

ClearUI
Set-Location $profit
Clear-Host

$dir_arr = @($profit, $backup, $out)
Test_dir($dir_arr)

$oxa = Get-ChildItem -Path $profit "*.oxa"
Write-Host -ForegroundColor Cyan "Найдено $(($oxa | Measure-Object).count) файл(а)!"
Write-Host -ForegroundColor White $oxa

foreach ($f in $oxa){
	$newname = $f.FullName -replace "oxa","txt"
	Copy-Item $f -Destination $newname
}

Move-Item -Path "$profit\*.txt" -Destination $out
Write-Host -ForegroundColor Cyan "Файл(ы) перенесен(ы) в $out"

Move-Item -Path "$profit\*.oxa" -Destination $backup
Write-Host -ForegroundColor Cyan "Файл(ы) перенесен(ы) в архив $backup"

Write-Host -ForegroundColor Green "Отправляем письмо!"

$days = @()
$year1 = (Get-Date).year
foreach ($d1 in $oxa){
	$d = $d1.Name
	$day1 = $d.Substring(6, 2)	
	$mon1 = $d.Substring(4, 2)
	$days += -join($day1, ".", $mon1, ".", $year1)
}
$dt1 = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
$encoding = [System.Text.Encoding]::UTF8
$text1 = "Баланс успешно отправлен!"
$text1 = -join ($text1, $days | Out-String)
Send-MailMessage -To $email -Body $text1 -Encoding $encoding -From "robot_bal@tmn.apkbank.apk" -Subject "Баланс успешно отправлен! - $dt1" -SmtpServer 191.168.6.50
