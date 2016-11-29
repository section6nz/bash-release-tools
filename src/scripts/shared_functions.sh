#!/usr/bin/env bash

# Copyright (c) 2016 SECTION6 Limited. All rights reserved.
#
# This file is part of Bash Release Tools.
#
# Bash Release Tools is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Bash Release Tools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Bash Release Tools. If not, see <http://www.gnu.org/licenses/>.
# Outputs an informational message with the specified content.

# Outputs an informational message with the specified content.
function info {
  echo -e "[INFO] $1" >&1
}

# Outputs a warning message with the specified content.
function warning {
  echo -e "[WARN] $1" >&2
}

# Outputs an error message with the specified content, and optionally terminates the script if EXIT_ON_ERROR is set to true.
function error {
  echo -e "[ERROR] $1" >&2
  if [ "$EXIT_ON_ERROR" = true ]; then
      exit 1
  fi
}
