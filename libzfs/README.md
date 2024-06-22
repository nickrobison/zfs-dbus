# Libzfs

OCaml bindings to `libzfs`

## Testing

The test suite either needs to be run as `root`, or with a user with the appropriate permissions:

```shell
sudo zfs allow {user} create,destroy,mount {pool}
```