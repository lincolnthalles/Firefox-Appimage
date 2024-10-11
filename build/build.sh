#!/bin/bash

export APPIMAGE_EXTRACT_AND_RUN=1
export FIREFOX_PRODUCT="${FIREFOX_PRODUCT:-firefox-esr}"
export FIREFOX_OS="${FIREFOX_OS:-linux64}"
export FIREFOX_LANG="${FIREFOX_LANG:-en-US}"
export GITHUB_ENV="${GITHUB_ENV:-.GITHUB_ENV}"

set -eu

rm -rf build/AppDir
rm -rf build/firefox*
mkdir -p build/src

if [[ ! -f "build/src/${FIREFOX_PRODUCT}-${FIREFOX_LANG}.tar.bz2" ]]; then
    echo "==> Downloading ${FIREFOX_PRODUCT}"
    wget "https://download.mozilla.org/?product=${FIREFOX_PRODUCT}-latest-ssl&os=${FIREFOX_OS}&lang=${FIREFOX_LANG}" -O "build/src/${FIREFOX_PRODUCT}-${FIREFOX_LANG}.tar.bz2"
fi

tar -xvf "build/src/${FIREFOX_PRODUCT}-${FIREFOX_LANG}.tar.bz2" -C build
mv build/firefox* build/AppDir

echo "==> Copying AppRun"
sed "s,FIREFOX_BIN_FILE,$(basename build/AppDir/firefox*-bin),g" <AppRun >build/AppDir/AppRun
chmod 755 build/AppDir/AppRun

echo "==> Copying Firefox Desktop file"
cp desktop/"${FIREFOX_PRODUCT}".desktop build/AppDir/.

echo "==> Disable Auto Updates"
cp -r distribution build/AppDir/.

FIREFOX_ICON_NAME="$(grep 'Icon=' <desktop/"${FIREFOX_PRODUCT}".desktop | sed 's,Icon=,,g')"
echo "==> Copying icon :: ${FIREFOX_ICON_NAME}"
ln -sr build/AppDir/browser/chrome/icons/default/default128.png build/AppDir/"${FIREFOX_ICON_NAME}".png

if ! [ -f "build/appimagetool" ]; then
    echo "==> Downloading appimagetool"
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage" -O build/appimagetool
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
export ARCH=FIREFOX_ARCH

./build/appimagetool -n --comp gzip \
    build/AppDir \
    --updateinformation "gh-releases-zsync|$GH_USER|$GH_REPO|$FIREFOX_PRODUCT|$FIREFOX_PRODUCT*.AppImage.zsync" \
    "${FIREFOX_PRODUCT}-${FIREFOX_VERSION}-${FIREFOX_LANG}-${FIREFOX_ARCH}".AppImage

mkdir -p dist
mv "$FIREFOX_PRODUCT"*.AppImage* dist/.
echo "==> Done, saved $(realpath dist/"$FIREFOX_PRODUCT"*.AppImage)"

RELEASE_NOTES_URL="https://www.mozilla.org/firefox/$FIREFOX_VERSION"
if [[ "$FIREFOX_PRODUCT" == "firefox-devedition" ]] || [[ "$FIREFOX_PRODUCT" == "firefox-beta" ]]; then
    RELEASE_NOTES_URL="${RELEASE_NOTES_URL}beta"
fi
RELEASE_NOTES_URL="${RELEASE_NOTES_URL}/releasenotes/"

echo "==> GitHub Actions "
{
    echo "FIREFOX_VERSION=$FIREFOX_VERSION"
    echo "FIREFOX_BUILD_ID=$FIREFOX_BUILD_ID"
    echo "RELEASE_NOTES_URL=$RELEASE_NOTES_URL"
} >>"$GITHUB_ENV"
