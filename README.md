
# Firefox AppImages

<img height="128" src="https://www.mozilla.org/media/protocol/img/logos/firefox/browser/beta/logo.9d84b80dbb88.svg" alt="Firefox Beta logo" align="right" />
<img height="128" src="https://www.mozilla.org/media/protocol/img/logos/firefox/browser/nightly/logo.91c8528645bc.svg" alt ="Firefox Nightly logo" align="right" />
<img height="128" src="https://www.mozilla.org/media/protocol/img/logos/firefox/browser/logo.eb1324e44442.svg" alt="Firefox logo" align="right" />

Automated unofficial AppImages builds for the following release channels:

- Stable
- ESR (Extended Support Release)
- Beta
- Developer Edition
- Nightly

[![Downloads](https://img.shields.io/github/downloads/lincolnthalles/Firefox-Appimage/total?logo=github)](https://github.com/lincolnthalles/Firefox-Appimage/releases) [![GitHub Stars](https://img.shields.io/github/stars/lincolnthalles/Firefox-Appimage?logo=github)](https://github.com/lincolnthalles/Firefox-Appimage)

## Get Started

Download the latest release from the [Releases](https://github.com/lincolnthalles/Firefox-Appimage/releases/) page.

Alternatively, use [`zap`](https://github.com/srevinsaju/zap), the command line AppImage package manager

```bash
zap install --github --from=lincolnthalles/Firefox-AppImage firefox-appimage
```

### Executing

#### File Manager

Just double click the `*.AppImage` file and you are done!

> In normal cases, the above method should work, but in some rare cases
the `+x` permissisions. So, right click > Properties > Allow Execution

#### Terminal

```bash
./Firefox-*.AppImage
```

```bash
chmod +x Firefox-*.AppImage
./Firefox-*.AppImage
```

In case, if FUSE support libraries are not installed on the host system, it is
still possible to run the AppImage

```bash
./Firefox-*.AppImage --appimage-extract
cd squashfs-root
./AppRun
```

## License

"Mozilla Firefox" is licensed under the [Mozilla Public License 2.0  (MPL 2.0)](https://en.wikipedia.org/wiki/Mozilla_Public_License)

The official source code of Mozilla Firefox is available at:

- <https://firefox-source-docs.mozilla.org/>
- <https://hg.mozilla.org/mozilla-central/>
