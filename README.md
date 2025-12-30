# Pocket Gallery (破壳萌图鉴)

<div align="center">
  <img src="docs/.vuepress/public/logo.png" alt="Pocket Gallery Logo" width="200"/>
  <p><strong>一款简洁大方的宝可梦图鉴应用</strong></p>
  <p>A comprehensive and elegant Pokédex application</p>
</div>

## 📖 About

**Pocket Gallery (破壳萌图鉴)** is an independently developed and maintained Pokédex application. Built with love for Pokémon enthusiasts, this app provides detailed information about all Pokémon across all generations.

### ✨ Key Features

- **📚 Complete Pokédex**: Comprehensive data for all 1025 Pokémon from Generation 1 to Generation 9
- **📝 Detailed Information**: Includes moves, abilities, items, weather, terrains, status conditions, and more
- **⚔️ Battle Tools**: Designed for competitive players with type matchup calculator, blind spots, and stat calculator
- **🎨 Team Builder**: Create and customize your Pokémon teams with support for shiny forms and custom names
- **🗺️ Interactive Maps**: LZA Interactive Map support
- **🌐 Multi-language Support**: Currently supporting Simplified Chinese
- **🎯 No Ads**: Free of advertisements and user data collection

## 🎮 Platform Availability

<div align="center">
  
[![App Store](docs/.vuepress/public/app-store-badge-zh-hans.svg)](https://apps.apple.com/us/app/pocket-gallery-app/id6464266038)

[![Huawei App Gallery](docs/.vuepress/public/app-gallery-badge-en.png)](https://url.cloud.huawei.com/nlFEFYg8Cc?shareTo=qrcode)

</div>

## 🌐 Website

Visit our official documentation website: [Pocket Gallery Docs](https://eurekaffeine.github.io/pocket-gallery/)

The website is built with VuePress and includes:
- Comprehensive release notes
- FAQ section
- Support information
- Additional resources

## 🚀 Development

This repository contains the VuePress-based documentation website for Pocket Gallery.

### Prerequisites

- Node.js
- Yarn or npm

### Installation

```bash
# Install dependencies
yarn install
# or
npm install
```

### Development

```bash
# Start development server
yarn docs:dev
# or
npm run docs:dev
```

The documentation site will be available at `http://localhost:8080`

### Build

```bash
# Build for production
yarn docs:build
# or
npm run docs:build
```

The built files will be generated in `docs/.vuepress/dist`

### Deployment

The project includes an automated deployment script for GitHub Pages:

```bash
./deploy.sh
```

This script will:
1. Build the documentation
2. Navigate to the dist directory
3. Initialize a git repository
4. Push to the `gh-pages` branch

## 📂 Project Structure

```
pocket-gallery/
├── docs/                    # Documentation source
│   ├── .vuepress/          # VuePress configuration
│   │   ├── config.js       # Site configuration
│   │   └── public/         # Static assets
│   ├── README.md           # Homepage
│   ├── faq/                # FAQ section
│   ├── release-notes/      # Version history
│   ├── support-us/         # Support information
│   └── others/             # Other resources
├── deploy.sh               # Deployment script
├── package.json            # Project dependencies
└── README.md               # This file
```

## 🔄 Recent Updates

### V3.3 (Latest)
- Added LZA Interactive Map
- Bug fixes and improvements

### V3.2
- Added "Z-A Ultra Dimension Burst" DLC data
- Bug fixes

### V3.1
- Added Pokémon and moves from "Legends: Z-A"
- Bug fixes

See the full [release notes](docs/release-notes/README.md) for complete version history.

## 💖 Support Us

Pocket Gallery is developed and maintained independently without ads or user data monetization. If you find this app useful, please consider supporting us:

- **Alipay**: See [Support Us](docs/support-us/README.md)
- **WeChat Pay**: See [Support Us](docs/support-us/README.md)

Your support helps us continue maintaining and improving the app for the Pokémon community.

## 📜 License

This project is licensed under the MIT License. See the [package.json](package.json) for details.

## ⚠️ Legal Notice

Pokémon and Pokémon character names are trademarks of Nintendo. Images used in this application are copyrighted but are believed to be used within fair use guidelines. This application does not intend to infringe on any copyrights. **Use at your own discretion.**

---

<div align="center">
  <p>Made with ❤️ for Pokémon Trainers</p>
  <p>Copyright © 2022-2025 破壳萌图鉴</p>
</div>
