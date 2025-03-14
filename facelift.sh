#!/bin/bash

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
    shell_type="zsh"
    save_history_cmd="fc -AI"
elif [ -n "$BASH_VERSION" ]; then
    shell_type="bash"
    save_history_cmd="history -a"
else
    echo "Unsupported shell!"
    exit 1
fi

# Force immediate history save
eval "$save_history_cmd"

# Log a custom entry for clarity
echo "[$shell_type] Terminal history saved." >> ~/.${shell_type}_history

# Capture user's GPG signature
if gpg --list-secret-keys > /dev/null 2>&1; then
    user_gpg_key=$(gpg --list-secret-keys --keyid-format LONG | grep 'sec' | awk '{print $2}' | cut -d'/' -f2)
    echo "[$shell_type] User GPG Key: $user_gpg_key" >> ~/.${shell_type}_history
else
    echo "[$shell_type] No GPG key found for user." >> ~/.${shell_type}_history
fi

# Buffer the current history file
cp ~/.${shell_type}_history ~/.${shell_type}_history_backup

# Sign the history log
if [ -n "$user_gpg_key" ]; then
    gpg --clearsign -o ~/.${shell_type}_history_signed ~/.${shell_type}_history
    mv ~/.${shell_type}_history_signed ~/.${shell_type}_history
    echo "[$shell_type] History log signed successfully." >> ~/.${shell_type}_history
else
    echo "[$shell_type] Failed to sign history log: No GPG key." >> ~/.${shell_type}_history
fi

# Verify the signed history log
if gpg --verify ~/.${shell_type}_history > /dev/null 2>&1; then
    echo "[$shell_type] History log verified successfully." >> ~/.${shell_type}_history
else
    echo "[$shell_type] WARNING: History log verification failed! Reverting to backup." >> ~/.${shell_type}_history
    mv ~/.${shell_type}_history_backup ~/.${shell_type}_history
fi

# Encrypt the verified history log
if [ -n "$user_gpg_key" ]; then
    gpg -e -r "$user_gpg_key" -o ~/.${shell_type}_history.gpg ~/.${shell_type}_history
    echo "[$shell_type] History log encrypted successfully." >> ~/.${shell_type}_history
else
    echo "[$shell_type] Failed to encrypt history log: No GPG key." >> ~/.${shell_type}_history
fi

# Automatically decrypt history log for future runs
if [ -f ~/.${shell_type}_history.gpg ]; then
    gpg -d ~/.${shell_type}_history.gpg -o ~/.${shell_type}_history
    echo "[$shell_type] History log decrypted successfully." >> ~/.${shell_type}_history
fi

# Check for redirection and log output file if found
if [[ "$1" =~ ">" ]]; then
    output_file=$(echo "$1" | grep -oP '(?<=\>).+')
    output_file=$(echo "$output_file" | xargs)  # Trim whitespace

    if [ -n "$output_file" ]; then
        echo "[$shell_type] Redirection detected: Output file => $output_file" >> ~/.${shell_type}_history
    fi
fi

# Ensure the script logs itself
echo "[$shell_type] $BASH_SOURCE" >> ~/.${shell_type}_history

# Clean up the backup
rm -f ~/.${shell_type}_history_backup
