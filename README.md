# Mupen64plus-SA-TUI
Mupen64plus Standalone emulator for TUI build script

Place the patches and scripts folders in muos-docker/workspace.

docker run --platform linux/amd64 -v .:/workspace --rm -it muos-developer:latest /bin/bash

```
apt update

apt-get install git

# PATH-first strip wrapper for muOS SDK (aarch64)
mkdir -p /workspace/cross-bin
cat > /workspace/cross-bin/strip <<'EOF'
#!/bin/sh
exec /muos-sdk/aarch64-buildroot-linux-gnu/bin/strip "$@"
EOF
chmod +x /workspace/cross-bin/strip
export PATH="/workspace/cross-bin:$PATH"

#Toolchain Path
export XTOOL=/muos-sdk
export XHOST=aarch64-buildroot-linux-gnu
export PATH="$XTOOL/bin:$PATH"
export SYSROOT="$XTOOL/$XHOST/sysroot"

#Make cross-pkg-config look at the sysroot
export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig"

#Cross pkg-config name (create if not present)
ln -sf "$(command -v pkgconf || command -v pkg-config)" "$XTOOL/bin/$XHOST-pkg-config"
export PKG_CONFIG="$XHOST-pkg-config"

#SDL2-config wrapper for SDL2 detection (some Makefile compatibility)
cat > "$XTOOL/bin/$XHOST-sdl2-config" <<'EOF'
#!/usr/bin/env sh
if [ "$1" = "--cflags" ]; then
  exec "$PKG_CONFIG" --cflags sdl2
elif [ "$1" = "--libs" ]; then
  exec "$PKG_CONFIG" --libs sdl2
else
  echo "usage: $0 [--cflags|--libs]" >&2
  exit 1
fi
EOF
chmod +x "$XTOOL/bin/$XHOST-sdl2-config"
export SDL_CONFIG="$XHOST-sdl2-config"

#Architecture fixation (to avoid cross-detection confusion)
cat > "$XTOOL/bin/$XHOST-sdl2-config" <<'EOF'
#!/usr/bin/env sh
if [ "$1" = "--cflags" ]; then
  exec "$PKG_CONFIG" --cflags sdl2
elif [ "$1" = "--libs" ]; then
  exec "$PKG_CONFIG" --libs sdl2
else
  echo "usage: $0 [--cflags|--libs]" >&2
  exit 1
fi
EOF
chmod +x "$XTOOL/bin/$XHOST-sdl2-config"
export SDL_CONFIG="$XHOST-sdl2-config"

#Use cross strip (to avoid host strip errors)
export STRIP="/muos-sdk/aarch64-buildroot-linux-gnu/bin/strip"

#Preventing conflicts caused by direct linker designation
unset LD

export USE_GLES=1
export GL_CFLAGS=""
export GL_LDLIBS="-lEGL -lGLESv2"

bitness=64 source scripts/mupen64plussa.sh
```
## Overview
A standard build using ArkOS scripts.

To prevent the screen from shifting to the left when using the rice plugin on devices with 16:9 screens, apply the ArkOS mupen64plus-video-rice-patch-aspect-ratio-hack.patch.
Also apply mupen64plus-ui-console-patch-pif-fix.patch (I don't know exactly what it is)

I modified the existing ext-mupen64plus.sh to adjust the screen ratio.
I made some changes to mupen64plus.cfg, but there may be better settings.
Since the settings of mupen64plus.cfg are changed and used in the ext-mupen64plus.sh, it is currently run with one mupen64plus.cfg.

To prevent a black screen when running glidemk2, I imported and used fb_disable_transparency, included in Crossmix.
