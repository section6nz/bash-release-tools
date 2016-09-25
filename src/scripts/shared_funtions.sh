#!/usr/bin/env bash

# Outputs a warning message with the specified content.
function warning {
  echo -e "[WARNING] $1" >&2
}

# Outputs an error message with the specified content, and optionally terminates the script if EXIT_ON_ERROR is set to true.
function error {
  echo -e "[ERROR] $1" >&2
  if [ "$EXIT_ON_ERROR" = true ]; then
      exit 1
  fi
}
