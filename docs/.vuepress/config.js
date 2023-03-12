module.exports = {
  base: "/",
  themeConfig: {
    logo: "/logo.png",
    locales: {
      "/": {
        selectText: "语言",
        nav: [
          { text: "主页", link: "/" },
          { text: "更新记录", link: "/release-notes/" },
          { text: "支持我们", link: "/support-us/"},
          { text: "其他", link: "/others/" },
        ],
      },
    },
    search: false,
    sidebar: "auto",
  },
  locales: {
    "/": {
      lang: "简体中文",
      title: "破壳萌图鉴",
      description: "一款简洁大方的宝可梦图鉴应用",
    },
  },
};
