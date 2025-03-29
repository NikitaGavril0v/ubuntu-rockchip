#!/bin/bash

apt install -y npm yarn
fnm install 18
fnm use 18
fnm default 18
corepack enable
curl https://raw.githubusercontent.com/bitfocus/companion-pi/main/install.sh | bash
mkdir /opt/companion-module-dev
cd /opt/companion-module-dev
git clone https://git.miem.hse.ru/19102/bitfocus/companion/akai-fire-backlight.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/companion-module-generic-http.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/companion-module-generic-onvif-dev.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/companion-module-obs-studio-dev.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/companion-module-server-http.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/companion-module-websocket-listener.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/generic-midi.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/generic-midi-winwet.git
git clone https://git.miem.hse.ru/19102/bitfocus/companion/generic-pelco.git
for dir in /opt/companion-module-dev/*/; do
  (
    cd "$dir"
    npm install && npm run build
  ) || (
    cd "$dir"
    yarn install && yarm build
  )
done
systemctl enable companion