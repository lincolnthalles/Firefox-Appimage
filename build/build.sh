#!/bin/bash

export APPIMAGE_EXTRACT_AND_RUN=1
export FIREFOX_CHANNEL="${FIREFOX_CHANNEL:-firefox-esr}"
export FIREFOX_OS="${FIREFOX_OS:-linux64}"
export FIREFOX_LANG="${FIREFOX_LANG:-en-US}"
export GITHUB_ENV="${GITHUB_ENV:-.GITHUB_ENV}"

set -eu

rm -rf build/AppDir
rm -rf build/firefox*
mkdir -p build/src

FIREFOX_TAR="build/src/${FIREFOX_CHANNEL}-${FIREFOX_OS}-${FIREFOX_LANG}.tar.bz2"

if [[ ! -f "$FIREFOX_TAR" ]]; then
    echo "==> Downloading ${FIREFOX_CHANNEL}"
    if ! wget "https://download.mozilla.org/?product=${FIREFOX_CHANNEL}-latest-ssl&os=${FIREFOX_OS}&lang=${FIREFOX_LANG}" -O "$FIREFOX_TAR"; then
        rm -f "$FIREFOX_TAR" && exit 1
    fi
fi

if ! tar -xvf "$FIREFOX_TAR" -C build ; then
    rm -f "$FIREFOX_TAR" && exit 1
fi
mv build/firefox* build/AppDir

echo "==> Copying AppRun"
sed "s,FIREFOX_BIN_FILE,$(basename build/AppDir/firefox*-bin),g" <AppRun >build/AppDir/AppRun
chmod 755 build/AppDir/AppRun

echo "==> Copying Firefox Desktop file"
cp desktop/"${FIREFOX_CHANNEL}".desktop build/AppDir/.

echo "==> Disable Auto Updates"
cp -r distribution build/AppDir/.

FIREFOX_ICON_NAME="$(grep 'Icon=' <desktop/"${FIREFOX_CHANNEL}".desktop | sed 's,Icon=,,g')"
echo "==> Copying icon :: ${FIREFOX_ICON_NAME}"
ln -sr build/AppDir/browser/chrome/icons/default/default128.png build/AppDir/"${FIREFOX_ICON_NAME}".png

if ! [ -x "$(command -v desktop-file-validate)" ]; then
    sudo apt-get -y install desktop-file-utils
fi

if ! [ -f "build/appimagetool" ]; then
    echo "==> Downloading appimagetool"
    wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$(uname -m).AppImage" -O build/appimagetool
    chmod +x build/appimagetool
fi

echo "==> Generating AppImage"
GH_USER="$(echo "$GITHUB_REPOSITORY" | grep -o ".*/" | head -c-2)"
GH_REPO="$(echo "$GITHUB_REPOSITORY" | grep -o "/.*" | cut -c2-)"

FIREFOX_VERSION="$(grep -E 'Version' <build/AppDir/application.ini | head -n 1 | sed -e 's/Version=\(.*\)$/\1/')"
export FIREFOX_VERSION

FIREFOX_BUILD_ID="$(grep -E 'BuildID' <build/AppDir/application.ini | head -n 1 | sed -e 's/BuildID=\(.*\)$/\1/')"
export FIREFOX_BUILD_ID

case "$FIREFOX_OS" in
"linux64")
    FIREFOX_ARCH="x86_64"
    ;;
"linux")
    FIREFOX_ARCH="i686"
    ;;
*)
    echo "Unsupported OS: $FIREFOX_OS"
    exit 1
    ;;
esac

ARCH=$FIREFOX_ARCH ./build/appimagetool -n --comp zstd \
    build/AppDir \
    --updateinformation "gh-releases-zsync|$GH_USER|$GH_REPO|$FIREFOX_CHANNEL|$FIREFOX_CHANNEL*.AppImage.zsync" \
    "${FIREFOX_CHANNEL}-${FIREFOX_VERSION}-${FIREFOX_ARCH}-${FIREFOX_LANG}".AppImage

mkdir -p dist
mv "$FIREFOX_CHANNEL"*.AppImage* dist/.
echo "==> Done, saved $(realpath dist/"$FIREFOX_CHANNEL"*.AppImage)"

RELEASE_NOTES_URL="https://www.mozilla.org/firefox/$FIREFOX_VERSION"
if [[ "$FIREFOX_CHANNEL" == "firefox-devedition" ]] || [[ "$FIREFOX_CHANNEL" == "firefox-beta" ]]; then
    RELEASE_NOTES_URL="${RELEASE_NOTES_URL}beta"
fi
RELEASE_NOTES_URL="${RELEASE_NOTES_URL}/releasenotes/"

echo "==> GitHub Actions "
{
    echo "FIREFOX_VERSION=$FIREFOX_VERSION"
    echo "FIREFOX_BUILD_ID=$FIREFOX_BUILD_ID"
    echo "RELEASE_NOTES_URL=$RELEASE_NOTES_URL"
} >>"$GITHUB_ENV"

echo "$FIREFOX_VERSION.r$FIREFOX_BUILD_ID"
