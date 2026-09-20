<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useData, useRoute, withBase } from 'vitepress'

const { lang, isDark } = useData()
const route = useRoute()
const activeFeature = ref(0)
const menuOpen = ref(false)
const languageOpen = ref(false)
const languageMenu = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | undefined

const localeKey = computed(() => {
  const value = lang.value.toLowerCase()
  if (value.startsWith('zh-hans')) return 'zh-hans'
  if (value.startsWith('zh-hant')) return 'zh-hant'
  if (value.startsWith('ja')) return 'ja-jp'
  if (value.startsWith('es')) return 'es'
  if (value.startsWith('fr')) return 'fr'
  if (value.startsWith('de')) return 'de'
  if (value.startsWith('it')) return 'it'
  if (value.startsWith('ko')) return 'ko'
  return 'root'
})

const prefix = computed(() => localeKey.value === 'root' ? '/' : `/${localeKey.value}/`)
const isChinese = computed(() => lang.value.startsWith('zh'))
const screenshotLocale = computed(() => localeKey.value === 'root' ? 'en' : localeKey.value)
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
  'zh-hant': {
    brand: '破殼萌圖鑑', navFeatures: '功能亮點', navUpdates: '更新日誌', navFaq: '常見問題', navDownload: '下載',
    eyebrow: '25 萬訓練家之選', title: '圖鑑隨身，冒險同行',
    intro: '查圖鑑、算對戰、配隊伍，所需資料一次備齊。', explore: '查看功能',
    sectionEyebrow: '一款應用，伴你探索每場冒險', sectionTitle: '訓練家所需，盡在其中',
    sectionIntro: '圖鑑、對戰、配隊，一站完成。',
    features: [
      { kicker: '01', title: '圖鑑齊全', body: '收錄第一至第九世代超過 1,000 隻寶可夢及其地區形態。' },
      { kicker: '02', title: '資料詳實', body: '招式、特性、能力值、形態與圖鑑介紹，清晰易查。' },
      { kicker: '03', title: '功能強大', body: '屬性相剋、攻防盲點、能力值與傷害計算，複雜資料一目了然。' },
      { kicker: '04', title: '自由組隊', body: '自訂隊伍名稱，自由搭配招式、形態與異色寶可夢。' },
      { kicker: '05', title: '地圖探索', body: '《寶可夢傳說 Z-A》互動地圖，地點與收集資訊一目了然。' },
    ],
    downloadEyebrow: '立即取得破殼萌圖鑑', downloadTitle: '選擇你的平台', downloadBody: '',
    official: '官方管道', open: '前往商店', global: '全球', regions: '部分地區提供',
    footer: '由粉絲獨立製作的非官方應用，與 Nintendo、GAME FREAK 或 The Pokémon Company 無任何關聯。',
    legal: '法律與支援', globalSite: 'Global', chinaSite: '中國大陸',
  },
  'ja-jp': {
    brand: 'ポケット・ギャラリー', navFeatures: '機能', navUpdates: '更新履歴', navFaq: 'よくある質問', navDownload: 'ダウンロード',
    eyebrow: '25万人のトレーナーに選ばれた図鑑', title: '図鑑を手に、冒険へ',
    intro: 'ポケモン図鑑、バトル、チーム編成。必要な情報をひとつのアプリに。', explore: '機能を見る',
    sectionEyebrow: 'ひとつのアプリで、すべての冒険を', sectionTitle: 'トレーナーに必要なものを、すべて',
    sectionIntro: '調べる。戦う。チームを組む。これひとつで。',
    features: [
      { kicker: '01', title: '充実の図鑑', body: '第1世代から第9世代まで、リージョンフォームを含む1,000種類以上のポケモンを収録。' },
      { kicker: '02', title: '豊富な情報', body: 'わざ、とくせい、能力値、すがた、図鑑説明を見やすく掲載。' },
      { kicker: '03', title: '便利なツール', body: 'タイプ相性や攻守の範囲、能力値・ダメージ計算をひとまとめに。' },
      { kicker: '04', title: '自由なチーム編成', body: 'チーム名、わざ、すがた、色違いのポケモンを自由に設定。' },
      { kicker: '05', title: 'マップ探索', body: '『Pokémon LEGENDS Z-A』インタラクティブマップで、場所や収集情報をすぐに確認。' },
    ],
    downloadEyebrow: 'ポケット・ギャラリーを入手', downloadTitle: 'ストアを選択', downloadBody: '',
    official: '公式配信', open: 'ストアを開く', global: 'グローバル', regions: '一部地域で利用可能',
    footer: 'ファンが独自に制作した非公式アプリです。Nintendo、GAME FREAK、The Pokémon Company とは一切関係ありません。',
    legal: '法的情報とサポート', globalSite: 'Global', chinaSite: '中国大陸',
  },
  es: {
    brand: 'Pocket Gallery', navFeatures: 'Funciones', navUpdates: 'Novedades', navFaq: 'Preguntas frecuentes', navDownload: 'Descargar',
    eyebrow: 'La elección de 250 mil Entrenadores', title: 'Tu Pokédex para cada aventura',
    intro: 'Pokédex, combates y equipos. Toda la información en una sola app.', explore: 'Ver funciones',
    sectionEyebrow: 'Una app para cada aventura', sectionTitle: 'Todo lo que necesita un Entrenador',
    sectionIntro: 'Explora. Combate. Crea tu equipo. Todo en un solo lugar.',
    features: [
      { kicker: '01', title: 'Completa', body: 'Más de 1.000 Pokémon de las nueve generaciones, incluidas sus formas regionales.' },
      { kicker: '02', title: 'Detallada', body: 'Movimientos, habilidades, estadísticas, formas y entradas de la Pokédex, siempre a mano.' },
      { kicker: '03', title: 'Práctica', body: 'Eficacia de tipos, coberturas ofensivas y defensivas, y calculadoras de estadísticas y daño.' },
      { kicker: '04', title: 'Personal', body: 'Crea equipos con nombres, movimientos, formas y Pokémon variocolor personalizados.' },
      { kicker: '05', title: 'Exploración', body: 'Consulta ubicaciones y coleccionables en el mapa interactivo de Leyendas Pokémon: Z-A.' },
    ],
    downloadEyebrow: 'Descarga Pocket Gallery', downloadTitle: 'Elige tu tienda', downloadBody: '',
    official: 'Canal oficial', open: 'Abrir tienda', global: 'Global', regions: 'Disponible en algunas regiones',
    footer: 'Aplicación no oficial creada de forma independiente por fans. No está afiliada a Nintendo, GAME FREAK ni The Pokémon Company.',
    legal: 'Información legal y asistencia', globalSite: 'Global', chinaSite: 'China continental',
  },
  fr: {
    brand: 'Pocket Gallery', navFeatures: 'Fonctionnalités', navUpdates: 'Nouveautés', navFaq: 'Questions fréquentes', navDownload: 'Télécharger',
    eyebrow: 'Le choix de 250 000 Dresseurs', title: 'Votre Pokédex pour chaque aventure',
    intro: 'Pokédex, combats et équipes : toutes les informations dans une seule app.', explore: 'Voir les fonctionnalités',
    sectionEyebrow: 'Une app pour toutes vos aventures', sectionTitle: 'Tout ce dont un Dresseur a besoin',
    sectionIntro: 'Explorez. Combattez. Composez votre équipe. Tout est là.',
    features: [
      { kicker: '01', title: 'Complet', body: 'Plus de 1 000 Pokémon des neuf générations, formes régionales comprises.' },
      { kicker: '02', title: 'Détaillé', body: 'Capacités, talents, statistiques, formes et descriptions du Pokédex, toujours à portée de main.' },
      { kicker: '03', title: 'Pratique', body: 'Efficacité des types, couvertures offensives et défensives, calculs de statistiques et de dégâts.' },
      { kicker: '04', title: 'Personnalisable', body: 'Composez vos équipes avec des noms, capacités, formes et Pokémon chromatiques personnalisés.' },
      { kicker: '05', title: 'Exploration', body: 'Repérez lieux et objets à collectionner sur la carte interactive de Légendes Pokémon : Z-A.' },
    ],
    downloadEyebrow: 'Télécharger Pocket Gallery', downloadTitle: 'Choisissez votre boutique', downloadBody: '',
    official: 'Canal officiel', open: 'Ouvrir la boutique', global: 'International', regions: 'Disponible dans certaines régions',
    footer: 'Application non officielle créée indépendamment par des fans. Elle n’est affiliée ni à Nintendo, ni à GAME FREAK, ni à The Pokémon Company.',
    legal: 'Mentions légales et assistance', globalSite: 'Global', chinaSite: 'Chine continentale',
  },
  de: {
    brand: 'Pocket Gallery', navFeatures: 'Funktionen', navUpdates: 'Neuigkeiten', navFaq: 'Häufige Fragen', navDownload: 'Herunterladen',
    eyebrow: 'Die Wahl von 250.000 Trainern', title: 'Dein Pokédex für jedes Abenteuer',
    intro: 'Pokédex, Kämpfe und Teams: alle wichtigen Informationen in einer App.', explore: 'Funktionen entdecken',
    sectionEyebrow: 'Eine App für jedes Abenteuer', sectionTitle: 'Alles, was ein Trainer braucht',
    sectionIntro: 'Entdecken. Kämpfen. Teams planen. Alles an einem Ort.',
    features: [
      { kicker: '01', title: 'Vollständig', body: 'Mehr als 1.000 Pokémon aus allen neun Generationen – inklusive Regionalformen.' },
      { kicker: '02', title: 'Detailreich', body: 'Attacken, Fähigkeiten, Statuswerte, Formen und Pokédex-Einträge übersichtlich aufbereitet.' },
      { kicker: '03', title: 'Praktisch', body: 'Typeneffektivität, offensive und defensive Abdeckung sowie Status- und Schadensrechner.' },
      { kicker: '04', title: 'Persönlich', body: 'Erstelle Teams mit eigenen Namen, Attacken, Formen und Schillernden Pokémon.' },
      { kicker: '05', title: 'Erkundung', body: 'Finde Orte und Sammelobjekte auf der interaktiven Karte zu Pokémon-Legenden: Z-A.' },
    ],
    downloadEyebrow: 'Pocket Gallery herunterladen', downloadTitle: 'Store auswählen', downloadBody: '',
    official: 'Offizieller Kanal', open: 'Store öffnen', global: 'Global', regions: 'In ausgewählten Regionen verfügbar',
    footer: 'Inoffizielle, unabhängig von Fans entwickelte App. Keine Verbindung zu Nintendo, GAME FREAK oder The Pokémon Company.',
    legal: 'Rechtliches und Support', globalSite: 'Global', chinaSite: 'Festlandchina',
  },
  it: {
    brand: 'Pocket Gallery', navFeatures: 'Funzioni', navUpdates: 'Novità', navFaq: 'Domande frequenti', navDownload: 'Scarica',
    eyebrow: 'La scelta di 250.000 Allenatori', title: 'Il tuo Pokédex per ogni avventura',
    intro: 'Pokédex, lotte e squadre: tutte le informazioni in un’unica app.', explore: 'Scopri le funzioni',
    sectionEyebrow: 'Un’app per ogni avventura', sectionTitle: 'Tutto ciò che serve a un Allenatore',
    sectionIntro: 'Esplora. Lotta. Crea la tua squadra. Tutto in un solo posto.',
    features: [
      { kicker: '01', title: 'Completo', body: 'Oltre 1.000 Pokémon di tutte le nove generazioni, incluse le forme regionali.' },
      { kicker: '02', title: 'Dettagliato', body: 'Mosse, abilità, statistiche, forme e descrizioni del Pokédex sempre a portata di mano.' },
      { kicker: '03', title: 'Pratico', body: 'Efficacia dei tipi, coperture offensive e difensive, calcolo di statistiche e danni.' },
      { kicker: '04', title: 'Personale', body: 'Crea squadre con nomi, mosse, forme e Pokémon cromatici personalizzati.' },
      { kicker: '05', title: 'Esplorazione', body: 'Trova luoghi e oggetti da raccogliere nella mappa interattiva di Leggende Pokémon: Z-A.' },
    ],
    downloadEyebrow: 'Scarica Pocket Gallery', downloadTitle: 'Scegli lo store', downloadBody: '',
    official: 'Canale ufficiale', open: 'Apri lo store', global: 'Globale', regions: 'Disponibile in alcune regioni',
    footer: 'App non ufficiale sviluppata in modo indipendente dai fan. Non è affiliata a Nintendo, GAME FREAK o The Pokémon Company.',
    legal: 'Informazioni legali e assistenza', globalSite: 'Global', chinaSite: 'Cina continentale',
  },
  ko: {
    brand: '포켓 갤러리', navFeatures: '주요 기능', navUpdates: '업데이트', navFaq: '자주 묻는 질문', navDownload: '다운로드',
    eyebrow: '25만 트레이너의 선택', title: '모든 모험을 위한 포켓몬 도감',
    intro: '도감, 배틀, 팀 구성에 필요한 정보를 하나의 앱에.', explore: '기능 살펴보기',
    sectionEyebrow: '하나의 앱으로, 모든 모험을', sectionTitle: '트레이너에게 필요한 모든 것',
    sectionIntro: '탐색하고, 배틀하고, 팀을 구성하세요. 모두 한곳에서.',
    features: [
      { kicker: '01', title: '완벽한 도감', body: '1세대부터 9세대까지 지역 모습을 포함한 1,000종 이상의 포켓몬을 수록했습니다.' },
      { kicker: '02', title: '풍부한 정보', body: '기술, 특성, 능력치, 모습과 도감 설명을 한눈에 확인하세요.' },
      { kicker: '03', title: '실전 도구', body: '타입 상성, 공격·방어 범위, 능력치 및 데미지 계산을 제공합니다.' },
      { kicker: '04', title: '자유로운 팀 구성', body: '팀 이름, 기술, 모습과 색이 다른 포켓몬을 자유롭게 설정하세요.' },
      { kicker: '05', title: '지도 탐색', body: 'Pokémon LEGENDS Z-A 인터랙티브 지도에서 장소와 수집 정보를 확인하세요.' },
    ],
    downloadEyebrow: '포켓 갤러리 다운로드', downloadTitle: '스토어 선택', downloadBody: '',
    official: '공식 채널', open: '스토어 열기', global: '글로벌', regions: '일부 지역에서 이용 가능',
    footer: '팬이 독립적으로 제작한 비공식 앱입니다. Nintendo, GAME FREAK, The Pokémon Company와 관련이 없습니다.',
    legal: '법적 고지 및 지원', globalSite: 'Global', chinaSite: '중국 본토',
  },
})

const copy = computed(() => translations[localeKey.value] || {
  ...translations.root,
  brand: localeKey.value === 'ja-jp' ? 'ポケット・ギャラリー' : localeKey.value === 'ko' ? '포켓 갤러리' : 'Pocket Gallery',
})

const badgeLocale = computed(() => ({
  root: 'en', 'zh-hans': 'zh-hans', 'zh-hant': 'zh-hant', 'ja-jp': 'jp',
  es: 'es', fr: 'fr', de: 'de', it: 'it', ko: 'ko',
}[localeKey.value] || 'en'))
const googleBadgeLocale = computed(() => localeKey.value === 'ja-jp' ? 'ja' : badgeLocale.value)
const appGalleryLocales = new Set(['en', 'de', 'es', 'fr', 'it', 'jp', 'ko'])
const appGalleryBadge = computed(() => {
  const locale = appGalleryLocales.has(badgeLocale.value) ? badgeLocale.value : 'en'
  return `app-gallery-badge-${locale}.${locale === 'en' || locale === 'it' ? 'png' : 'svg'}`
})
const stores = computed(() => [
  { name: 'App Store', badge: `app-store-badge-${badgeLocale.value}.svg`, url: 'https://apps.apple.com/us/app/pocket-gallery-app/id6464266038' },
  { name: 'Google Play', badge: `google-play-badge-${googleBadgeLocale.value}.png`, url: 'https://play.google.com/store/apps/details?id=com.eurekaffeine.pokedex.renaissance' },
  { name: 'Huawei AppGallery', badge: appGalleryBadge.value, url: 'https://url.cloud.huawei.com/nlFEFYg8Cc?shareTo=qrcode' },
])

const languages = [
  ['English', '/'], ['简体中文', '/zh-hans/'], ['繁體中文', '/zh-hant/'], ['日本語', '/ja-jp/'],
  ['Español', '/es/'], ['Français', '/fr/'], ['Deutsch', '/de/'], ['Italiano', '/it/'], ['한국어', '/ko/'],
]
const currentLanguageLabel = computed(() => ({
  root: 'English', 'zh-hans': '简体中文', 'zh-hant': '繁體中文', 'ja-jp': '日本語',
  es: 'Español', fr: 'Français', de: 'Deutsch', it: 'Italiano', ko: '한국어',
}[localeKey.value] || 'English'))

function observeFeatureChapters() {
  observer?.disconnect()
  const chapters = document.querySelectorAll<HTMLElement>('[data-feature-index]')
  observer = new IntersectionObserver((entries) => {
    const visible = entries.filter(entry => entry.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0]
    if (visible) activeFeature.value = Number((visible.target as HTMLElement).dataset.featureIndex)
  }, { rootMargin: '-28% 0px -42%', threshold: [0.1, 0.35, 0.65] })
  chapters.forEach(chapter => observer?.observe(chapter))
}

function closeLanguageMenu() {
  languageOpen.value = false
}

function handleOutsidePointer(event: PointerEvent) {
  if (languageOpen.value && !languageMenu.value?.contains(event.target as Node)) closeLanguageMenu()
}

function handleEscape(event: KeyboardEvent) {
  if (event.key === 'Escape') closeLanguageMenu()
}

onMounted(() => {
  observeFeatureChapters()
  document.addEventListener('pointerdown', handleOutsidePointer)
  document.addEventListener('keydown', handleEscape)
})

watch(lang, async () => {
  closeLanguageMenu()
  menuOpen.value = false
  activeFeature.value = 0
  await nextTick()
  requestAnimationFrame(observeFeatureChapters)
})

onBeforeUnmount(() => {
  observer?.disconnect()
  document.removeEventListener('pointerdown', handleOutsidePointer)
  document.removeEventListener('keydown', handleEscape)
})
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
        <div class="pg-hero-visual"><div class="pg-hero-glow"></div><img :src="withBase('/hero.png')" alt="Pocket Gallery shown on tablet, Android phone, and iPhone"></div>
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

    <footer class="pg-footer"><div class="pg-shell"><div class="pg-footer-brand"><img :src="withBase('/logo.png')" alt=""><strong>{{ copy.brand }}</strong></div><p>{{ copy.footer }}</p><small>© 2022–2026 Pocket Gallery</small></div></footer>
  </div>
</template>
