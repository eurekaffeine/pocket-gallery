module.exports = {
  base: "/",
  themeConfig: {
    logo: "/logo.png",
    locales: {
      "/en-us/": {
        selectText: "Languages",
        nav: [
          { text: "Home", link: "/en-us/" },
          { text: "Release Notes", link: "/en-us/release-notes/" },
          { text: "Others", link: "/en-us/others/" },
        ],
      },
      "/": {
        selectText: "语言",
        nav: [
          { text: "主页", link: "/" },
          { text: "更新记录", link: "/release-notes/" },
          { text: "其他", link: "/others/" },
        ],
      },
      "/zh-hant/": {
        selectText: "語言",
        nav: [
          { text: "主頁", link: "/zh-hant/" },
          { text: "更新記錄", link: "/zh-hant/release-notes/" },
          { text: "其他", link: "/zh-hant/others/" },
        ],
      },
      "/ja-jp/": {
        selectText: "言語",
        nav: [
          { text: "ホームページ", link: "/ja-jp/" },
          { text: "更新記録", link: "/ja-jp/release-notes/" },
          { text: "その他", link: "/ja-jp/others/" },
        ],
      },
    },
    search: false,
    sidebar: "auto",
  },
  locales: {
    "/en-us/": {
      lang: "English",
      title: "Pocket Gallery",
      description: "A consise Pokédex App",
    },
    "/": {
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
      title: "ポケット・ギャラリー",
      description: "シンプルで上品なポケモンイラストアプリ",
    },
  },
};
