<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useData, useRoute, withBase } from 'vitepress'

const { lang, isDark } = useData()
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
const heroImage = computed(() => withBase('/heroes/zh-hans/devices.webp'))
const screenshotPages = ['home', 'detail', 'battle', 'team', 'map']
const activeScreenshot = computed(() => withBase(`/screenshots/${screenshotLocale.value}/${screenshotPages[activeFeature.value]}.webp`))

const translations: Record<string, any> = {
  root: {
    brand: 'Pocket Gallery', navFeatures: 'Features', navUpdates: 'What’s New', navFaq: 'FAQ', navDownload: 'Download',
    eyebrow: 'Chosen by 250K Trainers', title: 'The Pokédex for every adventure',
    intro: 'Every Pokémon. Every battle. Always within reach.',
    explore: 'Explore features', available: 'Available on iPhone, iPad, Android, and Huawei devices',
    proof: [['1,000+', 'Pokémon and forms'], ['Gen I–IX', 'Games and regional data'], ['No ads', 'A focused experience']],
    sectionEyebrow: 'One app. Every adventure.', sectionTitle: 'Everything a Trainer needs.',
    sectionIntro: 'Explore. Battle. Build. All in one place.',
    features: [
      { kicker: '01', title: 'Comprehensive', body: 'A complete Pokédex spanning every generation, regional form, and more than a thousand Pokémon.' },
      { kicker: '02', title: 'Informative', body: 'Moves, abilities, stats, forms, descriptions, and game data stay clear and close at hand.' },
      { kicker: '03', title: 'Functional', body: 'Type effectiveness, blind spots, and calculators turn dense battle data into useful decisions.' },
      { kicker: '04', title: 'Personal', body: 'Build your own teams with custom names, moves, forms, and shiny Pokémon.' },
      { kicker: '05', title: 'Explorative', body: 'Navigate the LZA interactive map and find useful locations without leaving the app.' },
    ],
    trustEyebrow: 'Focused by design', trustTitle: 'Powerful tools. None of the noise.',
    trust: [['Offline ready', 'Keep essential reference data close, even when the network is not.'], ['Private by default', 'The global Google Play listing declares no data collected or shared.'], ['Made for every screen', 'Thoughtful layouts for phones and tablets across platforms.'], ['Nine languages', 'Explore in English, Chinese, Japanese, Korean, and major European languages.']],
    updatesEyebrow: 'Always evolving', updatesTitle: 'New adventures, already inside.', updatesBody: 'Recent releases add Pokémon and moves from Pokémon Legends: Z-A, DLC data, the LZA interactive map, and ongoing refinements.', updatesLink: 'Read all release notes',
    downloadEyebrow: 'Get Pocket Gallery', downloadTitle: 'Choose your store', downloadBody: '',
    official: 'Official channel', open: 'Open store', global: 'Global', regions: 'Availability varies by region',
    footer: 'An unofficial, fan-made companion. Not affiliated with Nintendo, GAME FREAK, or The Pokémon Company.',
    legal: 'Legal & support', globalSite: 'Global', chinaSite: '中国大陆',
  },
  'zh-hans': {
    brand: '破壳萌图鉴', navFeatures: '功能亮点', navUpdates: '更新日志', navFaq: '常见问题', navDownload: '下载',
    eyebrow: '25 万训练家之选', title: '图鉴随身，冒险随行',
    intro: '查图鉴、算对战、配队伍，所需资料一站备齐。',
    explore: '查看功能', available: '支持 iPhone、iPad、Android 与华为设备',
    proof: [['1,000+', '宝可梦与形态'], ['第一至第九世代', '游戏与地区资料'], ['无广告', '专注纯粹的体验']],
    sectionEyebrow: '一款应用，伴你探索每场冒险', sectionTitle: '训练家所需，尽在其中',
    sectionIntro: '图鉴、对战、配队，一站搞定。',
    features: [
      { kicker: '01', title: '图鉴齐全', body: '收录第一至第九世代超过 1,000 只宝可梦及其地区形态。' },
      { kicker: '02', title: '资料详实', body: '招式、特性、能力值、形态与图鉴介绍，清晰易查。' },
      { kicker: '03', title: '功能强大', body: '属性克制、攻防盲点、能力值与伤害计算，复杂数据一目了然。' },
      { kicker: '04', title: '自由配队', body: '自定义队名，自由搭配招式、形态与异色宝可梦。' },
      { kicker: '05', title: '地图探索', body: '《宝可梦传说 Z-A》互动地图，地点与收集信息一目了然。' },
    ],
    trustEyebrow: '专注体验', trustTitle: '功能强大，体验纯粹',
    trust: [['离线可用', '无需网络，常用资料也能随时查阅。'], ['重视隐私', '不收集、不共享用户数据。'], ['多端适配', '针对手机和平板精心优化。'], ['九种语言', '支持中文、英语、日语、韩语及多种欧洲语言。']],
    updatesEyebrow: '持续更新', updatesTitle: '新冒险，已就位', updatesBody: '现已收录《宝可梦传说 Z-A》、DLC 与互动地图等最新内容。', updatesLink: '查看全部更新日志',
    downloadEyebrow: '立即获取破壳萌图鉴', downloadTitle: '选择你的平台', downloadBody: '',
    official: '官方渠道', open: '前往商店', global: '全球', regions: '部分地区可用',
    footer: '由粉丝独立制作的非官方应用，与 Nintendo、GAME FREAK 或 The Pokémon Company 无任何关联。', legal: '法律与支持', globalSite: 'Global', chinaSite: '中国大陆',
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
    <main>
      <section class="pg-hero">
        <div class="pg-hero-copy">
          <p class="pg-eyebrow">{{ copy.eyebrow }}</p>
          <h1>{{ copy.title }}</h1>
          <p class="pg-hero-lede">{{ copy.intro }}</p>
          <div class="pg-actions"><a class="pg-button primary" href="#download">{{ copy.navDownload }}</a><a class="pg-button secondary" href="#features">{{ copy.explore }}</a></div>
        </div>
        <div class="pg-hero-visual"><div class="pg-hero-glow"></div><img :src="heroImage" alt="破壳萌图鉴在 iPad、Android 手机与 iPhone 上的界面"></div>
      </section>

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
        <div class="pg-chapters"><article v-for="(feature, index) in copy.features" :key="feature.title" :data-feature-index="index" :class="{ active: activeFeature === index }"><span>{{ feature.kicker }}</span><h3>{{ feature.title }}</h3><p>{{ feature.body }}</p></article></div>
      </section>

      <section id="download" class="pg-download"><div class="pg-shell"><p class="pg-eyebrow">{{ copy.downloadEyebrow }}</p><h2>{{ copy.downloadTitle }}</h2><div class="pg-store-badges"><a v-for="store in stores" :key="store.name" :href="store.url" target="_blank" rel="noopener" class="pg-store-badge" :aria-label="store.name"><img :src="withBase(`/${store.badge}`)" :alt="store.name"></a></div></div></section>
    </main>

    <footer class="pg-footer"><div class="pg-shell"><div class="pg-footer-brand"><img :src="withBase('/logo.png')" alt=""><strong>{{ copy.brand }}</strong></div><p>{{ copy.footer }}</p><small>© 2022–2026 破壳萌图鉴 · <a href="https://beian.miit.gov.cn/">苏ICP备2023003413号-1</a> · <a href="https://beian.mps.gov.cn/#/query/webSearch?code=32059002005040">苏公网安备32059002005040号</a></small></div></footer>
  </div>
</template>
