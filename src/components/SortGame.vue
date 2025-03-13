<template>
  <div class="sort-game">
    <h1>Ordena de mejor a peor</h1>
    <p class="instructions">Arrastra los elementos para ordenarlos correctamente</p>
    
    <div class="game-container">
      <draggable 
        v-model="items" 
        class="list-group" 
        item-key="id"
        :options="{
          animation: 150,
          delay: 50,
          delayOnTouchOnly: true,
          touchStartThreshold: 5,
          forceFallback: true
        }"
        @end="onDragEnd"
        handle=".handle"
      >
        <template #item="{ element }">
          <div class="list-group-item">
            <div class="handle">
              <i class="fas fa-grip-lines"></i>
            </div>
            <div class="item-image">
              <img :src="element.img" :alt="element.text">
            </div>
            <div class="item-content">
              {{ element.text }}
            </div>
          </div>
        </template>
      </draggable>
    </div>
    
    <div class="actions">
      <button class="check-button" @click="checkOrder">Comprobar</button>
      <button class="reset-button" @click="resetOrder">Reiniciar</button>
    </div>
    
    <div v-if="resultMessage" class="result" :class="{ 'success': isCorrect, 'error': !isCorrect }">
      {{ resultMessage }}
    </div>
    
    <!-- Contenedor para los emojis de mierda -->
    <div class="poop-container" ref="poopContainer">
      <div v-for="(poop, index) in poopEmojis" :key="index" 
           class="poop-emoji" 
           :style="{ left: poop.left + 'px', animationDuration: poop.duration + 's' }">
        💩
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import draggable from 'vuedraggable'
import confetti from 'canvas-confetti'

interface Item {
  id: number
  text: string
  correctPosition: number
  img: string
}

const originalItems = [
  { id: 1, text: 'VINO ALABA BLANCO', correctPosition: 1, img: 'https://a0.soysuper.com/4934fd0efcb3e6b953fa1434574a62a9.1500.0.0.0.wmark.0ae9bf8b.jpg'},
  { id: 2, text: 'VINO FOUR LINES', correctPosition: 2, img: 'https://sgfm.elcorteingles.es/SGFM/dctm/MEDIA03/201610/25/00118766301529____2__600x600.jpg' },
  { id: 3, text: 'VINO LEGARIS BLANCO', correctPosition: 3, img: 'https://www.bodeboca.com/sites/default/files/wines/2024-05/bot-legaris-suavignon-blanc-2019_0_0.jpg' },
  { id: 4, text: 'VINO CUNE AFRUTADO', correctPosition: 4, img: 'https://solowine.es/wp-content/uploads/2023/12/Cune-Afrutado-rioja-1-thumbnail-2000x2000-80.jpg' },
  { id: 5, text: 'VINO BACH SEMIDULCE', correctPosition: 5, img: 'https://vinopremier.com/media/catalog/product/cache/070e1948fa79794c1092c01c58a07334/1/5/1544730970.jpeg'},
  { id: 6, text: 'VINO BOCA BLANCO', correctPosition: 6, img: 'https://a0.soysuper.com/1669c8b5facc3bdf75373e324e81ebcb.1500.0.0.0.wmark.31316d64.jpg' }
]

// Mezclar los elementos para el inicio del juego
const shuffleArray = (array: Item[]) => {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

const items = ref<Item[]>([])
const resultMessage = ref('')
const isCorrect = ref(false)
const poopEmojis = ref<{ left: number; duration: number }[]>([])
const poopContainer = ref<HTMLElement | null>(null)

onMounted(() => {
  // Mezclar los elementos al montar el componente
  items.value = shuffleArray(originalItems)
})

// Función para lanzar confeti cuando el usuario gana
const fireConfetti = () => {
  const duration = 3 * 1000
  const animationEnd = Date.now() + duration
  const defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 0 }

  const randomInRange = (min: number, max: number) => {
    return Math.random() * (max - min) + min
  }

  const interval = setInterval(() => {
    const timeLeft = animationEnd - Date.now()

    if (timeLeft <= 0) {
      return clearInterval(interval)
    }

    const particleCount = 50 * (timeLeft / duration)
    
    // Lanzar confeti desde diferentes ángulos
    confetti({
      ...defaults,
      particleCount,
      origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 }
    })
    confetti({
      ...defaults,
      particleCount,
      origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 }
    })
  }, 250)
}

// Función para mostrar emojis de mierda cuando el usuario pierde
const showPoopEmojis = () => {
  // Limpiar cualquier emoji previo
  poopEmojis.value = []
  
  // Crear nuevos emojis
  const containerWidth = poopContainer.value?.offsetWidth || 600
  const numberOfEmojis = 15
  
  for (let i = 0; i < numberOfEmojis; i++) {
    poopEmojis.value.push({
      left: Math.random() * containerWidth,
      duration: 2 + Math.random() * 3
    })
  }
}

const checkOrder = () => {
  const correctOrder = items.value.every((item, index) => item.correctPosition === index + 1)
  
  if (correctOrder) {
    resultMessage.value = '¡Correcto! Has ordenado todos los elementos correctamente.'
    isCorrect.value = true
    // Lanzar confeti
    fireConfetti()
  } else {
    resultMessage.value = 'Incorrecto. Intenta ordenarlos nuevamente.'
    isCorrect.value = false
    // Mostrar emojis de mierda
    showPoopEmojis()
  }
}

const resetOrder = () => {
  items.value = shuffleArray(originalItems)
  resultMessage.value = ''
  // Limpiar emojis
  poopEmojis.value = []
}

const onDragEnd = () => {
  resultMessage.value = ''
  // Limpiar emojis
  poopEmojis.value = []
}
</script>

<style lang="scss" scoped>
.sort-game {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
  position: relative; // Para posicionamiento absoluto de emojis y confeti

  h1 {
    text-align: center;
    color: #333;
    margin-bottom: 20px;
  }

  .instructions {
    margin-bottom: 20px;
    color: #666;
    text-align: center;
  }

  .game-container {
    margin-bottom: 20px;
  }

  .list-group-item {
    display: flex;
    align-items: center;
    padding: 15px;
    margin-bottom: 10px;
    background-color: #f9f9f9;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    border-left: 5px solid #007bff;
    touch-action: none; 
    user-select: none; 

    .handle {
      margin-right: 15px;
      color: #aaa;
      cursor: grab;
      padding: 10px;
      display: flex;
      align-items: center;
      justify-content: center;

      i {
        font-size: 16px;
      }
    }

    .item-image {
      width: 60px;
      height: 60px;
      margin-right: 15px;
      border-radius: 5px;
      overflow: hidden;
      flex-shrink: 0;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }

    .item-content {
      flex-grow: 1;
      font-size: 16px;
      color: #333;
    }
  }

  .actions {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;

    button {
      padding: 12px 20px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-weight: bold;
      transition: background-color 0.3s;
      font-size: 16px;
    }
  }

  .check-button {
    background-color: #4CAF50;
    color: white;

    &:hover {
      background-color: #3e8e41;
    }
  }

  .reset-button {
    background-color: #f44336;
    color: white;

    &:hover {
      background-color: #d32f2f;
    }
  }

  .result {
    padding: 15px;
    border-radius: 5px;
    text-align: center;
    margin-top: 20px;
    font-weight: bold;

    &.success {
      background-color: #dff0d8;
      color: #3c763d;
    }

    &.error {
      background-color: #f2dede;
      color: #a94442;
    }
  }
  
  // Estilos para los emojis de mierda
  .poop-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none; // Para que no interfieran con los clicks
    overflow: hidden;
    z-index: 10;
    
    .poop-emoji {
      position: absolute;
      top: -50px;
      font-size: 30px;
      animation: fall linear forwards;
      z-index: 100;
    }
  }
}

// Animación para la caída de emojis
@keyframes fall {
  0% {
    transform: translateY(-20px) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  100% {
    transform: translateY(800px) rotate(360deg);
    opacity: 0;
  }
}

/* Estilos específicos para móviles */
@media (max-width: 600px) {
  .sort-game {
    padding: 15px;

    h1 {
      font-size: 24px;
    }
    
    .list-group-item {
      padding: 12px;

      .item-image {
        width: 50px;
        height: 50px;
        margin-right: 10px;
      }

      .item-content {
        font-size: 14px;
      }
    }
    
    .actions {
      flex-direction: column;

      button {
        padding: 15px;
        width: 100%;
      }
    }
    
    .handle {
      padding: 10px;

      i {
        font-size: 20px;
      }
    }
    
    .poop-emoji {
      font-size: 24px;
    }
  }
}
</style> 