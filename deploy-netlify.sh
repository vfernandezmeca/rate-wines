#!/usr/bin/env sh

# Abortar en caso de errores
set -e

# Configurar variable de entorno para Netlify
export NETLIFY=true

# Compilar con la configuración correcta para Netlify
echo "Compilando la aplicación para Netlify..."
npm run build

# Si tienes Netlify CLI instalado, puedes desplegar directamente
if command -v netlify &> /dev/null; then
  echo "Desplegando a Netlify..."
  netlify deploy --prod
else
  echo "Para desplegar automáticamente, instala Netlify CLI:"
  echo "npm install -g netlify-cli"
  echo "O despliega manualmente subiendo la carpeta 'dist' desde el panel de control de Netlify."
fi

echo "¡Proceso completado!" 