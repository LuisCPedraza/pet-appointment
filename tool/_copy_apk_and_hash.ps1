$file = 'build\\app\\outputs\\flutter-apk\\app-release.apk'
if (Test-Path $file) {
  $it = Get-Item $file
  Write-Output 'SOURCE:'
  $it | Select-Object FullName,@{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}},LastWriteTime
  Write-Output 'SHA256:'
  Get-FileHash $file -Algorithm SHA256 | Format-List
  New-Item -ItemType Directory -Force 'docs\\entrega_final\\artefacts' | Out-Null
  Copy-Item -Force $file 'docs\\entrega_final\\artefacts\\app-release.apk'
  $it2 = Get-Item 'docs\\entrega_final\\artefacts\\app-release.apk'
  Write-Output 'COPIED:'
  $it2 | Select-Object FullName,@{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}},LastWriteTime
  Get-FileHash 'docs\\entrega_final\\artefacts\\app-release.apk' -Algorithm SHA256 | Format-List
} else {
  Write-Error 'APK not found'
}
