import { defineConfig } from 'vitepress'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const configDir = dirname(fileURLToPath(import.meta.url))

export default defineConfig({
  lang: 'zh-Hans',
  title: '破壳萌图鉴',
  description: '把完整图鉴装进口袋。查图鉴、看资料、算对战、配队伍。',
  outDir: resolve(configDir, '../.vuepress/dist'),
  vite: { publicDir: resolve(configDir, '../.vuepress/public') },
  cleanUrls: true,
  lastUpdated: true,
  sitemap: { hostname: 'https://www.pocket-gallery.cn/' },
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#d60032' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:image', content: 'https://www.pocket-gallery.cn/hero.png' }],
  ],
  themeConfig: {
    logo: '/logo.png',
    siteTitle: '破壳萌图鉴',
    search: { provider: 'local' },
    nav: [
      { text: '功能', link: '/#features' },
      { text: '更新记录', link: '/release-notes/' },
      { text: '常见问题', link: '/faq/' },
      { text: '支持我们', link: '/support-us/' },
      { text: '下载', link: '/#download' },
      { text: 'Global', link: 'https://eurekaffeine.github.io/pocket-gallery/' },
    ],
    outline: { level: [2, 3] },
    docFooter: { prev: false, next: false },
  },
})
