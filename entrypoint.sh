#!/bin/bash

if [ -z "$1" ]; then
  not_owned="$(find / -nouser -type d)"

  # This expands the variable by spaces and applies them as current parameters,
  # so $1 will be set to the first found entry of the find above.
  set -- $not_owned
fi

PROJECT_DIR="$1"

echo "* set PROJECT_DIR: ${PROJECT_DIR}"

PROJECT_UID="$(stat -c %u "${PROJECT_DIR}")"
PROJECT_GID="$(stat -c %g "${PROJECT_DIR}")"

echo "* adding executing user with uid: ${PROJECT_UID}, gid: ${PROJECT_GID}"

useradd --uid "${PROJECT_UID}" --gid "${PROJECT_GID}" -m user -s /bin/bash

# Use this for debugging!
# su - user -c "cd ${PROJECT_DIR}; /bin/bash"

su - user -c "cd ${PROJECT_DIR}; npm install; npm test"
