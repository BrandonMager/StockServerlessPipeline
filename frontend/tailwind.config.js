/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js}"],
  theme: {
    extend: {
      colors: {
        navy: "#0A0F2C",
        "navy-deep": "#060912",
        panel: "rgba(255,255,255,0.045)",
        "panel-border": "rgba(255,255,255,0.09)",
        ink: "#F4F6FB",
        muted: "#8C93B8",
        gain: { DEFAULT: "#2DD4BF", bg: "rgba(45,212,191,0.14)" },
        loss: { DEFAULT: "#FB7185", bg: "rgba(251,113,133,0.14)" },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["IBM Plex Mono", "ui-monospace", "monospace"],
      },
      boxShadow: {
        "glow-gain": "0 0 50px -12px rgba(45,212,191,0.5)",
        "glow-loss": "0 0 50px -12px rgba(251,113,133,0.5)",
        panel: "0 8px 30px -10px rgba(0,0,0,0.5)",
      },
      borderRadius: {
        "2xl": "1.25rem",
      },
    },
  },
  plugins: [],
};