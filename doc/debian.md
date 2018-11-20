# Debian packages

## Releasing

For contrail debian packages, we have to manually increase the
`debianPackageVersion` version defined in `pkgs/debian-packages/default.nix`.

We could not use hashes for the version because we need a ordered version
element and we don't want to use the date in order to let the version number
determinist.
