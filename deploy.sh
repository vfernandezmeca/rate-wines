#!/usr/bin/env sh

# Abortar en caso de errores
set -e

# Compilar
npm run build

# Navegar al directorio de compilación
cd dist

# Si estás desplegando a un dominio personalizado
# echo 'www.ejemplo.com' > CNAME

# Crear archivo .nojekyll para evitar procesamiento Jekyll
touch .nojekyll

# Inicializar repositorio si no existe
if [ -d ".git" ]; then
  echo "Repositorio Git ya inicializado"
else
  git init
  git checkout -b main
fi

# Añadir cambios al área de preparación
git add -A

# Hacer commit con mensaje
git commit -m 'Deploy'

# Desplegar a GitHub Pages
git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages

cd -

echo "Despliegue completado exitosamente!" 