# Juego de Ordenar Vinos

Un juego interactivo de arrastrar y soltar para ordenar vinos. Optimizado para dispositivos móviles.

## Características

- Interfaz de arrastrar y soltar (drag & drop) optimizada para móviles
- Verificación del orden correcto
- Efectos visuales: confeti al ganar, emojis al perder
- Diseño responsive
- Funcionalidad para reiniciar el juego

## Demo

Puedes ver el juego funcionando [aquí](https://vfernandezmeca.github.io/rate-wines/).

## Tecnologías utilizadas

- Vue 3
- TypeScript
- Vuedraggable (basado en Sortable.js)
- Canvas Confetti para efectos visuales
- SCSS para estilos
- Font Awesome para iconos

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/vfernandezmeca/rate-wines.git
cd rate-wines

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev

# Compilar para producción
npm run build
```

## Despliegue en GitHub Pages

Este proyecto está configurado para ser desplegado fácilmente en GitHub Pages.

### Método 1: Usando el script de despliegue

1. Ejecuta el comando:
```bash
npm run deploy
```

### Método 2: Usando el script deploy.sh

1. Haz el script ejecutable (solo en sistemas Unix/Linux/Mac):
```bash
chmod +x deploy.sh
```
2. Ejecuta el script:
```bash
./deploy.sh
```

### Método manual

1. Compila el proyecto:
```bash
npm run build
```
2. Navega al directorio de compilación:
```bash
cd dist
```
3. Inicializa un repositorio Git y sube los archivos a la rama gh-pages:
```bash
git init
touch .nojekyll
git add -A
git commit -m 'deploy'
git push -f https://github.com/vfernandezmeca/rate-wines.git main:gh-pages
```

## Cómo jugar

1. Los vinos aparecen en orden aleatorio
2. Arrastra los elementos usando el icono de agarre a la izquierda
3. Ordénalos en la secuencia correcta
4. Haz clic en "Comprobar Orden" para verificar si es correcto
5. Si aciertas, verás una explosión de confeti
6. Si fallas, verás emojis de mierda cayendo
7. Puedes reiniciar el juego en cualquier momento

## Uso en dispositivos móviles

Para jugar en dispositivos móviles, simplemente accede a la URL del juego desde tu navegador móvil. La interfaz está optimizada para tocar y arrastrar en pantallas táctiles.
