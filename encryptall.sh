#!/bin/bash

cd "$(dirname "$0")"
mkdir -p Encrypted

echo -n "Enter password: "
read PASSWORD
echo ""

PASSFILE=$(mktemp)
echo "$PASSWORD" > "$PASSFILE"

for file in *; do
    if [ -f "$file" ] && [ "$file" != "Encrypted" ] && [ "$file" != "encryptall.sh" ]; then
        # Check if already encrypted previously
        if [ -f "Encrypted/${file}.gpg" ]; then
            echo "Skipping (already encrypted): $file"
        else
            echo "Encrypting: $file"
            gpg --batch --yes --passphrase-file "$PASSFILE" --symmetric --cipher-algo AES256 -o "Encrypted/${file}.gpg" "$file"
            if [ $? -eq 0 ]; then
                echo "✓ Success: $file"
            else
                echo "✗ Failed: $file"
            fi
        fi
    fi
done

rm -f "$PASSFILE"
unset PASSWORD
echo "Done!"
