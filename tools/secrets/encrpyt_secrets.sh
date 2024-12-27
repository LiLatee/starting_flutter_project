#!/bin/bash

# Navigates to the root directory of the project.
# In that case to the directory with the name of the Flutter project.
# So it can be run from anywhere.
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/../.." || exit

# Set the name of the output encrypted archive file
output_archive="tools/secrets/encrypted_secrets.tar.gz.enc"

# Set the path for the file containing the list of files and directories to encrypt
secret_files_list_file="tools/secrets/secret_files_list.txt"

# Set the name of the file containing the encryption password
password_file="tools/secrets/encryption_password.txt"

# Set the path for the version file
version_file="tools/secrets/secrets_version.txt"
# Check if the password file exists
if [ ! -e "$password_file" ]; then
  echo "Warning: The file $password_file is not present."
  echo "Creating the file $password_file."
  touch "$password_file"
fi

# Check if the password file is empty
if [ -s "$password_file" ]; then
  echo "Password file is not empty. Continuing with encryption."
else
  echo "Error: Password file is empty. Please provide the password in $password_file."
  read -s -p "Paste the password and press Enter: " password
  echo "$password" > "$password_file"
fi

# Check if the file containing the list of files and directories to encrypt exists
if [ ! -e "$secret_files_list_file" ]; then
  echo "Error: The file $secret_files_list_file is not present."
  echo "Create the file $secret_files_list_file and add the list of files and directories to encrypt, one path per line."
  exit 1
fi

# Read the list of files and directories to encrypt from the file into an array
files_to_encrypt=()
while IFS= read -r line; do
  files_to_encrypt+=("$line")
done < "$secret_files_list_file"


# Checks if all secret files exists
for file_path in "${files_to_encrypt[@]}"; do
    if [ ! -e "$file_path" ]; then
        echo "File or directory '$file_path' does not exist. Run decrypt first and make your changes."
        exit 1
    fi
done

# Create a tar archive of all files with the original directory structure, excluding .DS_Store files
tar czf - --files-from="$secret_files_list_file" --directory="$(pwd)" --exclude='.DS_Store' | openssl enc -aes-256-cbc -salt -pbkdf2 -out "$output_archive" -pass "file:$password_file"

# Increment the version in secrets_version.txt
if [ ! -e "$version_file" ]; then
  echo "0" > "$version_file"
else
  current_version=$(head -n 1 "$version_file")
  echo $((current_version + 1)) > "$version_file"
fi

# Clear previous content of secrets_version.txt
echo -e -n "$(<"$version_file")\n" > "$version_file"

# Add the date and current Git user name to secrets_version.txt
echo -e "Date of Change: $(date '+%d.%m.%Y %H:%M:%S')" >> "$version_file"
echo "Current Git User: $(git config user.name)" >> "$version_file"

echo "Encryption complete. Encrypted archive saved to $output_archive"
