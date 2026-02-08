import { defineUserConfig } from 'vuepress'
import { defaultTheme } from '@vuepress/theme-default'
import { viteBundler } from '@vuepress/bundler-vite'

export default defineUserConfig({
  base: '/',
  
  bundler: viteBundler(),
  
  locales: {
    '/': {
      lang: 'zh-CN',
      title: '破壳萌图鉴',
      description: '一款简洁大方的宝可梦图鉴应用',
    },
  },

  theme: defaultTheme({
    logo: '/logo.png',
    lastUpdated: false,
    contributors: false,
    
    locales: {
      '/': {
        selectLanguageName: '简体中文',
        navbar: [
          { text: '主页', link: '/' },
          { text: '更新记录', link: '/release-notes/' },
          { text: '支持我们', link: '/support-us/' },
          { text: '常见问题', link: '/faq/' },
          { text: '其他', link: '/others/' },
        ],
      },
    },

    search: false,
  }),
})
