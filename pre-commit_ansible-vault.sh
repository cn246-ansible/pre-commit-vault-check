#!/usr/bin/env bash

# Pre-commit hook that verifies if all files containing 'vault' in the name
# are encrypted.
# If not, commit will fail with an error message
#
# Original author: @ralovely
# https://www.reinteractive.net/posts/167-ansible-real-life-good-practices
#
# File should be .git/hooks/pre-commit and executable

FILES_PATTERN='.*vault.*\..*$'
REQUIRED='$ANSIBLE_VAULT'
exit_status=0
unencrypted_files=()

# Colored output
code_red () { tput setaf 1; printf '%s\n' "${1}"; tput sgr0; }
code_yel () { tput setaf 3; printf '%s\n' "${1}"; tput sgr0; }

# Find modified vault files that are not deleted
while IFS= read -rd '' file; do
  if [[ -f "${file}" ]]; then
    if ! head -n1 "${file}" 2>/dev/null | grep -q "${REQUIRED}"; then
      unencrypted_files+=("${file}")
      exit_status=1
    fi
  fi
done < <(git diff --cached --diff-filter=d --name-only -z | grep -zE "${FILES_PATTERN}" || true)

# Report errors if unencrypted files found
if [[ ${exit_status} -ne 0 ]]; then
  printf '\n'
  code_red "[ERROR] COMMIT REJECTED!"
  printf '\n'
  printf '%s\n' "Unencrypted vault files found:"
  for file in "${unencrypted_files[@]}"; do
    code_yel "  ${file}"
  done
  printf '\n'
  printf '%s\n' "Fix: ansible-vault encrypt test_vault.yml"
  printf '%s\n' "Bypass: git commit --no-verify"
  printf '\n'
fi

exit "${exit_status}"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
