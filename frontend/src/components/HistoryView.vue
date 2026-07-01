<script setup>
import MoverCard from "./MoverCard.vue";
 
defineProps({
  movers: { type: Array, required: true },
});
defineEmits(["select"]);
</script>
 
<template>
  <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
    <button
      v-for="m in movers"
      :key="m.date"
      class="text-left"
      @click="$emit('select', m)"
    >
      <MoverCard :mover="m" interactive />
    </button>
  </div>
</template>