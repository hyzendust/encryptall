#!/bin/bash

cd "$(dirname "$0")"
mkdir -p Encrypted

echo -n "Enter password: "
read PASSWORD
echo "Password length: ${#PASSWORD}"

PASSFILE=$(mktemp)
echo "$PASSWORD" > "$PASSFILE"
echo "Temp file: $PASSFILE"

for file in *; do
    if [ -f "$file" ] && [ "$file" != "Encrypted" ] && [ "$file" != "encryptall.sh" ]; then
        echo "Processing: $file"
        gpg --batch --yes --passphrase-file "$PASSFILE" --symmetric --cipher-algo AES256 -o "Encrypted/${file}.gpg" "$file"
        if [ $? -eq 0 ]; then
            echo "Success: $file"
        else
            echo "Failed: $file"
        fi
    fi
done

rm -f "$PASSFILE"
unset PASSWORD
echo "Done!"
