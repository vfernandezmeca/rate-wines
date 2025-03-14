import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router' // Importar el router

// Crear la aplicación
const app = createApp(App)

// Usar el router
app.use(router)

// Montar la aplicación
app.mount('#app')

// Manejo de errores global
app.config.errorHandler = (err, _instance, info) => {
  console.error('Error en la aplicación:', err)
  console.error('Información adicional:', info)
}
