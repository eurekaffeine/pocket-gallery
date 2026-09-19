<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'
import LandingPage from './components/LandingPage.vue'

const { frontmatter } = useData()
</script>

<template>
  <LandingPage v-if="frontmatter.layout === 'landing' || frontmatter.home" />
  <DefaultTheme.Layout v-else />
</template>
