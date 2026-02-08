import { defineUserConfig } from 'vuepress'
import { defaultTheme } from '@vuepress/theme-default'
import { viteBundler } from '@vuepress/bundler-vite'

export default defineUserConfig({
  base: '/pocket-gallery/',
  
  bundler: viteBundler(),
  
  locales: {
    '/': {
      lang: 'en-US',
      title: 'Pocket Gallery',
      description: 'A consise Pokédex App',
    },
    '/zh-hans/': {
      lang: 'zh-CN',
      title: '破壳萌图鉴',
      description: '一款简洁大方的宝可梦图鉴应用',
    },
    '/zh-hant/': {
      lang: 'zh-TW',
      title: '破殼萌圖鑑',
      description: '一款簡潔大方的寶可夢圖鑑應用',
    },
    '/ja-jp/': {
      lang: 'ja-JP',
      title: 'ポケット・ギャラリー',
      description: 'シンプルで上品なポケモンイラストアプリ',
    },
    '/es/': {
      lang: 'es-ES',
      title: 'Pocket Gallery',
      description: 'Una aplicación de Pokédex concisa',
    },
    '/fr/': {
      lang: 'fr-FR',
      title: 'Pocket Gallery',
      description: 'Une application Pokédex concise',
    },
    '/de/': {
      lang: 'de-DE',
      title: 'Pocket Gallery',
      description: 'Eine prägnante Pokédex-App',
    },
    '/it/': {
      lang: 'it-IT',
      title: 'Pocket Gallery',
      description: "Un'app Pokédex concisa",
    },
    '/ko/': {
      lang: 'ko-KR',
      title: '포켓 갤러리',
      description: '간결한 포켓몬 도감 앱',
    },
  },

  theme: defaultTheme({
    logo: '/logo.png',
    lastUpdated: false,
    contributors: false,
    
    locales: {
      '/': {
        selectLanguageName: 'English',
        navbar: [
          { text: 'Home', link: '/' },
          { text: 'Release Notes', link: '/release-notes/' },
          { text: 'FAQ', link: '/faq/' },
          { text: 'Others', link: '/others/' },
        ],
      },
      '/zh-hans/': {
        selectLanguageName: '简体中文',
        navbar: [
          { text: '主页', link: '/zh-hans/' },
          { text: '更新记录', link: '/zh-hans/release-notes/' },
          { text: '常见问题', link: '/zh-hans/faq/' },
          { text: '其他', link: '/zh-hans/others/' },
        ],
      },
      '/zh-hant/': {
        selectLanguageName: '繁體中文',
        navbar: [
          { text: '主頁', link: '/zh-hant/' },
          { text: '更新記錄', link: '/zh-hant/release-notes/' },
          { text: '常見問題', link: '/zh-hant/faq/' },
          { text: '其他', link: '/zh-hant/others/' },
        ],
      },
      '/ja-jp/': {
        selectLanguageName: '日本語',
        navbar: [
          { text: 'ホームページ', link: '/ja-jp/' },
          { text: '更新記録', link: '/ja-jp/release-notes/' },
          { text: 'よくある質問', link: '/ja-jp/faq/' },
          { text: 'その他', link: '/ja-jp/others/' },
        ],
      },
      '/es/': {
        selectLanguageName: 'Español',
        navbar: [
          { text: 'Inicio', link: '/es/' },
          { text: 'Notas de la versión', link: '/es/release-notes/' },
          { text: 'Preguntas frecuentes', link: '/es/faq/' },
          { text: 'Otros', link: '/es/others/' },
        ],
      },
      '/fr/': {
        selectLanguageName: 'Français',
        navbar: [
          { text: 'Accueil', link: '/fr/' },
          { text: 'Notes de version', link: '/fr/release-notes/' },
          { text: 'Questions fréquemment posées', link: '/fr/faq/' },
          { text: 'Autres', link: '/fr/others/' },
        ],
      },
      '/de/': {
        selectLanguageName: 'Deutsch',
        navbar: [
          { text: 'Startseite', link: '/de/' },
          { text: 'Versionshinweise', link: '/de/release-notes/' },
          { text: 'Häufig gestellte Fragen', link: '/de/faq/' },
          { text: 'Andere', link: '/de/others/' },
        ],
      },
      '/it/': {
        selectLanguageName: 'Italiano',
        navbar: [
          { text: 'Home', link: '/it/' },
          { text: 'Note sulla versione', link: '/it/release-notes/' },
          { text: 'Domande frequenti', link: '/it/faq/' },
          { text: 'Altri', link: '/it/others/' },
        ],
      },
      '/ko/': {
        selectLanguageName: '한국어',
        navbar: [
          { text: '홈', link: '/ko/' },
          { text: '릴리즈 노트', link: '/ko/release-notes/' },
          { text: '자주 묻는 질문', link: '/ko/faq/' },
          { text: '기타', link: '/ko/others/' },
        ],
      },
    },
  }),
})
