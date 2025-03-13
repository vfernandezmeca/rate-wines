# Script de despliegue para GitHub Pages usando PowerShell

# Abortar en caso de errores
$ErrorActionPreference = "Stop"

Write-Host "Iniciando proceso de despliegue..."

# Compilar
Write-Host "Compilando la aplicación..."
npm run build

# Navegar al directorio de compilación
cd dist

# Crear archivo .nojekyll para evitar procesamiento Jekyll
Write-Host "Creando archivo .nojekyll..."
New-Item -ItemType File -Path ".nojekyll" -Force | Out-Null

# Asegurarse de que los archivos de configuración están presentes
Write-Host "Copiando archivos de configuración adicionales..."
Copy-Item -Path "../public/_headers" -Destination "./_headers" -Force
Copy-Item -Path "../public/.htaccess" -Destination "./.htaccess" -Force

# Inicializar repositorio si no existe
if (Test-Path ".git") {
    Write-Host "Repositorio Git ya inicializado"
} else {
    Write-Host "Inicializando repositorio Git..."
    git init
    git checkout -b main
}

# Añadir cambios al área de preparación
Write-Host "Preparando cambios para commit..."
git add -A

# Hacer commit con mensaje
Write-Host "Creando commit..."
git commit -m "Deploy"

# Desplegar a GitHub Pages
Write-Host "Desplegando a GitHub Pages..."
git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages

cd ..

Write-Host "¡Despliegue completado exitosamente!" -ForegroundColor Green

Write-Host "¡Despliegue completado! Tu aplicación estará disponible en:" -ForegroundColor Green
Write-Host "https://vfernandezmeca.github.io/rate-wines/" -ForegroundColor Magenta 