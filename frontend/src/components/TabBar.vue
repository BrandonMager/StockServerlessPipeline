<script setup>
defineProps({
  tabs: { type: Array, required: true }, // [{ id, label }]
  active: { type: String, required: true },
});
defineEmits(["change"]);
</script>
 
<template>
  <div class="flex rounded-full border border-panel-border bg-panel p-1">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      class="rounded-full px-4 py-1.5 text-sm font-medium transition"
      :class="active === tab.id ? 'bg-gain text-navy-deep' : 'text-muted hover:text-ink'"
      @click="$emit('change', tab.id)"
    >
      {{ tab.label }}
    </button>
  </div>
</template>