#!/bin/sh

set -e

PREV_DIR=$(pwd)
PACK_DIR=$(dirname -- "$0")
cd "$PACK_DIR"

TARGET="../Dopamine/Dopamine/bootstrap/basebin.tar"

if [ -d "$TARGET" ]; then
	rm -rf "$TARGET"
fi

if [ -d "basebin.tar" ]; then
	rm -rf "basebin.tar"
fi

if [ -d ".tmp/basebin" ]; then
	rm -rf ".tmp/basebin"
fi
mkdir -p ".tmp/basebin"

cd ChOma
make TARGET=ios DISABLE_SIGNING=1 DISABLE_TESTS=1 DYLIB_LDFLAGS="-install_name @loader_path/libchoma.dylib"
cd -
cp ./ChOma/output/ios/lib/libchoma.dylib .tmp/basebin/libchoma.dylib
cp -r ./ChOma/output/ios/include/choma ./_shared/choma

# libfilecom
cd "libfilecom"
make
cd -
cp "./libfilecom/libfilecom.dylib" ".tmp/basebin/libfilecom.dylib"
rm -rf "./_shared/libfilecom"
mkdir -p "./_shared/libfilecom"
cp ./libfilecom/src/*.h ./_shared/libfilecom

# libjailbreak
cd "libjailbreak"
make
cd -
cp "./libjailbreak/libjailbreak.dylib" ".tmp/basebin/libjailbreak.dylib"
rm -rf "./_shared/libjailbreak"
mkdir -p "./_shared/libjailbreak"
cp ./libjailbreak/src/*.h ./_shared/libjailbreak

# jailbreakd
cd "jailbreakd"
make
cd -
cp "./jailbreakd/jailbreakd" ".tmp/basebin/jailbreakd"

# jailbreakd
cd "idownloadd"
make
cd -
cp "./idownloadd/idownloadd" ".tmp/basebin/idownloadd"

# daemon plists
# needs separate directory because launchd is picky
mkdir -p ".tmp/basebin/LaunchDaemons/Disabled"
cp "./jailbreakd/daemon.plist" ".tmp/basebin/LaunchDaemons/com.opa334.jailbreakd.plist"
cp "./idownloadd/daemon.plist" ".tmp/basebin/LaunchDaemons/Disabled/com.opa334.idownloadd.plist"
cp "./jbctl/rebuild_daemon.plist" ".tmp/basebin/LaunchDaemons/com.opa334.trustcache_rebuild.plist"

# boomerang
cd "boomerang"
make
cd -
cp "./boomerang/boomerang" ".tmp/basebin/boomerang"

# jbinit
cd "jbinit"
make
cd -
cp "./jbinit/jbinit" ".tmp/basebin/jbinit"

# jbctl
cd "jbctl"
make
cd -
cp "./jbctl/jbctl" ".tmp/basebin/jbctl"

# launchdhook
cd "launchdhook"
make
cd -
cp "./launchdhook/launchdhook.dylib" ".tmp/basebin/launchdhook.dylib"

# systemhook
cd "systemhook"
make
cd -
cp "./systemhook/systemhook.dylib" ".tmp/basebin/systemhook.dylib"

# watchdoghook
cd "watchdoghook"
make
cd -
cp "./watchdoghook/watchdoghook.dylib" ".tmp/basebin/watchdoghook.dylib"

# roothidehooks
cd "roothidehooks"
make clean && make
cd -
cp "./roothidehooks/.theos/obj/roothidehooks.dylib" ".tmp/basebin/roothidehooks.dylib"

# forkfix
cd "forkfix"
make
cd -
cp "./forkfix/forkfix.dylib" ".tmp/basebin/forkfix.dylib"

# external
cp -r ./_external/* .tmp/basebin/

# Create TrustCache, for basebinaries
rm -rf "./basebin.tc"
trustcache create "./basebin.tc" "./.tmp/basebin"
cp "./basebin.tc" "./.tmp/basebin"

# Tar /tmp to basebin.tar
cd ".tmp"
# only works with procursus tar for whatever reason
DYLD_FALLBACK_LIBRARY_PATH=".." ../tar -cvf "../$TARGET" "./basebin" --owner=0 --group=0 
cd -

rm -rf ".tmp"

cd "$PREV_DIR"