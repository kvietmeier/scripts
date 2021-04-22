#!/bin/bash

if [ "$#" -eq 3 ]; then
	CLEAR_VER="$1"
	CHROOT_DIR="$2"
	BUNDLES=($3)
elif [ "$#" -eq 2 ]; then
	CLEAR_VER=$(< /usr/share/clear/version)
	CHROOT_DIR="$1"
	BUNDLES=($2)
fi

if [ -n "$CLEAR_VER" ] && [ -n "$CHROOT_DIR" ] && [ -n "$BUNDLES" ]; then
	sudo -E rm -rf "$CHROOT_DIR"
	BUNDLE_DIR="$CHROOT_DIR"/usr/share/clear/bundles
	sudo -E mkdir -p "$BUNDLE_DIR"
	for BUNDLE in "${BUNDLES[@]}"; do
		sudo -E touch "$BUNDLE_DIR/$BUNDLE"
	done
	sudo -E swupd clean --all
	sudo -E swupd verify --install --path="$CHROOT_DIR" --manifest="$CLEAR_VER"
	sudo -E chown "$USER":"$USER" "$CHROOT_DIR"
fi
