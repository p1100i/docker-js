#!/bin/bash

echo "* entrypoint.sh START, ls -la /"

ls -la /

echo "* CI_PROJECT_PATH: ${CI_PROJECT_PATH}"

if [ -z "${CI_PROJECT_PATH}" ]; then
  echo "* CI_PROJECT_PATH is falsy, using find to determine PROJECT_PATH"

  not_owned="$(find / -nouser -type d)"

  #
  # This expands the variable by spaces and applies them as current parameters,
  # so $1 will be set to the first found entry of the find above.
  #
  set -- $not_owned
fi

PROJECT_PATH="$1"

echo "* using PROJECT_PATH: ${PROJECT_PATH}"

PROJECT_UID="$(stat -c %u "${PROJECT_PATH}")"
PROJECT_GID="$(stat -c %g "${PROJECT_PATH}")"
PROJECT_USER=dockeruser
PROJECT_GROUP=dockerusers

if grep -q $PROJECT_GID /etc/group; then
  echo "* group exists (skipping group creation)"
else
  echo "* group does not exist, creating group: ${PROJECT_GROUP}, gid: ${PROJECT_GID}"
  groupadd --gid "${PROJECT_GID}" ${PROJECT_GROUP}
fi

echo "* creating user: ${PROJECT_USER}, uid: ${PROJECT_UID}, gid: ${PROJECT_GID}"

useradd --uid "${PROJECT_UID}" --gid "${PROJECT_GID}" -m "${PROJECT_USER}" -s /bin/bash

#
# Use this for debugging!
# su - "${PROJECT_USER}" -c "cd ${PROJECT_PATH}; /bin/bash"
#

su - "${PROJECT_USER}" -c "cd ${PROJECT_PATH}; npm install; npm test"
