// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Fleetbox',
  tagline: 'Keep track of your vehicle maintenance.',
  url: 'https://fleetbox.io',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'LutrisEng', // Usually your GitHub org/user name.
  projectName: 'fleetbox', // Usually your repo name.

  clientModules: [
    require.resolve('./src/sentry.ts')
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl: 'https://github.com/LutrisEng/fleetbox/tree/main/Documentation/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          editUrl: 'https://github.com/LutrisEng/fleetbox/tree/main/Documentation/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  plugins: [
    '@docusaurus/plugin-ideal-image',
    '@cmfcmf/docusaurus-search-local'
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'Fleetbox',
        logo: {
          alt: 'Fleetbox Logo',
          src: 'img/logo.png',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'User Manual',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'https://github.com/LutrisEng/fleetbox',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'User Manual',
                to: '/docs/intro',
              },
            ],
          },
          // {
          //   title: 'Community',
          //   items: [
          //     {
          //       label: 'Stack Overflow',
          //       href: 'https://stackoverflow.com/questions/tagged/docusaurus',
          //     },
          //     {
          //       label: 'Discord',
          //       href: 'https://discordapp.com/invite/docusaurus',
          //     },
          //     {
          //       label: 'Twitter',
          //       href: 'https://twitter.com/docusaurus',
          //     },
          //   ],
          // },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/LutrisEng/fleetbox',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Lutris, Inc. Lutris and Fleetbox are trademarks of Lutris, Inc. All rights reserved. App Store, Mac App Store, iOS, iPadOS, and macOS are trademarks of Apple, Inc., registered in the U.S. and other countries. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
