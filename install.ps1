# ApliArte Click Pro - Windows Remote Installer
# Downloads and extracts the latest version from GitHub

$ErrorActionPreference = "Stop"

# Configuration
$repoOwner = "erbolamm"
$repoName = "ApliArteClick"
$version = "v3.0.0"
$filename = "ApliArteClickPro-Windows-$version.zip"
$downloadUrl = "https://github.com/$repoOwner/$repoName/releases/download/$version/$filename"
$installDir = Join-Path $env:LOCALAPPDATA "ApliArteClick"
$tempDir = Join-Path $env:TEMP "ApliArteClickInstaller"

Write-Host "🚀 Instalador de ApliArte Click Pro para Windows" -ForegroundColor Cyan
Write-Host "============================================="

# Create directories
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir }
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir }

Write-Host "⬇️ Descargando versión $version..." -ForegroundColor Blue
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile (Join-Path $tempDir $filename)
    Write-Host "✅ Descarga completada." -ForegroundColor Green
}
catch {
    Write-Host "❌ Error al descargar. Verifica tu conexión o que la versión exista." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Descomprimiendo..." -ForegroundColor Blue
Expand-Archive -Path (Join-Path $tempDir $filename) -DestinationPath $installDir -Force

# Create Desktop Shortcut
Write-Host "🔗 Creando acceso directo en el escritorio..." -ForegroundColor Blue
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut([Join-Path ([Environment]::GetFolderPath("Desktop")) "ApliArte Clicker.lnk"])
$Shortcut.TargetPath = Join-Path $installDir "apliarte_click.exe"
$Shortcut.WorkingDirectory = $installDir
$Shortcut.Save()

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "🎉 ¡Instalación completada con éxito!" -ForegroundColor Green
Write-Host "ApliArte Click Pro se ha instalado en: $installDir"
Write-Host "Se ha creado un acceso directo en tu Escritorio."
Write-Host ""
Write-Host "👉 Abriendo la aplicación..." -ForegroundColor Blue
Start-Process -FilePath (Join-Path $installDir "apliarte_click.exe")
