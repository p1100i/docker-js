#!/bin/bash

set -eufo pipefail

echo "                                          "
echo "          _ _  ___   ___  _    ___        "
echo "    _ __ / / |/ _ \ / _ \(_)  / (_)___    "
echo "   | '_ \| | | | | | | | | | / /| / __|   "
echo "   | |_) | | | |_| | |_| | |/ / | \__ \   "
echo "   | .__/|_|_|\___/ \___/|_/_/ _/ |___/   "
echo "   |_|                        |__/        "
echo "                                          "

if [ -n "${CI_PROJECT_DIR:-}" ]; then
  project_dir="${CI_PROJECT_DIR}"
else
  echo "* CI_PROJECT_DIR is falsy, using find to determine project_dir"

  not_owned="$(find / -nouser -type d)"

  #
  # This expands the variable by spaces and applies them as current parameters,
  # so $1 will be set to the first found entry of the find above.
  #
  set -- $not_owned

  project_dir="$1"
fi

echo "* using project_dir: ${project_dir}"

project_uid="$(stat -c %u "${project_dir}")"
project_gid="$(stat -c %g "${project_dir}")"
project_user=dockeruser
project_group=dockerusers

if [ "${project_uid}" = "0" ]; then
  #
  # Avoid using the root user for build/test.
  #
  project_uid=1234
  project_gid=1234
  chown_needed=1
fi

if grep -q "${project_gid}" /etc/group; then
  echo "* group exists (skipping group creation)"
else
  echo "* group does not exist, creating group: ${project_group}, gid: ${project_gid}"

  groupadd --gid "${project_gid}" ${project_group}
fi

echo "* creating user: ${project_user}, uid: ${project_uid}, gid: ${project_gid}"

useradd --uid "${project_uid}" --gid "${project_gid}" -m "${project_user}" -s /bin/bash

if [ -n "${chown_needed:-}" ]; then
  #
  # If the root user owned the project_dir before, change it for the dockeruser."
  #
  echo "* chown recursively ${project_dir} with uid: ${project_uid}, gid: ${project_gid}"

  chown -Rh ${project_user}:${project_group} "${project_dir}"
fi

#
# Use this for debugging this docker image:
#
# su - "${project_user}" -c "cd ${project_dir}; /bin/bash"
#

project_command="cd ${project_dir};"

if [ -z "${SKIP_NPM_INSTALL:-}" ]; then
  project_command="${project_command} npm install;"
fi

project_command="${project_command} npm test;"

su - "${project_user}" -c "${project_command}"
