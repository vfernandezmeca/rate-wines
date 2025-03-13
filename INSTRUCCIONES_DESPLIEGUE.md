# Instrucciones para solucionar la página en blanco en GitHub Pages

Estás experimentando un problema común cuando se despliega una aplicación Vue/Vite en GitHub Pages. Los errores 404 indican que los recursos como `main.ts` y `vite.svg` no se están cargando correctamente debido a problemas con las rutas.

## Pasos para solucionar el problema:

### 1. Construye la aplicación con las correcciones realizadas

```powershell
# Asegúrate de estar en el directorio raíz del proyecto
cd C:\Dev\rate-vinos

# Construir el proyecto
npm run build
```

### 2. Prepara los archivos para GitHub Pages

```powershell
# Navega a la carpeta dist
cd dist

# Crea un archivo .nojekyll para evitar el procesamiento de Jekyll
New-Item -Path . -Name ".nojekyll" -ItemType "file" -Force

# Inicializa un repositorio Git
git init

# Añade todos los archivos
git add -A

# Haz un commit
git commit -m "deploy"

# Push a la rama gh-pages
git push -f https://github.com/vfernandezmeca/rate-wines.git master:gh-pages
# O si usas main como rama principal:
# git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages
```

### 3. Actualiza la configuración de GitHub Pages

1. Ve a tu repositorio en GitHub: https://github.com/vfernandezmeca/rate-wines
2. Ve a Settings (Configuración) > Pages
3. Asegúrate de que la fuente sea "gh-pages" 
4. Espera unos minutos a que se actualice el sitio

## Si persiste el problema, prueba estas soluciones adicionales:

### Solución 1: Crea un archivo `vue.config.js` en la raíz (para proyectos Vue CLI)

```javascript
module.exports = {
  publicPath: process.env.NODE_ENV === 'production' 
    ? '/rate-wines/' 
    : '/'
}
```

### Solución 2: Actualiza las rutas de recursos en `index.html`

Modifica las rutas en `index.html` para que usen rutas relativas en lugar de absolutas:

```html
<!-- En lugar de href="/assets/..." -->
<link href="./assets/..." />

<!-- En lugar de src="/assets/..." -->
<script src="./assets/..." />
```

### Solución 3: Usa unpkg como CDN alternativo

Si ninguna solución funciona, considera empaquetar la aplicación y subirla a unpkg o jsdelivr como CDN:

```html
<script src="https://unpkg.com/tu-paquete@version/dist/tu-paquete.js"></script>
```

## Enlaces útiles:

- [Guía oficial de despliegue en Vite](https://vitejs.dev/guide/static-deploy.html#github-pages)
- [GitHub Pages con Vue](https://cli.vuejs.org/guide/deployment.html#github-pages)
- [Solución a problemas de rutas en GitHub Pages](https://stackoverflow.com/questions/58886293/how-to-fix-the-blank-page-on-github-pages-using-vue-cli) 