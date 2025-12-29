#!/bin/bash
pkill menu 2>/dev/null

set -euo pipefail

# ======= WARNA =======
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
RESET="\e[0m"

# ======= DETEKSI ARCH =======
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        INSTALLER="install-amd64"
        ;;
    aarch64|arm64)
        INSTALLER="install-arm64"
        ;;
    *)
        echo -e "${RED}❌ Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

echo -e "${YELLOW}✔ Architecture detected : $ARCH${RESET}"
echo -e "${YELLOW}✔ Using installer       : $INSTALLER${RESET}"
echo ""

# ======= PATH INSTALLER =======
DEST="/usr/local/bin/install"
URL="https://github.com/tridebleng/udp-zivpn/releases/latest/download/$INSTALLER"

# ======= BACKUP INSTALLER JIKA ADA =======
if [[ -f "$DEST" ]]; then
    echo -e "${YELLOW}🔄 Existing installer found, creating backup...${RESET}"
    cp "$DEST" "${DEST}.backup_$(date +%Y%m%d%H%M)" || true
fi

# ======= DOWNLOAD INSTALLER =======
echo -e "${YELLOW}⬇ Downloading latest installer...${RESET}"

for attempt in {1..3}; do
    if wget -q --show-progress -O "$DEST" "$URL"; then
        break
    else
        echo -e "${RED}⚠ Download failed (attempt $attempt)...${RESET}"
        sleep 2
    fi

    if [[ $attempt -eq 3 ]]; then
        echo -e "${RED}❌ Failed to download installer after 3 attempts.${RESET}"
        exit 1
    fi
done

# ======= VALIDASI FILE =======
if [[ ! -s "$DEST" ]]; then
    echo -e "${RED}❌ Installer file is empty or corrupted.${RESET}"
    exit 1
fi

chmod +x "$DEST"

echo -e "${GREEN}✔ Installer downloaded successfully${RESET}"
echo ""

# ======= JALANKAN UPDATE =======
echo -e "${YELLOW}🔧 Running installer update...${RESET}"

$DEST --update

echo -e "${BLUE}You may now run : ${RESET} menu"
echo ""
