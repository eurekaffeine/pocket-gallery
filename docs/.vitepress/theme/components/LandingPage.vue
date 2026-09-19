<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useData, useRoute, withBase } from 'vitepress'

const { lang } = useData()
const mainland = true
const route = useRoute()
const activeFeature = ref(0)
const menuOpen = ref(false)
let observer: IntersectionObserver | undefined

const localeKey = computed(() => {
  const path = route.path
  if (path.includes('/zh-hans/')) return 'zh-hans'
  if (path.includes('/zh-hant/')) return 'zh-hant'
  if (path.includes('/ja-jp/')) return 'ja-jp'
  if (path.includes('/es/')) return 'es'
  if (path.includes('/fr/')) return 'fr'
  if (path.includes('/de/')) return 'de'
  if (path.includes('/it/')) return 'it'
  if (path.includes('/ko/')) return 'ko'
  return mainland ? 'zh-hans' : 'root'
})

const prefix = computed(() => mainland || localeKey.value === 'root' ? '/' : `/${localeKey.value}/`)
const isChinese = computed(() => lang.value.startsWith('zh'))
const screenshotLocale = computed(() => 'zh-hans')
const screenshotPages = ['home', 'detail', 'battle', 'team', 'map']
const activeScreenshot = computed(() => withBase(`/screenshots/${screenshotLocale.value}/${screenshotPages[activeFeature.value]}.webp`))

const translations: Record<string, any> = {
  root: {
    brand: 'Pocket Gallery', navFeatures: 'Features', navUpdates: 'What’s New', navFaq: 'FAQ', navDownload: 'Download',
    eyebrow: '', title: '250K Trainers’ Choice',
    intro: 'Explore every generation, understand every matchup, and build your team in one beautifully focused app.',
    explore: 'Explore features', available: 'Available on iPhone, iPad, Android, and Huawei devices',
    proof: [['1,000+', 'Pokémon and forms'], ['Gen I–IX', 'Games and regional data'], ['No ads', 'A focused experience']],
    sectionEyebrow: 'One app. Every answer.', sectionTitle: 'Made for the way trainers explore.',
    sectionIntro: 'Scroll through Pocket Gallery’s most useful tools. The interface stays quiet, so the information can lead.',
    features: [
      { kicker: 'Discover', title: 'Find anything in seconds.', body: 'Search and filter a complete Pokédex spanning every generation and regional form.' },
      { kicker: 'Understand', title: 'The detail behind every choice.', body: 'Moves, abilities, stats, forms, descriptions, and game data stay clear and close at hand.' },
      { kicker: 'Compete', title: 'See the matchup before it starts.', body: 'Type effectiveness, blind spots, and calculators turn dense battle data into useful decisions.' },
      { kicker: 'Create', title: 'Build the team imagined.', body: 'Choose forms, moves, shiny variants, and custom names in a team builder made to stay out of the way.' },
      { kicker: 'Explore', title: 'A map built for discovery.', body: 'Navigate the LZA interactive map and find useful locations without leaving the app.' },
    ],
    trustEyebrow: 'Focused by design', trustTitle: 'Powerful tools. None of the noise.',
    trust: [['Offline ready', 'Keep essential reference data close, even when the network is not.'], ['Private by default', 'The global Google Play listing declares no data collected or shared.'], ['Made for every screen', 'Thoughtful layouts for phones and tablets across platforms.'], ['Nine languages', 'Explore in English, Chinese, Japanese, Korean, and major European languages.']],
    updatesEyebrow: 'Always evolving', updatesTitle: 'New adventures, already inside.', updatesBody: 'Recent releases add Pokémon and moves from Pokémon Legends: Z-A, DLC data, the LZA interactive map, and ongoing refinements.', updatesLink: 'Read all release notes',
    downloadEyebrow: 'Choose your channel', downloadTitle: 'Download Pocket Gallery your way.', downloadBody: 'Every official distribution channel is shown below. Pick the store that works best on your device and in your region.',
    official: 'Official channel', open: 'Open store', global: 'Global', regions: 'Availability varies by region',
    footer: 'An unofficial, fan-made companion. Not affiliated with Nintendo, GAME FREAK, or The Pokémon Company.',
    legal: 'Legal & support', globalSite: 'Global', chinaSite: '中国大陆',
  },
  'zh-hans': {
    brand: '破壳萌图鉴', navFeatures: '功能', navUpdates: '更新记录', navFaq: '常见问题', navDownload: '下载',
    eyebrow: '', title: '25万训练家的选择',
    intro: '查图鉴、看资料、算对战、配队伍，一款简洁专注的宝可梦工具。',
    explore: '探索功能', available: '支持 iPhone、iPad、Android 与华为设备',
    proof: [['1,000+', '宝可梦与形态'], ['第一至第九世代', '游戏与地区资料'], ['无广告', '专注纯粹的体验']],
    sectionEyebrow: '一款应用，所有答案', sectionTitle: '为训练家探索资料的方式而设计。',
    sectionIntro: '向下滚动，了解破壳萌图鉴最实用的功能。界面保持克制，让信息成为主角。',
    features: [
      { kicker: '发现', title: '几秒之内，找到答案。', body: '搜索和筛选跨越全部世代、包含地区形态的完整图鉴。' },
      { kicker: '了解', title: '每一个选择，都有详实资料。', body: '招式、特性、能力值、形态、图鉴描述和游戏资料清晰呈现。' },
      { kicker: '对战', title: '对战开始前，看清克制关系。', body: '属性克制、打击盲点、联防盲点和计算器，让复杂数据变成有效决策。' },
      { kicker: '创造', title: '组建心目中的队伍。', body: '自由配置形态、招式、异色与自定义名称，编辑过程简单直接。' },
      { kicker: '探索', title: '为发现而生的地图。', body: '通过 LZA 交互地图查找地点与资料，无需离开应用。' },
    ],
    trustEyebrow: '专注设计', trustTitle: '强大功能，没有多余干扰。',
    trust: [['离线可用', '没有网络时，重要的参考资料依然触手可及。'], ['尊重隐私', '全球 Google Play 页面声明不收集或共享用户数据。'], ['适配多种屏幕', '为不同平台的手机和平板提供用心设计的布局。'], ['九种语言', '支持中文、英语、日语、韩语及多种欧洲语言。']],
    updatesEyebrow: '持续进化', updatesTitle: '新的冒险，已经就位。', updatesBody: '近期版本加入《宝可梦传说 Z-A》的宝可梦和招式、DLC 资料、LZA 交互地图，并持续优化体验。', updatesLink: '查看完整更新记录',
    downloadEyebrow: '选择下载渠道', downloadTitle: '通过适合你的方式下载。', downloadBody: '所有官方分发渠道均在下方完整展示。请根据设备和所在地区选择应用商店。',
    official: '官方渠道', open: '打开商店', global: '全球', regions: '可用地区因商店而异',
    footer: '非官方粉丝应用，与 Nintendo、GAME FREAK 或 The Pokémon Company 无关联。', legal: '法律与支持', globalSite: 'Global', chinaSite: '中国大陆',
  },
}

Object.assign(translations, {
  'zh-hant': { ...translations['zh-hans'], brand: '破殼萌圖鑑', navUpdates: '更新記錄', navFaq: '常見問題', navDownload: '下載', title: '把完整圖鑑，裝進口袋。', intro: '查圖鑑、看資料、算對戰、配隊伍，一款簡潔專注的寶可夢工具。', explore: '探索功能', available: '支援 iPhone、iPad、Android 與華為裝置', official: '官方管道', open: '開啟商店', global: '全球', footer: '非官方粉絲應用，與 Nintendo、GAME FREAK 或 The Pokémon Company 無關聯。' },
  'ja-jp': { ...translations.root, brand: 'ポケット・ギャラリー', navFeatures: '機能', navUpdates: '更新記録', navFaq: 'よくある質問', navDownload: 'ダウンロード', eyebrow: 'ポケモン図鑑を、もう一度考える', title: 'すべての情報を、ポケットに。', intro: '図鑑を調べ、バトルを理解し、理想のチームをひとつの美しいアプリで。', explore: '機能を見る', available: 'iPhone、iPad、Android、Huawei デバイスに対応', official: '公式チャンネル', open: 'ストアを開く' },
  es: { ...translations.root, navFeatures: 'Funciones', navUpdates: 'Novedades', navFaq: 'Preguntas', navDownload: 'Descargar', eyebrow: 'La Pokédex, reinventada', title: 'Cada detalle. En tu bolsillo.', intro: 'Explora cada generación, comprende cada combate y crea tu equipo en una app elegante.', explore: 'Ver funciones', available: 'Disponible en iPhone, iPad, Android y dispositivos Huawei', official: 'Canal oficial', open: 'Abrir tienda' },
  fr: { ...translations.root, navFeatures: 'Fonctions', navUpdates: 'Nouveautés', navFaq: 'Questions', navDownload: 'Télécharger', eyebrow: 'Le Pokédex réinventé', title: 'Chaque détail. Dans votre poche.', intro: 'Explorez chaque génération, comprenez chaque combat et composez votre équipe dans une app élégante.', explore: 'Voir les fonctions', available: 'Disponible sur iPhone, iPad, Android et appareils Huawei', official: 'Canal officiel', open: 'Ouvrir la boutique' },
  de: { ...translations.root, navFeatures: 'Funktionen', navUpdates: 'Neuigkeiten', navFaq: 'FAQ', navDownload: 'Laden', eyebrow: 'Der Pokédex, neu gedacht', title: 'Jedes Detail. Direkt in deiner Tasche.', intro: 'Entdecke jede Generation, verstehe jedes Matchup und baue dein Team in einer klaren App.', explore: 'Funktionen entdecken', available: 'Für iPhone, iPad, Android und Huawei-Geräte', official: 'Offizieller Kanal', open: 'Store öffnen' },
  it: { ...translations.root, navFeatures: 'Funzioni', navUpdates: 'Novità', navFaq: 'Domande', navDownload: 'Scarica', eyebrow: 'Il Pokédex, ripensato', title: 'Ogni dettaglio. Sempre in tasca.', intro: 'Esplora ogni generazione, comprendi ogni sfida e crea la tua squadra in un’unica app.', explore: 'Scopri le funzioni', available: 'Disponibile su iPhone, iPad, Android e dispositivi Huawei', official: 'Canale ufficiale', open: 'Apri store' },
  ko: { ...translations.root, brand: '포켓 갤러리', navFeatures: '기능', navUpdates: '업데이트', navFaq: '자주 묻는 질문', navDownload: '다운로드', eyebrow: '새롭게 생각한 포켓몬 도감', title: '모든 정보를, 주머니 속에.', intro: '모든 세대를 탐색하고, 배틀을 이해하며, 나만의 팀을 하나의 앱에서 구성하세요.', explore: '기능 살펴보기', available: 'iPhone, iPad, Android 및 Huawei 기기 지원', official: '공식 채널', open: '스토어 열기' },
})

const copy = computed(() => {
  const selected = translations[localeKey.value] || translations.root
  if (!mainland) return selected
  return {
    ...selected,
    trust: [
      ['离线可用', '没有网络时，重要的参考资料依然触手可及。'],
      ['不含广告', '界面不被广告打断，始终专注于需要的信息。'],
      ['三大平台', '用心适配 iOS、Android 与 HarmonyOS。'],
      ['持续维护', '独立开发并不断跟进新游戏与资料更新。'],
    ],
  }
})

const stores = [
  { name: 'App Store', badge: 'app-store-badge-zh-hans.svg', url: 'https://apps.apple.com/us/app/pocket-gallery-app/id6464266038' },
  { name: '华为应用市场', badge: 'app-gallery-badge-en.png', url: 'https://url.cloud.huawei.com/nlFEFYg8Cc?shareTo=qrcode' },
]

const languages = [['简体中文', '/']]

onMounted(() => {
  const chapters = document.querySelectorAll<HTMLElement>('[data-feature-index]')
  observer = new IntersectionObserver((entries) => {
    const visible = entries.filter(entry => entry.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0]
    if (visible) activeFeature.value = Number((visible.target as HTMLElement).dataset.featureIndex)
  }, { rootMargin: '-28% 0px -42%', threshold: [0.1, 0.35, 0.65] })
  chapters.forEach(chapter => observer?.observe(chapter))
})

onBeforeUnmount(() => observer?.disconnect())
</script>

<template>
  <div class="pg-site">
    <header class="pg-nav">
      <div class="pg-nav-inner">
        <a class="pg-brand" :href="withBase(prefix)"><img :src="withBase('/logo.png')" alt=""><span>{{ copy.brand }}</span></a>
        <button class="pg-menu-button" :aria-expanded="menuOpen" aria-label="Menu" @click="menuOpen = !menuOpen"><span></span><span></span></button>
        <nav class="pg-links" :class="{ open: menuOpen }">
          <a href="#features" @click="menuOpen = false">{{ copy.navFeatures }}</a>
          <a :href="withBase(`${prefix}release-notes/`)">{{ copy.navUpdates }}</a>
          <a :href="withBase(`${prefix}faq/`)">{{ copy.navFaq }}</a>
          <a v-if="mainland" class="pg-region-link" href="https://eurekaffeine.github.io/pocket-gallery/">Global</a>
          <details v-else class="pg-language"><summary>{{ lang.toUpperCase() }}</summary><div><a v-for="item in languages" :key="item[1]" :href="withBase(item[1])">{{ item[0] }}</a></div></details>
          <a class="pg-nav-cta" href="#download">{{ copy.navDownload }}</a>
        </nav>
      </div>
    </header>

    <main>
      <section class="pg-hero">
        <div class="pg-hero-copy">
          <h1>{{ copy.title }}</h1>
          <div class="pg-actions"><a class="pg-button primary" href="#download">{{ copy.navDownload }}</a><a class="pg-button secondary" href="#features">{{ copy.explore }} <span>↓</span></a></div>
        </div>
        <div class="pg-hero-visual"><div class="pg-hero-glow"></div><img :src="withBase('/hero.png')" alt="Pocket Gallery shown on tablet, Android phone, and iPhone"></div>
      </section>

      <section class="pg-proof"><div v-for="item in [['1,000+', '宝可梦与形态'], ['三大平台', 'iOS · Android · HarmonyOS'], ['无广告', '专注纯粹的体验']]" :key="item[0]"><strong>{{ item[0] }}</strong><span>{{ item[1] }}</span></div></section>

      <section id="features" class="pg-feature-intro pg-shell"><p class="pg-eyebrow">{{ copy.sectionEyebrow }}</p><h2>{{ copy.sectionTitle }}</h2><p>{{ copy.sectionIntro }}</p></section>

      <section class="pg-story pg-shell">
        <div class="pg-phone-column">
          <div class="pg-phone">
            <div class="pg-phone-speaker"></div>
            <div class="pg-phone-screen">
              <img :key="activeScreenshot" class="pg-device-screenshot" :src="activeScreenshot" :alt="copy.features[activeFeature].title">
            </div>
          </div>
        </div>
        <div class="pg-chapters"><article v-for="(feature, index) in copy.features" :key="feature.title" :data-feature-index="index" :class="{ active: activeFeature === index }"><span>0{{ index + 1 }}</span><p class="pg-eyebrow">{{ feature.kicker }}</p><h3>{{ feature.title }}</h3><p>{{ feature.body }}</p></article></div>
      </section>

      <section class="pg-trust"><div class="pg-shell"><p class="pg-eyebrow">{{ copy.trustEyebrow }}</p><h2>{{ copy.trustTitle }}</h2><div class="pg-trust-grid"><article v-for="(item,index) in copy.trust" :key="item[0]"><span>{{ ['↯','◎','▱','文'][index] }}</span><h3>{{ item[0] }}</h3><p>{{ item[1] }}</p></article></div></div></section>

      <section class="pg-updates pg-shell"><div><p class="pg-eyebrow">{{ copy.updatesEyebrow }}</p><h2>{{ copy.updatesTitle }}</h2><p>{{ copy.updatesBody }}</p><a :href="withBase(`${prefix}release-notes/`)">{{ copy.updatesLink }} →</a></div><div class="pg-update-art"><span>Z–A</span><i></i><b>New data<br>New map<br>New adventures</b></div></section>

      <section id="download" class="pg-download"><div class="pg-shell"><p class="pg-eyebrow">{{ copy.downloadEyebrow }}</p><h2>{{ copy.downloadTitle }}</h2><p class="pg-download-intro">{{ copy.downloadBody }}</p><div class="pg-store-badges"><a v-for="store in stores" :key="store.name" :href="store.url" target="_blank" rel="noopener" class="pg-store-badge" :aria-label="store.name"><img :src="withBase(`/${store.badge}`)" :alt="store.name"></a></div></div></section>
    </main>

    <footer class="pg-footer"><div class="pg-shell"><div class="pg-footer-brand"><img :src="withBase('/logo.png')" alt=""><strong>{{ copy.brand }}</strong></div><p>{{ copy.footer }}</p><nav><a href="/faq/">常见问题</a><a href="/support-us/">支持我们</a><a href="/others/#隐私政策">隐私政策</a><a href="https://eurekaffeine.github.io/pocket-gallery/">Global</a></nav><small>© 2022–2026 破壳萌图鉴 · <a href="https://beian.miit.gov.cn/">苏ICP备2023003413号-1</a> · <a href="https://beian.mps.gov.cn/#/query/webSearch?code=32059002005040">苏公网安备32059002005040号</a></small></div></footer>
  </div>
</template>
