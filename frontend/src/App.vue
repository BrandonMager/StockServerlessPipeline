<script setup>
import { ref, onMounted } from "vue";
import MoverCard from "./components/MoverCard.vue";

const API_URL = import.meta.env.VITE_API_BASE_URL
  ? `${import.meta.env.VITE_API_BASE_URL.replace(/\/$/, "")}/movers`
  : "/movers";

const movers = ref([]); 
const status = ref("loading");

async function loadMovers() {
  status.value = "loading";
  try {
    const res = await fetch(API_URL);
    if (!res.ok) throw new Error(`Request failed: ${res.status}`);
    movers.value = await res.json();
    status.value = "ready";
  } catch (err) {
    console.error(err);
    status.value = "error";
  }
}

onMounted(loadMovers);
</script>

<template>
  <main class="min-h-screen px-4 py-10 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-3xl">
      <header class="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold tracking-tight text-ink">Top Movers</h1>
          <p class="mt-1 text-sm text-muted">Biggest daily move across the watchlist — last 7 trading days.</p>
        </div>
        <button
          class="flex items-center gap-1.5 rounded-full bg-gain px-4 py-2 text-sm font-semibold text-navy-deep transition hover:bg-gain/90"
          @click="loadMovers"
        >
          ↻ Refresh
        </button>
      </header>
    
      <div v-if="status === 'loading'" class="py-16 text-center text-sm text-muted">
        Loading…
      </div>

      <div
        v-else-if="status === 'error'"
        class="rounded-2xl border border-panel-border bg-panel p-6 text-center shadow-panel"
      >
        <p class="text-sm font-medium text-loss">Couldn't load the data.</p>
        <p class="mt-1 text-sm text-muted">Check that the API is reachable, then try again.</p>
        <button
          class="mt-4 rounded-full bg-gain px-4 py-2 text-sm font-semibold text-navy-deep"
          @click="loadMovers"
        >
          Retry
        </button>
      </div>

      <div
        v-else-if="movers.length === 0"
        class="rounded-2xl border border-dashed border-panel-border bg-panel p-12 text-center shadow-panel"
      >
        <p class="text-sm font-medium text-ink">No movers yet</p>
        <p class="mt-1 text-sm text-muted">Check back after the next scheduled run.</p>
      </div>

      <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <MoverCard v-for="m in movers" :key="m.date" :mover="m" />
      </div>
    </div>
  </main>
</template>