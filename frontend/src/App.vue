<script setup>
import { ref, onMounted } from "vue";
import TabBar from "./components/TabBar.vue";
import DailyView from "./components/DailyView.vue";
import HistoryView from "./components/HistoryView.vue";

const API_URL = import.meta.env.VITE_API_BASE_URL
  ? `${import.meta.env.VITE_API_BASE_URL.replace(/\/$/, "")}/movers`
  : "/movers";

const movers = ref([]);
const status = ref("loading");
const activeTab = ref("daily");
const selectedMover = ref(null);

const TABS = [
  { id: "daily", label: "Daily" },
  { id: "history", label: "History" },
];

async function loadMovers() {
  status.value = "loading";
  try {
    const res = await fetch(API_URL);
    if (!res.ok) throw new Error(`Request failed: ${res.status}`);
    movers.value = await res.json();
    selectedMover.value = movers.value[0] || null;
    status.value = "ready";
  } catch (err) {
    console.error(err);
    status.value = "error";
  }
}

onMounted(loadMovers);

function onCardSelect(mover) {
  selectedMover.value = mover;
  activeTab.value = "daily";
}

function onTabChange(tab) {
  activeTab.value = tab;
  // Reset to latest when switching back to daily without a card selected.
  if (tab === "daily" && !selectedMover.value && movers.value.length) {
    selectedMover.value = movers.value[0];
  }
}
</script>

<template>
  <main class="min-h-screen px-4 py-10 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-2xl">
      <header class="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold tracking-tight text-ink">Top Movers</h1>
          <p class="mt-1 text-sm text-muted">Biggest daily move across the watchlist.</p>
        </div>
        <div class="flex items-center gap-3">
          <TabBar :tabs="TABS" :active="activeTab" @change="onTabChange" />
          <button
            class="rounded-full border border-panel-border bg-panel px-3 py-1.5 text-sm text-muted transition hover:text-ink"
            @click="loadMovers"
          >
            ↻
          </button>
        </div>
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
      <template v-else>
        <DailyView
          v-if="activeTab === 'daily'"
          :mover="selectedMover || movers[0]"
          :movers="movers"
        />
        <HistoryView
          v-else-if="activeTab === 'history'"
          :movers="movers"
          @select="onCardSelect"
        />
       
      </template>
    </div>
  </main>
</template>