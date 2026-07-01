<script setup>
import { computed } from "vue";

const props = defineProps({
  mover: { type: Object, required: true },
  movers: { type: Array, required: true }, // full 7-day list for stats
});

const isGain = computed(() => props.mover.pctChange >= 0);

function formatDate(iso) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString(undefined, {
    weekday: "long",
    month: "long",
    day: "numeric",
    timeZone: "UTC",
  });
}

function fmt(n, decimals = 2) {
  return n == null ? "—" : `$${Number(n).toFixed(decimals)}`;
}


const open = computed(() => fmt(props.mover.openPrice));
const close = computed(() => fmt(props.mover.closePrice));


// Stats summary from the 7-day window
const stats = computed(() => {
  const m = props.movers;
  if (!m.length) return null;

  const gains = m.filter((x) => x.pctChange > 0);
  const losses = m.filter((x) => x.pctChange < 0);
  const avg = m.reduce((s, x) => s + x.pctChange, 0) / m.length;

  const biggestGain = gains.length
    ? gains.reduce((a, b) => (a.pctChange > b.pctChange ? a : b))
    : null;
  const biggestLoss = losses.length
    ? losses.reduce((a, b) => (a.pctChange < b.pctChange ? a : b))
    : null;

  const freq = m.reduce((acc, x) => {
    acc[x.ticker] = (acc[x.ticker] || 0) + 1;
    return acc;
  }, {});
  const mostVolatile = Object.entries(freq).sort((a, b) => b[1] - a[1])[0];

  return { avg, biggestGain, biggestLoss, mostVolatile };
});

function shortDate(iso) {
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  });
}
</script>

<template>
  <div class="space-y-4">
    <div
      class="rounded-2xl border border-panel-border bg-panel p-6 shadow-panel backdrop-blur-sm"
      :class="isGain ? 'shadow-glow-gain' : 'shadow-glow-loss'"
    >

      <div class="flex items-start justify-between gap-4">
        <div>
          <p class="text-sm text-muted">{{ formatDate(mover.date) }}</p>
          <h2 class="mt-1 text-2xl font-semibold tracking-tight text-ink">{{ mover.ticker }}</h2>
        </div>
        <span
          class="rounded-full px-3 py-1 text-sm font-semibold"
          :class="isGain ? 'bg-gain-bg text-gain' : 'bg-loss-bg text-loss'"
        >
          {{ isGain ? "↗" : "↘" }} {{ isGain ? "+" : "" }}{{ mover.pctChange.toFixed(2) }}%
        </span>
      </div>

      <p class="mt-5 font-mono text-5xl font-bold text-ink">
        {{ fmt(mover.closePrice) }}
      </p>

    
      <div class="mt-5 flex flex-wrap gap-x-8 gap-y-2 border-t border-panel-border pt-4 text-sm">
        <div>
          <span class="text-muted">Close</span>
          <span class="ml-2 font-mono font-medium text-ink">{{ close }}</span>
        </div>
        <div>
          <span class="text-muted">Change</span>
          <span class="ml-2 font-mono font-medium" :class="isGain ? 'text-gain' : 'text-loss'">
            {{ isGain ? "+" : "" }}{{ mover.pctChange.toFixed(2) }}%
          </span>
        </div>
        <div>
          <span class="text-muted">Ticker</span>
          <span class="ml-2 font-mono font-medium text-ink">{{ mover.ticker }}</span>
        </div>
      </div>
    </div>

    <div
      v-if="stats"
      class="rounded-2xl border border-panel-border bg-panel p-5 shadow-panel backdrop-blur-sm"
    >
      <h3 class="mb-4 text-xs font-medium uppercase tracking-wide text-muted">
        7-Day Summary
      </h3>
      <div class="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <div>
          <p class="text-xs text-muted">Avg move</p>
          <p
            class="mt-1 font-mono text-base font-semibold"
            :class="stats.avg >= 0 ? 'text-gain' : 'text-loss'"
          >
            {{ stats.avg >= 0 ? "+" : "" }}{{ stats.avg.toFixed(2) }}%
          </p>
        </div>
        <div>
          <p class="text-xs text-muted">Biggest gain</p>
          <p class="mt-1 font-mono text-base font-semibold text-gain">
            {{ stats.biggestGain ? `${stats.biggestGain.ticker} +${stats.biggestGain.pctChange.toFixed(2)}%` : "—" }}
          </p>
          <p v-if="stats.biggestGain" class="text-xs text-muted">
            {{ shortDate(stats.biggestGain.date) }}
          </p>
        </div>
        <div>
          <p class="text-xs text-muted">Biggest loss</p>
          <p class="mt-1 font-mono text-base font-semibold text-loss">
            {{ stats.biggestLoss ? `${stats.biggestLoss.ticker} ${stats.biggestLoss.pctChange.toFixed(2)}%` : "—" }}
          </p>
          <p v-if="stats.biggestLoss" class="text-xs text-muted">
            {{ shortDate(stats.biggestLoss.date) }}
          </p>
        </div>
        <div>
          <p class="text-xs text-muted">Most volatile</p>
          <p class="mt-1 font-mono text-base font-semibold text-ink">
            {{ stats.mostVolatile ? stats.mostVolatile[0] : "—" }}
          </p>
          <p v-if="stats.mostVolatile" class="text-xs text-muted">
            {{ stats.mostVolatile[1] }} win{{ stats.mostVolatile[1] > 1 ? "s" : "" }} this week
          </p>
        </div>
      </div>
    </div>

  </div>
</template>