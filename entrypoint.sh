#!/bin/bash

echo "* entrypoint.sh START, ls -la /"

ls -la /

if [ -n "${CI_PROJECT_DIR}" ]; then
  PROJECT_DIR="${CI_PROJECT_DIR}"
else
  echo "* CI_PROJECT_DIR is falsy, using find to determine PROJECT_DIR"

  not_owned="$(find / -nouser -type d)"

  #
  # This expands the variable by spaces and applies them as current parameters,
  # so $1 will be set to the first found entry of the find above.
  #
  set -- $not_owned

  PROJECT_DIR="$1"
fi

echo "* using PROJECT_DIR: ${PROJECT_DIR}"

PROJECT_UID="$(stat -c %u "${PROJECT_DIR}")"
PROJECT_GID="$(stat -c %g "${PROJECT_DIR}")"
PROJECT_USER=dockeruser
PROJECT_GROUP=dockerusers

if grep -q $PROJECT_GID /etc/group; then
  echo "* group exists (skipping group creation)"
else
  echo "* group does not exist, creating group: ${PROJECT_GROUP}, gid: ${PROJECT_GID}"
  groupadd --gid "${PROJECT_GID}" ${PROJECT_GROUP}
fi

if [ "${PROJECT_UID}" = "0" ]; then
  #
  # Avoid using the root user for build/test.
  #
  PROJECT_UID=1234
  chown_needed=1
fi

echo "* creating user: ${PROJECT_USER}, uid: ${PROJECT_UID}, gid: ${PROJECT_GID}"

useradd --uid "${PROJECT_UID}" --gid "${PROJECT_GID}" -m "${PROJECT_USER}" -s /bin/bash

if [ -n "${chown_needed}" ]; then
  #
  # If the root user owned the PROJECT_DIR before, change it for the dockeruser."
  #
  echo "* chown recursively ${PROJECT_DIR} with uid: ${PROJECT_UID}, gid: ${PROJECT_GID}"

  chown -Rh "${PROJECT_USER}:${PROJECT_GROUP}" "${PROJECT_DIR}"
fi

#
# Use this for debugging!
# su - "${PROJECT_USER}" -c "cd ${PROJECT_DIR}; /bin/bash"
#

su - "${PROJECT_USER}" -c "cd ${PROJECT_DIR}; npm install; npm test"
