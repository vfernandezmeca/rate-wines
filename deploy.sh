#!/usr/bin/env sh

# Abortar en caso de errores
set -e

# Compilar
echo "Compilando la aplicación..."
npm run build

# Navegar al directorio de compilación
cd dist

# Si estás desplegando a un dominio personalizado
# echo 'www.ejemplo.com' > CNAME

# Crear archivo .nojekyll para evitar procesamiento Jekyll
echo "Creando archivo .nojekyll..."
touch .nojekyll

# Asegurarse de que los archivos de configuración están presentes
echo "Copiando archivos de configuración adicionales..."
cp -f ../public/_headers ./_headers
cp -f ../public/.htaccess ./.htaccess

# Inicializar repositorio si no existe
if [ -d ".git" ]; then
  echo "Repositorio Git ya inicializado"
else
  echo "Inicializando repositorio Git..."
  git init
  git checkout -b main
fi

# Añadir cambios al área de preparación
echo "Preparando cambios para commit..."
git add -A

# Hacer commit con mensaje
echo "Creando commit..."
git commit -m 'Deploy'

# Desplegar a GitHub Pages
echo "Desplegando a GitHub Pages..."
git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages

cd -

echo "¡Despliegue completado exitosamente!" 