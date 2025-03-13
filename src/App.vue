<script setup lang="ts">
import SortGame from './components/SortGame.vue'
</script>

<template>
  <div class="app-container">
    <SortGame />
  </div>
</template>

<style lang="scss">
body {
  margin: 0;
  padding: 0;
  font-family: Arial, sans-serif;
  background-color: #f5f5f5;
}

.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
</style>
