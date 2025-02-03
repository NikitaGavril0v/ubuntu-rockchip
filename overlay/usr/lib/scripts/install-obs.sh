#!/bin/bash

#Установка OBS:
cd ~/
git clone -b release/30.1 --recursive https://github.com/obsproject/obs-studio.git
sudo apt install -y cmake ninja-build pkg-config clang clang-format build-essential curl ccache git zsh
sudo apt install -y libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev libx264-dev libcurl4-openssl-dev libmbedtls-dev libgl1-mesa-dev libjansson-dev libluajit-5.1-dev python3-dev libx11-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-xinerama0-dev libxcb-composite0-dev libxcomposite-dev libxinerama-dev libxcb1-dev libx11-xcb-dev libxcb-xfixes0-dev swig libcmocka-dev libxss-dev libglvnd-dev libgles2-mesa libgles2-mesa-dev libwayland-dev librist-dev libsrt-openssl-dev libpci-dev libpipewire-0.3-dev libqrcodegencpp-dev
sudo apt install -y \
       qt6-base-dev \
       qt6-base-private-dev \
       libqt6svg6-dev \
       qt6-wayland \
       qt6-image-formats-plugins
sudo apt install -y \
       libasound2-dev \
       libfdk-aac-dev \
       libfontconfig-dev \
       libfreetype6-dev \
       libjack-jackd2-dev \
       libpulse-dev libsndio-dev \
       libspeexdsp-dev \
       libudev-dev \
       libv4l-dev \
       libva-dev \
       libvlc-dev \
       libdrm-dev \
       nlohmann-json3-dev \
       libwebsocketpp-dev \
       libasio-dev \
       uthash-dev
cd ~/obs-studio/cmake/Modules
rm ObsHelpers_Linux.cmake CompilerConfig.cmake
wget https://github.com/hufman/obs-studio/raw/generate-libobs-pkgconfig/cmake/Modules/CompilerConfig.cmake
wget https://github.com/hufman/obs-studio/raw/generate-libobs-pkgconfig/cmake/Modules/ObsHelpers_Linux.cmake
cd ~/obs-studio
cmake -S . -B ~/obs-build -G Ninja \
	-DENABLE_BROWSER=OFF \
	-DENABLE_PIPEWIRE=ON \
	-DENABLE_AJA=0 \
        -DENABLE_WEBRTC=0 \
	-DQT_VERSION=6  \
	-DENABLE_QSV11=OFF \
	-DENABLE_NATIVE_NVENC=OFF
cd ~/obs-build
cmake --build . --target package
sudo apt install -y ./obs-studio-*.deb
sudo apt-mark hold obs-studio
cd

# Установка gstreamer c mpp:
sudo apt --no-install-recommends install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-gl
sudo apt install -y gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp rockchip-multimedia-config libgl4es libgl4es-dev libdri2to3

# Установка obs-gstreamer:
sudo apt install -y meson
git clone https://github.com/fzwoch/obs-gstreamer.git
cd ~/obs-gstreamer
meson --buildtype=release build
ninja -C build
cd build
sudo mv obs-gstreamer.so /usr/local/lib/obs-plugins/

# Установка Source Record
cd ~/
git clone https://github.com/exeldro/obs-source-record.git
cd ~/obs-source-record
cmake -S . -B build -DBUILD_OUT_OF_TREE=On && cmake --build build
cd build
sudo mv source-rekord.so /usr/local/lib/obs-plugins/

# Установка Color Monitor
cd ~/
git clone https://github.com/norihiro/obs-color-monitor.git
cd obs-color-monitor
cmake -S . -B build && cmake --build build
cd build
sudo mv obs-color-monitor.so /usr/local/lib/obs-plugins/

# Установка NDI SDK
/usr/lib/scripts/libndi-get.sh

# Установка DistroAV
cd ~
git clone https://github.com/DistroAV/DistroAV.git
cd DistroAV
.github/scripts/build-linux --skip-deps
.github/scripts/package-linux --package
sudo dpkg -i release/distroav*.deb
sudo apt install -y avahi-daemon ffmpeg
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
sudo ufw allow 5353/udp
sudo ufw allow 5959:5969/tcp
sudo ufw allow 5959:5969/udp
sudo ufw allow 6960:6970/tcp
sudo ufw allow 6960:6970/udp
sudo ufw allow 7960:7970/tcp
sudo ufw allow 7960:7970/udp
sudo ufw allow 5960/tcp
