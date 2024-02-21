import { defineConfig } from 'astro/config';
import yaml  from '@rollup/plugin-yaml';

// https://astro.build/config

export default defineConfig({
    site: "https://ceduni.github.io",
    base: "/lino",
    vite: {
        plugins: [yaml()]
    }
});
