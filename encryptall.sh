#!/bin/bash

mkdir -p Encrypted

echo -n "Enter password: "
read PASSWORD
echo ""

PASSFILE=$(mktemp)
echo "$PASSWORD" > "$PASSFILE"

# Recursive encrypt function
encrypt_recursive() {
    local source_dir="$1"
    local encrypted_base="$2"
    
    for item in "$source_dir"/*; do
        [ -e "$item" ] || continue
        
        local rel_path="${item#./}"
        
        if [ -d "$item" ]; then
            mkdir -p "$encrypted_base/$rel_path"
            echo "Created directory: $rel_path/"
            encrypt_recursive "$item" "$encrypted_base"
        elif [ -f "$item" ]; then
            # Check if already encrypted previously
            if [ -f "$encrypted_base/${rel_path}.gpg" ]; then
                echo "Skipping (already encrypted): $rel_path"
            else
                echo "Encrypting: $rel_path"
                mkdir -p "$(dirname "$encrypted_base/${rel_path}.gpg")"
                gpg --batch --yes --passphrase-file "$PASSFILE" --symmetric --cipher-algo AES256 -o "$encrypted_base/${rel_path}.gpg" "$item"
                if [ $? -eq 0 ]; then
                    echo "✓ Success: $rel_path"
                else
                    echo "✗ Failed: $rel_path"
                fi
            fi
        fi
    done
}

for item in *; do
    if [ "$item" = "Encrypted" ] || [ "$item" = "encryptall.sh" ] || [ "$item" = "encryptall" ]; then
        continue
    fi
    
    if [ -d "$item" ]; then
        mkdir -p "Encrypted/$item"
        echo "Processing directory: $item/"
        encrypt_recursive "$item" "Encrypted"
    elif [ -f "$item" ]; then
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
