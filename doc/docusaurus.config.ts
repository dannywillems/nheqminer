import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import path from 'path';

const config: Config = {
  title: 'nheqminer',
  tagline: 'Equihash CPU miner for Zcash: live build and mining docs',

  url: 'https://dannywillems.github.io',
  baseUrl: '/nheqminer/',

  // GitHub Pages project-site deployment target.
  organizationName: 'dannywillems',
  projectName: 'nheqminer',

  onBrokenLinks: 'throw',

  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  plugins: [
    // Expose the repository build scripts to the docs through an @scripts
    // alias, and load .sh files as raw strings (webpack asset/source) so
    // pages can render the exact, CI-verified scripts.
    function scriptsRawLoaderPlugin() {
      return {
        name: 'scripts-raw-loader',
        configureWebpack() {
          return {
            resolve: {
              alias: {
                '@scripts': path.resolve(__dirname, '../scripts'),
              },
            },
            module: {
              rules: [{ test: /\.sh$/, type: 'asset/source' }],
            },
          };
        },
      };
    },
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          remarkPlugins: [remarkMath],
          rehypePlugins: [rehypeKatex],
          editUrl:
            'https://github.com/dannywillems/nheqminer/tree/zebra-mining/doc/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  // KaTeX stylesheet for math rendering.
  stylesheets: [
    {
      href: 'https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css',
      type: 'text/css',
      integrity:
        'sha384-nB0miv6/jRmo5UMMR1wu3Gz6NLsoTkbqJghGIsx//Rlm+ZU03BU6SQNC66uf4l5+',
      crossOrigin: 'anonymous',
    },
  ],

  // Local search, no external service.
  themes: [
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        indexDocs: true,
        indexBlog: false,
        indexPages: true,
        language: ['en'],
        highlightSearchTermsOnTargetPage: true,
      },
    ],
  ],

  themeConfig: {
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'nheqminer',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://github.com/dannywillems/nheqminer',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: 'nheqminer documentation',
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'toml', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
