#!/bin/sh

# Pre-commit hook that verifies if all files containing 'vault' in the name
# are encrypted.
# If not, commit will fail with an error message
#
# Original author: @ralovely
# https://www.reinteractive.net/posts/167-ansible-real-life-good-practices
#
# File should be .git/hooks/pre-commit and executable

. /usr/local/lib/color_text

files_pattern='.*vault.*\.*$'
required='ANSIBLE_VAULT'
exit_status=0

for f in $(git diff --cached --diff-filter=d --name-only | grep -E "${files_pattern}"); do
  match=$(head -n1 "${f}" | grep --no-messages "${required}")
  if [ ! "${match}" ] ; then
    set -- "$@" "${f}"
    exit_status=1
  fi
done

if [ ! ${exit_status} = 0 ] ; then
  if [ -n "$*" ]; then
    code_red "COMMIT REJECTED!"
    printf '%s\n\n' "There are unencrypted ansible-vault files part of the commit:"

    for item in "$@"; do
      code_yel "unencrypted:   ${item}"
    done

    printf '\n%s\n' "Please encrypt them with 'ansible-vault encrypt <file>'"
    printf '\t%s\n\n' "(or force the commit with '--no-verify')."
  fi
  exit "${exit_status}"
fi

exit "${exit_status}"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
