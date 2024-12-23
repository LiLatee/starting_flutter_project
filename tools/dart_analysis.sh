#!/bin/bash

# Navigates to the root directory of the project.
# In that case to the directory with the name of the Flutter project.
# So it can be run from anywhere.
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
cd "$parent_path/.." || exit


exclude_lib_files="'{**.g.dart,**.freezed.dart}'"
exclude_test_files="''"
commands=(
  "flutter analyze --fatal-infos;Run flutter analyze --fatal-infos"
  "dart run dart_code_linter:metrics check-unused-files lib --exclude=$exclude_lib_files;Check Unused Files /lib/"
  "dart run dart_code_linter:metrics check-unused-files test --exclude=$exclude_test_files;Check Unused Test Files /test/"
  "dart run dart_code_linter:metrics check-unused-code lib --exclude=$exclude_lib_files;Check Unused Code /lib/"
  "dart run dart_code_linter:metrics check-unused-code test --exclude=$exclude_test_files;Check Unused Code /test/"
  "dart run custom_lint;Check custom lint rules"
)

failed_commands=()

execute_command() {
  local command="$1"
  local description="$2"
  # Replace all spaces to underscores.
  local log_file="log_${description// /_}.txt"
  # Replace forward slash with dash.
  # Check Unused Code /lib/ => log_Check_Unused_Code_-lib-.txt
  log_file="${log_file//\//-}"

  echo "Running $description..."
  eval "$command"

  local exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    echo "Command $command failed with code $exit_code."
    failed_commands+=("$description ; $command")
  else
    echo "Command $command succeeded"
  fi
}

# Record start time.
# seconds.nanoseconds
start_time=$(date +%s.%N)

for command_desc in "${commands[@]}"; do
  IFS=";" read -ra command_parts <<<"$command_desc"
  command="${command_parts[0]}"
  description="${command_parts[1]}"

  execute_command "$command" "$description"
done

# Record end time.
# seconds.nanoseconds
end_time=$(date +%s.%N)

# Calculate execution time.
execution_time=$(echo "($end_time - $start_time)" | bc)

num_failures=${#failed_commands[@]}

echo

if [ "$num_failures" -gt 0 ]; then
  echo "At least one command failed. Failed commands:"
  printf '%s\n' "${failed_commands[@]}"
  echo "Total execution time: $execution_time seconds"
  exit 1
else
  echo "All analysis commands succeeded!"
  echo "Total execution time: $execution_time seconds"
  exit 0
fi
