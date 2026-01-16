#!/bin/bash

mkdir -p Encrypted

echo -n "Enter password: "
read PASSWORD
echo ""

PASSFILE=$(mktemp)
echo "$PASSWORD" > "$PASSFILE"

for item in *; do
    # Skip the Encrypted folder and the script itself
    if [ "$item" = "Encrypted" ] || [ "$item" = "encryptall.sh" ] || [ "$item" = "encryptall" ]; then
        continue
    fi
    
    # For folders, archive first
    if [ -d "$item" ]; then
        archive_name="${item}.tar.xz"
        # Check if already encrypted previously
        if [ -f "Encrypted/${archive_name}.gpg" ]; then
            echo "Skipping (already encrypted): $item/ (folder)"
        else
            echo "Archiving folder: $item/"
            tar -cJf "$archive_name" "$item"
            
            if [ $? -eq 0 ]; then
                echo "Encrypting archive: $archive_name"
                gpg --batch --yes --passphrase-file "$PASSFILE" --symmetric --cipher-algo AES256 -o "Encrypted/${archive_name}.gpg" "$archive_name"
                
                if [ $? -eq 0 ]; then
                    echo "✓ Success: $item/ (folder)"
                    # Remove the temporary archive file
                    rm -f "$archive_name"
                else
                    echo "✗ Failed to encrypt: $archive_name"
                fi
            else
                echo "✗ Failed to archive: $item/"
            fi
        fi
    # For files
    elif [ -f "$item" ]; then
        # Check if already encrypted previously
        if [ -f "Encrypted/${item}.gpg" ]; then
            echo "Skipping (already encrypted): $item"
        else
            echo "Encrypting: $item"
            gpg --batch --yes --passphrase-file "$PASSFILE" --symmetric --cipher-algo AES256 -o "Encrypted/${item}.gpg" "$item"
            if [ $? -eq 0 ]; then
                echo "✓ Success: $item"
            else
                echo "✗ Failed: $item"
            fi
        fi
    fi
done

rm -f "$PASSFILE"
unset PASSWORD
echo "Done!"
