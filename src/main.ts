import { createApp } from 'vue'
import './style.css'
import App from './App.vue'

// Crear la aplicación
const app = createApp(App)

// Montar la aplicación
app.mount('#app')

// Manejo de errores global
app.config.errorHandler = (err, _instance, info) => {
  console.error('Error en la aplicación:', err)
  console.error('Información adicional:', info)
}
