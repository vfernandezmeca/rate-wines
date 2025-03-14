import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import Home from '../components/Home.vue'
import SortGame from '../components/SortGame.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/sort-game',
    name: 'SortGame',
    component: SortGame
  },
  {
    path: '/new-game',
    name: 'NewGame',
    // Placeholder para el nuevo juego (se creará más adelante)
    component: Home
  },
  // Redirección para rutas no encontradas
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router 