#!/bin/bash

# Define the folder scope to check all files within apps/*
FOLDER_SCOPE="apps/*"

# Download the CSS file from webassets.iota.org and calculate its SHA-384 hash
NEW_HASH=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
    -H "Accept: text/css,*/*;q=0.1" \
    -H "Referer: https://webassets.iota.org/" \
    -L "https://webassets.iota.org/api/protected?face=alliance-no2" | openssl dgst -sha384 -binary | openssl base64 -A)

echo "🔍 New hash obtained: sha384-$NEW_HASH"

# Find all HTML and CSS files under the specified scope
FILES=$(find $FOLDER_SCOPE -type f \( -iname \*.html -o -iname \*.css \))

OUTDATED=false

# Loop through each file and check if the hash matches
for FILE in $FILES; do
    if grep -q "sha384-$NEW_HASH" "$FILE"; then
        echo "✅ The file $FILE already has the updated hash."
    else
        echo "❌ ERROR: The file $FILE has an outdated hash. 🚨"
        OUTDATED=true
    fi
done

# If any file is outdated, exit with an error
if [ "$OUTDATED" = true ]; then
    echo -e "\n🚨🚨🚨"
    echo "The hash of the CSS file from webassets.iota.org has changed."
    echo "Please update the affected files with the new hash: sha384-$NEW_HASH"
    echo "🚨🚨🚨"
    exit 1
else
    echo "✅ All hashes are up to date."
fi
