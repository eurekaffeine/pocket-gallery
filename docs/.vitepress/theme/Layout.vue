<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'
import LandingPage from './components/LandingPage.vue'

const { frontmatter } = useData()
</script>

<template>
  <DefaultTheme.Layout>
    <template v-if="frontmatter.pageClass === 'pg-landing-page'" #page-top>
      <LandingPage />
    </template>
  </DefaultTheme.Layout>
</template>
