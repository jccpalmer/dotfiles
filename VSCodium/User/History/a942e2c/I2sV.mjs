import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'My Docs',
			social: {
				linkedin: 'https://linkedin.com/in/jccpalmer',
				github: 'https://github.com/jccpalmer/docs',
			},
			favicon: 'favicon.svg',
			sidebar: [
				{
					label: 'Getting started',
					items: [
						{ label: 'Welcome!', slug: 'getting-started/landing'},
					],
				},
				{
					label: 'Docker',
					items: [
						{ label: 'Grav', slug: 'docker/grav/grav' },
						{ label: 'Gluetun', slug: 'docker/gluetun/gluetun' },
						{ label: 'Deluge', slug: 'docker/deluge-vpn/deluge-vpn' },
					],
				},
				{
					label: 'Software',
					items: [
						{ label: 'Pi-hole', slug: 'software/pi-hole/pi-hole'},
						{ label: 'NixOS', slug: 'software/nixos/nixos'},
					],
				},
				{
					label: 'Hardware',
					autogenerate: { directory: 'hardware' },
				},
				{
					label: 'About',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'About me', slug: 'about/about-me' },
					],
				},
			],
		}),
	],
});
