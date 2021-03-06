$dir1 = Split-Path -Path $myInvocation.MyCommand.Path -Parent

$work_dir = "c:\WORK"
$arch_dir = "\\tmn-ts-01\311p\Arhive"
$ptk_path = "l:\PTK PSD\Post\Post"
$mask = "BN06962*.arj"
$email = "tmn-f311@tmn.apkbank.apk"

Clear-Host
Set-Location $work_dir

$file2 = Get-ChildItem $mask
Write-Host $file2.name -ForegroundColor Blue

$AllArgs = @('l', $file2)
$var1 = &"$dir1\arj32.exe" $AllArgs 
$var1 = $var1 | Select-Object -Last 1

$regex = "(?<=\ ).*(?=\ files)"
$match = [regex]::Match($var1, $regex)
if ($match.Success){
	$kol = [int]$match.Value
}

$date1 = Get-Date -UFormat "%d%m%Y"
$d_arch_path = -join ($arch_dir, "\", $date1)

if (!(Test-Path($d_arch_path))){
    New-Item -type directory -path $d_arch_path > $null
}

$f1 = ""

$f_count = @(Get-ChildItem "$d_arch_path\$mask")    
if ($f_count.Length -ne 0){
    $num1 = $f_count.Length + 1
    $num1_s = [String]"{0:0000}" -f $num1
	$date2 = Get-Date -UFormat "%y%m%d"
    $f1 = $file2.name -replace "(?<=BN06962$date2).*(?=\.ARJ)", $num1_s
    Rename-Item -Path $file2.Name -NewName $f1
}

if ($f1 -ne ""){
    Write-Host "Переименован в $f1" -ForegroundColor Green
}

Copy-Item $mask -destination $ptk_path
Write-Host "Скопирован в $ptk_path" -ForegroundColor Green

Move-Item "*.arj" -destination $d_arch_path
Write-Host "Перемещён в архив $d_arch_path" -ForegroundColor Green

$body1 = "Отправлено $kol файлов"
$encoding = [System.Text.Encoding]::UTF8
Send-MailMessage -To $email -Body $body1 -Encoding $encoding -From "robot311@tmn.apkbank.apk" -Subject "Отправка в ИФНС $date1" -SmtpServer 191.168.6.50