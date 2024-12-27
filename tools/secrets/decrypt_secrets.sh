#!/bin/bash

# Navigates to the root directory of the project.
# In that case to the directory with the name of the Flutter project.
# So it can be run from anywhere.
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/../.." || exit

# Set the name of the encrypted archive file
encrypted_archive="tools/secrets/encrypted_secrets.tar.gz.enc"

# Set the name of the file containing the decryption password
password_file="tools/secrets/encryption_password.txt"

# Check if the password file exists
if [ ! -e "$password_file" ]; then
  echo "Warning: The file $password_file is not present."
  echo "Creating the file $password_file."
  touch "$password_file"
fi

# Check if the [SECRETS_PASSWORD] environment variable is present.
# It is used in CI/CD.
if [ -n "$SECRETS_PASSWORD" ]; then
  echo "$SECRETS_PASSWORD" >"$password_file"
# Check if the password file is empty
elif [ -s "$password_file" ]; then
  echo "Password file is not empty. Continuing with decryption."
# Otherwise ask user to provide password.
else
  echo "Error: Password file is empty. Please provide the password in $password_file."
  read -s -p "Paste the password and press Enter: " password
  echo "$password" >"$password_file"
fi

# Decrypt the archive and extract files preserving the original directory structure
openssl enc -d -aes-256-cbc -salt -pbkdf2 -in "$encrypted_archive" -pass "file:$password_file" | tar xzf -

echo "Decryption complete. Decrypted files restored with the original directory structure."
