import { defineConfig } from 'vitepress'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const configDir = dirname(fileURLToPath(import.meta.url))

const base = '/pocket-gallery/'

const localeMeta = {
  root: { label: 'English', lang: 'en', path: '/', title: 'Pocket Gallery', description: 'A focused Pokédex for every trainer.' },
  'zh-hans': { label: '简体中文', lang: 'zh-Hans', path: '/zh-hans/', title: '破壳萌图鉴', description: '一款简洁、全面的宝可梦图鉴应用。' },
  'zh-hant': { label: '繁體中文', lang: 'zh-Hant', path: '/zh-hant/', title: '破殼萌圖鑑', description: '一款簡潔、全面的寶可夢圖鑑應用。' },
  'ja-jp': { label: '日本語', lang: 'ja-JP', path: '/ja-jp/', title: 'ポケット・ギャラリー', description: 'すべてのトレーナーのためのポケモン図鑑。' },
  es: { label: 'Español', lang: 'es', path: '/es/', title: 'Pocket Gallery', description: 'Una Pokédex completa y concisa.' },
  fr: { label: 'Français', lang: 'fr', path: '/fr/', title: 'Pocket Gallery', description: 'Un Pokédex complet et épuré.' },
  de: { label: 'Deutsch', lang: 'de', path: '/de/', title: 'Pocket Gallery', description: 'Ein vollständiger, übersichtlicher Pokédex.' },
  it: { label: 'Italiano', lang: 'it', path: '/it/', title: 'Pocket Gallery', description: 'Un Pokédex completo ed essenziale.' },
  ko: { label: '한국어', lang: 'ko', path: '/ko/', title: '포켓 갤러리', description: '모든 트레이너를 위한 간결한 포켓몬 도감.' },
} as const

const navCopy: Record<string, { features: string; updates: string; faq: string; others: string; download: string }> = {
  root: { features: 'Features', updates: 'What’s New', faq: 'FAQ', others: 'About', download: 'Download' },
  'zh-hans': { features: '功能', updates: '更新记录', faq: '常见问题', others: '其他', download: '下载' },
  'zh-hant': { features: '功能', updates: '更新記錄', faq: '常見問題', others: '其他', download: '下載' },
  'ja-jp': { features: '機能', updates: '更新記録', faq: 'よくある質問', others: 'その他', download: 'ダウンロード' },
  es: { features: 'Funciones', updates: 'Novedades', faq: 'Preguntas', others: 'Otros', download: 'Descargar' },
  fr: { features: 'Fonctions', updates: 'Nouveautés', faq: 'Questions', others: 'Autres', download: 'Télécharger' },
  de: { features: 'Funktionen', updates: 'Neuigkeiten', faq: 'FAQ', others: 'Andere', download: 'Laden' },
  it: { features: 'Funzioni', updates: 'Novità', faq: 'Domande', others: 'Altro', download: 'Scarica' },
  ko: { features: '기능', updates: '업데이트', faq: '자주 묻는 질문', others: '기타', download: '다운로드' },
}

function localizedTheme(key: string) {
  const locale = localeMeta[key as keyof typeof localeMeta]
  const copy = navCopy[key]
  const prefix = locale.path
  return {
    nav: [
      { text: copy.features, link: `${prefix}#features` },
      { text: copy.updates, link: `${prefix}release-notes/` },
      { text: copy.faq, link: `${prefix}faq/` },
      { text: copy.others, link: `${prefix}others/` },
      { text: copy.download, link: `${prefix}#download`, activeMatch: '^$' },
    ],
    outline: { level: [2, 3] as [number, number] },
    docFooter: { prev: false, next: false },
    returnToTopLabel: 'Back to top',
    sidebarMenuLabel: 'Menu',
    darkModeSwitchLabel: 'Appearance',
  }
}

const locales = Object.fromEntries(
  Object.entries(localeMeta).map(([key, value]) => [key, {
    label: value.label,
    lang: value.lang,
    title: value.title,
    description: value.description,
    link: value.path,
    themeConfig: localizedTheme(key),
  }]),
)

export default defineConfig({
  base,
  srcDir: '.',
  outDir: resolve(configDir, '../.vuepress/dist'),
  vite: {
    publicDir: resolve(configDir, '../.vuepress/public'),
  },
  cleanUrls: true,
  lastUpdated: true,
  sitemap: { hostname: 'https://eurekaffeine.github.io/pocket-gallery/' },
  head: [
    ['link', { rel: 'icon', href: `${base}favicon.ico` }],
    ['meta', { name: 'theme-color', content: '#d60032' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:image', content: 'https://eurekaffeine.github.io/pocket-gallery/hero.png' }],
  ],
  locales,
  themeConfig: {
    logo: '/logo.png',
    siteTitle: 'Pocket Gallery',
    search: { provider: 'local' },
    socialLinks: [{ icon: 'github', link: 'https://github.com/eurekaffeine/pocket-gallery' }],
  },
})
