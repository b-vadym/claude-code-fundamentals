<script setup lang="ts">
defineProps<{
  url: string
  label?: string
}>()
</script>

<template>
  <div class="doc-ref">
    <a :href="url" target="_blank" rel="noopener">
      📖 {{ label || url.replace(/^https?:\/\//, '') }}
    </a>
  </div>
</template>

<style scoped>
.doc-ref {
  position: absolute;
  bottom: 0.6rem;
  right: 1rem;
  font-size: 0.7rem;
  opacity: 0.45;
  z-index: 10;
  transition: opacity 0.2s;
}
.doc-ref:hover {
  opacity: 0.95;
}
.doc-ref a {
  color: inherit;
  text-decoration: none;
  border-bottom: 1px dotted currentColor;
}
</style>
