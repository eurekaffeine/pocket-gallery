module.exports = {
  base: "/pocket-gallery/",
  themeConfig: {
    logo: "/logo.png",
    locales: {
      "/": {
        selectText: "Languages",
        nav: [
          { text: "Home", link: "/" },
          { text: "Release Notes", link: "/release-notes/" },
        ],
      },
      "/zh-hans/": {
        selectText: "语言",
        nav: [
          { text: "主页", link: "/zh-hans/" },
          { text: "更新记录", link: "/zh-hans/release-notes/" },
        ],
      },
      "/zh-hant/": {
        selectText: "語言",
        nav: [
          { text: "主頁", link: "/zh-hant/" },
          { text: "更新記錄", link: "/zh-hant/release-notes/" },
        ],
      },
      "/ja-jp/": {
        selectText: "言語",
        nav: [
          { text: "ホームページ", link: "/ja-jp/" },
          { text: "更新記録", link: "/ja-jp/release-notes/" },
        ],
      },
    },
    search: false,
    sidebar: "auto",
  },
  locales: {
    "/": {
      lang: "English",
      title: "Pocket Gallery",
      description: "A consise Pokédex App",
    },
    "/zh-hans/": {
      lang: "简体中文",
      title: "破壳萌图鉴",
      description: "一款简洁大方的宝可梦图鉴应用",
    },
    "/zh-hant/": {
      lang: "繁體中文",
      title: "破殼萌圖鑑",
      description: "一款簡潔大方的寶可夢圖鑑應用",
    },
    "/ja-jp/": {
      lang: "日本語",
      title: "ポケット ギャラリー",
      description: "シンプルで上品なポケモンイラストアプリ",
    },
  },
};
