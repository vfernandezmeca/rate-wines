# Script de despliegue para GitHub Pages usando PowerShell

# Abortar en caso de errores
$ErrorActionPreference = "Stop"

Write-Host "Iniciando proceso de despliegue a GitHub Pages..." -ForegroundColor Green

# Compilar el proyecto
Write-Host "Compilando el proyecto..." -ForegroundColor Yellow
npm run build

# Navegar al directorio de compilación
Write-Host "Navegando al directorio de compilación..." -ForegroundColor Yellow
cd dist

# Crear archivo .nojekyll para evitar procesamiento Jekyll
Write-Host "Creando archivo .nojekyll..." -ForegroundColor Yellow
New-Item -Path . -Name ".nojekyll" -ItemType "file" -Force | Out-Null

# Inicializar repositorio Git
Write-Host "Inicializando repositorio Git..." -ForegroundColor Yellow
git init
git checkout -b main

# Añadir todos los archivos
Write-Host "Añadiendo archivos al repositorio..." -ForegroundColor Yellow
git add -A

# Hacer commit
Write-Host "Haciendo commit..." -ForegroundColor Yellow
git commit -m "deploy"

# Pushar a GitHub Pages
Write-Host "Desplegando a GitHub Pages..." -ForegroundColor Cyan
git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages

# Volver al directorio principal
cd ..

Write-Host "¡Despliegue completado! Tu aplicación estará disponible en:" -ForegroundColor Green
Write-Host "https://vfernandezmeca.github.io/rate-wines/" -ForegroundColor Magenta 