# Script de despliegue para Netlify usando PowerShell

# Abortar en caso de errores
$ErrorActionPreference = "Stop"

# Configurar variable de entorno para Netlify
$env:NETLIFY = "true"

Write-Host "Iniciando proceso de despliegue para Netlify..." -ForegroundColor Green

# Compilar con la configuración correcta para Netlify
Write-Host "Compilando la aplicación para Netlify..." -ForegroundColor Yellow
npm run build

# Verificar si Netlify CLI está instalado
$netlifyInstalled = $null
try {
    $netlifyInstalled = Get-Command netlify -ErrorAction SilentlyContinue
} catch {
    # Nada que hacer, simplemente seguimos
}

if ($netlifyInstalled) {
    Write-Host "Desplegando a Netlify..." -ForegroundColor Cyan
    netlify deploy --prod
} else {
    Write-Host "Para desplegar automáticamente, instala Netlify CLI:" -ForegroundColor Yellow
    Write-Host "npm install -g netlify-cli" -ForegroundColor Magenta
    Write-Host "O despliega manualmente subiendo la carpeta 'dist' desde el panel de control de Netlify." -ForegroundColor Yellow
}

Write-Host "¡Proceso completado!" -ForegroundColor Green 