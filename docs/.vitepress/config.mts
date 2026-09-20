import { defineConfig } from 'vitepress'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const configDir = dirname(fileURLToPath(import.meta.url))

const base = '/pocket-gallery/'

const localeMeta = {
  root: { label: 'English', lang: 'en', path: '/', title: 'Pocket Gallery', description: 'Pokédex, battles, and team building—all in one app.' },
  'zh-hans': { label: '简体中文', lang: 'zh-Hans', path: '/zh-hans/', title: '破壳萌图鉴', description: '查图鉴、算对战、配队伍，所需资料一站备齐。' },
  'zh-hant': { label: '繁體中文', lang: 'zh-Hant', path: '/zh-hant/', title: '破殼萌圖鑑', description: '查圖鑑、算對戰、配隊伍，所需資料一次備齊。' },
  'ja-jp': { label: '日本語', lang: 'ja-JP', path: '/ja-jp/', title: 'ポケット・ギャラリー', description: 'ポケモン図鑑、バトル、チーム編成に必要な情報をひとつのアプリに。' },
  es: { label: 'Español', lang: 'es', path: '/es/', title: 'Pocket Gallery', description: 'Pokédex, combates y equipos: toda la información en una sola app.' },
  fr: { label: 'Français', lang: 'fr', path: '/fr/', title: 'Pocket Gallery', description: 'Pokédex, combats et équipes : toutes les informations dans une seule app.' },
  de: { label: 'Deutsch', lang: 'de', path: '/de/', title: 'Pocket Gallery', description: 'Pokédex, Kämpfe und Teams: alle wichtigen Informationen in einer App.' },
  it: { label: 'Italiano', lang: 'it', path: '/it/', title: 'Pocket Gallery', description: 'Pokédex, lotte e squadre: tutte le informazioni in un’unica app.' },
  ko: { label: '한국어', lang: 'ko', path: '/ko/', title: '포켓 갤러리', description: '도감, 배틀, 팀 구성에 필요한 정보를 하나의 앱에.' },
} as const

const navCopy: Record<string, { features: string; updates: string; faq: string; others: string; download: string }> = {
  root: { features: 'Features', updates: 'What’s New', faq: 'FAQ', others: 'About Us', download: 'Download' },
  'zh-hans': { features: '功能亮点', updates: '更新日志', faq: '常见问题', others: '关于我们', download: '下载' },
  'zh-hant': { features: '功能亮點', updates: '更新日誌', faq: '常見問題', others: '關於我們', download: '下載' },
  'ja-jp': { features: '機能', updates: '更新履歴', faq: 'よくある質問', others: '私たちについて', download: 'ダウンロード' },
  es: { features: 'Funciones', updates: 'Novedades', faq: 'Preguntas frecuentes', others: 'Sobre nosotros', download: 'Descargar' },
  fr: { features: 'Fonctionnalités', updates: 'Nouveautés', faq: 'Questions fréquentes', others: 'À propos', download: 'Télécharger' },
  de: { features: 'Funktionen', updates: 'Neuigkeiten', faq: 'Häufige Fragen', others: 'Über uns', download: 'Herunterladen' },
  it: { features: 'Funzioni', updates: 'Novità', faq: 'Domande frequenti', others: 'Chi siamo', download: 'Scarica' },
  ko: { features: '주요 기능', updates: '업데이트', faq: '자주 묻는 질문', others: '소개', download: '다운로드' },
}

function localizedTheme(key: string) {
  const locale = localeMeta[key as keyof typeof localeMeta]
  const copy = navCopy[key]
  const prefix = locale.path
  return {
    siteTitle: locale.title,
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
  },
})
