<script setup>
import { computed } from "vue";

const props = defineProps({
  mover: { type: Object, required: true },
});

const isGain = computed(() => props.mover.pctChange >= 0);

function formatDate(iso) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString(undefined, {
    weekday: "short",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  });
}
</script>

<template>
  <div
    class="rounded-2xl border border-panel-border bg-panel p-5 shadow-panel backdrop-blur-sm transition hover:border-white/20"
  >
    <div class="flex items-center justify-between">
      <span class="text-xs font-medium text-muted">{{ formatDate(mover.date) }}</span>
      <span
        class="rounded-full px-2.5 py-0.5 text-xs font-semibold"
        :class="isGain ? 'bg-gain-bg text-gain' : 'bg-loss-bg text-loss'"
      >
        {{ isGain ? "↗" : "↘" }} {{ isGain ? "+" : "" }}{{ mover.pctChange.toFixed(2) }}%
      </span>
    </div>

    <p class="mt-3 text-xl font-semibold tracking-tight text-ink">{{ mover.ticker }}</p>

    <p class="mt-1 font-mono text-lg font-semibold text-ink/90">
      ${{ mover.closePrice.toFixed(2) }}
    </p>

    <div class="mt-3 h-1 overflow-hidden rounded-full bg-white/5">
      <div
        class="h-full rounded-full"
        :class="isGain ? 'bg-gain' : 'bg-loss'"
        :style="{ width: `${Math.min(Math.abs(mover.pctChange), 10) / 10 * 100}%` }"
      />
    </div>
  </div>
</template>