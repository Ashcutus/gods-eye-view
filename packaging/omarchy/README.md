# Omarchy edition

This directory contains the first Omarchy-native packaging pass for God's Eye
View. It keeps the application as a normal desktop app and uses Omarchy's
existing web-app launcher and Walker application discovery. It does not install
a Quickshell plugin, add a default hotkey, or modify files under `/usr/share/omarchy`.

## Install locally

From the repository root:

```sh
npm run omarchy:check
npm run omarchy:install
```

The installer copies the checkout to
`$XDG_DATA_HOME/gods-eye-view` (normally `~/.local/share/gods-eye-view`),
installs dependencies, runs the upstream doctor check, and registers:

- `~/.local/bin/gods-eye-view-launch`
- `~/.local/share/applications/com.bilawal.GodsEyeView.desktop`
- the existing project logo in the local icon theme

Source `.env` files are deliberately not copied into the installed app. Add
credentials through the in-app Provider Settings panel, or create a local
`.env` in the installed app directory yourself if you need headless setup.
The installer does not delete an existing installed `.env` on updates.

If Node is not available, install the Omarchy Node development environment with
`omarchy install dev-env node` and run the installer again.

## Runtime behavior

The launcher starts the upstream Vite development server on
`127.0.0.1:4173` as the user service `gods-eye-view-4173.service`, then opens the
page with Omarchy's focus-or-launch web-app helper. The server is intentionally
loopback-only. On systems without a user service manager, the launcher falls
back to a PID and log under `$XDG_STATE_HOME/gods-eye-view`.

Useful commands:

```sh
gods-eye-view-launch --status
gods-eye-view-launch --stop
```

Run `npm run omarchy:uninstall` from the original repository checkout to
remove the installed copy and its Walker entry. The uninstaller refuses to
remove the checkout itself.

For a development checkout, set `GEV_APP_ROOT` to the checkout path. Set
`GEV_PORT` if port 4173 is already in use.

## Scope of this pass

This is an installable alpha boundary, not yet a distributable Arch package.
It deliberately uses the upstream dev server so the existing local provider
routes and development-only key setup continue to work. A follow-up pass should
add a production-oriented Node server and a proper package recipe before broad
distribution; the current user-service lifecycle is suitable for local testing,
not a release guarantee.

Review the upstream [data-source notes](../../DATA_SOURCES.md) and
[security notes](../../SECURITY.md) before enabling private providers or
redistributing the project. Some bundled datasets and providers have separate
license or usage restrictions.
