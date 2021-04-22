#!/bin/bash
if [ -n "$1" ]; then
	if ! getent passwd "$1" > /dev/null; then
		sudo -E useradd -m "$1"
	fi
	sudo -E usermod -a -G wheelnopw "$1"

	if [ -n "$2" ] || [ -n "$3" ]; then
		USER_HOME_DIR="$(getent passwd "$1" | cut -d ':' -f 6)"
		SSH_DIR="$USER_HOME_DIR/.ssh"
		sudo -E mkdir -p "$SSH_DIR"

		if [ -n "$2" ] && [ -z "$3" ]; then
			sudo -E cp -f "$2" "$SSH_DIR/authorized_keys"
		else
			sudo -E cp -f "$2" "$SSH_DIR/id_rsa.pub"
			sudo -E cp -fa "$SSH_DIR/id_rsa.pub" "$SSH_DIR/authorized_keys"
			sudo -E cp -f "$3" "$SSH_DIR/id_rsa"
		fi

		sudo -E chown -R "$1":"$1" "$SSH_DIR"
		sudo -E chmod -R 600 "$SSH_DIR"
		sudo -E chmod 700 "$SSH_DIR"
	fi
fi
