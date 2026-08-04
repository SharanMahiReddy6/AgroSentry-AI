/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#2E7D32",
          light: "#E8F5E9",
          dark: "#1B5E20",
        },
        background: "#F5F5F5",
        surface: "#FFFFFF",
        accent: "#4CAF50",
        danger: "#D32F2F",
        warning: "#FFA000",
        success: "#388E3C",
      },
      borderRadius: {
        xl: "16px",
        lg: "12px",
      },
    },
  },
  plugins: [],
  darkMode: 'class',
}
