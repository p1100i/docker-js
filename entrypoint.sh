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

if grep -q $PROJECT_GID /etc/group; then
  echo "* group exists (skipping group creation)"
else
  echo "* group does not exist, creating group: dockerusers, gid: ${PROJECT_GID}"
  groupadd --gid "${PROJECT_GID}" users
fi

echo "* creating user: dockeruser, uid: ${PROJECT_UID}, gid: ${PROJECT_GID}"

useradd --uid "${PROJECT_UID}" --gid "${PROJECT_GID}" -m dockeruser -s /bin/bash

# Use this for debugging!
# su - user -c "cd ${PROJECT_DIR}; /bin/bash"

su - user -c "cd ${PROJECT_DIR}; npm install; npm test"
