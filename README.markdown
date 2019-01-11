# git over qrexec

This is very limited, and very secure git remote helper, which fetches git tags
from another qube over qrexec. The tag has to be signed using a trusted key, and
this is mandatory. All objects are verified before actually writing them to
git's object database against either gpg signature or their SHA1 object
identifier.

## usage

To use this, define remote using `qrexec://` protocol.

```
git remote add <remote> qrexec://<qube>/<directory>[?keyring=<keyring>][&list_head_only=0]
```

- `<qube>` is a name of the remote qube
- `<directory>` is a directory under `$HOME/QubesGit` in the `<qube>`, and also
  an argument to qrexec's policy if you'd like to give per-repo access
- `<keyring>` is optional path to keyring which holds trusted public keys; if
  relative, it should be under `$HOME/.gnupg`, but just use
  `gpg --no-default-keyring --keyring <keyring> --import` and you'll be fine
- list_head_only= if true (the default) means that only the latest tag is
  listed; set to something false to list all tags

After defining it, you can list it and fetch individual tags:

```
git ls-remote <remote>
git pull [--ff-only] <remote> <tag>
```

*NOTE* that by design it is not possible to list branches and pull from them,
because branches (their names and things they point to) are not signed. So there
is no way to verify you're actually pulling from the branch you'd like. In
contrast, tags are signed and the signature also covers the name of the tag.

For the first commit, `git pull` refuses to merge disjoint histories (after
`git init` there is no commit in current branch). Therefore, use `git fetch` and
`git reset --hard FETCH_HEAD`:

```
git init
git ls-remote <remote>
git fetch <remote> <tag>
git reset --hard FETCH_HEAD
```

## installation and setup

1. `git-remote-qrexec` goes somewhere in the `$PATH`, maybe `$HOME/bin` or
   `/usr/bin`
1. everything under `qubes-rpc/` goes to `/etc/qubes-rpc` in template, or
   `/usr/local/etc/qubes-rpc` in the domain that holds remote repo (the source,
   from which we'll be pulling).
1. the source repos go to `$HOME/QubesGit`
1. last but not least, some sane policy goes to `/etc/qubes-rpc/policy` in dom0
   (see below)

## qrexec policy

There are two calls, `git.List` and `git.Fetch`. They both accept argument, the
name of directory (or symlink) under `$HOME/QubesGit`.

## bugs

Certainly.

## example

```
user@github:~$ mkdir -p QubesGit
user@github:QubesGit$ cd QubesGit
user@github:QubesGit$ git fetch https://github.com/QubesOS/qubes-core-admin

user@dom0:~$ cd /etc/qubes-rpc/policy
user@dom0:/etc/qubes-rpc/policy$ cat <<EOF > git.Fetch+qubes-core-admin
qubes-dev github allow
EOF
user@dom0:/etc/qubes-rpc/policy$ cat <<EOF > git.List+qubes-core-admin
$include:git.Fetch+qubes-core-admin
EOF

user@qubes-dev:~$ cd qubes-src
user@qubes-dev:~$ gpg --no-default-keyring --keyring qubes-team.kbx --import secpack/keys/core-devs/*
user@qubes-dev:qubes-src$ mkdir core-admin
user@qubes-dev:qubes-src$ cd core-admin
user@qubes-dev:qubes-src/core-admin$ git init
user@qubes-dev:qubes-src/core-admin$ git remote add origin qrexec://github/qubes-core-admin?keyring=qubes-team.kbx
user@qubes-dev:qubes-src/core-admin$ git ls-remote origin
user@qubes-dev:qubes-src/core-admin$ git fetch origin R4.0
user@qubes-dev:qubes-src/core-admin$ git reset --hard FETCH_HEAD
```

## hacking

Possible improvements (help wanted!):
- support for signed commits, not only tags
- unit tests would be welcome
