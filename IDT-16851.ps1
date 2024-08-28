$directoryPath = "C:\Users\fatih\Pictures\Screenshots"
$logFilePath = "C:\Users\fatih\Pictures\Screenshots\delete_log.txt"
$thresholdDate = (Get-Date).AddDays(-8)

New-Item -Path $logFilePath -ItemType File -Force | Out-Null

function Write-Log {
    param (
        [string]$message
    )
    $message | Out-File -FilePath $logFilePath -Append
}

$items = Get-ChildItem -Path $directoryPath -Recurse -Force

foreach ($item in $items) {
    $lastWriteTime = $item.LastWriteTime

    if ($lastWriteTime -lt $thresholdDate) {
        try {
            Remove-Item -Path $item.FullName -Force -Recurse
            $message = "Silinen öğe: $($item.FullName)"
            Write-Host $message
            Write-Log $message
        } catch {
            $message = "Hata oluştu, öğe silinemedi: $($item.FullName) - Hata: $($_.Exception.Message)"
            Write-Host $message
            Write-Log $message
        }
    }
}

Write-Host "İşlem tamamlandı. Log dosyası: $logFilePath"
