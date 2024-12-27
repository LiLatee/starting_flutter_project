#!/bin/bash

# Navigates to the root directory of the project.
# In that case to the directory with the name of the Flutter project.
# So it can be run from anywhere.
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/../.." || exit

# Set the path for the file containing the list of files and directories to delete
secret_files_list_file="tools/secrets/secret_files_list.txt"

# Check if the file containing the list of files and directories to delete exists
if [ ! -e "$secret_files_list_file" ]; then
  echo "Error: The file $secret_files_list_file is not present."
  echo "Create the file $secret_files_list_file and add the list of files and directories to delete, one path per line."
  exit 1
fi

# Read the list of files and directories to delete from the file using a while loop
while IFS= read -r path_to_delete; do
  echo $path_to_delete
  if [ -e "$path_to_delete" ]; then
    # Use find to delete both files and directories
    find "$path_to_delete" -delete
    echo "Deleted: $path_to_delete"
  else
    echo "Path not found: $path_to_delete"
  fi
done < "$secret_files_list_file"

echo "Deletion complete."
