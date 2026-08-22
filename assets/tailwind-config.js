tailwind.config = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Pretendard Variable', 'Pretendard', '-apple-system', 'BlinkMacSystemFont', 'Apple SD Gothic Neo', 'Segoe UI', 'Roboto', 'sans-serif']
      },
      colors: {
        background: '#0a0612',
        surface: '#15101f',
        'surface-elevated': '#1c1530',
        foreground: '#f5f1ff',
        muted: '#1a1428',
        'muted-foreground': '#9b94b3',
        border: 'rgba(140,110,200,0.22)',
        'neon-purple': '#b566ff',
        'neon-pink': '#ff5fb0',
        'neon-blue': '#5ec8ff'
      },
      animation: {
        'fade-up': 'fade-up 0.7s cubic-bezier(0.22,1,0.36,1) both',
        'glow-pulse': 'glow-pulse 3s ease-in-out infinite',
        'shimmer': 'shimmer 6s linear infinite'
      },
      keyframes: {
        'fade-up': { '0%': { opacity: 0, transform: 'translateY(24px)' }, '100%': { opacity: 1, transform: 'translateY(0)' } },
        'glow-pulse': { '0%,100%': { boxShadow: '0 0 20px -8px rgba(181,102,255,0.5)' }, '50%': { boxShadow: '0 0 35px -4px rgba(181,102,255,0.85)' } },
        'shimmer': { '0%': { backgroundPosition: '0% 50%' }, '100%': { backgroundPosition: '200% 50%' } }
      }
    }
  }
};
