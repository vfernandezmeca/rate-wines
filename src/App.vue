<script setup lang="ts">
// No necesitamos importar SortGame ya que ahora usamos enrutamiento
</script>

<template>
  <div class="app-container">
    <div class="decoration top-left">🍇</div>
    <div class="decoration top-right">🎀</div>
    <div class="decoration bottom-left">🍷</div>
    <div class="decoration bottom-right">🎀</div>
    
    <!-- Usar router-view en lugar de SortGame -->
    <router-view></router-view>
  </div>
</template>

<style lang="scss">
body {
  margin: 0;
  padding: 0;
  font-family: 'Comic Sans MS', 'Marker Felt', cursive;
  background-color: #fff5f9;
  background-image: url('https://www.transparenttextures.com/patterns/cubes.png');
  overflow-x: hidden;
}

.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, #fff5f9 0%, #ffecf2 100%);
  width: 100%;
  max-width: 100vw;
  box-sizing: border-box;
}

/* Elementos decorativos animados */
.decoration {
  position: fixed;
  font-size: 3rem;
  animation: float 6s ease-in-out infinite;
  z-index: -1;
}

.top-left {
  top: 5%;
  left: 5%;
  animation-delay: 0s;
  transform: rotate(-10deg);
}

.top-right {
  top: 5%;
  right: 5%;
  animation-delay: 1.5s;
  transform: rotate(10deg);
}

.bottom-left {
  bottom: 5%;
  left: 5%;
  animation-delay: 3s;
  transform: rotate(10deg);
}

.bottom-right {
  bottom: 5%;
  right: 5%;
  animation-delay: 4.5s;
  transform: rotate(-10deg);
}

@keyframes float {
  0% {
    transform: translateY(0) rotate(0);
  }
  50% {
    transform: translateY(-20px) rotate(5deg);
  }
  100% {
    transform: translateY(0) rotate(0);
  }
}

/* Añadir estrellas brillantes al fondo */
.app-container::before {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  background-image: radial-gradient(circle, #fff 1px, transparent 1px);
  background-size: 40px 40px;
  opacity: 0.4;
  z-index: -1;
}

/* Media query para dispositivos móviles */
@media (max-width: 768px) {
  .decoration {
    font-size: 2rem;
  }
  
  .top-left {
    top: 2%;
    left: 2%;
  }
  
  .top-right {
    top: 2%;
    right: 2%;
  }
  
  .bottom-left {
    bottom: 2%;
    left: 2%;
  }
  
  .bottom-right {
    bottom: 2%;
    right: 2%;
  }
}
</style>
