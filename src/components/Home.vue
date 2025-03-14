<template>
  <div class="cards-home">
    <h1>¡Feliz Cumpleaños, Paulina! 🎂</h1>
    <p class="subtitle">Toca las tarjetas para descubrir las sorpresas del día</p>
    
    <div class="time-banner">
      <div class="timer-container">
        <div class="timer-label">Próxima sorpresa</div>
        <div class="current-time">{{ nextCardCountdown }}</div>
      </div>
    </div>
    
    <div class="cards-container">
      <div 
        v-for="(card, index) in cardsToShow" 
        :key="index"
        class="card"
        :class="{
          'card-active': isCardUnlocked(card, getOriginalIndex(card)),
          'card-flipped': flippedCards[getOriginalIndex(card)],
          'card-locked': !isCardUnlocked(card, getOriginalIndex(card)),
          'card-unlocking': unlockingCard === index,
          'card-final': card.isFinalCard,
          'card-golden': card.hasGoldenCoupon
        }"
        @click="flipCard(index, $event)"
        @touchstart="handleTouchStart($event, index)"
        @touchmove="handleTouchMove($event)"
        @touchend="handleTouchEnd()"
        :style="{ 
          transform: `translateX(${getCardPosition(index) + dragOffset}px) rotate(${getCardRotation(index)}deg)`,
          transition: isDragging ? 'none' : 'all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)'
        }"
      >
        <div class="unlock-animation" v-if="unlockingCard === index">
          <div class="unlock-rays"></div>
          <div class="unlock-icon">🔓</div>
        </div>
        
        <div class="card-inner">
          <div class="card-front">
            <div class="card-decoration">
              <span v-if="isCardUnlocked(card, getOriginalIndex(card))">{{ card.icon }}</span>
              <span v-else class="lock-icon">🔒</span>
            </div>
            <div class="card-time">{{ formatCardTime(card.unlockTime) }}</div>
          </div>
          <div class="card-back">
            <div class="card-content" v-if="isCardUnlocked(card, getOriginalIndex(card))">
              <h3>{{ card.title }}</h3>
              <p>{{ card.message }}</p>
              <div class="card-emoji">{{ card.icon }}</div>
              <div v-if="card.isGame" class="card-game-button">
                <router-link to="/sort-game" class="play-button" @click.stop>
                  <span>¡Jugar!</span>
                  <span class="icon">🎮</span>
                </router-link>
              </div>
            </div>
            <div class="card-locked-content" v-else>
              <div class="big-lock-icon">🔒</div>
              <p>Esta sorpresa aún no está disponible</p>
              <div class="card-time-big">Disponible a las {{ formatCardTime(card.unlockTime) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Sección de tarjetas ya vistas -->
    <div v-if="viewedCards.length > 0" class="viewed-cards-section">
      <h2 class="viewed-title">Sorpresas descubiertas</h2>
      <div class="viewed-cards-container">
        <div 
          v-for="(card, index) in sortedViewedCards" 
          :key="'viewed-' + index"
          class="viewed-card card-flipped"
          :class="{ 'viewed-card-golden': card.hasGoldenCoupon }"
          @click="openViewedCard()"
        >
          <div class="card-inner">
            <div class="card-front">
              <div class="card-decoration">
                <span>{{ card.icon }}</span>
              </div>
            </div>
            <div class="card-back">
              <div class="card-content">
                <h3>{{ card.title }}</h3>
                <p>{{ card.message }}</p>
                <div class="card-emoji">{{ card.icon }}</div>
                <div v-if="card.isGame" class="card-game-button">
                  <router-link to="/sort-game" class="play-button" @click.stop>
                    <span>¡Jugar!</span>
                    <span class="icon">🎮</span>
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Decoración flotante -->
    <div class="floating-decorations">
      <div class="floating-item" style="top: 10%; left: 5%;">🎈</div>
      <div class="floating-item" style="top: 15%; right: 10%;">🎁</div>
      <div class="floating-item" style="bottom: 10%; left: 8%;">🎊</div>
      <div class="floating-item" style="bottom: 15%; right: 5%;">🎉</div>
    </div>
    
    <!-- Instrucciones -->
    <div class="instructions" v-if="unlockedCount < cards.length">
      {{ pendingCount > 0 ? 'Hay ' + pendingCount + ' sorpresas por descubrir hoy' : 'Todas las sorpresas han sido reveladas' }}
    </div>
    
    <!-- Botón para reiniciar -->
    <div v-if="viewedCards.length === cards.length" class="reset-button-container">
      <button @click="resetAppData" class="reset-button">
        <span class="reset-icon">🔄</span>
        <span>Reiniciar experiencia</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import confetti from 'canvas-confetti';

interface Card {
  title: string;
  message: string;
  icon: string;
  unlockTime: string; // formato "HH:MM"
  isGame?: boolean;
  manuallyUnlocked?: boolean; // Para controlar el desbloqueo manual
  viewed?: boolean; // Para saber si ya fue vista
  isFinalCard?: boolean; // Para la tarjeta del mensaje final
  hasGoldenCoupon?: boolean; // Para tarjetas con cupón dorado
}

// Definir las cartas con sus mensajes y horarios
const cards = ref<Card[]>([
  {
    title: "¡Comienza la aventura!",
    message: "¡Feliz cumpleaños, Paulina! Hoy comenzamos en el rocódromo. ¡Prepárate y trae una muda de ropa! Va a ser una actividad muy divertida.",
    icon: "🧗‍♀️",
    unlockTime: "08:00", // Se desbloquea desde las 8:00
    viewed: false
  },
  {
    title: "Hora de comer",
    message: "Vamos a McDonald's para disfrutar de una rica comida.",
    icon: "🍔",
    unlockTime: "08:10", // Se desbloquea a las 13:00
    viewed: false
  },
  {
    title: "¡Vámonos de compras!",
    message: "¡CUPÓN DORADO! 🎖️ Esta tarjeta es un cupón especial para que elijas cualquier producto que te guste en Sephora en tu día especial. ¡Regalo de cumpleaños!",
    icon: "🛍️",
    unlockTime: "08:11", // Se desbloquea a las 17:00
    viewed: false,
    hasGoldenCoupon: true
  },
  {
    title: "¡Dulce Japón!",
    message: "¡Parada en una tienda japonesa! Vamos a comprar chuches random para seguir con la diversión.",
    icon: "🍬",
    unlockTime: "08:12", // Se desbloquea a las 17:30
    viewed: false
  },
  {
    title: "¡Juega y diviértete!",
    message: "Para continuar con la celebración, un juego especial de vinos que hemos preparado para ti. ¡A ver qué tal se te da ordenarlos!",
    icon: "🍷",
    unlockTime: "08:13", // Se desbloquea a las 18:15
    isGame: true,
    viewed: false
  },
  {
    title: "¡Arte para recordar!",
    message: "Toca hacernos un retrato para inmortalizar este día tan especial. ¡Una obra de arte para un día inolvidable!",
    icon: "🖼️",
    unlockTime: "08:14", // Se desbloquea a las 19:00
    viewed: false
  },
  {
    title: "¡Momento de deseos!",
    message: "Ha llegado el momento de soplar las velas. ¡Pide un deseo muy especial en este día tan importante!",
    icon: "🎂",
    unlockTime: "08:15", // Se desbloquea a las 19:30
    viewed: false
  },
  {
    title: "¡Cena especial!",
    message: "Para terminar este día maravilloso, vamos a disfrutar de una deliciosa cena de sushi. ¡El broche perfecto para tu cumpleaños!",
    icon: "🍣",
    unlockTime: "08:16", // Se desbloquea a las 20:00
    viewed: false
  }
]);

// Estado para controlar qué cartas están volteadas
const flippedCards = ref<boolean[]>(Array(cards.value.length).fill(false));
const currentTime = ref(new Date());
const clockInterval = ref<number | null>(null);
const manuallyUnlockedCards = ref<boolean[]>(Array(cards.value.length).fill(false));
const unlockingCard = ref<number | null>(null); // Controla qué carta está siendo desbloqueada
const viewedCards = ref<Card[]>([]);

// Variables para el arrastre táctil
const isDragging = ref(false);
const dragOffset = ref(0);
const startX = ref(0);
const currentCardIndex = ref(-1);
const dragThreshold = 5; // Mínimo desplazamiento para considerar un arrastre (pixels)
const maxDragOffset = 100; // Máximo desplazamiento permitido

// Filtrar tarjetas para mostrar todas las no vistas, incluyendo las bloqueadas
const cardsToShow = computed(() => {
  // Obtener todas las tarjetas no vistas, sin importar si están bloqueadas
  const notViewedCards = cards.value.filter(card => !card.viewed);
  
  // Si todas las tarjetas ya fueron vistas, mostrar una tarjeta especial con el mensaje final
  if (notViewedCards.length === 0 && viewedCards.value.length === cards.value.length) {
    return [{
      title: "¡Fin de la aventura!",
      message: "¡Todas las sorpresas han sido reveladas! El año que viene más y mejor ✨",
      icon: "🎉",
      unlockTime: "00:00",
      manuallyUnlocked: true,
      viewed: false,
      isGame: false,
      isFinalCard: true
    }];
  }
  
  // Si no hay tarjetas, mostrar la primera incluso si está vista
  if (notViewedCards.length === 0 && cards.value.length > 0) {
    return [cards.value[0]];
  }
  
  // Separar la primera tarjeta (siempre desbloqueada) del resto
  const initialCard = notViewedCards.find(card => getOriginalIndex(card) === 0);
  const otherCards = notViewedCards.filter(card => getOriginalIndex(card) !== 0);
  
  // Ordenar las demás tarjetas por tiempo de desbloqueo (de mayor a menor)
  const sortedOtherCards = otherCards.sort((a, b) => {
    const [hoursA, minutesA] = a.unlockTime.split(':').map(Number);
    const [hoursB, minutesB] = b.unlockTime.split(':').map(Number);
    
    const timeA = hoursA * 60 + minutesA;
    const timeB = hoursB * 60 + minutesB;
    
    return timeB - timeA; // Orden descendente: de mayor a menor
  });
  
  // Combinar la tarjeta inicial con el resto ordenado por tiempo
  const result = initialCard ? [initialCard, ...sortedOtherCards] : sortedOtherCards;
  return result;
});

// Tarjetas vistas ordenadas por hora (orden inverso)
const sortedViewedCards = computed(() => {
  // Ordenar las tarjetas vistas por tiempo de desbloqueo (mayor a menor)
  return [...viewedCards.value].sort((a, b) => {
    const [hoursA, minutesA] = a.unlockTime.split(':').map(Number);
    const [hoursB, minutesB] = b.unlockTime.split(':').map(Number);
    
    const timeA = hoursA * 60 + minutesA;
    const timeB = hoursB * 60 + minutesB;
    
    return timeB - timeA; // Orden inverso: de mayor a menor
  });
});

// Temporizador hasta la próxima tarjeta
const nextCardCountdown = computed(() => {
  // Buscar la próxima tarjeta bloqueada
  const lockedCards = cards.value.filter((card, index) => 
    !isCardUnlocked(card, index) && !card.viewed
  );
  
  if (lockedCards.length === 0) {
    return "¡Todas las sorpresas están disponibles!";
  }
  
  // Ordenar las tarjetas bloqueadas por hora de desbloqueo
  lockedCards.sort((a, b) => {
    const timeA = new Date();
    const timeB = new Date();
    const [hoursA, minutesA] = a.unlockTime.split(':').map(Number);
    const [hoursB, minutesB] = b.unlockTime.split(':').map(Number);
    
    timeA.setHours(hoursA, minutesA, 0, 0);
    timeB.setHours(hoursB, minutesB, 0, 0);
    
    return timeA.getTime() - timeB.getTime();
  });
  
  // Calcular tiempo restante para la próxima tarjeta
  const nextCard = lockedCards[0];
  const [hours, minutes] = nextCard.unlockTime.split(':').map(Number);
  
  const unlockTime = new Date();
  unlockTime.setHours(hours, minutes, 0, 0);
  
  // Si la hora de desbloqueo ya pasó para hoy, calcular para mañana
  if (unlockTime < currentTime.value) {
    unlockTime.setDate(unlockTime.getDate() + 1);
  }
  
  // Calcular la diferencia de tiempo
  const diffMs = unlockTime.getTime() - currentTime.value.getTime();
  
  if (diffMs <= 0) {
    return "¡Desbloqueo inminente!";
  }
  
  // Convertir a horas, minutos y segundos
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
  const diffSeconds = Math.floor((diffMs % (1000 * 60)) / 1000);
  
  // Formatear la salida
  return `${diffHours.toString().padStart(2, '0')}:${diffMinutes.toString().padStart(2, '0')}:${diffSeconds.toString().padStart(2, '0')}`;
});


// Número de cartas desbloqueadas
const unlockedCount = computed(() => {
  return cards.value.filter((card, index) => isCardUnlocked(card, index)).length;
});

// Número de cartas pendientes por desbloquear
const pendingCount = computed(() => {
  return cards.value.filter((card, index) => !isCardUnlocked(card, index)).length;
});

// Verificar si una carta está desbloqueada según la hora actual o manualmente
const isCardUnlocked = (card: Card, index: number) => {
  // Si es la primera carta, debe estar desbloqueada desde el principio
  if (index === 0 || card.manuallyUnlocked) return true;
  
  // Si fue desbloqueada manualmente por la hora correspondiente
  if (manuallyUnlockedCards.value[index]) return true;
  
  // Verificar por hora
  const [hours, minutes] = card.unlockTime.split(':').map(Number);
  const unlockDateTime = new Date();
  unlockDateTime.setHours(hours, minutes, 0, 0);
  
  return currentTime.value >= unlockDateTime;
};

// Formatear la hora de la carta
const formatCardTime = (timeString: string) => {
  return timeString;
};

// Función para reproducir sonido de desbloqueo
const playUnlockSound = () => {
  try {
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    const oscillator1 = audioContext.createOscillator();
    const oscillator2 = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    // Primer tono
    oscillator1.type = 'sine';
    oscillator1.frequency.setValueAtTime(300, audioContext.currentTime);
    oscillator1.frequency.exponentialRampToValueAtTime(800, audioContext.currentTime + 0.2);
    
    // Segundo tono (armonía)
    oscillator2.type = 'sine';
    oscillator2.frequency.setValueAtTime(400, audioContext.currentTime + 0.1);
    oscillator2.frequency.exponentialRampToValueAtTime(1200, audioContext.currentTime + 0.3);
    
    // Control de volumen
    gainNode.gain.setValueAtTime(0.01, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.2, audioContext.currentTime + 0.1);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.4);
    
    // Conectar todo
    oscillator1.connect(gainNode);
    oscillator2.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    // Iniciar y detener
    oscillator1.start(audioContext.currentTime);
    oscillator2.start(audioContext.currentTime + 0.1);
    oscillator1.stop(audioContext.currentTime + 0.3);
    oscillator2.stop(audioContext.currentTime + 0.4);
  } catch (e) {
    console.log('Audio no soportado');
  }
};

// Función para voltear una carta
const flipCard = (index: number, event: MouseEvent | TouchEvent) => {
  // Si se estaba arrastrando, no voltear
  if (isDragging.value) return;
  
  const card = cardsToShow.value[index];
  const originalIndex = getOriginalIndex(card);
  
  // Solo permitir voltear cartas desbloqueadas - verificación más estricta
  if (!isCardUnlocked(card, originalIndex)) {
    playLockedSound();
    // Añadir vibración para reforzar el feedback de bloqueo
    if (navigator.vibrate) {
      navigator.vibrate([100]);
    }
    return;
  }
  
  // Si la carta ya está volteada y tiene contenido interactivo
  if (flippedCards.value[originalIndex] && card.isGame) {
    // Verificar si el clic fue en el botón de juego
    const target = event.target as HTMLElement;
    if (target.closest('.play-button')) {
      return; // Permitir que el enlace funcione
    }
  }
  
  // Si la carta ya está volteada, no hacer nada más
  if (flippedCards.value[originalIndex]) return;
  
  // Si es una carta recién desbloqueada (no la primera), mostrar animación de desbloqueo
  if (originalIndex > 0 && !card.manuallyUnlocked && !manuallyUnlockedCards.value[originalIndex]) {
    // Iniciar animación de desbloqueo
    unlockingCard.value = index;
    playUnlockSound();
    
    // Después de la animación, voltear la carta
    setTimeout(() => {
      unlockingCard.value = null;
      
      // Reproducir sonido de carta
      playCardSound();
      
      // Añadir vibración si el dispositivo lo soporta
      if (navigator.vibrate) {
        navigator.vibrate([30, 50, 30]);
      }
      
      // Voltear la carta
      flippedCards.value[originalIndex] = true;
      
      // Marcar como vista después de un tiempo
      setTimeout(() => {
        // Marcar la carta como vista
        cards.value[originalIndex].viewed = true;
        // Añadir a las tarjetas vistas
        const cardToAdd = {...cards.value[originalIndex]};
        viewedCards.value.push(cardToAdd);
        // Guardar estado en localStorage
        saveCardState();
      }, 2000);
      
      checkAllCardsUnlocked();
    }, 1500);
    
    return;
  }
  
  // Reproducir sonido de carta
  playCardSound();
  
  // Añadir vibración si el dispositivo lo soporta
  if (navigator.vibrate) {
    navigator.vibrate(50);
  }
  
  // Voltear la carta
  flippedCards.value[originalIndex] = true;
  
  // Marcar como vista y mover a la sección de vistas después de un tiempo más largo
  setTimeout(() => {
    // Marcar la carta como vista
    cards.value[originalIndex].viewed = true;
    // Añadir a las tarjetas vistas
    const cardToAdd = {...cards.value[originalIndex]};
    viewedCards.value.push(cardToAdd);
    // Guardar estado en localStorage
    saveCardState();
  }, 3000); // Aumentado a 3 segundos para dar más tiempo
  
  checkAllCardsUnlocked();
};

// Verificar si todas las cartas desbloqueadas han sido abiertas
const checkAllCardsUnlocked = () => {
  const allUnlocked = cards.value.every((card, idx) => 
    !isCardUnlocked(card, idx) || flippedCards.value[idx]
  );
  
  if (allUnlocked) {
    // Si todas las cartas disponibles han sido abiertas
    setTimeout(() => {
      fireConfetti();
    }, 500);
  }
};

// Función para calcular la posición de las cartas
const getCardPosition = (index: number) => {
  const card = cardsToShow.value[index];
  const originalIndex = getOriginalIndex(card);
  const isUnlocked = isCardUnlocked(card, originalIndex);
  const isMobile = window.innerWidth <= 768;
  
  // Cálculos específicos para móviles para evitar que se salgan de la pantalla
  if (isMobile) {
    // Las cartas bloqueadas se posicionan de forma escalonada pero no demasiado a la derecha
    if (!isUnlocked) {
      return 40 + index * 10; // Valores reducidos para móviles
    }
    
    // Las cartas desbloqueadas que no están volteadas, ligeramente escalonadas
    if (!flippedCards.value[originalIndex]) {
      return 15 + index * 3; // Valores más pequeños para evitar salirse de la pantalla
    }
    
    // Las cartas desbloqueadas y volteadas se posicionan al centro
    return 0;
  } else {
    // Comportamiento original para pantallas grandes
    // Las cartas bloqueadas se posicionan más a la derecha y escalonadas
    if (!isUnlocked) {
      return 60 + index * 15; // Más separación para las tarjetas bloqueadas
    }
    
    // Las cartas desbloqueadas que no están volteadas, un poco a la derecha
    if (!flippedCards.value[originalIndex]) {
      return 20 + index * 5;
    }
    
    // Las cartas desbloqueadas y volteadas se posicionan al centro
    return 0;
  }
};

// Función para calcular la rotación de las cartas
const getCardRotation = (index: number) => {
  const card = cardsToShow.value[index];
  const originalIndex = getOriginalIndex(card);
  const isUnlocked = isCardUnlocked(card, originalIndex);
  const isMobile = window.innerWidth <= 768;
  
  // Rotación reducida para dispositivos móviles
  if (isMobile) {
    // Si la carta está bloqueada, inclinarla ligeramente
    if (!isUnlocked) {
      return 5 + index * 2; // Menor rotación para evitar problemas en móviles
    }
    
    // Si está volteada, sin rotación
    if (flippedCards.value[originalIndex]) {
      return 0;
    }
    
    // Rotación muy leve para las demás
    return 1 + index * 0.5;
  } else {
    // Comportamiento original para pantallas grandes
    // Si la carta está bloqueada, inclinarla más
    if (!isUnlocked) {
      return 8 + index * 3; // Mayor rotación para las bloqueadas
    }
    
    // Si está volteada, sin rotación
    if (flippedCards.value[originalIndex]) {
      return 0;
    }
    
    // Ligera rotación para las demás
    return 2 + index * 1;
  }
};

// Función para lanzar confeti
const fireConfetti = () => {
  const count = 200;
  const defaults = {
    origin: { y: 0.7 },
    zIndex: 9999
  };

  confetti({
    ...defaults,
    particleCount: count * 0.25,
    spread: 100,
    shapes: ['circle'],
    colors: ['#ffb6c1', '#ffd1dc', '#f5c7f7', '#e0cffc', '#c5f9cc'],
  });

  setTimeout(() => {
    confetti({
      ...defaults,
      particleCount: count * 0.2,
      angle: 60,
      spread: 80,
      origin: { x: 0 },
      colors: ['#ff6ec4', '#ff8dce', '#e84393'],
    });
    
    confetti({
      ...defaults,
      particleCount: count * 0.2,
      angle: 120,
      spread: 80,
      origin: { x: 1 },
      colors: ['#ff6ec4', '#ff8dce', '#e84393'],
    });
  }, 250);
};

// Función para reproducir un sonido cuando se voltea una carta
const playCardSound = () => {
  try {
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.type = 'sine';
    oscillator.frequency.setValueAtTime(500, audioContext.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(900, audioContext.currentTime + 0.1);
    gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    oscillator.start();
    oscillator.stop(audioContext.currentTime + 0.3);
  } catch (e) {
    console.log('Audio no soportado');
  }
};

// Función para reproducir sonido cuando una carta está bloqueada
const playLockedSound = () => {
  try {
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.type = 'square';
    oscillator.frequency.setValueAtTime(200, audioContext.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(150, audioContext.currentTime + 0.2);
    gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    oscillator.start();
    oscillator.stop(audioContext.currentTime + 0.3);
  } catch (e) {
    console.log('Audio no soportado');
  }
};

// Actualizar el reloj cada segundo
const updateClock = () => {
  currentTime.value = new Date();
};

// Función para abrir una carta ya vista
const openViewedCard = () => {
  // Simplemente mostrar un diálogo o lanzar una animación simple
  playCardSound();
};

// Función para obtener el índice original de una tarjeta
const getOriginalIndex = (card: Card) => {
  // Si es la tarjeta final, devolver un índice que no exista en las tarjetas originales
  if (card.isFinalCard) {
    return -1; // Usamos -1 para indicar que es la tarjeta final
  }
  return cards.value.findIndex(c => c.title === card.title);
};

// Funciones para manejo de localStorage
const saveCardState = () => {
  const savedState = {
    viewedCardTitles: cards.value.filter(card => card.viewed).map(card => card.title),
    flippedState: flippedCards.value,
    lastVisitTime: new Date().toISOString()
  };
  localStorage.setItem('birthdayCardState', JSON.stringify(savedState));
};

const loadCardState = () => {
  const savedStateJson = localStorage.getItem('birthdayCardState');
  if (!savedStateJson) return false;
  
  try {
    const savedState = JSON.parse(savedStateJson);
    
    // Restaurar estado de cartas vistas
    if (savedState.viewedCardTitles && Array.isArray(savedState.viewedCardTitles)) {
      // Marcar tarjetas como vistas según los títulos guardados
      savedState.viewedCardTitles.forEach((title: string) => {
        const cardIndex = cards.value.findIndex(card => card.title === title);
        if (cardIndex >= 0) {
          cards.value[cardIndex].viewed = true;
          
          // Añadir a la lista de tarjetas vistas si no está ya
          const cardExists = viewedCards.value.some(c => c.title === title);
          if (!cardExists) {
            viewedCards.value.push({...cards.value[cardIndex]});
          }
        }
      });
    }
    
    // Restaurar estado de volteo
    if (savedState.flippedState && Array.isArray(savedState.flippedState)) {
      // Asegurarse de que el array tenga la longitud correcta
      const minLength = Math.min(savedState.flippedState.length, flippedCards.value.length);
      for (let i = 0; i < minLength; i++) {
        flippedCards.value[i] = savedState.flippedState[i];
      }
    }
    
    return true;
  } catch (error) {
    console.error('Error al cargar estado desde localStorage:', error);
    return false;
  }
};

// Función para reiniciar los datos de la aplicación
const resetAppData = () => {
  if (confirm('¿Estás seguro de que quieres reiniciar la experiencia? Todas las tarjetas volverán a su estado original.')) {
    // Eliminar datos del localStorage
    localStorage.removeItem('birthdayCardState');
    
    // Reiniciar estados
    cards.value.forEach(card => {
      card.viewed = false;
      // Mantener la primera carta desbloqueada
      if (getOriginalIndex(card) > 0) {
        card.manuallyUnlocked = false;
      }
    });
    
    // Reiniciar arrays
    flippedCards.value = Array(cards.value.length).fill(false);
    manuallyUnlockedCards.value = Array(cards.value.length).fill(false);
    manuallyUnlockedCards.value[0] = true; // La primera carta siempre desbloqueada
    viewedCards.value = [];
    
    // Reproducir un sonido de reinicio
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();
      
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
      oscillator.frequency.exponentialRampToValueAtTime(200, audioContext.currentTime + 0.5);
      gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);
      
      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);
      oscillator.start();
      oscillator.stop(audioContext.currentTime + 0.5);
    } catch (e) {
      console.log('Audio no soportado');
    }
    
    // Añadir vibración
    if (navigator.vibrate) {
      navigator.vibrate([100, 50, 100]);
    }
    
    // Notificar al usuario
    alert('¡Experiencia reiniciada! Las tarjetas han vuelto a su estado original.');
  }
};

// Manejar inicio del toque
const handleTouchStart = (event: TouchEvent, index: number) => {
  // Guardamos la posición X inicial del toque
  startX.value = event.touches[0].clientX;
  isDragging.value = false;
  currentCardIndex.value = index;
  
  // No llamamos a preventDefault() para permitir que funcionen los toques normales
};

// Manejar movimiento durante el toque
const handleTouchMove = (event: TouchEvent) => {
  if (currentCardIndex.value === -1) return;
  
  // Calcular el desplazamiento
  const currentX = event.touches[0].clientX;
  const diffX = currentX - startX.value;
  
  // Solo iniciar el arrastre si supera el umbral
  if (Math.abs(diffX) > dragThreshold) {
    isDragging.value = true;
    
    // Aplicar efecto de resistencia en los extremos
    if (Math.abs(diffX) > maxDragOffset) {
      dragOffset.value = diffX > 0 
        ? maxDragOffset 
        : -maxDragOffset;
    } else {
      // Añadir efecto de resistencia proporcional
      const resistance = 0.8;
      dragOffset.value = diffX * resistance;
    }
    
    // Una vez que estamos arrastrando, prevenir el scroll
    if (isDragging.value) {
      event.preventDefault();
    }
  }
};

// Manejar fin del toque
const handleTouchEnd = () => {
  // Si no hubo arrastre (solo un toque), intentar voltear la tarjeta
  if (!isDragging.value && currentCardIndex.value !== -1) {
    // Llamar a flipCard para el toque (sin arrastre)
    const cardIndex = currentCardIndex.value;
    const fakeEvent = new MouseEvent('click');
    flipCard(cardIndex, fakeEvent);
  } else if (isDragging.value) {
    // Resetear estado de arrastre
    isDragging.value = false;
    
    // Animación de rebote al soltar
    const springEffect = () => {
      if (Math.abs(dragOffset.value) < 2) {
        dragOffset.value = 0;
        return;
      }
      
      dragOffset.value = dragOffset.value * 0.8;
      requestAnimationFrame(springEffect);
    };
    
    springEffect();
  }
  
  // Resetear el índice de la tarjeta actual
  currentCardIndex.value = -1;
};

// Al montar el componente
onMounted(() => {
  // Iniciar el reloj
  updateClock();
  clockInterval.value = window.setInterval(updateClock, 1000);
  
  // Pequeño retraso inicial para asegurar que todo se ha renderizado
  setTimeout(() => {
    // Cargar estado guardado
    const stateLoaded = loadCardState();
    console.log('Estado cargado desde localStorage:', stateLoaded);
    
    // Función para verificar y actualizar el estado de las cartas
    const updateCardStatuses = () => {
      // Asegurarse de que la primera carta (rocódromo) esté desbloqueada desde el principio
      cards.value[0].manuallyUnlocked = true;
      manuallyUnlockedCards.value[0] = true;
      
      // Para las demás cartas, verificar SOLO por hora
      for (let i = 1; i < cards.value.length; i++) {
        const card = cards.value[i];
        const [hours, minutes] = card.unlockTime.split(':').map(Number);
        const unlockDateTime = new Date();
        unlockDateTime.setHours(hours, minutes, 0, 0);
        
        // Actualizar el estado de desbloqueo según la hora actual
        manuallyUnlockedCards.value[i] = currentTime.value >= unlockDateTime;
      }
    };
    
    // Verificar inicialmente el estado de las cartas
    updateCardStatuses();
    
    // Configurar una verificación periódica para actualizar el estado de las cartas
    // Esto asegura que las cartas se desbloqueen cuando sea su hora
    const intervalId = window.setInterval(() => {
      updateCardStatuses();
      // Guardar estado después de cada actualización
      saveCardState();
    }, 10000); // Cada 10 segundos
    
    // Almacenar el ID del intervalo para limpiarlo después
    clockInterval.value = intervalId as unknown as number;
  }, 800);
});

// Al desmontar el componente
onUnmounted(() => {
  if (clockInterval.value !== null) {
    clearInterval(clockInterval.value);
    clockInterval.value = null;
  }
  
  // Guardar estado antes de desmontar
  saveCardState();
});
</script>

<style lang="scss" scoped>
.cards-home {
  max-width: 900px;
  padding: 2rem;
  text-align: center;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  position: relative;
}

h1 {
  color: #e84393;
  font-family: 'Comic Sans MS', 'Marker Felt', cursive;
  font-size: 2.5rem;
  text-shadow: 2px 2px 4px rgba(255, 105, 180, 0.3);
  margin-bottom: 0.5rem;
  position: relative;
  z-index: 10;
}

h1::before {
  content: "🎂";
  position: absolute;
  left: -40px;
  top: 5px;
}

h1::after {
  content: "🎂";
  position: absolute;
  right: -40px;
  top: 5px;
}

.subtitle {
  color: #b15b88;
  font-size: 1.2rem;
  margin-bottom: 2rem;
  font-style: italic;
}

.time-banner {
  background-color: #ffecf9;
  border-radius: 50px;
  padding: 0.7rem 1.5rem;
  margin-bottom: 2.5rem;
  box-shadow: 0 4px 15px rgba(255, 105, 180, 0.2);
  border: 2px solid #ffb6c1;
  animation: pulse 2s infinite;
}

.timer-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.timer-label {
  font-size: 1.2rem;
  font-weight: bold;
  color: #e84393;
  margin-bottom: 5px;
}

.current-time {
  font-size: 1.8rem;
  font-weight: bold;
  color: #e84393;
  font-family: 'Courier New', monospace;
  text-shadow: 0 2px 4px rgba(232, 67, 147, 0.2);
  background-color: white;
  padding: 0.3rem 1rem;
  border-radius: 10px;
  box-shadow: inset 0 0 10px rgba(255, 182, 193, 0.3);
  border: 1px solid #ffd1dc;
  letter-spacing: 2px;
}

.cards-container {
  position: relative;
  height: 450px; /* Aumentada para dar más espacio */
  width: 100%;
  max-width: 350px;
  margin: 0 auto;
  perspective: 1000px;
  overflow: visible; /* Permite que las tarjetas se vean correctamente fuera del contenedor */
}

.card {
  position: absolute;
  top: 0;
  left: 0;
  width: 280px;
  height: 380px;
  margin: 0 auto;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(255, 105, 180, 0.3);
  transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  transform-style: preserve-3d;
  cursor: pointer;
  z-index: 1;
  
  &:hover {
    transform: translateY(-10px) translateX(0) rotate(0deg) !important;
    box-shadow: 0 15px 30px rgba(255, 105, 180, 0.5);
  }
  
  /* Indicador de deslizamiento para usuarios en dispositivos móviles */
  &::after {
    content: "↔️";
    position: absolute;
    bottom: -30px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 1.5rem;
    opacity: 0.5;
    animation: swipeHint 2s infinite;
    display: none;
  }
}

.card-active {
  z-index: 2;
}

.card-golden {
  background: linear-gradient(135deg, #ffd700, #ffecb3);
  border: 3px solid #ffd700;
  box-shadow: 0 5px 20px rgba(255, 215, 0, 0.6);
  
  &::before {
    content: "🏆";
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 1.5rem;
    z-index: 10;
    animation: shine 2s infinite;
  }
  
  .card-front {
    background: linear-gradient(145deg, #fffce6, #ffd700);
    border-color: #ffd700;
    
    &::after {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(45deg, transparent 40%, rgba(255, 215, 0, 0.4) 50%, transparent 60%);
      background-size: 200% 200%;
      animation: goldShine 2.5s ease-in-out infinite;
      border-radius: 12px;
    }
  }
  
  .card-back {
    background: #fffef7;
    border: 3px solid #ffd700;
    
    .card-content {
      h3 {
        color: #b8860b;
        text-shadow: 1px 1px 2px rgba(184, 134, 11, 0.3);
      }
      
      p {
        color: #8b6914;
      }
      
      .card-emoji {
        position: relative;
        
        &::after {
          content: "🎖️";
          position: absolute;
          top: -15px;
          right: -15px;
          font-size: 1.5rem;
          animation: bounce 1.5s infinite alternate;
        }
      }
    }
  }
}

.card-final {
  background: linear-gradient(135deg, #fff0f5, #ffe4e1);
  border: 3px solid #ffd1dc;
  box-shadow: 0 10px 30px rgba(255, 105, 180, 0.5);
  animation: pulse-glow 2s infinite alternate;
  
  .card-front {
    background: linear-gradient(135deg, #ffecf2, #fff0f5);
    border-color: #ffb6c1;
  }
  
  .card-decoration {
    font-size: 6rem;
    animation: bounce 1.5s infinite alternate;
  }
  
  .card-content {
    h3 {
      color: #e84393;
      font-size: 1.8rem;
      text-shadow: 1px 1px 3px rgba(232, 67, 147, 0.3);
    }
    
    p {
      font-size: 1.2rem;
      line-height: 1.6;
      color: #d13b7b;
    }
  }
}

.card-flipped {
  transform: rotateY(180deg) !important;
  z-index: 3;
  
  &:hover {
    transform: rotateY(180deg) translateY(-10px) !important;
  }
}

.card-locked {
  filter: grayscale(0.8);
  opacity: 0.7;
  pointer-events: auto;
  z-index: 0;
  
  &:hover {
    filter: grayscale(0.6);
    opacity: 0.8;
    transform: translateY(-5px) translateX(0) rotate(0deg) !important;
    box-shadow: 0 8px 15px rgba(180, 105, 255, 0.3);
    
    &::before {
      content: "🔒";
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      font-size: 6rem;
      opacity: 0.6;
      z-index: 3;
      animation: pulse 1s infinite;
    }
  }
  
  &::after {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.3);
    border-radius: 15px;
    z-index: 2;
  }
  
  .card-front {
    background: linear-gradient(135deg, #e0e0e0 0%, #d1d1d1 100%);
    border: 3px solid #c0c0c0;
  }
  
  .lock-icon {
    font-size: 4rem;
    filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.7));
    animation: pulse 1.5s infinite;
    display: block;
    position: relative;
    z-index: 3;
  }
}

.card-unlocking {
  z-index: 10;
  
  &::before {
    content: "";
    position: absolute;
    top: -10px;
    left: -10px;
    right: -10px;
    bottom: -10px;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 255, 0) 70%);
    border-radius: 20px;
    z-index: -1;
    opacity: 0;
    animation: pulse-glow 1.5s ease-in-out;
  }
  
  .card-decoration {
    animation: shake 0.5s ease-in-out;
  }
}

.unlock-animation {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 100;
  pointer-events: none;
}

.unlock-rays {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 180px;
  height: 180px;
  transform: translate(-50%, -50%);
  background: radial-gradient(circle, rgba(255, 239, 213, 0.9) 0%, rgba(255, 239, 213, 0) 70%);
  border-radius: 50%;
  animation: expand 1.2s ease-out;
}

.unlock-icon {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 5rem;
  animation: bounce-up 1.2s ease-out;
}

.card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transform-style: preserve-3d;
  transition: transform 0.6s;
}

.card-front, .card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  padding: 20px;
  box-sizing: border-box;
}

.card-front {
  background: linear-gradient(135deg, #fff5f9 0%, #ffecf2 100%);
  border: 3px solid #ffd1dc;
  color: #e84393;
}

.card-back {
  background: white;
  border: 3px solid #ff69b4;
  transform: rotateY(180deg);
  color: #b15b88;
  overflow: hidden;
}

.card-decoration {
  font-size: 5rem;
  margin-bottom: 20px;
  animation: float 3s ease-in-out infinite;
}

.card-time {
  font-size: 1.2rem;
  font-weight: bold;
  color: #ff69b4;
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(255, 255, 255, 0.8);
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  border: 1px solid #ffd1dc;
}

.card-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  
  h3 {
    font-family: 'Comic Sans MS', 'Marker Felt', cursive;
    color: #e84393;
    margin: 0 0 15px 0;
    font-size: 1.5rem;
  }
  
  p {
    flex-grow: 1;
    display: flex;
    align-items: center;
    text-align: center;
    font-size: 1.1rem;
    line-height: 1.5;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: rgba(232, 67, 147, 0.3) transparent;
    
    &::-webkit-scrollbar {
      width: 4px;
      height: 4px;
    }
    
    &::-webkit-scrollbar-thumb {
      background-color: rgba(232, 67, 147, 0.3);
      border-radius: 10px;
    }
    
    &::-webkit-scrollbar-track {
      background: transparent;
    }
  }
}

.card-emoji {
  font-size: 3rem;
  margin-top: 10px;
  margin-bottom: 15px;
  animation: bounce 2s ease-in-out infinite;
}

.card-game-button {
  margin-top: 5px;
}

.play-button {
  background-color: #ffb8e9;
  color: #9d2f70;
  border: 2px solid #ff69b4;
  padding: 0.9rem 1.8rem;
  font-size: 1.2rem;
  border-radius: 50px;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(232, 67, 147, 0.3);
  cursor: pointer;
  z-index: 100;
  
  &::before {
    content: "";
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
    transition: all 0.4s;
  }
  
  &:hover {
    transform: translateY(-5px) scale(1.05);
    box-shadow: 0 8px 25px rgba(232, 67, 147, 0.5);
    background-color: #ff9ed8;
    
    &::before {
      left: 100%;
    }
    
    .icon {
      transform: rotate(15deg) scale(1.2);
    }
  }
  
  &:active {
    transform: translateY(0) scale(0.98);
  }
  
  .icon {
    margin-left: 10px;
    font-size: 1.3rem;
    transition: transform 0.3s;
  }
}

.floating-decorations {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: -1;
}

.floating-item {
  position: absolute;
  font-size: 2rem;
  animation: float 8s ease-in-out infinite;
  opacity: 0.7;
}

.instructions {
  margin-top: 2rem;
  color: #b15b88;
  font-size: 1.1rem;
  font-style: italic;
  animation: pulse 2s infinite;
}

@keyframes float {
  0% {
    transform: translateY(0) rotate(0);
  }
  50% {
    transform: translateY(-15px) rotate(5deg);
  }
  100% {
    transform: translateY(0) rotate(0);
  }
}

.viewed-cards-section {
  margin-top: 3rem;
  width: 100%;
  text-align: center;
}

.viewed-title {
  color: #e84393;
  font-family: 'Comic Sans MS', 'Marker Felt', cursive;
  font-size: 1.8rem;
  text-shadow: 1px 1px 3px rgba(255, 105, 180, 0.2);
  margin-bottom: 1.5rem;
  position: relative;
  display: inline-block;
}

.viewed-title::before,
.viewed-title::after {
  content: "✨";
  font-size: 1.5rem;
  position: absolute;
  top: 0;
}

.viewed-title::before {
  left: -30px;
}

.viewed-title::after {
  right: -30px;
}

.viewed-cards-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.viewed-card {
  position: relative;
  width: 220px;
  height: 360px;
  border-radius: 15px;
  box-shadow: 0 3px 10px rgba(255, 105, 180, 0.2);
  transform-style: preserve-3d;
  cursor: pointer;
  transition: all 0.3s ease;
  transform: rotateY(180deg);
  margin-bottom: 15px;
  
  &:hover {
    transform: rotateY(180deg) translateY(-5px);
    box-shadow: 0 8px 15px rgba(255, 105, 180, 0.3);
  }
  
  .card-inner {
    position: relative;
    width: 100%;
    height: 100%;
    transform-style: preserve-3d;
    transition: transform 0.6s;
  }
  
  .card-front, .card-back {
    position: absolute;
    width: 100%;
    height: 100%;
    backface-visibility: hidden;
    border-radius: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    padding: 15px;
    box-sizing: border-box;
    overflow: hidden;
  }
  
  .card-content {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    
    h3 {
      font-size: 1.1rem;
      margin: 0 0 5px 0;
      width: 100%;
      text-align: center;
    }
    
    p {
      font-size: 0.85rem;
      flex-grow: 1;
      width: 100%;
      padding: 0 5px;
      margin: 0 0 5px 0;
      text-align: center;
      display: block;
      line-height: 1.3;
      overflow: hidden;
    }
    
    .card-emoji {
      font-size: 2.2rem;
      margin: 5px 0;
    }
    
    .card-game-button {
      margin-top: 5px;
      
      .play-button {
        padding: 0.4rem 1rem;
        font-size: 0.9rem;
      }
    }
  }
}

.viewed-card-golden {
  box-shadow: 0 3px 15px rgba(255, 215, 0, 0.5);
  border: 2px solid #ffd700;
  
  &:hover {
    box-shadow: 0 8px 20px rgba(255, 215, 0, 0.6);
  }
  
  &::before {
    content: "🏆";
    position: absolute;
    top: 5px;
    right: 5px;
    font-size: 1.2rem;
    z-index: 10;
    transform: rotateY(180deg);
  }
  
  .card-back {
    background: #fffef7;
    border: 2px solid #ffd700;
  }
  
  .card-content {
    h3 {
      color: #b8860b;
    }
    
    p {
      color: #8b6914;
    }
    
    .card-emoji {
      position: relative;
      
      &::after {
        content: "🎖️";
        position: absolute;
        top: -10px;
        right: -10px;
        font-size: 1.2rem;
      }
    }
  }
}

/* Estilos responsivos */
@media (max-width: 768px) {
  .cards-home {
    padding: 1.5rem 0.8rem;
    max-width: 100%;
    overflow-x: hidden; /* Prevenir scroll horizontal */
  }
  
  h1 {
    font-size: 2rem;
  }
  
  h1::before, h1::after {
    font-size: 1.8rem;
    position: relative;
    top: 0;
    display: inline-block;
    margin: 0 5px;
  }
  
  .subtitle {
    font-size: 1rem;
    margin-bottom: 1.5rem;
  }
  
  .time-banner {
    margin-bottom: 1.5rem;
    padding: 0.5rem 1rem;
    width: 90%;
  }
  
  .timer-label {
    font-size: 1rem;
  }
  
  .current-time {
    font-size: 1.4rem;
    padding: 0.2rem 0.8rem;
  }
  
  .cards-container {
    height: 380px;
    max-width: 100%;
    width: 290px; /* Ancho fijo más pequeño para contener las tarjetas */
    padding: 0;
    margin-bottom: 40px;
    overflow: visible;
    perspective: 1200px;
  }
  
  .card {
    width: 240px; /* Tamaño reducido para móviles */
    height: 340px;
    left: 50%;
    transform-origin: center center;
    margin-left: -182px; /* La mitad del ancho para centrar */
  }
  
  /* Ajustar posición en dispositivos pequeños */
  @media (max-width: 360px) {
    .cards-container {
      width: 240px;
    }
    
    .card {
      width: 220px;
      height: 320px;
      margin-left: -110px;
    }
  }

  /* Ajustes para dispositivos muy pequeños */
  @media (max-width: 320px) {
    .cards-container {
      width: 220px;
    }
    
    .card {
      width: 200px;
      height: 300px;
      margin-left: -100px;
    }
    
    .card-content h3 {
      font-size: 1rem;
    }
    
    .card-content p {
      font-size: 0.85rem;
    }
  }
  
  .card-front, .card-back {
    width: 100%;
    height: 100%;
  }
  
  .card-front .card-decoration {
    font-size: 3.5rem;
    margin-bottom: 15px;
  }
  
  .card-time {
    font-size: 1rem;
    padding: 0.2rem 0.6rem;
  }
  
  .card-content h3 {
    font-size: 1.2rem;
    margin-bottom: 8px;
  }
  
  .card-content p {
    font-size: 0.95rem;
    line-height: 1.3;
    max-height: 160px;
    padding: 0 5px;
    overflow-y: auto;
    padding-right: 5px;
  }
  
  /* Indicador visual de deslizamiento */
  .cards-container::after {
    content: "↔️ Desliza para ver más";
    position: absolute;
    bottom: -28px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 0.9rem;
    color: #b15b88;
    opacity: 0.8;
    width: 100%;
    text-align: center;
    animation: pulse 2s infinite;
  }
  
  .viewed-cards-section {
    margin-top: 2.5rem;
  }
  
  .viewed-card {
    width: 160px;
    height: 260px;
  }
  
  .viewed-cards-container {
    gap: 0.8rem;
  }
  
  .viewed-title {
    font-size: 1.5rem;
  }
  
  .viewed-title::before,
  .viewed-title::after {
    font-size: 1.2rem;
  }
}

@keyframes swipeHint {
  0%, 100% {
    transform: translateX(-50%);
  }
  50% {
    transform: translateX(-70%);
  }
  75% {
    transform: translateX(-30%);
  }
}

/* Estilo para el contenido bloqueado */
.card-locked-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  background-color: rgba(238, 238, 238, 0.9);
  border-radius: 12px;
  padding: 20px;
  color: #888;
  
  p {
    font-size: 1.1rem;
    margin: 15px 0;
    font-style: italic;
  }
  
  .big-lock-icon {
    font-size: 6rem;
    margin-bottom: 20px;
    animation: pulse 2s infinite;
    color: #aaa;
  }
  
  .card-time-big {
    font-size: 1.3rem;
    font-weight: bold;
    color: #999;
    margin-top: 15px;
    background-color: rgba(255, 255, 255, 0.5);
    padding: 5px 15px;
    border-radius: 20px;
  }
}

/* Estilos para el mensaje final */
.final-message-container {
  margin-top: 2rem;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  animation: fadeIn 1s ease-in-out;
}

.final-message {
  background-color: #fff5f9;
  border-radius: 15px;
  padding: 1.5rem 2rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 5px 20px rgba(255, 105, 180, 0.3);
  border: 2px solid #ffd1dc;
  text-align: center;
  max-width: 90%;
  
  h2 {
    color: #e84393;
    font-family: 'Comic Sans MS', 'Marker Felt', cursive;
    font-size: 1.5rem;
    margin-bottom: 0.8rem;
  }
  
  p {
    color: #b15b88;
    font-size: 1.2rem;
    font-style: italic;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Estilos para el botón de reinicio */
.reset-button-container {
  margin-top: 0.5rem;
  width: 100%;
  display: flex;
  justify-content: center;
}

.reset-button {
  background-color: #f4f4f4;
  color: #777;
  border: 1px dashed #ccc;
  padding: 0.7rem 1.5rem;
  font-size: 0.9rem;
  border-radius: 30px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  
  &:hover {
    background-color: #ffe5ee;
    color: #e84393;
    border-color: #ffb6c1;
  }
  
  .reset-icon {
    font-size: 1.2rem;
  }
}

@media (max-width: 768px) {
  .reset-button {
    padding: 0.5rem 1.2rem;
    font-size: 0.8rem;
  }
  
  .final-message {
    padding: 1.2rem 1.5rem;
    
    h2 {
      font-size: 1.3rem;
    }
    
    p {
      font-size: 1rem;
    }
  }
}

@keyframes goldShine {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: 0 0;
  }
}

@keyframes shine {
  0% {
    opacity: 0.8;
    transform: scale(1);
  }
  50% {
    opacity: 1;
    transform: scale(1.2);
  }
  100% {
    opacity: 0.8;
    transform: scale(1);
  }
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 0 15px rgba(255, 105, 180, 0.5);
  }
  50% {
    box-shadow: 0 0 30px rgba(255, 105, 180, 0.9);
  }
}

@keyframes shake {
  0%, 100% {
    transform: translateX(0);
  }
  10%, 30%, 50%, 70%, 90% {
    transform: translateX(-5px);
  }
  20%, 40%, 60%, 80% {
    transform: translateX(5px);
  }
}

@keyframes expand {
  0% {
    transform: translate(-50%, -50%) scale(0);
    opacity: 0.5;
  }
  50% {
    opacity: 1;
  }
  100% {
    transform: translate(-50%, -50%) scale(1.5);
    opacity: 0;
  }
}

@keyframes bounce-up {
  0% {
    transform: translate(-50%, -50%) scale(0.3);
    opacity: 0;
  }
  50% {
    transform: translate(-50%, -80%) scale(1.2);
    opacity: 1;
  }
  70% {
    transform: translate(-50%, -40%) scale(0.8);
  }
  85% {
    transform: translate(-50%, -50%) scale(1.1);
  }
  100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
  }
}
</style> 