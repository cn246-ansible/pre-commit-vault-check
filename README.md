# Ansible Vault Pre-commit Hook

A Git pre-commit hook that prevents accidentally committing unencrypted Ansible
vault files.


## Overview

This hook scans all staged files matching the pattern `*vault*.*` and verifies
they contain the `$ANSIBLE_VAULT` header. If any vault files are unencrypted,
the commit is rejected with a clear error message listing the problematic files.


## Requirements

- Git
- Bash
- Standard Unix utilities (`grep`, `head`, `tput`)


## Installation
### Per-Repository Installation

#### Option A: Version controlled (recommended for teams)

Create a hooks directory in your repository and configure Git:
```bash
mkdir -p .githooks
cp pre-commit_ansible-vault.sh .githooks/pre-commit
chmod +x .githooks/pre-commit
git add .githooks/
git config --local core.hooksPath .githooks
```

This keeps the hook in version control so it ships with your playbook.


#### Option B: Git hooks directory (traditional)

Copy the hook to Git's hooks directory:
```bash
cp pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
Note: This is not version controlled and won't ship with the repository.


### Global Installation (All Repositories)

1. Set up a global hooks directory:
```bash
mkdir -p ~/.git-hooks
cp pre-commit ~/.git-hooks/pre-commit
chmod +x ~/.git-hooks/pre-commit
```

2. Configure Git to use the global hooks directory:
```bash
git config --global core.hooksPath ~/.git-hooks
```


## Usage

Once installed, the hook runs automatically on every `git commit`. No additional
action is required.

### Example Output

When unencrypted vault files are detected:

```
[ERROR] COMMIT REJECTED!

Unencrypted vault files found:
  group_vars/production/vault.yml
  host_vars/web01/vault.yml

Fix: ansible-vault encrypt test_vault.yml
Bypass: git commit --no-verify
```


### Bypassing the Hook

If you need to commit unencrypted vault files (not recommended), you can bypass
the hook:

```bash
git commit --no-verify
```


## How It Works

1. Identifies all staged files matching `*vault*.*` pattern
2. Checks the first line of each file for `$ANSIBLE_VAULT` header
3. Rejects the commit if any vault files are unencrypted
4. Provides colored output listing all problematic files


## File Naming Convention

The hook assumes vault files follow this naming pattern:
- Must contain the word "vault" in the filename
- Must have a file extension

Examples that match:
- `secrets.vault.yml`
- `vault.yml`
- `group_vars/all/vault.yaml`
- `roles/app/files/vault.json`
- `myvault.template.j2`
- `vault-prod.enc.txt`
- `foo/vault123.bar.baz`
- `/tmp/somevault.something`

Examples that do not match:
- `vault` (no dot after it)
- `vaultfile` (no dot)
- `my_vault` (no dot)
- `secrets.yml` (doesn’t contain vault)
- `VAULT.yml` (case-sensitive, so no match unless you enable case-insensitive matching)


## Troubleshooting
### False Positives

If you have files with "vault" in the name that shouldn't be encrypted, consider:
1. Renaming them to avoid the "vault" keyword
2. Modifying the `FILES_PATTERN` variable in the hook
3. Using `--no-verify` for specific commits (use sparingly)


## Credits

Original author: [@ralovely](https://www.reinteractive.net/posts/167-ansible-real-life-good-practices)
