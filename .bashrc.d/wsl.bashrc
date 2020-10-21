#!/usr/bin/env bash
#
# Utilities for Windows Subsystem for Linux

if ! command wsl.exe > /dev/null 2>&1; then
    # Don't do anything if not WSL.
    :
else
    # Pinpoint the exact running VM to determine WSL version.
    # According to the docs, `wsl.exe -l -v` can fail if the Windows Build
    # isn't 19041 or higher.
    # Reference: https://docs.microsoft.com/en-us/windows/wsl/reference
    # This loop may be simplified by sorting the list, since the asterisk
    # will come first, but wsl.exe leaves an empty line that comes before
    # the line with the asterisk.
    while read -r vm; do
        # Ignore all other VMs. Only focus on the current VM.
        if ! echo "$vm" | grep "^\*" > /dev/null 2>&1; then
            continue
        else
            wsl_ver=$(echo "$vm" | sed -E 's/^\* [A-Za-z ]+([12]).*$/\1/g')
            # WSL2 specific snippets:
            #   - setting display 
            if [[ "$wsl_ver" == 2 ]]; then
                # Sets $DISPLAY for WSL GUI apps
                # Adapted from:
                #   https://techcommunity.microsoft.com/t5
                #       /windows-dev-appconsult
                #       /running-wsl-gui-apps-on-windows-10/ba-p/1493242
                DISPLAY=$(grep nameserver /etc/resolv.conf \
                    | sed 's/nameserver //'):0
                export DISPLAY
            fi
            # Since there should only be one VM marked with the asterisk,
            # stop the loop entirely.
            break
        fi
    done < <(wsl.exe -l -v | tail -n+2)
fi
