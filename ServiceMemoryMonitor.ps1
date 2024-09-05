$serviceName = "FatihService"  # Servis adı
$processName = "FatihProcess"  # İşlem adı
$memoryLimitMB = 20000 # Bellek limiti MB cinsinden
$logFilePath = "C:\Logs\log-fatih.txt" # Log dosyasının yolu
$checkInterval = 60 # Kontrol aralığı (saniye)

# Log dosyasını oluşturup başlat
if (-not (Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File -Force | Out-Null
}
Add-Content -Path $logFilePath -Value "$(Get-Date) - Script started"

while ($true) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Running') {
            $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($processes) {
                foreach ($process in $processes) {
                    $memoryUsageMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
                    if ($memoryUsageMB -gt $memoryLimitMB) {
                        Add-Content -Path $logFilePath -Value "$(Get-Date) - $processName bellek kullanımının $memoryUsageMB MB olduğu tespit edildi. Servis yeniden başlatılıyor."
                        Restart-Service -Name $serviceName -Force
                        Add-Content -Path $logFilePath -Value "$(Get-Date) - $serviceName servisi yeniden başlatıldı."
                    } 
                }
            } else {
                Add-Content -Path $logFilePath -Value "$(Get-Date) - $processName işlemi bulunamadı."
            }
        } else {
            Add-Content -Path $logFilePath -Value "$(Get-Date) - $serviceName servisi çalışmıyor."
        }
    } catch {
        Add-Content -Path $logFilePath -Value "$(Get-Date) - Hata: $_"
    }

    Start-Sleep -Seconds $checkInterval
}
