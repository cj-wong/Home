#!/usr/bin/env bash
#
# Injects .bashrc.d functionality into .bashrc

INJECT_BASHRCD=$(cat <<END
.bashrc.d functionality was not detected in your .bashrc file. If injected,
your old .bashrc will be saved to a temporary file.
Do you want to inject this? [yN] 
END
)

TEXT=$(cat <<END
if [ -d ~/.bashrc.d ]; then
    for file in ~/.bashrc.d/*.bashrc; do
        . "\$file"
    done
fi
END
)

# If the injection block isn't found in ~/.bashrc, ask the user whether to
# inject the block to allow .bashrc.d functionality.
#grep -z "$TEXT" ~/.bashrc 2&> /dev/null
IFS=$'\n' ARR=($TEXT)
TEXT_LEN=$(echo "$TEXT" | wc -l)
TEXT_BASHRC=$(grep -A $TEXT_LEN -F "${ARR[0]}" ~/.bashrc)

if [[ "$TEXT" != "$TEXT_BASHRC" ]]; then
    read -p "$INJECT_BASHRCD" prompt
    if [[ $prompt =~ ^[yY] ]]; then
        type -t copy_tmp 2&> /dev/null
        if [[ $? != 0 ]]; then
            . "$(dirname $0)/.bashrc.d/functions.bashrc"
        fi
        copy_tmp ~/.bashrc
        echo "$TEXT" >>  ~/.bashrc
        echo "Injected .bashrc.d into your .bashrc file. Restart shell to use."
    else
        echo "Aborting injection and script."
        exit 1
    fi
fi
