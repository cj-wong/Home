#!/usr/bin/env bash
#
# Companion script for: https://www.funtoo.org/Keychain

command -v keychain 2>&1 > /dev/null

if [ -n "$SSH_CLIENT" ]; then
    echo "keychain will not start in SSH sessions. Aborting keychain.bashrc."
elif [[ $? != 0 ]]; then
    echo "keychain is not installed. Aborting keychain.bashrc."
else
    KEYS=( )

    for pubkey in ~/.ssh/*.pub; do
        privkey="${pubkey%.pub}"
        if [ -f "$privkey" ]; then
            KEYS+=($privkey)
        fi
    done

    eval `keychain --eval --agents ssh --clear ${KEYS[@]}`
fi
