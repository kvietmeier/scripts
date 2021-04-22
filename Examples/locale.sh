#!/bin/bash
if [ -n "$1" ]; then
	if which locale-gen > /dev/null; then
		echo "$1" | sudo -E tee /etc/locale.gen > /dev/null
		locale-gen
	fi
	sudo -E localectl set-locale "LANG=$1"
fi
if [ -n "$2" ]; then
	sudo -E localectl set-keymap "$2"
fi
