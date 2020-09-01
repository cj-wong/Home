#!/usr/bin/env bash
# Companion script for: https://www.funtoo.org/Keychain

command -v keychain
if [[ $? != 0 ]]; then
    echo "keychain is not installed. Aborting script."
    exit 1
fi

KEYS=( )

for pubkey in ~/.ssh/*.pub; do
    privkey="${pubkey%.pub}"
    if [ -f "$privkey" ]; then
        KEYS+=($privkey)
    fi
done

eval `keychain --eval --agents ssh --clear ${KEYS[@]}`
