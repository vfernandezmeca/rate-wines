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
          animation: 300,
          delay: 20,
          delayOnTouchOnly: true,
          touchStartThreshold: 3,
          forceFallback: true,
          ghostClass: 'ghost-item',
          chosenClass: 'chosen-item',
          dragClass: 'drag-item',
          scrollSensitivity: 30,
          preventDefaultOnDrag: true,
          lockAxis: 'y',
          lockToContainerEdges: true,
          fallbackOnBody: false,
          scroll: false
        }"
        @start="onDragStart"
        @end="onDragEnd"
        @change="onChange"
      >
        <template #item="{ element, index }">
          <div 
            class="list-group-item" 
            :class="{ 'dragging': element.id === draggingId }"
            @mouseenter="hoverIndex = index"
            @mouseleave="hoverIndex = -1"
          >
            <div class="item-image">
              <img :src="element.img" :alt="element.text">
            </div>
            <div class="item-content">
              {{ element.text }}
            </div>
            <div class="item-position" :class="{ 'visible': true }">
              {{ index + 1 }}
            </div>
          </div>
        </template>
      </draggable>
    </div>
    
    <div class="actions">
      <button class="check-button" @click="checkOrder">Comprobar</button>
      <button class="reset-button" @click="resetOrder">Reiniciar</button>
      <button class="solution-button" @click="showSolution" v-if="resultMessage && !isCorrect">Ver solución</button>
      <router-link to="/" class="back-button">Volver a las Cartas</router-link>
    </div>
    
    <div v-if="resultMessage" class="result" :class="{ 'success': isCorrect, 'error': !isCorrect }">
      {{ resultMessage }}
    </div>
    
    <!-- Contenedor para los emojis decorativos -->
    <div class="poop-container" ref="poopContainer">
      <div v-for="(poop, index) in poopEmojis" :key="index" 
           class="poop-emoji" 
           :style="{ left: poop.left + 'px', animationDuration: poop.duration + 's' }">
        {{ isCorrect ? '🌟' : '💩' }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import draggable from 'vuedraggable'
import confetti from 'canvas-confetti'

interface Item {
  id: number
  text: string
  correctPosition: number
  img: string
}

const originalItems = [
  { id: 1, text: '✨ VINO ALABA BLANCO ✨', correctPosition: 1, img: 'https://a0.soysuper.com/4934fd0efcb3e6b953fa1434574a62a9.1500.0.0.0.wmark.0ae9bf8b.jpg'},
  { id: 2, text: '🌟 VINO FOUR LINES 🌟', correctPosition: 2, img: 'https://sgfm.elcorteingles.es/SGFM/dctm/MEDIA03/201610/25/00118766301529____2__600x600.jpg' },
  { id: 3, text: '🥂 VINO LEGARIS BLANCO 🥂', correctPosition: 3, img: 'https://www.bodeboca.com/sites/default/files/wines/2024-05/bot-legaris-suavignon-blanc-2019_0_0.jpg' },
  { id: 4, text: '🍇 VINO CUNE AFRUTADO 🍇', correctPosition: 4, img: 'https://solowine.es/wp-content/uploads/2023/12/Cune-Afrutado-rioja-1-thumbnail-2000x2000-80.jpg' },
  { id: 5, text: '🍷 VINO BACH SEMIDULCE 🍷', correctPosition: 5, img: 'https://vinopremier.com/media/catalog/product/cache/070e1948fa79794c1092c01c58a07334/1/5/1544730970.jpeg'},
  { id: 6, text: '💖 VINO BOCA BLANCO 💖', correctPosition: 6, img: 'https://a0.soysuper.com/1669c8b5facc3bdf75373e324e81ebcb.1500.0.0.0.wmark.31316d64.jpg' }
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
const draggingId = ref<number | null>(null)
const hoverIndex = ref<number>(-1)
const currentPosition = ref<number>(0)

// Función para manejar el inicio del arrastre
const onDragStart = (e: any) => {
  draggingId.value = e.item.__draggable_context.element.id
  currentPosition.value = e.oldIndex
  
  // Optimización para dispositivos móviles
  if ('ontouchstart' in window) {
    // Ajustar la posición del elemento arrastrado para móviles
    const dragElement = document.querySelector('.sortable-drag') as HTMLElement;
    if (dragElement) {
      // Mejorar la posición para que se sienta más natural bajo el dedo
      dragElement.style.transform = 'translate3d(0px, 0px, 0px)';
      dragElement.style.transition = 'transform 0.05s';
      dragElement.style.willChange = 'transform';
      dragElement.style.zIndex = '1000';
    }
  }
  
  // Efecto de sonido al empezar a arrastrar
  playSound('pickup')
  
  // Añadir vibración
  if (window.navigator && window.navigator.vibrate) {
    window.navigator.vibrate(50)
  }
  
  // Limpiar mensajes anteriores
  resultMessage.value = ''
}

// Función para manejar cambios durante el arrastre
const onChange = (e: any) => {
  if (e.moved) {
    currentPosition.value = e.moved.newIndex
    
    // Añadir feedback sutil cuando se mueve entre posiciones
    if (window.navigator && window.navigator.vibrate) {
      window.navigator.vibrate(20)
    }
    
    // Actualizar las posiciones visualmente
    setTimeout(() => {
      const items = document.querySelectorAll('.list-group-item');
      items.forEach((item, idx) => {
        const position = item.querySelector('.item-position');
        if (position) {
          position.textContent = (idx + 1).toString();
        }
      });
    }, 50);
  }
}

// Prevenir scroll horizontal durante el arrastre
const preventHorizontalScroll = (e: Event) => {
  if (draggingId.value !== null) {
    e.preventDefault();
  }
}

// Añadir evento para prevenir scroll
onMounted(() => {
  // Mezclar los elementos al montar el componente
  items.value = shuffleArray(originalItems)
  
  // Crear sparkles decorativos
  const sparklesContainer = document.createElement('div')
  sparklesContainer.className = 'sparkles'
  
  for (let i = 0; i < 20; i++) {
    const sparkle = document.createElement('div')
    sparkle.className = 'sparkle'
    sparkle.style.left = `${Math.random() * 100}%`
    sparkle.style.top = `${Math.random() * 100}%`
    sparkle.style.transform = `scale(${0.5 + Math.random() * 0.5})`
    sparklesContainer.appendChild(sparkle)
  }
  
  document.querySelector('.sort-game')?.appendChild(sparklesContainer)
  
  // Prevenir scroll horizontal
  document.addEventListener('touchmove', preventHorizontalScroll, { passive: false });
  document.addEventListener('wheel', preventHorizontalScroll, { passive: false });
})

// Limpiar eventos al desmontar
onUnmounted(() => {
  document.removeEventListener('touchmove', preventHorizontalScroll);
  document.removeEventListener('wheel', preventHorizontalScroll);
})

// Función para reproducir un efecto de sonido
const playSound = (type: 'pickup' | 'drop' | 'correct' | 'error') => {
  // Solo intentar reproducir sonido si el contexto de audio está disponible
  try {
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()
    
    // Configurar el tipo de sonido según la acción
    switch (type) {
      case 'pickup':
        // Sonido agudo y corto
        oscillator.type = 'sine'
        oscillator.frequency.setValueAtTime(600, audioContext.currentTime)
        oscillator.frequency.exponentialRampToValueAtTime(900, audioContext.currentTime + 0.1)
        gainNode.gain.setValueAtTime(0.1, audioContext.currentTime)
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2)
        oscillator.connect(gainNode)
        gainNode.connect(audioContext.destination)
        oscillator.start()
        oscillator.stop(audioContext.currentTime + 0.2)
        break
        
      case 'drop':
        // Sonido más grave al soltar
        oscillator.type = 'sine'
        oscillator.frequency.setValueAtTime(800, audioContext.currentTime)
        oscillator.frequency.exponentialRampToValueAtTime(400, audioContext.currentTime + 0.15)
        gainNode.gain.setValueAtTime(0.1, audioContext.currentTime)
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3)
        oscillator.connect(gainNode)
        gainNode.connect(audioContext.destination)
        oscillator.start()
        oscillator.stop(audioContext.currentTime + 0.3)
        break
        
      case 'correct':
        // Sonido alegre para respuesta correcta
        oscillator.type = 'sine'
        oscillator.frequency.setValueAtTime(500, audioContext.currentTime)
        oscillator.frequency.exponentialRampToValueAtTime(800, audioContext.currentTime + 0.1)
        oscillator.frequency.exponentialRampToValueAtTime(1200, audioContext.currentTime + 0.2)
        gainNode.gain.setValueAtTime(0.1, audioContext.currentTime)
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.4)
        oscillator.connect(gainNode)
        gainNode.connect(audioContext.destination)
        oscillator.start()
        oscillator.stop(audioContext.currentTime + 0.4)
        break
        
      case 'error':
        // Sonido triste para error
        oscillator.type = 'sine'
        oscillator.frequency.setValueAtTime(400, audioContext.currentTime)
        oscillator.frequency.exponentialRampToValueAtTime(200, audioContext.currentTime + 0.2)
        gainNode.gain.setValueAtTime(0.1, audioContext.currentTime)
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3)
        oscillator.connect(gainNode)
        gainNode.connect(audioContext.destination)
        oscillator.start()
        oscillator.stop(audioContext.currentTime + 0.3)
        break
    }
  } catch (e) {
    // Si no se puede reproducir el sonido, simplemente ignoramos el error
    console.log('Audio no soportado')
  }
}

// Función para lanzar confeti cuando el usuario gana
const fireConfetti = () => {
  // Crear un efecto de confeti más cute con corazones y estrellas
  const count = 200
  const defaults = {
    origin: { y: 0.7 },
    zIndex: 9999
  }

  // Confeti normal de colores pastel
  confetti({
    ...defaults,
    particleCount: count * 0.25,
    colors: ['#ffb6c1', '#ffd1dc', '#f5c7f7', '#e0cffc', '#c5f9cc'],
    spread: 100,
  })

  // Confeti en forma de corazones (usando emoji como textos)
  setTimeout(() => {
    confetti({
      ...defaults,
      particleCount: count * 0.2,
      colors: ['#ff6ec4', '#ff8dce', '#e84393'],
      shapes: ['circle'],
      scalar: 2,
    })
  }, 500)

  // Efecto final con confeti más grande
  setTimeout(() => {
    confetti({
      ...defaults,
      particleCount: count * 0.35,
      angle: 120,
      spread: 120,
      origin: { x: 0 },
      colors: ['#ffb6c1', '#ffd1dc', '#ff8dce', '#ff6ec4'],
    })
    
    confetti({
      ...defaults,
      particleCount: count * 0.35,
      angle: 60,
      spread: 120,
      origin: { x: 1 },
      colors: ['#f5c7f7', '#e0cffc', '#ff8dce', '#ff6ec4'],
    })
  }, 1000)
}

// Modificar el emoji de mierda por algo más cute
const firePoopEmoji = () => {
  if (!poopContainer.value) return

  // Borrar los emojis existentes
  poopEmojis.value = []

  // Crear nuevos emojis
  const containerWidth = poopContainer.value.offsetWidth
  const numberOfEmojis = 30
  const newEmojis = []

  for (let i = 0; i < numberOfEmojis; i++) {
    newEmojis.push({
      left: Math.random() * containerWidth,
      duration: 3 + Math.random() * 4 // Duración entre 3 y 7 segundos
    })
  }

  poopEmojis.value = newEmojis
}

// Función para comprobar si el orden es correcto
const checkOrder = () => {
  let correctCount = 0;
  const totalCount = items.value.length;
  
  // Primero, resetear cualquier marcado anterior
  const listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(item => {
    item.classList.remove('item-correct', 'item-incorrect', 'solution-highlight');
  });
  
  // Comprobar cada elemento y marcar si está en la posición correcta
  for (let i = 0; i < items.value.length; i++) {
    if (items.value[i].correctPosition === i + 1) {
      correctCount++;
      listItems[i].classList.add('item-correct');
    } else {
      listItems[i].classList.add('item-incorrect');
    }
  }
  
  // Determinar si el orden completo es correcto
  const isOrderCorrect = correctCount === totalCount;
  
  if (isOrderCorrect) {
    isCorrect.value = true;
    resultMessage.value = '¡Muy bien! 🎉 ¡Has ordenado los vinos correctamente! 🥳 ¡Eres un/a experto/a en vinos! 💖';
    fireConfetti();
    playSound('correct');
  } else {
    isCorrect.value = false;
    resultMessage.value = `¡Has acertado ${correctCount} de ${totalCount} vinos! 🍷 ¡Sigue intentándolo! 💪🏻`;
    firePoopEmoji();
    playSound('error');
  }
}

// Función para reiniciar el orden
const resetOrder = () => {
  // Limpiar las marcas de correctas e incorrectas
  const listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(item => {
    item.classList.remove('item-correct', 'item-incorrect', 'solution-highlight');
  });
  
  items.value = shuffleArray(originalItems);
  resultMessage.value = '';
  isCorrect.value = false;
}

// Maneja el evento onDragEnd
const onDragEnd = () => {
  // Efecto de sonido al soltar
  playSound('drop')
  
  // Añadir vibración
  if (window.navigator && window.navigator.vibrate) {
    window.navigator.vibrate([30, 50, 30])
  }
  
  // Crear un pequeño efecto visual al soltar
  const sparkle = document.createElement('div')
  sparkle.className = 'drop-sparkle'
  document.body.appendChild(sparkle)
  
  setTimeout(() => {
    sparkle.remove()
  }, 500)
  
  // Resetear el id de arrastre
  draggingId.value = null
  resultMessage.value = ''
}

// Función para mostrar la solución correcta
const showSolution = () => {
  // Ordenamos los elementos según su posición correcta
  const sortedItems = [...originalItems].sort((a, b) => a.correctPosition - b.correctPosition);
  items.value = sortedItems;
  
  // Añadimos un mensaje indicando que esta es la solución correcta
  resultMessage.value = '✨ Esta es la solución correcta ✨';
  isCorrect.value = true;
  
  // Efecto visual para destacar la solución
  setTimeout(() => {
    const listItems = document.querySelectorAll('.list-group-item');
    listItems.forEach((item, index) => {
      setTimeout(() => {
        item.classList.add('solution-highlight');
        
        // Efecto de sonido suave al mostrar cada elemento
        try {
          const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
          const oscillator = audioContext.createOscillator();
          const gainNode = audioContext.createGain();
          
          oscillator.type = 'sine';
          oscillator.frequency.setValueAtTime(600 + (index * 50), audioContext.currentTime);
          gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
          gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
          
          oscillator.connect(gainNode);
          gainNode.connect(audioContext.destination);
          oscillator.start();
          oscillator.stop(audioContext.currentTime + 0.3);
        } catch (e) {
          // Ignorar errores de audio
        }
      }, index * 300);
    });
  }, 100);
}
</script>

<style lang="scss" scoped>
.sort-game {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  background-color: rgba(255, 255, 255, 0.8);
  border-radius: 25px;
  box-shadow: 0 10px 25px rgba(255, 105, 180, 0.3);
  position: relative;
  overflow: hidden;
}

.sort-game::before {
  content: "🌸";
  position: absolute;
  top: 10px;
  left: 10px;
  font-size: 1.5rem;
}

.sort-game::after {
  content: "🌸";
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 1.5rem;
}

h1 {
  color: #e84393;
  font-family: 'Comic Sans MS', 'Marker Felt', cursive;
  text-shadow: 2px 2px 4px rgba(255, 105, 180, 0.3);
  position: relative;
  margin-bottom: 2rem;
}

h1::before {
  content: "🍷";
  position: absolute;
  left: -40px;
  top: 5px;
}

h1::after {
  content: "🍷";
  position: absolute;
  right: -40px;
  top: 5px;
}

.instructions {
  color: #b15b88;
  font-size: 1.2rem;
  margin-bottom: 1.5rem;
  font-style: italic;
  position: relative;
  display: inline-block;
}

.instructions::before {
  content: "✨";
  margin-right: 10px;
}

.instructions::after {
  content: "✨";
  margin-left: 10px;
}

.game-container {
  margin: 2rem 0;
  background-color: rgba(255, 218, 233, 0.5);
  padding: 1.5rem;
  border-radius: 20px;
  border: 2px dashed #ffb6c1;
  overflow: hidden;
  position: relative;
}

.list-group {
  position: relative;
  width: 100%;
  overflow: visible;
}

.list-group-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  margin-bottom: 1rem;
  background-color: white;
  border-radius: 15px;
  box-shadow: 0 4px 8px rgba(255, 182, 193, 0.3);
  border: 2px solid #ffd1dc;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  position: relative;
  cursor: grab;
  will-change: transform, opacity;
  z-index: 1;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  touch-action: pan-y;
}

.list-group-item:hover {
  transform: translateY(-3px) scale(1.01);
  box-shadow: 0 8px 16px rgba(255, 182, 193, 0.4);
  border-color: #ff69b4;
}

.list-group-item.dragging {
  opacity: 0.9;
  transform: scale(1.03);
  box-shadow: 0 12px 20px rgba(255, 105, 180, 0.5);
  z-index: 10;
}

.ghost-item {
  opacity: 0.4;
  background-color: #ffecf2 !important;
  border: 2px dashed #ffb6c1 !important;
  max-width: 100%;
  box-sizing: border-box;
}

.chosen-item {
  transform: scale(1.02);
  box-shadow: 0 10px 20px rgba(255, 105, 180, 0.5);
  border-color: #ff69b4;
}

.drag-item {
  opacity: 0.8;
  background: linear-gradient(135deg, #fff5f9 0%, #ffecf2 100%);
}

.item-image {
  width: 60px;
  height: 60px;
  margin-right: 1rem;
  overflow: hidden;
  border-radius: 50%;
  border: 3px solid #ffc0cb;
  transition: all 0.3s;
}

.list-group-item:hover .item-image,
.list-group-item.dragging .item-image {
  border-color: #ff69b4;
  transform: scale(1.05);
}

.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: all 0.3s;
}

.list-group-item:hover .item-image img,
.list-group-item.dragging .item-image img {
  transform: scale(1.1);
}

.item-content {
  flex-grow: 1;
  color: #b15b88;
  font-weight: bold;
  font-family: 'Comic Sans MS', 'Marker Felt', cursive;
  transition: all 0.3s;
  padding: 0 10px;
}

.list-group-item:hover .item-content,
.list-group-item.dragging .item-content {
  color: #e84393;
}

.item-position {
  width: 30px;
  height: 30px;
  background-color: #ffb8e9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #9d2f70;
  font-weight: bold;
  opacity: 1;
  transition: opacity 0.3s, transform 0.3s, background-color 0.3s;
  transform: scale(1);
  margin-left: 10px;
  box-shadow: 0 3px 6px rgba(157, 47, 112, 0.2);
}

.item-position.visible {
  opacity: 1;
  transform: scale(1);
}

.actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-top: 2rem;
  flex-wrap: wrap;
}

.check-button {
  background-color: #ffb8e9;
  color: #9d2f70;
  border: 2px solid #ff69b4;
  padding: 0.7rem 1.5rem;
  font-size: 1.1rem;
  position: relative;
}

.check-button::before {
  content: "✓";
  margin-right: 5px;
}

.reset-button {
  background-color: #f5c7f7;
  color: #8e42a4;
  border: 2px solid #cf8de7;
  padding: 0.7rem 1.5rem;
  font-size: 1.1rem;
  position: relative;
}

.reset-button::before {
  content: "↺";
  margin-right: 5px;
}

.solution-button {
  background-color: #c5a3ff;
  color: #6a3093;
  border: 2px solid #8a5cdd;
  padding: 0.7rem 1.5rem;
  font-size: 1.1rem;
  position: relative;
  margin-top: 0.5rem;
}

.solution-button::before {
  content: "💡";
  margin-right: 5px;
}

.result {
  margin-top: 1.5rem;
  padding: 1rem;
  border-radius: 15px;
  font-weight: bold;
  animation: pulse 1.5s infinite;
  font-size: 1.2rem;
  text-align: center;
}

.success {
  background-color: rgba(205, 255, 216, 0.7);
  color: #2b9464;
  border: 2px solid #a3f9b9;
}

.error {
  background-color: rgba(255, 235, 238, 0.7);
  color: #e84393;
  border: 2px solid #ffc2cc;
}

.poop-container {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 100;
  overflow: hidden;
}

.poop-emoji {
  position: absolute;
  bottom: -50px;
  animation: fallAnimation linear forwards;
  font-size: 2rem;
}

.drop-sparkle {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 9999;
  background: radial-gradient(circle at center, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 255, 0) 70%);
  opacity: 0;
  animation: drop-effect 0.5s ease-out;
}

@keyframes drop-effect {
  0% {
    opacity: 0.7;
    transform: scale(0.1);
  }
  100% {
    opacity: 0;
    transform: scale(2);
  }
}

@keyframes fallAnimation {
  0% {
    transform: translateY(0) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    transform: translateY(-120vh) rotate(360deg);
    opacity: 0;
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

/* Decoraciones adicionales */
.sparkles {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: -1;
}

.sparkle {
  position: absolute;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23ffb6c1"><path d="M12 2l2.5 7.5H22l-6 4.5 2.5 7.5-6.5-5-6.5 5 2.5-7.5-6-4.5h7.5z"/></svg>');
  background-repeat: no-repeat;
  width: 20px;
  height: 20px;
  opacity: 0.6;
}

/* Añadimos un estilo global para evitar el scroll horizontal */
:deep(body), :deep(html) {
  overflow-x: hidden !important;
}

/* Ajustes para móviles */
@media (max-width: 768px) {
  .list-group-item {
    padding: 0.8rem;
  }
  
  .item-image {
    width: 50px;
    height: 50px;
  }
  
  .item-position {
    width: 25px;
    height: 25px;
    font-size: 0.9rem;
  }
}

/* Estilos específicos para Sortable */
:deep(.sortable-drag) {
  opacity: 0.9 !important;
  position: absolute !important;
  z-index: 1000 !important;
  pointer-events: none !important;
  touch-action: none !important;
  will-change: transform !important;
  transform: translate3d(0, 0, 0) !important;
  box-shadow: 0 10px 30px rgba(232, 67, 147, 0.6) !important;
  transition: transform 0.05s !important;
}

:deep(.sortable-ghost) {
  opacity: 0.3 !important;
  background-color: #ffecf2 !important;
  border: 2px dashed #ff69b4 !important;
}

:deep(.sortable-chosen) {
  background-color: #fff5f9 !important;
}

/* Animaciones de transición para cuando los elementos se reordenan */
.list-group-item {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

/* Mejora de la respuesta táctil */
@supports (-webkit-touch-callout: none) {
  /* Estilos específicos para iOS */
  .list-group-item {
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -webkit-tap-highlight-color: transparent;
  }
  
  :deep(.sortable-drag) {
    transform: translateY(-10px) !important;
  }
}

/* Ajustes para dispositivos táctiles */
@media (pointer: coarse) {
  .list-group-item {
    touch-action: none !important;
    margin-bottom: 1.2rem;
  }
  
  .sort-game, .game-container {
    touch-action: pan-y !important;
  }
}

/* Estilo para el resaltado de la solución */
.solution-highlight {
  animation: highlightSolution 1s ease;
  border-color: #ffa1d5;
  box-shadow: 0 0 15px rgba(255, 105, 180, 0.6);
}

@keyframes highlightSolution {
  0% {
    transform: scale(1);
    background-color: white;
  }
  50% {
    transform: scale(1.05);
    background-color: #fff0f7;
  }
  100% {
    transform: scale(1);
    background-color: white;
  }
}

/* Estilos específicos para Desktop */
@media (pointer: fine) {
  :deep(.sortable-drag) {
    display: flex !important;
    align-items: center !important;
    opacity: 0.9 !important;
    background-color: #fff5f9 !important;
    position: fixed !important; /* Cambiamos a fixed */
    will-change: transform;
    z-index: 1000 !important;
    box-shadow: 0 10px 30px rgba(232, 67, 147, 0.6) !important;
    width: 100% !important;
    max-width: 100% !important;
    border-radius: 15px !important;
    border: 2px solid #ff69b4 !important;
    box-sizing: border-box !important;
    pointer-events: none !important;
    margin-bottom: 0 !important;
  }
  
  :deep(.sortable-ghost) {
    height: 4rem !important;
    min-height: 4rem !important;
    background-color: rgba(255, 182, 193, 0.2) !important;
    border: 2px dashed #ff69b4 !important;
    margin: 0.5rem 0 !important;
  }
  
  :deep(.sortable-drag .item-image),
  :deep(.sortable-drag .item-content),
  :deep(.sortable-drag .item-position) {
    display: flex !important;
    opacity: 1 !important;
    visibility: visible !important;
  }
}

/* Estilos para elementos correctos e incorrectos */
.item-correct {
  border: 2px solid #4cd964 !important;
  background-color: rgba(205, 255, 216, 0.2) !important;
  animation: correctPulse 0.8s ease;
}

.item-correct::after {
  content: "✅";
  position: absolute;
  right: -10px;
  top: -10px;
  font-size: 1.5rem;
  animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.item-incorrect {
  border: 2px solid #ff3b30 !important;
  background-color: rgba(255, 235, 238, 0.2) !important;
  animation: incorrectShake 0.8s ease;
}

.item-incorrect::after {
  content: "❌";
  position: absolute;
  right: -10px;
  top: -10px;
  font-size: 1.5rem;
  animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes correctPulse {
  0% {
    transform: scale(1);
    box-shadow: 0 0 0 rgba(76, 217, 100, 0);
  }
  50% {
    transform: scale(1.03);
    box-shadow: 0 0 20px rgba(76, 217, 100, 0.5);
  }
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 rgba(76, 217, 100, 0);
  }
}

@keyframes incorrectShake {
  0%, 100% {
    transform: translateX(0);
  }
  10%, 30%, 50%, 70%, 90% {
    transform: translateX(-4px);
  }
  20%, 40%, 60%, 80% {
    transform: translateX(4px);
  }
}

@keyframes popIn {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.back-button {
  background-color: #e0cffc;
  color: #6a3093;
  border: 2px solid #8a5cdd;
  padding: 0.7rem 1.5rem;
  font-size: 1.1rem;
  position: relative;
  text-decoration: none;
  border-radius: 15px;
  display: inline-block;
  transition: all 0.3s;
  box-shadow: 0 4px 8px rgba(106, 48, 147, 0.2);
  margin-top: 0.5rem;
}

.back-button::before {
  content: "🔙";
  margin-right: 5px;
}

.back-button:hover {
  background-color: #d2b7ff;
  transform: translateY(-3px);
  box-shadow: 0 6px 12px rgba(106, 48, 147, 0.3);
}
</style> 